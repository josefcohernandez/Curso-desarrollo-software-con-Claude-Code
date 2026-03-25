# Integración con Claude Code

El caso más interesante del Agent SDK es que puedes usar Claude Code para construir los propios agentes que usarás con el SDK. Es una relación recursiva: la herramienta se usa para construir herramientas. Este capítulo explica el workflow de desarrollo, las modalidades de despliegue y cuándo usar el Agent SDK frente a otros frameworks.

---

## Usar Claude Code para desarrollar agentes

Claude Code es ideal para el desarrollo del SDK porque:

- Puede leer, entender y modificar tu código de agente
- Puede ejecutar los tests del agente directamente
- Puede sugerir mejoras en el system prompt, la selección de herramientas o la lógica de reintentos
- Plan Mode te permite diseñar la arquitectura antes de escribir una sola línea

### Workflow de desarrollo recomendado

```
1. DISEÑAR con Plan Mode en Claude Code
   - Describir la tarea que el agente debe realizar
   - Identificar qué herramientas necesita (Read, Bash, MCP, etc.)
   - Definir el system prompt y las restricciones
   - Planificar el manejo de errores

2. PROTOTIPAR como subagente de Claude Code
   - Crear un archivo .claude/agents/mi-agente.md
   - Probarlo interactivamente con /agents o delegación automática
   - Ajustar el prompt y las herramientas

3. IMPLEMENTAR con el Agent SDK
   - Traducir la definición del subagente a ClaudeAgentOptions
   - Añadir lógica de aplicación (entrada, salida, errores)
   - Escribir tests

4. TESTEAR con Claude Code
   - Pedir a Claude Code que ejecute los tests
   - Iterar sobre el system prompt y la selección de herramientas
   - Validar el comportamiento en casos de fallo

5. DESPLEGAR
   - Como servicio web, CLI o GitHub Action
```

### Ejemplo: de subagente a SDK

Un subagente en Claude Code se define así:

```markdown
---
name: analisis-seguridad
description: Analiza código en busca de vulnerabilidades de seguridad
tools: Read, Glob, Grep
model: sonnet
---
Eres un experto en seguridad de aplicaciones. Busca vulnerabilidades OWASP Top 10.
Clasifica cada hallazgo como crítico, alto, medio o bajo.
Responde en español con ejemplos de código vulnerable y la corrección recomendada.
```

La traducción directa al Agent SDK es:

```python
from claude_agent_sdk import query, ClaudeAgentOptions

options = ClaudeAgentOptions(
    allowed_tools=["Read", "Glob", "Grep"],
    model="claude-sonnet-4-6",
    system_prompt=(
        "Eres un experto en seguridad de aplicaciones. Busca vulnerabilidades OWASP Top 10. "
        "Clasifica cada hallazgo como crítico, alto, medio o bajo. "
        "Responde en español con ejemplos de código vulnerable y la corrección recomendada."
    ),
)
```

El mapeo es directo:
- `tools:` del frontmatter → `allowed_tools` en `ClaudeAgentOptions`
- `model:` del frontmatter → `model` en `ClaudeAgentOptions`
- El cuerpo del `.md` → `system_prompt` en `ClaudeAgentOptions`

---

## Despliegue de agentes

### Como script de línea de comandos (CLI)

```python
#!/usr/bin/env python3
"""
Agente de análisis de seguridad.
Uso: python seguridad.py <directorio>
"""
import asyncio
import sys
from claude_agent_sdk import query, ClaudeAgentOptions, ResultMessage


async def analizar(directorio: str) -> int:
    """Retorna 0 si no hay vulnerabilidades críticas, 1 si las hay."""
    tiene_criticos = False

    async for message in query(
        prompt=(
            f"Analiza el código en {directorio} en busca de vulnerabilidades. "
            "Si encuentras vulnerabilidades críticas, incluye la palabra CRITICO en tu respuesta."
        ),
        options=ClaudeAgentOptions(
            allowed_tools=["Read", "Glob", "Grep"],
            system_prompt=(
                "Eres un experto en seguridad. Analiza código en busca de "
                "vulnerabilidades OWASP Top 10. Sé conciso pero preciso."
            ),
        ),
    ):
        if isinstance(message, ResultMessage) and message.subtype == "success":
            resultado = getattr(message, "result", "") or ""
            print(resultado)
            if "CRITICO" in resultado.upper():
                tiene_criticos = True

    return 1 if tiene_criticos else 0


def main() -> None:
    if len(sys.argv) != 2:
        print(f"Uso: {sys.argv[0]} <directorio>")
        sys.exit(1)

    directorio = sys.argv[1]
    codigo_salida = asyncio.run(analizar(directorio))
    sys.exit(codigo_salida)


if __name__ == "__main__":
    main()
```

Para instalar el CLI localmente:

```bash
pip install -e .
# O directamente:
python seguridad.py ./src
```

### Como servicio web con FastAPI

```python
from fastapi import FastAPI, BackgroundTasks
from pydantic import BaseModel
import asyncio
import uuid
from claude_agent_sdk import query, ClaudeAgentOptions, ResultMessage

app = FastAPI(title="Servicio de Análisis de Código")

# Almacén simple de tareas (en producción usar Redis o base de datos)
tareas: dict[str, dict] = {}


class SolicitudAnalisis(BaseModel):
    directorio: str
    tipo: str = "seguridad"  # "seguridad" o "calidad"


async def ejecutar_analisis(tarea_id: str, solicitud: SolicitudAnalisis) -> None:
    tareas[tarea_id]["estado"] = "en_progreso"

    system_prompts = {
        "seguridad": "Eres un experto en seguridad. Busca vulnerabilidades OWASP Top 10.",
        "calidad": "Eres un experto en calidad de código. Evalúa mantenibilidad y mejores prácticas.",
    }

    async for message in query(
        prompt=f"Analiza {solicitud.directorio} en busca de problemas de {solicitud.tipo}.",
        options=ClaudeAgentOptions(
            allowed_tools=["Read", "Glob", "Grep"],
            system_prompt=system_prompts.get(solicitud.tipo, system_prompts["calidad"]),
        ),
    ):
        if isinstance(message, ResultMessage) and message.subtype == "success":
            tareas[tarea_id]["estado"] = "completado"
            tareas[tarea_id]["resultado"] = getattr(message, "result", "")
        elif isinstance(message, ResultMessage):
            tareas[tarea_id]["estado"] = "error"
            tareas[tarea_id]["resultado"] = f"Error: {message.subtype}"


@app.post("/analizar")
async def iniciar_analisis(
    solicitud: SolicitudAnalisis,
    background_tasks: BackgroundTasks,
) -> dict:
    tarea_id = str(uuid.uuid4())
    tareas[tarea_id] = {"estado": "pendiente", "resultado": None}
    background_tasks.add_task(ejecutar_analisis, tarea_id, solicitud)
    return {"tarea_id": tarea_id, "estado": "pendiente"}


@app.get("/tareas/{tarea_id}")
async def obtener_tarea(tarea_id: str) -> dict:
    if tarea_id not in tareas:
        return {"error": "Tarea no encontrada"}
    return tareas[tarea_id]
```

Ejecutar el servicio:

```bash
pip install fastapi uvicorn claude-agent-sdk
uvicorn servicio:app --reload
```

### Como GitHub Action

```yaml
name: Análisis de Seguridad con Agent SDK

on:
  pull_request:
    paths:
      - "src/**"

jobs:
  seguridad:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Configurar Python
        uses: actions/setup-python@v5
        with:
          python-version: "3.12"

      - name: Instalar dependencias
        run: pip install claude-agent-sdk

      - name: Ejecutar análisis de seguridad
        env:
          ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
        run: python scripts/seguridad.py ./src

      - name: Publicar resultados
        if: always()
        uses: actions/upload-artifact@v4
        with:
          name: informe-seguridad
          path: informe-seguridad.md
```

---

## Agent SDK vs otros frameworks

El ecosistema de frameworks para construir agentes es amplio. Aquí una comparativa honesta para tomar la decisión correcta:

| Aspecto | Agent SDK | LangChain | CrewAI | AutoGen |
|---------|-----------|-----------|--------|---------|
| Modelo principal | Claude (Anthropic) | Agnóstico | Agnóstico | Agnóstico |
| Herramientas integradas | Sí (Read, Edit, Bash...) | No (implementar) | Limitadas | Limitadas |
| Curva de aprendizaje | Baja | Alta | Media | Media |
| Abstracciones | Mínimas y directas | Muchas capas | Media | Media |
| Ecosistema | Creciendo | Muy amplio | Amplio | Creciendo |
| Soporte MCP | Sí, nativo | Via plugins | Limitado | Via plugins |
| Mantenimiento | Anthropic (oficial) | Comunidad | Comunidad | Microsoft |
| Caso ideal | Agentes Claude en producción | Multi-modelo, RAG | Equipos de agentes | Conversaciones multi-agente |

### Cuándo usar el Agent SDK

- Tu agente usa exclusivamente Claude
- Necesitas las herramientas integradas (Read, Edit, Bash) sin implementarlas
- Quieres compatibilidad nativa con el ecosistema Claude Code (MCP, hooks, skills)
- Prefieres APIs minimalistas y directas

### Cuándo usar LangChain

- Necesitas cambiar de modelo de lenguaje según el caso
- Tu caso de uso requiere RAG (Retrieval Augmented Generation) con vectorstores
- El ecosistema de integraciones de LangChain tiene exactamente lo que necesitas

### Cuándo usar CrewAI o AutoGen

- Tu arquitectura se basa en equipos de agentes colaborando
- Necesitas abstracciones de alto nivel para definir roles y tareas
- La compatibilidad multi-modelo es un requisito crítico

---

## Errores comunes

**No aislar el servicio FastAPI del directorio de trabajo del servidor.** El agente tiene acceso al sistema de archivos del entorno donde se ejecuta. En producción, usa contenedores Docker para aislar cada ejecución.

**Exponer `bypassPermissions` en servicios de cara al usuario.** Este modo no pide confirmación para ninguna acción. En servicios web, usa siempre `acceptEdits` o `default` con un callback `canUseTool` que valide las acciones.

**Ignorar el coste de tokens en pipelines de CI.** Cada paso del pipeline consume tokens. Usa modelos más económicos (Haiku) para tareas de análisis y reserva Sonnet/Opus para generación y revisión crítica.

---

## Nota sobre prefill en Opus 4.6

> **Deprecación v3.0:** El **prefilling** de mensajes del asistente (insertar texto al inicio de la respuesta de Claude para guiar su formato) ya **no es soportado en Opus 4.6**. Si tu código usa prefill para forzar un formato de respuesta (por ejemplo, empezar con `{` para forzar JSON), debes migrar a:
>
> - `output_config.format` para forzar formato de salida
> - `--json-schema` para respuestas JSON con esquema validado
> - System prompts explícitos que instruyan el formato deseado

---

## Resumen

- Claude Code es el entorno ideal para diseñar y desarrollar agentes con el Agent SDK
- El flujo recomendado es: diseñar en Plan Mode → prototipar como subagente → implementar con SDK → testear → desplegar
- La traducción de subagente a SDK es directa: `tools:` → `allowed_tools`, cuerpo del `.md` → `system_prompt`
- Puedes desplegar agentes como CLI, servicio web (FastAPI) o GitHub Action
- El Agent SDK es la mejor opción para agentes Claude puros; otros frameworks tienen ventajas para casos multi-modelo o con abstracciones de alto nivel
- **Deprecación v3.0:** Prefill removal en Opus 4.6 — usar `output_config.format` o system prompts para guiar el formato de salida
