# 01 - Modo No Interactivo de Claude Code

## Introducción

El modo no interactivo permite ejecutar Claude Code como parte de scripts, pipelines de CI/CD y automatizaciones. En lugar de iniciar una sesión interactiva donde escribes comandos uno a uno, le pasas una consulta directamente y Claude responde sin esperar más input.

Este modo es la base de toda la automatización con Claude Code.

---

## El Flag `-p` (Pipe Mode)

El flag `-p` (o `--print`) es la puerta de entrada al modo no interactivo. Ejecuta una consulta y devuelve el resultado directamente a stdout:

```bash
# Consulta simple
claude -p "Explica qué hace el patrón Observer en 3 líneas"

# Analizar un archivo específico
claude -p "Revisa este archivo y sugiere mejoras" < src/main.py

# Con un archivo como contexto
claude -p "Encuentra bugs potenciales en este código" < lib/auth.ts
```

**Diferencias clave con el modo interactivo:**
- No se abre una sesión persistente
- No hay historial de conversación (cada ejecución es independiente)
- La salida va directamente a stdout (ideal para pipes)
- No se piden confirmaciones de permisos (según configuración)
- El proceso termina automáticamente al completar la respuesta

---

## Pipe Mode: Combinación con Unix Pipes

Una de las funcionalidades más potentes es combinar Claude Code con el ecosistema de herramientas Unix:

### Revisión de diffs de Git

```bash
# Revisar cambios antes de hacer commit
git diff --staged | claude -p "Revisa estos cambios. Busca bugs, problemas de seguridad y mejoras de estilo"

# Revisar un PR completo
git diff main...feature-branch | claude -p "Haz un code review de este diff. Sé específico y constructivo"
```

### Análisis de logs

```bash
# Encontrar la causa raíz de un error
cat error.log | claude -p "Analiza este log de errores y encuentra la causa raíz"

# Filtrar y analizar logs recientes
tail -n 200 /var/log/app.log | claude -p "Resume los errores críticos de las últimas entradas"
```

### Exploración de proyectos

```bash
# Listar archivos Python y su propósito
find . -name "*.py" -not -path "*/node_modules/*" | claude -p "Lista estos archivos Python y describe brevemente el propósito probable de cada uno"

# Analizar estructura de un proyecto
ls -la src/ | claude -p "¿Qué tipo de proyecto es este basándote en la estructura de archivos?"
```

### Análisis de dependencias

```bash
# Revisar dependencias de un proyecto Node.js
cat package.json | claude -p "Analiza estas dependencias. ¿Hay alguna desactualizada o con vulnerabilidades conocidas?"

# Revisar requirements de Python
cat requirements.txt | claude -p "Revisa estas dependencias Python y sugiere actualizaciones"
```

### Encadenamiento de pipes

```bash
# Obtener métricas de código y analizarlas
cloc src/ --json | claude -p "Analiza estas métricas de código y sugiere si el proyecto está bien estructurado"

# Buscar TODOs y priorizarlos
grep -rn "TODO\|FIXME\|HACK" src/ | claude -p "Prioriza estos TODOs por importancia y urgencia"
```

---

## El Flag `--bare`: ejecución mínima

> **Novedad v3.0 (v2.1.81)**

El flag `--bare` ejecuta Claude Code saltándose hooks, LSP y sincronización de plugins. Está diseñado para llamadas scripteadas con `-p` donde quieres la ejecución más rápida y limpia posible:

```bash
# Ejecución mínima sin hooks ni plugins
claude --bare -p "Genera un commit message para estos cambios" < diff.txt
```

**Cuándo usar `--bare`:**
- Scripts de CI/CD donde los hooks no son necesarios
- Llamadas rápidas `-p` en pipelines de automatización
- Cuando los hooks interfieren con la salida esperada
- Scripting de alta frecuencia donde cada milisegundo cuenta

**Cuándo NO usar `--bare`:**
- Sesiones interactivas (los hooks aportan valor)
- Cuando necesitas que se ejecuten hooks de seguridad
- Cuando dependes de plugins o servidores MCP

---

## Formatos de Salida: `--output-format`

Claude Code soporta tres formatos de salida para adaptarse a diferentes necesidades:

### Texto plano (por defecto)

```bash
claude -p "Explica async/await" --output-format text
```

Devuelve texto legible para humanos. Ideal para lectura directa o logs.

### JSON estructurado

```bash
claude -p "Analiza este código" --output-format json < src/app.ts
```

Devuelve un objeto JSON con la estructura completa de la respuesta:

```json
{
  "type": "result",
  "subtype": "success",
  "cost_usd": 0.003,
  "is_error": false,
  "duration_ms": 2450,
  "duration_api_ms": 2100,
  "num_turns": 1,
  "result": "El código presenta los siguientes puntos...",
  "session_id": "abc123..."
}
```

Ideal para procesamiento posterior con `jq` u otras herramientas:

```bash
# Extraer solo el resultado
result=$(claude -p "analiza este código" --output-format json < src/app.ts)
echo "$result" | jq -r '.result'

# Obtener el costo de la ejecución
echo "$result" | jq '.cost_usd'

# Verificar si hubo error
echo "$result" | jq '.is_error'
```

### JSON en streaming

```bash
claude -p "Genera un informe detallado" --output-format stream-json
```

Devuelve objetos JSON línea por línea a medida que se generan. Útil para:
- Mostrar progreso en tiempo real
- Procesar respuestas largas incrementalmente
- Integración con sistemas de streaming

---

## Validación con JSON Schema: `--json-schema`

Puedes forzar que la respuesta de Claude se ajuste a un esquema JSON específico. Esto es extremadamente útil para automatizaciones que necesitan salida predecible:

```bash
# Definir un esquema para análisis de código
claude -p "Analiza este código Python" \
  --output-format json \
  --json-schema '{
    "type": "object",
    "properties": {
      "calidad": {
        "type": "string",
        "enum": ["buena", "aceptable", "necesita_mejoras", "critica"]
      },
      "problemas": {
        "type": "array",
        "items": {
          "type": "object",
          "properties": {
            "tipo": { "type": "string" },
            "descripcion": { "type": "string" },
            "linea": { "type": "integer" },
            "severidad": { "type": "string", "enum": ["baja", "media", "alta", "critica"] }
          },
          "required": ["tipo", "descripcion", "severidad"]
        }
      },
      "resumen": { "type": "string" }
    },
    "required": ["calidad", "problemas", "resumen"]
  }' < src/utils.py
```

La respuesta será un JSON válido que cumple con el esquema:

```json
{
  "calidad": "aceptable",
  "problemas": [
    {
      "tipo": "seguridad",
      "descripcion": "Input del usuario no sanitizado en la línea 42",
      "linea": 42,
      "severidad": "alta"
    },
    {
      "tipo": "rendimiento",
      "descripcion": "Bucle innecesario que podría reemplazarse con list comprehension",
      "linea": 67,
      "severidad": "baja"
    }
  ],
  "resumen": "El código es funcional pero tiene un problema de seguridad importante"
}
```

---

## Control de Iteraciones: `--max-turns`

Cuando Claude Code trabaja en modo agente (ejecutando herramientas, leyendo archivos, etc.), puede realizar múltiples "turnos" de interacción. El flag `--max-turns` limita cuántos turnos puede ejecutar:

```bash
# Limitar a 3 turnos como máximo
claude -p "Refactoriza esta función para mejorar su rendimiento" --max-turns 3

# Para tareas simples, 1 turno suele ser suficiente
claude -p "Explica qué hace esta función" --max-turns 1

# Para tareas complejas que requieren explorar archivos
claude -p "Encuentra y corrige todos los bugs en src/" --max-turns 10
```

**Recomendaciones:**
- Tareas de análisis/explicación: `--max-turns 1-3`
- Revisión de código: `--max-turns 3-5`
- Refactorización de un archivo: `--max-turns 5-10`
- Tareas de exploración compleja: `--max-turns 10-15`

---

## Control de Presupuesto: `--max-budget-usd`

Para evitar gastos inesperados, especialmente en automatizaciones que se ejecutan frecuentemente:

```bash
# Limitar a $0.50 por ejecución
claude -p "Haz un análisis completo del proyecto" --max-budget-usd 0.50

# En CI/CD, mantener costos bajos
claude -p "Revisa este PR" --max-budget-usd 0.10

# Para tareas de batch processing
claude -p "Genera documentación" --max-budget-usd 1.00
```

Si se alcanza el límite, Claude detiene la ejecución y devuelve lo que haya completado hasta ese punto.

---

## System Prompts Personalizados

Puedes proporcionar instrucciones de sistema para personalizar el comportamiento de Claude en automatizaciones:

### Inline

```bash
claude -p "Revisa este código" \
  --system-prompt "Eres un revisor de código senior especializado en seguridad. Responde siempre en español. Enfócate en vulnerabilidades OWASP Top 10." \
  < src/api/auth.ts
```

### Desde archivo

```bash
# Crear un archivo con el system prompt
cat > /tmp/review-prompt.txt << 'EOF'
Eres un revisor de código experto. Tus revisiones deben:
1. Ser constructivas y específicas
2. Priorizar seguridad > rendimiento > legibilidad
3. Incluir ejemplos de cómo corregir cada problema
4. Responder siempre en español
5. Usar formato Markdown para la salida
EOF

# Usarlo en la ejecución
claude -p "Revisa este archivo" \
  --system-prompt-file /tmp/review-prompt.txt \
  < src/services/payment.ts
```

---

## Códigos de Salida

Claude Code devuelve códigos de salida estándar para integración con scripts:

| Código | Significado |
|--------|-------------|
| `0` | Ejecución exitosa |
| `1` | Error general |
| `2` | Error de conexión / API |

Uso en scripts:

```bash
#!/bin/bash

# Ejecutar revisión y verificar resultado
if claude -p "¿Hay vulnerabilidades de seguridad en este código?" --max-turns 3 < src/auth.ts; then
    echo "Revisión completada exitosamente"
else
    echo "Error en la revisión (código de salida: $?)"
    exit 1
fi
```

---

## Salida Estructurada para Scripting

Combinando `--output-format json` con herramientas como `jq`, puedes crear pipelines robustos:

```bash
#!/bin/bash

# Ejecutar análisis y capturar resultado JSON
result=$(claude -p "Analiza la calidad de este código. Responde con una puntuación del 1 al 10 y un resumen." \
  --output-format json \
  < src/main.py)

# Extraer campos específicos
respuesta=$(echo "$result" | jq -r '.result')
costo=$(echo "$result" | jq '.cost_usd')
error=$(echo "$result" | jq '.is_error')

# Actuar según el resultado
if [ "$error" = "true" ]; then
    echo "ERROR: La ejecución falló"
    exit 1
fi

echo "Resultado del análisis:"
echo "$respuesta"
echo "---"
echo "Costo: \$$costo USD"
```

### Ejemplo avanzado: Pipeline de validación

```bash
#!/bin/bash

# Validar múltiples archivos y generar informe
informe=""
costo_total=0

for archivo in src/**/*.ts; do
    echo "Analizando: $archivo"

    resultado=$(claude -p "Califica este código del 1 al 10. Responde SOLO con el número." \
      --output-format json \
      --max-turns 1 \
      --max-budget-usd 0.05 \
      < "$archivo")

    puntuacion=$(echo "$resultado" | jq -r '.result' | grep -oP '\d+' | head -1)
    costo=$(echo "$resultado" | jq '.cost_usd')
    costo_total=$(echo "$costo_total + $costo" | bc)

    informe+="$archivo: $puntuacion/10\n"
done

echo -e "\n=== INFORME DE CALIDAD ==="
echo -e "$informe"
echo "Costo total: \$$costo_total USD"
```

---

## Resumen

| Flag / Opción | Uso |
|---------------|-----|
| `-p "consulta"` | Modo no interactivo |
| `--output-format text\|json\|stream-json` | Formato de salida |
| `--json-schema '{...}'` | Validar estructura de respuesta |
| `--max-turns N` | Limitar iteraciones del agente |
| `--max-budget-usd N` | Tope de gasto por ejecución |
| `--system-prompt "..."` | Prompt de sistema inline |
| `--system-prompt-file path` | Prompt de sistema desde archivo |
| `\| claude -p "..."` | Recibir input por pipe |

El modo no interactivo es la pieza fundamental para toda automatización con Claude Code. En las siguientes secciones veremos cómo aplicarlo en GitHub Actions y scripts de automatización.
