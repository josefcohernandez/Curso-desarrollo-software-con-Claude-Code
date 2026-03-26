# Referencia CLI — Variables de entorno

> Documentacion exhaustiva de todas las variables de entorno que afectan al comportamiento de Claude Code.

Indice: [referencia-cli-indice.md](./referencia-cli-indice.md)

---

## Como configurar variables de entorno

Hay tres formas de establecer variables de entorno para Claude Code:

**1. En el shell antes de arrancar:**

```bash
export ANTHROPIC_API_KEY="sk-ant-..."
export MAX_THINKING_TOKENS=8000
claude
```

**2. En el fichero `.claude/settings.json` del proyecto (bajo la clave `env`):**

```json
{
  "env": {
    "BASH_DEFAULT_TIMEOUT_MS": "30000",
    "MAX_THINKING_TOKENS": "8000"
  }
}
```

Las variables definidas aqui se aplican a todos los que usen el proyecto.

**3. En el fichero `~/.claude/settings.json` (configuracion global del usuario):**

```json
{
  "env": {
    "ANTHROPIC_API_KEY": "sk-ant-...",
    "CLAUDE_CODE_DISABLE_AUTO_MEMORY": "1"
  }
}
```

---

## Autenticacion

| Variable | Valores | Defecto | Descripcion |
|----------|---------|---------|-------------|
| `ANTHROPIC_API_KEY` | `sk-ant-...` | — | API key de Anthropic para autenticacion directa. Cuando esta definida, tiene prioridad sobre el login con cuenta (`/login`). Preferir el login con cuenta para uso personal para evitar cargos inesperados de API |
| `ANTHROPIC_AUTH_TOKEN` | string | — | Token de autenticacion alternativo. Equivalente funcional a `ANTHROPIC_API_KEY` |
| `ANTHROPIC_BASE_URL` | URL | `https://api.anthropic.com` | URL base para las peticiones a la API. Util para proxies corporativos o entornos de prueba |
| `ANTHROPIC_CUSTOM_HEADERS` | string | — | Cabeceras HTTP adicionales a incluir en las peticiones, separadas por `\n`. Ejemplo: `"X-Custom-Header: valor\nX-Otro: valor2"`. Usado para AWS Bedrock Guardrails |

### Ejemplo: autenticacion con proxy corporativo

```bash
export ANTHROPIC_BASE_URL="https://mi-proxy.empresa.com/anthropic"
export ANTHROPIC_API_KEY="sk-ant-..."
claude
```

---

## Proveedor: Amazon Bedrock

| Variable | Valores | Defecto | Descripcion |
|----------|---------|---------|-------------|
| `CLAUDE_CODE_USE_BEDROCK` | `1` | — | Activa la integracion con Amazon Bedrock. **Obligatorio** para usar Bedrock |
| `AWS_REGION` | region AWS | — | Region de AWS. **Obligatorio** cuando se usa Bedrock. Claude Code no lee esta configuracion del fichero `.aws/config` |
| `AWS_ACCESS_KEY_ID` | string | — | ID de la clave de acceso AWS |
| `AWS_SECRET_ACCESS_KEY` | string | — | Clave secreta de acceso AWS |
| `AWS_SESSION_TOKEN` | string | — | Token de sesion AWS (para credenciales temporales) |
| `AWS_PROFILE` | nombre | — | Perfil de AWS a usar (para SSO u otros mecanismos de credenciales) |
| `AWS_BEARER_TOKEN_BEDROCK` | string | — | API key de Bedrock. Alternativa simplificada a las credenciales AWS completas |
| `ANTHROPIC_SMALL_FAST_MODEL_AWS_REGION` | region AWS | `AWS_REGION` | Override de region para el modelo pequeno/rapido (Haiku). Permite usar una region diferente solo para Haiku |

### Variables de seleccion de modelo para Bedrock

| Variable | Descripcion |
|----------|-------------|
| `ANTHROPIC_DEFAULT_OPUS_MODEL` | ID del modelo Opus en Bedrock (ej: `us.anthropic.claude-opus-4-6-v1`) |
| `ANTHROPIC_DEFAULT_SONNET_MODEL` | ID del modelo Sonnet en Bedrock (ej: `us.anthropic.claude-sonnet-4-6`) |
| `ANTHROPIC_DEFAULT_HAIKU_MODEL` | ID del modelo Haiku en Bedrock (ej: `us.anthropic.claude-haiku-4-5-20251001-v1:0`) |

### Variables de capacidades de modelo (v2.1.84+)

Permiten declarar explicitamente las capacidades del modelo configurado, necesario cuando Claude Code no puede detectarlas automaticamente (por ejemplo, con modelos personalizados en Bedrock o Vertex).

| Variable | Descripcion |
|----------|-------------|
| `ANTHROPIC_DEFAULT_OPUS_MODEL_SUPPORTS` | Capacidades del modelo Opus por defecto. Permite sobreescribir la deteccion automatica de features para el modelo Opus configurado |
| `ANTHROPIC_DEFAULT_SONNET_MODEL_SUPPORTS` | Capacidades del modelo Sonnet por defecto. Idem para el modelo Sonnet configurado |
| `ANTHROPIC_DEFAULT_HAIKU_MODEL_SUPPORTS` | Capacidades del modelo Haiku por defecto. Idem para el modelo Haiku configurado |

### Ejemplo: configuracion completa con Bedrock

```bash
# Activar Bedrock
export CLAUDE_CODE_USE_BEDROCK=1
export AWS_REGION=us-east-1

# Anclar versiones de modelo (recomendado para equipos)
export ANTHROPIC_DEFAULT_SONNET_MODEL="us.anthropic.claude-sonnet-4-6"
export ANTHROPIC_DEFAULT_HAIKU_MODEL="us.anthropic.claude-haiku-4-5-20251001-v1:0"

# Usar perfil SSO
export AWS_PROFILE=mi-perfil-empresa
aws sso login --profile mi-perfil-empresa
claude
```

---

## Proveedor: Google Vertex AI

| Variable | Valores | Defecto | Descripcion |
|----------|---------|---------|-------------|
| `CLAUDE_CODE_USE_VERTEX` | `1` | — | Activa la integracion con Google Vertex AI |
| `CLOUD_ML_REGION` | region GCP | — | Region de Google Cloud para Vertex AI (ej: `us-east5`) |
| `ANTHROPIC_VERTEX_PROJECT_ID` | string | — | ID del proyecto de Google Cloud |

### Ejemplo: configuracion con Vertex AI

```bash
export CLAUDE_CODE_USE_VERTEX=1
export CLOUD_ML_REGION=us-east5
export ANTHROPIC_VERTEX_PROJECT_ID=mi-proyecto-gcp
claude
```

---

## Modelo y razonamiento

| Variable | Valores | Defecto | Descripcion |
|----------|---------|---------|-------------|
| `ANTHROPIC_MODEL` | nombre de modelo | — | Modelo por defecto para la sesion. Acepta alias (`sonnet`, `opus`) o nombre completo (`claude-sonnet-4-6`). Equivalente a `--model` |
| `ANTHROPIC_SMALL_FAST_MODEL` | nombre de modelo | Haiku | Modelo usado para tareas rapidas y subagentes ligeros |
| `MAX_THINKING_TOKENS` | numero | — | Limita el numero de tokens de razonamiento interno (extended thinking). Util para controlar costes cuando el extended thinking esta activo |
| `DISABLE_PROMPT_CACHING` | `1` | — | Desactiva el prompt caching. Util en regiones de Bedrock donde el caching no esta disponible |

---

## Bash y ejecucion

| Variable | Valores | Defecto | Descripcion |
|----------|---------|---------|-------------|
| `BASH_DEFAULT_TIMEOUT_MS` | numero (ms) | `120000` (2 min) | Timeout por defecto para comandos bash. Aumentar para scripts de larga duracion |
| `BASH_MAX_TIMEOUT_MS` | numero (ms) | `600000` (10 min) | Timeout maximo permitido para comandos bash. Claude no puede superar este limite aunque el usuario lo pida |
| `BASH_MAX_OUTPUT_CHARS` | numero | `200000` | Limite de caracteres en la salida de un comando bash antes de truncar |
| `CLAUDE_CODE_SHELL` | path | `/bin/bash` | Shell a usar para ejecutar comandos bash |
| `CLAUDE_CODE_TMPDIR` | path | directorio temporal del sistema | Directorio temporal para ficheros de trabajo de Claude Code |
| `CLAUDE_CODE_DISABLE_BACKGROUND_TASKS` | `1` | — | Desactiva toda la funcionalidad de tareas en segundo plano |
| `CLAUDE_CODE_SUBPROCESS_ENV_SCRUB` | `1` | — | Elimina las credenciales del entorno antes de lanzar subprocesos desde Claude Code. Impide que comandos bash ejecutados por Claude hereden `ANTHROPIC_API_KEY` y otras variables sensibles. Recomendado en entornos de produccion (v2.1.81+) |
| `CLAUDE_STREAM_IDLE_TIMEOUT_MS` | numero (ms) | — | Timeout del watchdog de streaming idle. Controla cuanto tiempo espera Claude Code antes de considerar una conexion de streaming como inactiva y cancelarla. Util para ajustar la tolerancia a pausas largas en respuestas de streaming (v2.1.84+) |

### Ejemplo: ajuste de timeouts para CI

```bash
# En un entorno CI con tests de integracion lentos
export BASH_DEFAULT_TIMEOUT_MS=300000   # 5 minutos
export BASH_MAX_TIMEOUT_MS=1800000      # 30 minutos
export BASH_MAX_OUTPUT_CHARS=500000     # Mas output para logs detallados
```

---

## MCP (Model Context Protocol)

| Variable | Valores | Defecto | Descripcion |
|----------|---------|---------|-------------|
| `MCP_TIMEOUT` | numero (ms) | `30000` | Timeout para operaciones de servidores MCP |
| `MAX_MCP_OUTPUT_TOKENS` | numero | — | Limite de tokens en la respuesta de una herramienta MCP |

---

## Memoria y contexto

| Variable | Valores | Defecto | Descripcion |
|----------|---------|---------|-------------|
| `CLAUDE_CODE_DISABLE_AUTO_MEMORY` | `0` / `1` | `0` | Desactiva la funcionalidad de auto-memory cuando se establece a `1`. Auto-memory escribe automaticamente entradas en CLAUDE.md basandose en la sesion |
| `CLAUDE_CODE_TASK_LIST_ID` | string | — | Nombre del directorio en `~/.claude/tasks/` para compartir una lista de tareas entre sesiones. Ejemplo: `CLAUDE_CODE_TASK_LIST_ID=mi-proyecto claude` |

---

## Telemetria y diagnostico

| Variable | Valores | Defecto | Descripcion |
|----------|---------|---------|-------------|
| `CLAUDE_CODE_ENABLE_TELEMETRY` | `1` | — | Activa la telemetria de OpenTelemetry. Requiere configurar las variables `OTEL_*` correspondientes |
| `DISABLE_TELEMETRY` | `1` | — | Desactiva el envio de telemetria a Anthropic |
| `DISABLE_NONESSENTIAL_TRAFFIC` | `1` | — | Desactiva todo el trafico no esencial: telemetria, sugerencias de prompts, actualizaciones de estado en segundo plano |
| `CLAUDE_CODE_DEBUG` | `1` | — | Activa logs de depuracion detallados. Equivalente a `--debug` |

### Variables de OpenTelemetry

Cuando `CLAUDE_CODE_ENABLE_TELEMETRY=1`, configura el destino de trazas con las variables estandar de OTEL:

```bash
export CLAUDE_CODE_ENABLE_TELEMETRY=1
export OTEL_EXPORTER_OTLP_ENDPOINT="https://mi-observabilidad.empresa.com"
export OTEL_EXPORTER_OTLP_HEADERS="Authorization=Bearer mi-token"
export OTEL_SERVICE_NAME="claude-code-mi-equipo"
```

---

## Interfaz de usuario

| Variable | Valores | Defecto | Descripcion |
|----------|---------|---------|-------------|
| `CLAUDE_CODE_STATUS_LINE` | template string | — | Personaliza la linea de estado del terminal. Ver [/statusline](https://code.claude.com/docs/en/statusline) para la sintaxis del template |
| `CLAUDE_CODE_ENABLE_PROMPT_SUGGESTION` | `true` / `false` | `true` | Activa o desactiva las sugerencias de prompts que aparecen en gris. Desactivar ahorra tokens cuando la cache esta fria |

---

## Funcionalidades experimentales y control de features

| Variable | Valores | Defecto | Descripcion |
|----------|---------|---------|-------------|
| `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS` | `1` | — | Habilita la funcionalidad experimental de Agent Teams |
| `ENABLE_TOOL_SEARCH` | `auto:N` | — | Activa Tool Search al N% del contexto. Ejemplo: `auto:5` activa la busqueda cuando el contexto supera el 5% de uso |
| `CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS` | `1` | — | Desactiva el uso de betas experimentales de la API |
| `CLAUDE_CODE_SIMPLE` | `1` | — | Activa el modo simplificado de Claude Code |

---

## Ejemplos de configuracion por caso de uso

### Uso personal con cuenta claude.ai (sin API key)

```bash
# No definir ANTHROPIC_API_KEY
# Autenticarse con /login en Claude Code
claude
```

### Desarrollo con API key directa

```bash
export ANTHROPIC_API_KEY="sk-ant-api03-..."
export ANTHROPIC_MODEL="claude-sonnet-4-6"
export DISABLE_NONESSENTIAL_TRAFFIC=1
claude
```

### Entorno enterprise con Bedrock, sin telemetria

```bash
export CLAUDE_CODE_USE_BEDROCK=1
export AWS_REGION=us-east-1
export AWS_PROFILE=empresa-prod
export ANTHROPIC_DEFAULT_SONNET_MODEL="us.anthropic.claude-sonnet-4-6"
export ANTHROPIC_DEFAULT_HAIKU_MODEL="us.anthropic.claude-haiku-4-5-20251001-v1:0"
export DISABLE_TELEMETRY=1
export BASH_MAX_TIMEOUT_MS=600000
claude
```

### CI/CD con presupuesto limitado

```bash
export ANTHROPIC_API_KEY="${ANTHROPIC_API_KEY}"  # Desde secreto del CI
export DISABLE_NONESSENTIAL_TRAFFIC=1
export BASH_DEFAULT_TIMEOUT_MS=60000
export MAX_THINKING_TOKENS=4000
claude -p "ejecuta los tests y reporta fallos" \
  --max-turns 5 \
  --max-budget-usd 1.00 \
  --output-format json
```

### Configuracion en settings.json para compartir con el equipo

```json
{
  "env": {
    "CLAUDE_CODE_USE_BEDROCK": "1",
    "AWS_REGION": "us-east-1",
    "ANTHROPIC_DEFAULT_SONNET_MODEL": "us.anthropic.claude-sonnet-4-6",
    "BASH_DEFAULT_TIMEOUT_MS": "60000",
    "MAX_THINKING_TOKENS": "8000",
    "DISABLE_TELEMETRY": "1"
  }
}
```

---

## Ver tambien

- [Flags de arranque](./referencia-cli-flags-arranque.md) — Muchas variables tienen equivalentes como flags CLI
- [estructura-carpeta-claude.md](./estructura-carpeta-claude.md) — Como configurar `settings.json` y variables por proyecto
- [github-actions-claude-code.md](./github-actions-claude-code.md) — Como usar variables de entorno en GitHub Actions
