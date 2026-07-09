# Referencia CLI — Formatos de salida

> Documentación exhaustiva de los formatos de salida disponibles en Claude Code para el modo no interactivo (`-p`), incluyendo JSON Schema y ejemplos de parseo con jq.

Índice: [referencia-cli-indice.md](./referencia-cli-indice.md)

---

## Disponibilidad

Los formatos de salida estructurados requieren el **modo print** (`-p` / `--print`). En el modo interactivo, la salida siempre es texto formateado para el terminal.

```bash
claude -p "query" --output-format <formato>
```

---

## Formato `text` (por defecto)

### Descripción

Salida en texto plano. Es el formato por defecto cuando no se especifica `--output-format`. El texto de la respuesta se escribe directamente a stdout, sin envolturas ni metadatos adicionales.

### Sintaxis

```bash
claude -p "query"
claude -p "query" --output-format text
```

### Cuando usarlo

- Integración sencilla con scripts bash que no necesitan metadatos
- Cuando quieres redirigir la respuesta a un fichero de texto
- Pipelines simples donde solo necesitas el contenido de la respuesta

### Ejemplos

```bash
# Guardar documentación en un fichero
claude -p "genera documentación para la función auth.login en src/auth.ts" > docs/auth.md

# Usar la respuesta en una variable
MENSAJE=$(claude -p "genera un mensaje de commit para: $(git diff --staged --stat)")
git commit -m "$MENSAJE"

# Pipeline de transformación
claude -p "traduce al inglés este README" < README.md > README.en.md
```

---

## Formato `json`

### Descripción

Al finalizar la ejecución completa, emite un único objeto JSON a stdout con la respuesta y metadatos completos de la sesión. No hay salida intermedia: el JSON se emite todo de una vez cuando Claude termina.

### Sintaxis

```bash
claude -p "query" --output-format json
```

### Estructura del objeto JSON de salida

```json
{
  "type": "result",
  "subtype": "success",
  "result": "Texto de la respuesta de Claude",
  "session_id": "550e8400-e29b-41d4-a716-446655440000",
  "is_error": false,
  "usage": {
    "input_tokens": 1250,
    "output_tokens": 340,
    "cache_creation_input_tokens": 0,
    "cache_read_input_tokens": 980
  }
}
```

### Campos del objeto de resultado

| Campo | Tipo | Descripción |
|-------|------|-------------|
| `type` | string | Siempre `"result"` |
| `subtype` | string | `"success"` si la ejecución fue correcta, `"error_max_turns"` si se alcanzó el límite de turnos |
| `result` | string | Texto de la respuesta final de Claude |
| `session_id` | string (UUID) | ID único de la sesión, útil para reanudar con `--resume` |
| `is_error` | boolean | `true` si la ejecución terminó en error |
| `usage` | object | Estadísticas de uso de tokens |
| `usage.input_tokens` | number | Tokens de entrada consumidos |
| `usage.output_tokens` | number | Tokens de salida generados |
| `usage.cache_creation_input_tokens` | number | Tokens usados para crear la caché de prompt |
| `usage.cache_read_input_tokens` | number | Tokens leídos desde la caché (no se facturan al precio completo) |

### Cuando usarlo

- Cuando necesitas los metadatos completos (coste, session_id) además de la respuesta
- Para integraciones que necesitan registrar el uso de tokens
- Cuando quieres poder reanudar la sesión con `--resume`
- En pipelines donde el resultado llega de una sola vez y puedes esperar

### Ejemplos

```bash
# Capturar resultado y session_id para posible reanudación
RESULTADO=$(claude -p "analiza el proyecto" --output-format json)
SESSION_ID=$(echo "$RESULTADO" | jq -r '.session_id')
RESPUESTA=$(echo "$RESULTADO" | jq -r '.result')

# Registrar uso de tokens
claude -p "query" --output-format json | \
  jq '{tokens_entrada: .usage.input_tokens, tokens_salida: .usage.output_tokens}' >> metricas.jsonl

# Verificar si la ejecución fue exitosa
SALIDA=$(claude -p "ejecuta los tests" --output-format json)
if [ "$(echo "$SALIDA" | jq -r '.is_error')" = "true" ]; then
  echo "Claude encontró un error"
fi
```

---

## Formato `stream-json`

### Descripción

Emite objetos JSON separados por líneas (formato NDJSON / JSON Lines) conforme Claude genera la respuesta. Cada línea es un objeto JSON independiente. Este formato permite procesar la respuesta de Claude en tiempo real, sin esperar a que termine.

### Sintaxis

```bash
claude -p "query" --output-format stream-json
```

### Tipos de eventos en el stream

El stream emite varios tipos de eventos a lo largo de la ejecución:

#### Evento de sistema (inicio)

```json
{"type":"system","subtype":"init","session_id":"550e8400-e29b-41d4-a716-446655440000","model":"claude-sonnet-4-6","cwd":"/home/usuario/proyecto","tools":["Read","Edit","Bash","Glob","Grep"],"plugin_errors":[]}
```

| Campo | Descripción |
|-------|-------------|
| `type` | `"system"` |
| `subtype` | `"init"` — evento de inicialización |
| `session_id` | ID de la sesión |
| `model` | Modelo usado |
| `cwd` | Directorio de trabajo |
| `tools` | Herramientas disponibles |
| `plugin_errors` | Lista de errores de carga de plugins (v2.1.111). Array vacío si todos los plugins cargaron correctamente; contiene strings descriptivos de error si algún plugin falló al inicializar |

#### Evento de asistente (respuesta en streaming)

```json
{"type":"assistant","message":{"id":"msg_01XFDUDYJgAACzvnptvVoYEL","type":"message","role":"assistant","content":[{"type":"text","text":"Analizando el proyecto..."}],"model":"claude-sonnet-4-6","stop_reason":null,"stop_sequence":null,"usage":{"input_tokens":1024,"output_tokens":45}}}
```

#### Evento de uso de herramienta

```json
{"type":"tool_use","name":"Read","input":{"file_path":"/home/usuario/proyecto/src/auth.ts"}}
```

#### Evento de resultado de herramienta

```json
{"type":"tool_result","tool_use_id":"toolu_01ABC","content":"// Contenido del fichero...","is_error":false}
```

#### Evento de resultado final

```json
{"type":"result","subtype":"success","result":"Aquí está el análisis completo del proyecto...","session_id":"550e8400-e29b-41d4-a716-446655440000","is_error":false,"usage":{"input_tokens":2048,"output_tokens":512,"cache_read_input_tokens":1024,"cache_creation_input_tokens":0}}
```

### Eventos con mensajes parciales (`--include-partial-messages`)

Si se añade `--include-partial-messages`, el stream incluye los bloques de contenido en construcción (streaming de texto carácter a carácter). Útil para mostrar progreso en tiempo real en interfaces propias.

```bash
claude -p "query" --output-format stream-json --include-partial-messages
```

### Cuando usarlo

- Interfaces que muestran la respuesta conforme se genera (tipo chat)
- Monitorizar en tiempo real el uso de herramientas por parte de Claude
- Procesar respuestas largas sin cargar todo en memoria
- Pipelines con timeout donde no puedes esperar a que termine

### Ejemplos

```bash
# Mostrar solo el texto de los mensajes del asistente en tiempo real
claude -p "explica el código en src/auth.ts" --output-format stream-json | \
  jq -r 'select(.type == "assistant") | .message.content[] | select(.type == "text") | .text'

# Capturar solo el resultado final
claude -p "analiza el proyecto" --output-format stream-json | \
  jq -r 'select(.type == "result") | .result'

# Registrar todas las herramientas usadas durante la ejecución
claude -p "implementa los tests" --output-format stream-json | \
  jq 'select(.type == "tool_use") | {herramienta: .name, input: .input}' >> herramientas-usadas.jsonl

# Mostrar progreso y extraer resultado final
claude -p "refactoriza src/api.ts" --output-format stream-json | while IFS= read -r linea; do
  TIPO=$(echo "$linea" | jq -r '.type' 2>/dev/null)
  case "$TIPO" in
    "tool_use")
      HERRAMIENTA=$(echo "$linea" | jq -r '.name')
      echo ">> Usando herramienta: $HERRAMIENTA"
      ;;
    "result")
      echo "== Resultado:"
      echo "$linea" | jq -r '.result'
      ;;
  esac
done
```

---

## Formato de entrada (`--input-format`)

Cuando se usa `--input-format stream-json`, Claude Code acepta eventos JSON Lines en stdin como entrada (en lugar de texto plano). Útil para encadenar sesiones de Claude Code.

```bash
# Encadenar: la salida stream-json de una sesión es la entrada de la siguiente
claude -p "genera tests" --output-format stream-json | \
  claude -p "revisa los tests generados" --input-format stream-json --output-format json
```

---

## JSON Schema (`--json-schema`)

### Descripción

Valida y fuerza que la salida de Claude sea un objeto JSON válido que cumpla un schema específico. Disponible solo en modo print (`-p`). Claude completa su workflow normalmente y al final genera una respuesta estructurada que cumple el schema indicado.

### Sintaxis

```bash
claude -p "query" --json-schema '<schema-json>'
claude -p "query" --json-schema "$(cat schema.json)"
```

### Cuando usarlo

- Cuando necesitas una respuesta estructurada para consumir desde código
- Integración con pipelines que esperan datos con formato específico
- Cuando necesitas múltiples campos de información en lugar de texto libre
- Validación automática del formato de respuesta

### Ejemplo: análisis de código con schema

Fichero `schema-analisis.json`:

```json
{
  "type": "object",
  "required": ["resumen", "issues", "puntuacion"],
  "properties": {
    "resumen": {
      "type": "string",
      "description": "Resumen ejecutivo del análisis"
    },
    "issues": {
      "type": "array",
      "items": {
        "type": "object",
        "required": ["tipo", "severidad", "descripcion", "fichero"],
        "properties": {
          "tipo": {"type": "string", "enum": ["bug", "seguridad", "rendimiento", "estilo"]},
          "severidad": {"type": "string", "enum": ["crítica", "alta", "media", "baja"]},
          "descripcion": {"type": "string"},
          "fichero": {"type": "string"}
        }
      }
    },
    "puntuacion": {
      "type": "number",
      "minimum": 0,
      "maximum": 10
    }
  }
}
```

```bash
# Usar el schema desde fichero
git diff --staged | claude -p "analiza este código" \
  --json-schema "$(cat schema-analisis.json)" \
  --output-format json
```

Salida resultante:

```json
{
  "type": "result",
  "subtype": "success",
  "result": "{\"resumen\":\"El código modifica el sistema de autenticación...\",\"issues\":[{\"tipo\":\"seguridad\",\"severidad\":\"alta\",\"descripcion\":\"Falta validación del token JWT\",\"fichero\":\"src/auth.ts\"}],\"puntuacion\":7.5}",
  "session_id": "...",
  "is_error": false,
  "usage": {...}
}
```

### Parseo completo con jq

```bash
# Extraer el JSON del campo result (que es un string JSON embebido)
ANALISIS=$(git diff --staged | claude -p "analiza este código" \
  --json-schema "$(cat schema-analisis.json)" \
  --output-format json | jq -r '.result')

# Ahora ANALISIS es un JSON parseable
echo "$ANALISIS" | jq '.puntuacion'
echo "$ANALISIS" | jq '.issues[] | select(.severidad == "crítica")'
```

---

## Parseo de salida JSON con jq

### Recetas frecuentes

```bash
# Extraer solo el texto de la respuesta (formato json)
claude -p "query" --output-format json | jq -r '.result'

# Verificar si hubo error
claude -p "query" --output-format json | jq '.is_error'

# Obtener el session_id para reanudar
claude -p "query" --output-format json | jq -r '.session_id'

# Calcular coste aproximado (Sonnet: $3/MTok entrada, $15/MTok salida)
claude -p "query" --output-format json | jq '
  .usage |
  {
    tokens_entrada: .input_tokens,
    tokens_salida: .output_tokens,
    tokens_cache: .cache_read_input_tokens,
    coste_estimado_usd: ((.input_tokens * 3 + .output_tokens * 15) / 1000000)
  }
'

# Del formato stream-json: obtener solo el resultado final
claude -p "query" --output-format stream-json | \
  jq -rs '[.[] | select(.type == "result")] | last | .result'

# Del formato stream-json: listar todas las herramientas usadas
claude -p "query" --output-format stream-json | \
  jq -r 'select(.type == "tool_use") | .name' | sort | uniq -c | sort -rn

# Del formato stream-json: obtener el texto de la respuesta progresivamente
claude -p "query" --output-format stream-json | \
  jq -r 'select(.type == "assistant") |
         .message.content[] |
         select(.type == "text") |
         .text' 2>/dev/null
```

### Guardar métricas de uso en fichero de log

```bash
#!/bin/bash
# Script: ejecutar-con-metricas.sh

QUERY="$1"
LOG_FILE="metricas-claude.jsonl"

RESULTADO=$(claude -p "$QUERY" --output-format json)

# Extraer y registrar métricas
echo "$RESULTADO" | jq \
  --arg fecha "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
  --arg query "$QUERY" \
  '{
    fecha: $fecha,
    query: $query,
    session_id: .session_id,
    input_tokens: .usage.input_tokens,
    output_tokens: .usage.output_tokens,
    cache_tokens: .usage.cache_read_input_tokens,
    error: .is_error
  }' >> "$LOG_FILE"

# Mostrar la respuesta
echo "$RESULTADO" | jq -r '.result'
```

---

## Comparativa de formatos

| Criterio | `text` | `json` | `stream-json` |
|----------|--------|--------|---------------|
| Tiempo hasta primera salida | Inmediato (streaming) | Al finalizar | Inmediato (streaming) |
| Metadatos disponibles | No | Sí (al final) | Sí (en evento `result`) |
| Progreso en tiempo real | Sí (texto) | No | Sí (todos los eventos) |
| Facilidad de parseo | Alta (texto directo) | Media (un JSON) | Baja (múltiples JSONs) |
| Uso de herramientas visible | No | No | Sí |
| Complejidad de integración | Baja | Media | Alta |
| Recomendado para | Scripts simples | Automatización con metadatos | Interfaces o monitoreo detallado |

---

## Subcomandos con salida estructurada

Algunos subcomandos de Claude Code emiten salida estructurada propia:

### `claude auth status`

```bash
# Salida JSON por defecto
claude auth status

# Salida legible para humanos
claude auth status --text
```

Ejemplo de salida JSON:

```json
{
  "authenticated": true,
  "email": "usuario@ejemplo.com",
  "plan": "max",
  "model": "claude-sonnet-4-6"
}
```

### `claude agents`

```bash
claude agents
```

Abre el dashboard de sesiones activas e incluidas en background. Con `--json`, emite un array de objetos con el estado de cada sesión:

```bash
claude agents --json
```

```json
[
  {
    "id": "sess_8f3a1c",
    "name": "feature-auth",
    "cwd": "/home/dev/proyectos/taskflow-api",
    "status": "blocked",
    "background": true,
    "waitingFor": "permission:Bash(npm run migrate)",
    "lastActivity": "2026-07-08T10:41:55Z"
  }
]
```

El campo `waitingFor` (v2.1.162) indica explícitamente el motivo de un bloqueo (`permission:...`, una pregunta al usuario, o una dependencia de otro agente) y es `null` cuando la sesión no está bloqueada. Ver [Módulo 16](../../modulo-16-agentes-background-workflows/teoria/01-agent-view.md) para el detalle completo de `claude agents`.

---

## Formato JSON de la línea de estado (`/statusline`)

### Descripción

Los scripts configurados con `/statusline` reciben por stdin un objeto JSON con información de la sesión actual, que usan para renderizar la línea de estado del prompt. Desde v2.1.145, ese payload incluye información del repositorio y del pull request de GitHub cuando Claude Code los detecta en el directorio de trabajo.

### Estructura del objeto JSON recibido

```json
{
  "session_id": "550e8400-e29b-41d4-a716-446655440000",
  "model": "claude-sonnet-4-6",
  "cwd": "/home/usuario/proyecto",
  "rate_limits": {
    "requests_remaining": 42,
    "resets_at": "2026-07-08T12:00:00Z"
  },
  "repository": {
    "name": "taskflow-api",
    "branch": "feature/auth",
    "remote": "github.com/miorg/taskflow-api"
  },
  "pull_request": {
    "number": 123,
    "state": "open",
    "url": "https://github.com/miorg/taskflow-api/pull/123"
  }
}
```

| Campo | Descripción | Versión |
|-------|-------------|---------|
| `rate_limits` | Información sobre límites de uso actuales | v2.1.80+ |
| `repository` | Nombre, branch y remote del repositorio detectado en `cwd` | v2.1.145 |
| `pull_request` | Número, estado y URL del PR asociado al branch actual, si `gh` detecta uno | v2.1.145 |

`repository` y `pull_request` solo aparecen cuando Claude Code detecta un repositorio git (y, en el caso de `pull_request`, un PR asociado al branch actual vía `gh`). Ver [`/statusline`](./referencia-cli-slash-commands.md) para cómo configurar el script.

---

## Salida estructurada de OpenTelemetry (OTEL)

### Descripción

Cuando `CLAUDE_CODE_ENABLE_TELEMETRY=1` (ver [Variables de entorno](./referencia-cli-variables-entorno.md)), Claude Code emite trazas y eventos OTEL con atributos que han ido ampliándose en versiones recientes.

### Atributos de Dynamic Workflows

Desde v2.1.202, las trazas generadas durante la ejecución de un [Dynamic Workflow](./referencia-cli-slash-commands.md) (`/workflows`) incluyen dos atributos adicionales que permiten correlacionar spans con un run concreto:

| Atributo | Descripción |
|----------|-------------|
| `workflow.run_id` | Identificador único del run del Dynamic Workflow |
| `workflow.name` | Nombre del Dynamic Workflow, si se le asignó uno |

```bash
# Ejemplo de query en un backend OTEL para agrupar spans por workflow.run_id
# (sintaxis ilustrativa, depende del backend de observabilidad usado)
```

### Evento `claude_code.assistant_response`

Desde v2.1.193, si `OTEL_LOG_ASSISTANT_RESPONSES=1` está activo, cada respuesta del asistente genera un evento `claude_code.assistant_response` en la traza, con el mismo criterio de privacidad por defecto (desactivado) que `OTEL_LOG_USER_PROMPTS`.

### `OTEL_RESOURCE_ATTRIBUTES` como labels

Desde v2.1.161, el contenido de la variable estándar `OTEL_RESOURCE_ATTRIBUTES` (pares `clave=valor` separados por coma) se propaga como labels/dimensiones en las métricas y trazas emitidas por Claude Code, no solo como metadatos del resource. Esto permite filtrar dashboards por equipo, entorno u otra dimensión organizativa sin instrumentación adicional:

```bash
export CLAUDE_CODE_ENABLE_TELEMETRY=1
export OTEL_RESOURCE_ATTRIBUTES="team=backend,env=staging"
claude -p "ejecuta la suite de integración"
```

---

## Ver también

- [Modos de ejecución](./referencia-cli-modos-ejecucion.md) — El modo print (`-p`) es el que habilita estos formatos
- [Flags de arranque](./referencia-cli-flags-arranque.md) — Todos los flags relacionados con output: `--output-format`, `--json-schema`, `--include-partial-messages`, `--input-format`
- [Variables de entorno](./referencia-cli-variables-entorno.md) — Variables `OTEL_*` y `CLAUDE_CODE_ENABLE_TELEMETRY`
- [github-actions-claude-code.md](./github-actions-claude-code.md) — Uso de formatos de salida en CI/CD
