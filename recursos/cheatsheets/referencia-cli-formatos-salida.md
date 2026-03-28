# Referencia CLI — Formatos de salida

> Documentacion exhaustiva de los formatos de salida disponibles en Claude Code para el modo no interactivo (`-p`), incluyendo JSON Schema y ejemplos de parseo con jq.

Indice: [referencia-cli-indice.md](./referencia-cli-indice.md)

---

## Disponibilidad

Los formatos de salida estructurados requieren el **modo print** (`-p` / `--print`). En el modo interactivo, la salida siempre es texto formateado para el terminal.

```bash
claude -p "query" --output-format <formato>
```

---

## Formato `text` (por defecto)

### Descripcion

Salida en texto plano. Es el formato por defecto cuando no se especifica `--output-format`. El texto de la respuesta se escribe directamente a stdout, sin envolturas ni metadatos adicionales.

### Sintaxis

```bash
claude -p "query"
claude -p "query" --output-format text
```

### Cuando usarlo

- Integracion sencilla con scripts bash que no necesitan metadatos
- Cuando quieres redirigir la respuesta a un fichero de texto
- Pipelines simples donde solo necesitas el contenido de la respuesta

### Ejemplos

```bash
# Guardar documentacion en un fichero
claude -p "genera documentacion para la funcion auth.login en src/auth.ts" > docs/auth.md

# Usar la respuesta en una variable
MENSAJE=$(claude -p "genera un mensaje de commit para: $(git diff --staged --stat)")
git commit -m "$MENSAJE"

# Pipeline de transformacion
claude -p "traduce al ingles este README" < README.md > README.en.md
```

---

## Formato `json`

### Descripcion

Al finalizar la ejecucion completa, emite un unico objeto JSON a stdout con la respuesta y metadatos completos de la sesion. No hay salida intermedia: el JSON se emite todo de una vez cuando Claude termina.

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

| Campo | Tipo | Descripcion |
|-------|------|-------------|
| `type` | string | Siempre `"result"` |
| `subtype` | string | `"success"` si la ejecucion fue correcta, `"error_max_turns"` si se alcanzo el limite de turnos |
| `result` | string | Texto de la respuesta final de Claude |
| `session_id` | string (UUID) | ID unico de la sesion, util para reanudar con `--resume` |
| `is_error` | boolean | `true` si la ejecucion termino en error |
| `usage` | object | Estadisticas de uso de tokens |
| `usage.input_tokens` | number | Tokens de entrada consumidos |
| `usage.output_tokens` | number | Tokens de salida generados |
| `usage.cache_creation_input_tokens` | number | Tokens usados para crear la cache de prompt |
| `usage.cache_read_input_tokens` | number | Tokens leidos desde la cache (no se facturan al precio completo) |

### Cuando usarlo

- Cuando necesitas los metadatos completos (coste, session_id) ademas de la respuesta
- Para integraciones que necesitan registrar el uso de tokens
- Cuando quieres poder reanudar la sesion con `--resume`
- En pipelines donde el resultado llega de una sola vez y puedes esperar

### Ejemplos

```bash
# Capturar resultado y session_id para posible reanudacion
RESULTADO=$(claude -p "analiza el proyecto" --output-format json)
SESSION_ID=$(echo "$RESULTADO" | jq -r '.session_id')
RESPUESTA=$(echo "$RESULTADO" | jq -r '.result')

# Registrar uso de tokens
claude -p "query" --output-format json | \
  jq '{tokens_entrada: .usage.input_tokens, tokens_salida: .usage.output_tokens}' >> metricas.jsonl

# Verificar si la ejecucion fue exitosa
SALIDA=$(claude -p "ejecuta los tests" --output-format json)
if [ "$(echo "$SALIDA" | jq -r '.is_error')" = "true" ]; then
  echo "Claude encontro un error"
fi
```

---

## Formato `stream-json`

### Descripcion

Emite objetos JSON separados por lineas (formato NDJSON / JSON Lines) conforme Claude genera la respuesta. Cada linea es un objeto JSON independiente. Este formato permite procesar la respuesta de Claude en tiempo real, sin esperar a que termine.

### Sintaxis

```bash
claude -p "query" --output-format stream-json
```

### Tipos de eventos en el stream

El stream emite varios tipos de eventos a lo largo de la ejecucion:

#### Evento de sistema (inicio)

```json
{"type":"system","subtype":"init","session_id":"550e8400-e29b-41d4-a716-446655440000","model":"claude-sonnet-4-6","cwd":"/home/usuario/proyecto","tools":["Read","Edit","Bash","Glob","Grep"]}
```

| Campo | Descripcion |
|-------|-------------|
| `type` | `"system"` |
| `subtype` | `"init"` — evento de inicializacion |
| `session_id` | ID de la sesion |
| `model` | Modelo usado |
| `cwd` | Directorio de trabajo |
| `tools` | Herramientas disponibles |

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
{"type":"result","subtype":"success","result":"Aqui esta el analisis completo del proyecto...","session_id":"550e8400-e29b-41d4-a716-446655440000","is_error":false,"usage":{"input_tokens":2048,"output_tokens":512,"cache_read_input_tokens":1024,"cache_creation_input_tokens":0}}
```

### Eventos con mensajes parciales (`--include-partial-messages`)

Si se anade `--include-partial-messages`, el stream incluye los bloques de contenido en construccion (streaming de texto caracter a caracter). Util para mostrar progreso en tiempo real en interfaces propias.

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
claude -p "explica el codigo en src/auth.ts" --output-format stream-json | \
  jq -r 'select(.type == "assistant") | .message.content[] | select(.type == "text") | .text'

# Capturar solo el resultado final
claude -p "analiza el proyecto" --output-format stream-json | \
  jq -r 'select(.type == "result") | .result'

# Registrar todas las herramientas usadas durante la ejecucion
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

Cuando se usa `--input-format stream-json`, Claude Code acepta eventos JSON Lines en stdin como entrada (en lugar de texto plano). Util para encadenar sesiones de Claude Code.

```bash
# Encadenar: la salida stream-json de una sesion es la entrada de la siguiente
claude -p "genera tests" --output-format stream-json | \
  claude -p "revisa los tests generados" --input-format stream-json --output-format json
```

---

## JSON Schema (`--json-schema`)

### Descripcion

Valida y fuerza que la salida de Claude sea un objeto JSON valido que cumpla un schema especifico. Disponible solo en modo print (`-p`). Claude completa su workflow normalmente y al final genera una respuesta estructurada que cumple el schema indicado.

### Sintaxis

```bash
claude -p "query" --json-schema '<schema-json>'
claude -p "query" --json-schema "$(cat schema.json)"
```

### Cuando usarlo

- Cuando necesitas una respuesta estructurada para consumir desde codigo
- Integracion con pipelines que esperan datos con formato especifico
- Cuando necesitas multiples campos de informacion en lugar de texto libre
- Validacion automatica del formato de respuesta

### Ejemplo: analisis de codigo con schema

Fichero `schema-analisis.json`:

```json
{
  "type": "object",
  "required": ["resumen", "issues", "puntuacion"],
  "properties": {
    "resumen": {
      "type": "string",
      "description": "Resumen ejecutivo del analisis"
    },
    "issues": {
      "type": "array",
      "items": {
        "type": "object",
        "required": ["tipo", "severidad", "descripcion", "fichero"],
        "properties": {
          "tipo": {"type": "string", "enum": ["bug", "seguridad", "rendimiento", "estilo"]},
          "severidad": {"type": "string", "enum": ["critica", "alta", "media", "baja"]},
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
git diff --staged | claude -p "analiza este codigo" \
  --json-schema "$(cat schema-analisis.json)" \
  --output-format json
```

Salida resultante:

```json
{
  "type": "result",
  "subtype": "success",
  "result": "{\"resumen\":\"El codigo modifica el sistema de autenticacion...\",\"issues\":[{\"tipo\":\"seguridad\",\"severidad\":\"alta\",\"descripcion\":\"Falta validacion del token JWT\",\"fichero\":\"src/auth.ts\"}],\"puntuacion\":7.5}",
  "session_id": "...",
  "is_error": false,
  "usage": {...}
}
```

### Parseo completo con jq

```bash
# Extraer el JSON del campo result (que es un string JSON embebido)
ANALISIS=$(git diff --staged | claude -p "analiza este codigo" \
  --json-schema "$(cat schema-analisis.json)" \
  --output-format json | jq -r '.result')

# Ahora ANALISIS es un JSON parseable
echo "$ANALISIS" | jq '.puntuacion'
echo "$ANALISIS" | jq '.issues[] | select(.severidad == "critica")'
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

### Guardar metricas de uso en fichero de log

```bash
#!/bin/bash
# Script: ejecutar-con-metricas.sh

QUERY="$1"
LOG_FILE="metricas-claude.jsonl"

RESULTADO=$(claude -p "$QUERY" --output-format json)

# Extraer y registrar metricas
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
| Metadatos disponibles | No | Si (al final) | Si (en evento `result`) |
| Progreso en tiempo real | Si (texto) | No | Si (todos los eventos) |
| Facilidad de parseo | Alta (texto directo) | Media (un JSON) | Baja (multiples JSONs) |
| Uso de herramientas visible | No | No | Si |
| Complejidad de integracion | Baja | Media | Alta |
| Recomendado para | Scripts simples | Automatizacion con metadatos | Interfaces o monitoreo detallado |

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

Lista los agentes configurados, agrupados por origen (proyecto, usuario global, etc.).

---

## Ver tambien

- [Modos de ejecucion](./referencia-cli-modos-ejecucion.md) — El modo print (`-p`) es el que habilita estos formatos
- [Flags de arranque](./referencia-cli-flags-arranque.md) — Todos los flags relacionados con output: `--output-format`, `--json-schema`, `--include-partial-messages`, `--input-format`
- [github-actions-claude-code.md](./github-actions-claude-code.md) — Uso de formatos de salida en CI/CD
