# Herramientas y Patrones Avanzados

Más allá del agente básico, el SDK ofrece patrones de composición que permiten abordar tareas complejas: orquestación con sub-agentes especializados, pipelines encadenados, evaluación con dos agentes independientes, integración con MCP y gestión de sesiones. Este capítulo cubre cada uno con ejemplos completos.

---

## Patrón de orquestación: agente principal con sub-agentes

Un agente principal puede delegar trabajo especializado a sub-agentes. El SDK gestiona la comunicación entre ellos de forma transparente.

### Definir sub-agentes con `AgentDefinition`

```python
import asyncio
from claude_agent_sdk import (
    query,
    ClaudeAgentOptions,
    AgentDefinition,
    ResultMessage,
)


async def revisar_codigo_con_especialistas(directorio: str) -> None:
    """
    Agente principal que delega a dos especialistas:
    - security-reviewer: busca vulnerabilidades
    - quality-reviewer: evalúa calidad y mantenibilidad
    """
    async for message in query(
        prompt=(
            f"Analiza el código en {directorio}. "
            "Usa el agente security-reviewer para buscar vulnerabilidades "
            "y el agente quality-reviewer para evaluar la calidad del código. "
            "Combina los resultados en un informe final."
        ),
        options=ClaudeAgentOptions(
            allowed_tools=["Read", "Glob", "Grep", "Agent"],
            agents={
                "security-reviewer": AgentDefinition(
                    description="Especialista en seguridad de aplicaciones.",
                    prompt=(
                        "Analiza el código en busca de vulnerabilidades de seguridad: "
                        "inyección SQL, XSS, CSRF, secretos expuestos, dependencias vulnerables. "
                        "Clasifica cada hallazgo como: crítico, alto, medio o bajo."
                    ),
                    tools=["Read", "Glob", "Grep"],
                ),
                "quality-reviewer": AgentDefinition(
                    description="Especialista en calidad y mantenibilidad del código.",
                    prompt=(
                        "Evalúa la calidad del código: complejidad ciclomática, "
                        "cobertura de tests, duplicación, nombres descriptivos, "
                        "documentación y adherencia a buenas prácticas."
                    ),
                    tools=["Read", "Glob", "Grep"],
                ),
            },
        ),
    ):
        if isinstance(message, ResultMessage) and message.subtype == "success":
            print(message.result)


asyncio.run(revisar_codigo_con_especialistas("./src"))
```

El agente principal tiene `"Agent"` en `allowed_tools`, que es lo que le permite invocar sub-agentes. Los sub-agentes operan en contextos separados con sus propias instrucciones y herramientas restringidas.

---

## Patrón de pipeline: agentes en secuencia

Encadena agentes donde la salida de uno es la entrada del siguiente. Usa sesiones para pasar contexto de forma eficiente.

```python
import asyncio
from claude_agent_sdk import query, ClaudeAgentOptions, ResultMessage


async def pipeline_documentacion(directorio: str) -> None:
    """
    Pipeline de tres etapas:
    1. Extracción: identifica funciones sin documentar
    2. Generación: escribe la documentación
    3. Revisión: verifica que la documentación es correcta
    """

    # Etapa 1: Identificar funciones sin documentar
    print("Etapa 1: Identificando funciones sin documentar...")
    session_id_etapa1 = None
    funciones_sin_doc = None

    async for message in query(
        prompt=(
            f"Analiza todos los archivos Python en {directorio}. "
            "Lista las funciones y métodos que no tienen docstring. "
            "Devuelve la lista en formato JSON con: archivo, nombre_funcion, linea."
        ),
        options=ClaudeAgentOptions(
            allowed_tools=["Read", "Glob", "Grep"],
            permission_mode="acceptEdits",
        ),
    ):
        if hasattr(message, "subtype") and message.subtype == "init":
            session_id_etapa1 = message.session_id
        if isinstance(message, ResultMessage) and message.subtype == "success":
            funciones_sin_doc = message.result

    if not funciones_sin_doc:
        print("No se encontraron funciones sin documentar.")
        return

    print(f"Encontradas funciones sin documentar. Sesión: {session_id_etapa1}")

    # Etapa 2: Generar documentación (reanuda la sesión anterior para mantener contexto)
    print("Etapa 2: Generando documentación...")
    session_id_etapa2 = None

    async for message in query(
        prompt=(
            "Para cada función de la lista que analizaste, genera un docstring "
            "en formato Google Style. Edita los archivos directamente."
        ),
        options=ClaudeAgentOptions(
            allowed_tools=["Read", "Edit", "Glob"],
            permission_mode="acceptEdits",
            resume=session_id_etapa1,  # Retoma el contexto de la etapa anterior
        ),
    ):
        if hasattr(message, "subtype") and message.subtype == "init":
            session_id_etapa2 = message.session_id
        if isinstance(message, ResultMessage) and message.subtype == "success":
            print("Documentación generada.")

    # Etapa 3: Verificar la documentación generada
    print("Etapa 3: Verificando la documentación...")

    async for message in query(
        prompt=(
            "Verifica que todos los docstrings generados sean correctos: "
            "que describan con precisión lo que hace la función, "
            "que los tipos de parámetros y retorno sean correctos, "
            "y que sigan el formato Google Style consistentemente."
        ),
        options=ClaudeAgentOptions(
            allowed_tools=["Read", "Glob", "Grep"],
            resume=session_id_etapa2,
        ),
    ):
        if isinstance(message, ResultMessage) and message.subtype == "success":
            print("Verificación completada:", message.result)


asyncio.run(pipeline_documentacion("./src"))
```

---

## Patrón de evaluación: generador y revisor

Un agente genera contenido y otro lo evalúa de forma independiente. Esto reduce el sesgo de auto-evaluación.

```python
import asyncio
from claude_agent_sdk import query, ClaudeAgentOptions, ResultMessage


async def generar_y_revisar_tests(archivo_fuente: str) -> None:
    """
    Patrón Writer/Reviewer:
    - El generador escribe tests unitarios
    - El revisor evalúa su calidad e integridad
    """

    # Paso 1: Generador escribe los tests
    print("Generando tests...")
    archivo_tests = archivo_fuente.replace(".py", "_test.py")
    codigo_generado = None

    async for message in query(
        prompt=(
            f"Lee {archivo_fuente} y escribe tests unitarios completos. "
            f"Guarda los tests en {archivo_tests}. "
            "Cubre: casos base, casos borde, manejo de errores y casos de fallo."
        ),
        options=ClaudeAgentOptions(
            allowed_tools=["Read", "Write", "Bash"],
            permission_mode="acceptEdits",
            system_prompt=(
                "Eres un ingeniero de software senior especialista en testing. "
                "Escribe tests exhaustivos, legibles y bien documentados."
            ),
        ),
    ):
        if isinstance(message, ResultMessage) and message.subtype == "success":
            codigo_generado = message.result
            print("Tests generados.")

    # Paso 2: Revisor evalúa los tests (contexto fresco, sin sesgos del generador)
    print("Revisando tests...")

    async for message in query(
        prompt=(
            f"Revisa los tests en {archivo_tests} y el código fuente en {archivo_fuente}. "
            "Evalúa: "
            "1. Cobertura: ¿se cubren todos los casos relevantes? "
            "2. Correctitud: ¿los assertions son válidos? "
            "3. Legibilidad: ¿los nombres de test son descriptivos? "
            "4. Independencia: ¿cada test es independiente del resto? "
            "Proporciona una puntuación del 1 al 10 y sugiere mejoras concretas."
        ),
        options=ClaudeAgentOptions(
            allowed_tools=["Read", "Bash"],
            system_prompt=(
                "Eres un revisor de código con experiencia en QA. "
                "Sé crítico y objetivo. Tu objetivo es mejorar la calidad, no validar el trabajo del generador."
            ),
        ),
    ):
        if isinstance(message, ResultMessage) and message.subtype == "success":
            print("Revisión completada:\n", message.result)


asyncio.run(generar_y_revisar_tests("./src/auth.py"))
```

---

## Integración con MCP

El Agent SDK admite servidores MCP de la misma forma que Claude Code. Puedes conectar bases de datos, navegadores, APIs externas y cientos de herramientas del ecosistema MCP.

### Servidor MCP stdio (local)

```python
import asyncio
from claude_agent_sdk import query, ClaudeAgentOptions, ResultMessage


async def consultar_base_de_datos(pregunta: str) -> None:
    """Agente que puede consultar una base de datos PostgreSQL via MCP."""
    async for message in query(
        prompt=pregunta,
        options=ClaudeAgentOptions(
            mcp_servers={
                "postgres": {
                    "command": "npx",
                    "args": [
                        "-y",
                        "@bytebase/dbhub",
                        "--dsn",
                        "postgresql://readonly:pass@localhost:5432/mi_app",
                    ],
                }
            },
        ),
    ):
        if isinstance(message, ResultMessage) and message.subtype == "success":
            print(message.result)


asyncio.run(consultar_base_de_datos(
    "¿Cuáles son los 10 usuarios con más pedidos en el último mes?"
))
```

### Servidor MCP HTTP (remoto)

```python
import asyncio
from claude_agent_sdk import query, ClaudeAgentOptions, ResultMessage


async def buscar_en_github(repo: str, consulta: str) -> None:
    """Agente que busca información en GitHub via MCP."""
    async for message in query(
        prompt=f"En el repositorio {repo}, {consulta}",
        options=ClaudeAgentOptions(
            mcp_servers={
                "github": {
                    "command": "npx",
                    "args": ["-y", "@modelcontextprotocol/server-github"],
                }
            },
        ),
    ):
        if isinstance(message, ResultMessage) and message.subtype == "success":
            print(message.result)


asyncio.run(buscar_en_github(
    "anthropics/claude-code",
    "lista los issues abiertos con la etiqueta 'bug' del último mes"
))
```

### Servidor MCP con automatización de navegador (Playwright)

```python
import asyncio
from claude_agent_sdk import query, ClaudeAgentOptions, ResultMessage


async def scrape_con_navegador(url: str, tarea: str) -> None:
    """Agente con capacidad de navegar por la web usando Playwright."""
    async for message in query(
        prompt=f"Abre {url} y {tarea}",
        options=ClaudeAgentOptions(
            mcp_servers={
                "playwright": {
                    "command": "npx",
                    "args": ["@playwright/mcp@latest"],
                }
            },
        ),
    ):
        if isinstance(message, ResultMessage) and message.subtype == "success":
            print(message.result)


asyncio.run(scrape_con_navegador(
    "https://pypi.org/project/claude-agent-sdk/",
    "extrae la versión actual del paquete y el historial de releases"
))
```

---

## Gestión de sesiones

Las sesiones permiten mantener contexto entre múltiples ejecuciones del agente. Claude recuerda los archivos leídos, el análisis realizado y el historial de la conversación.

```python
import asyncio
from claude_agent_sdk import query, ClaudeAgentOptions, ResultMessage


async def sesion_persistente() -> None:
    """
    Demuestra cómo mantener contexto entre dos llamadas separadas.
    """
    session_id = None

    # Primera llamada: Claude lee y analiza el módulo de autenticación
    print("=== Primera llamada: análisis inicial ===")
    async for message in query(
        prompt="Lee el módulo de autenticación en ./src/auth/ y entiende cómo funciona.",
        options=ClaudeAgentOptions(
            allowed_tools=["Read", "Glob", "Grep"],
        ),
    ):
        # Capturar el ID de sesión del mensaje de inicialización
        if hasattr(message, "subtype") and message.subtype == "init":
            session_id = message.session_id
            print(f"Sesión iniciada: {session_id}")
        if isinstance(message, ResultMessage) and message.subtype == "success":
            print("Análisis completado.")

    # Segunda llamada: retoma la sesión con contexto completo
    print("\n=== Segunda llamada: usa el contexto previo ===")
    async for message in query(
        prompt=(
            "Ahora encuentra todos los lugares del codebase que llaman "
            "a las funciones de autenticación que acabas de analizar."
        ),
        options=ClaudeAgentOptions(
            allowed_tools=["Read", "Glob", "Grep"],
            resume=session_id,  # Retoma exactamente donde lo dejó
        ),
    ):
        if isinstance(message, ResultMessage) and message.subtype == "success":
            print("Búsqueda completada:\n", message.result)


asyncio.run(sesion_persistente())
```

---

## Hooks del SDK: logging y control

Los hooks del SDK funcionan como callbacks en Python/TypeScript, en lugar de scripts de shell como en Claude Code. Puedes usarlos para logging, auditoría, bloqueo de acciones o transformación de inputs.

```python
import asyncio
from datetime import datetime
from claude_agent_sdk import (
    query,
    ClaudeAgentOptions,
    HookMatcher,
    ResultMessage,
)


async def log_cambio_archivo(input_data: dict, tool_use_id: str, context: dict) -> dict:
    """Hook PostToolUse: registra cada modificación de archivo."""
    ruta = input_data.get("tool_input", {}).get("file_path", "desconocido")
    timestamp = datetime.now().isoformat()
    with open("./auditoria.log", "a") as f:
        f.write(f"{timestamp} | modificado: {ruta}\n")
    return {}  # Retorna dict vacío para no bloquear la ejecución


async def bloquear_archivos_criticos(input_data: dict, tool_use_id: str, context: dict) -> dict:
    """Hook PreToolUse: impide modificar archivos de configuración de producción."""
    ruta = input_data.get("tool_input", {}).get("file_path", "")
    archivos_protegidos = ["production.env", ".env.production", "secrets.yaml"]
    if any(protegido in ruta for protegido in archivos_protegidos):
        return {
            "permissionDecision": "deny",
            "reason": f"Modificación de {ruta} bloqueada por política de seguridad.",
        }
    return {}


async def agente_con_hooks() -> None:
    async for message in query(
        prompt="Refactoriza el módulo utils.py para mejorar la legibilidad.",
        options=ClaudeAgentOptions(
            allowed_tools=["Read", "Edit", "Glob"],
            permission_mode="acceptEdits",
            hooks={
                "PreToolUse": [
                    HookMatcher(
                        matcher="Edit|Write",
                        hooks=[bloquear_archivos_criticos],
                    )
                ],
                "PostToolUse": [
                    HookMatcher(
                        matcher="Edit|Write",
                        hooks=[log_cambio_archivo],
                    )
                ],
            },
        ),
    ):
        if isinstance(message, ResultMessage) and message.subtype == "success":
            print("Refactorización completada.")
            print("Revisa auditoria.log para ver los cambios realizados.")


asyncio.run(agente_con_hooks())
```

Los hooks reciben el input de la herramienta, el ID de la llamada y contexto adicional. Para bloquear una acción, devuelven `{"permissionDecision": "deny", "reason": "..."}`. Para permitirla, devuelven un dict vacío `{}`.

---

## Manejo de errores y reintentos

El agente puede terminar con distintos subtipos de error. Implementa lógica de reintento con backoff exponencial para errores transitorios:

```python
import asyncio
import time
from claude_agent_sdk import query, ClaudeAgentOptions, ResultMessage


async def ejecutar_con_reintentos(
    prompt: str,
    options: ClaudeAgentOptions,
    max_intentos: int = 3,
    espera_base: float = 2.0,
) -> str | None:
    """Ejecuta un agente con reintentos ante fallos transitorios."""
    for intento in range(1, max_intentos + 1):
        try:
            resultado = None
            async for message in query(prompt=prompt, options=options):
                if isinstance(message, ResultMessage):
                    if message.subtype == "success":
                        return getattr(message, "result", "")
                    elif message.subtype == "error_max_turns":
                        print(f"Intento {intento}: límite de turnos alcanzado.")
                        return None  # No es reintentable
                    elif message.subtype == "error":
                        print(f"Intento {intento}: error del agente.")
                        break  # Salir del async for para reintentar
        except Exception as error:
            print(f"Intento {intento}: excepción inesperada: {error}")

        if intento < max_intentos:
            espera = espera_base * (2 ** (intento - 1))
            print(f"Reintentando en {espera:.1f} segundos...")
            await asyncio.sleep(espera)

    print(f"Falló después de {max_intentos} intentos.")
    return None


async def main() -> None:
    resultado = await ejecutar_con_reintentos(
        prompt="Busca todos los archivos Python con más de 200 líneas y lista sus nombres.",
        options=ClaudeAgentOptions(
            allowed_tools=["Glob", "Bash"],
            permission_mode="acceptEdits",
        ),
    )
    if resultado:
        print("Resultado:", resultado)


asyncio.run(main())
```

---

## Errores comunes

**No incluir `"Agent"` en `allowed_tools` cuando se usan sub-agentes.** Los sub-agentes se invocan a través de la herramienta `Agent`. Sin ella, el agente principal no puede delegarles trabajo.

**Reutilizar el mismo `session_id` en pipelines independientes.** Cada pipeline debería comenzar con una sesión nueva. Solo usa `resume` cuando quieras contexto compartido explícitamente entre pasos.

**Hooks que no devuelven un dict.** Los hooks deben devolver siempre un diccionario, incluso si no hacen nada (`return {}`). Devolver `None` puede causar errores silenciosos.

**Asumir que el agente siempre termina con éxito.** Los subtipos de `ResultMessage` incluyen `"error"`, `"error_max_turns"` y otros. Siempre verifica el subtipo antes de procesar el resultado.

---

## Deprecaciones API en Opus 4.6 (v3.0)

Las siguientes API han cambiado en la generación Opus 4.6:

### Adaptive thinking reemplaza `thinking: {type: "enabled"}`

```python
# ANTES (deprecado en Opus 4.6)
options = ClaudeAgentOptions(
    thinking={"type": "enabled", "budget_tokens": 50000},
)

# AHORA (recomendado)
# Opus 4.6 usa adaptive thinking por defecto.
# No necesitas configurar thinking explícitamente.
# Si necesitas forzar razonamiento profundo, usa effort:
options = ClaudeAgentOptions(
    effort="max",  # Nuevo nivel máximo para Opus 4.6
)
```

El parámetro `budget_tokens` también está deprecado. Opus 4.6 decide automáticamente cuánto razonar basándose en la complejidad de la tarea.

### `output_format` → `output_config.format`

```python
# ANTES (deprecado)
options = ClaudeAgentOptions(output_format="json")

# AHORA (recomendado)
options = ClaudeAgentOptions(output_config={"format": "json"})
```

---

## Resumen

- El patrón de orquestación usa `AgentDefinition` y la herramienta `"Agent"` para delegar a especialistas
- El patrón de pipeline encadena agentes usando `resume` para pasar contexto de forma eficiente
- El patrón de evaluación usa dos agentes con contextos separados para evitar sesgos
- La integración MCP conecta bases de datos, navegadores y APIs externas como herramientas del agente
- Las sesiones permiten retomar trabajo previo con `resume=session_id`
- Los hooks del SDK son callbacks Python/TypeScript que interceptan eventos del bucle agéntico
- Implementa reintentos con backoff exponencial para errores transitorios
- **Deprecaciones v3.0:** `thinking: {type: "enabled"}` y `budget_tokens` → usar adaptive thinking; `output_format` → usar `output_config.format`
