# Referencia CLI — Variables de entorno

> Documentación exhaustiva de todas las variables de entorno que afectan al comportamiento de Claude Code.

Índice: [referencia-cli-indice.md](./referencia-cli-indice.md)

---

## Cómo configurar variables de entorno

Hay tres formás de establecer variables de entorno para Claude Code:

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

Las variables definidas aquí se aplican a todos los que usen el proyecto.

**3. En el fichero `~/.claude/settings.json` (configuración global del usuario):**

```json
{
  "env": {
    "ANTHROPIC_API_KEY": "sk-ant-...",
    "CLAUDE_CODE_DISABLE_AUTO_MEMORY": "1"
  }
}
```

---

## Autenticación

| Variable | Valores | Defecto | Descripción |
|----------|---------|---------|-------------|
| `ANTHROPIC_API_KEY` | `sk-ant-...` | — | API key de Anthropic para autenticación directa. Cuando está definida, tiene prioridad sobre el login con cuenta (`/login`). Preferir el login con cuenta para uso personal para evitar cargos inesperados de API |
| `ANTHROPIC_AUTH_TOKEN` | string | — | Token de autenticación alternativo. Equivalente funcional a `ANTHROPIC_API_KEY` |
| `ANTHROPIC_BASE_URL` | URL | `https://api.anthropic.com` | URL base para las peticiones a la API. Útil para proxies corporativos o entornos de prueba |
| `ANTHROPIC_CUSTOM_HEADERS` | string | — | Cabeceras HTTP adicionales a incluir en las peticiones, separadas por `\n`. Ejemplo: `"X-Custom-Header: valor\nX-Otro: valor2"`. Usado para AWS Bedrock Guardrails |
| `ANTHROPIC_WORKSPACE_ID` | string | — | ID del workspace de Anthropic Console a asociar con la sesión. Útil en organizaciones con múltiples workspaces para atribuir el uso al workspace correcto (v2.1.141) |

### Ejemplo: autenticación con proxy corporativo

```bash
export ANTHROPIC_BASE_URL="https://mi-proxy.empresa.com/anthropic"
export ANTHROPIC_API_KEY="sk-ant-..."
claude
```

---

## Proveedor: Amazon Bedrock

| Variable | Valores | Defecto | Descripción |
|----------|---------|---------|-------------|
| `CLAUDE_CODE_USE_BEDROCK` | `1` | — | Activa la integración con Amazon Bedrock. **Obligatorio** para usar Bedrock |
| `AWS_REGION` | región AWS | — | Región de AWS. **Obligatorio** cuando se usa Bedrock. Claude Code no lee esta configuración del fichero `.aws/config` |
| `AWS_ACCESS_KEY_ID` | string | — | ID de la clave de acceso AWS |
| `AWS_SECRET_ACCESS_KEY` | string | — | Clave secreta de acceso AWS |
| `AWS_SESSION_TOKEN` | string | — | Token de sesión AWS (para credenciales temporales) |
| `AWS_PROFILE` | nombre | — | Perfil de AWS a usar (para SSO u otros mecanismos de credenciales) |
| `AWS_BEARER_TOKEN_BEDROCK` | string | — | API key de Bedrock. Alternativa simplificada a las credenciales AWS completas |
| `ANTHROPIC_SMALL_FAST_MODEL_AWS_REGION` | región AWS | `AWS_REGION` | Override de región para el modelo pequeño/rápido (Haiku). Permite usar una región diferente solo para Haiku |

### Variables de seleccion de modelo para Bedrock

| Variable | Descripción |
|----------|-------------|
| `ANTHROPIC_DEFAULT_OPUS_MODEL` | ID del modelo Opus en Bedrock (ej: `us.anthropic.claude-opus-4-6-v1`) |
| `ANTHROPIC_DEFAULT_SONNET_MODEL` | ID del modelo Sonnet en Bedrock (ej: `us.anthropic.claude-sonnet-4-6`) |
| `ANTHROPIC_DEFAULT_HAIKU_MODEL` | ID del modelo Haiku en Bedrock (ej: `us.anthropic.claude-haiku-4-5-20251001-v1:0`) |

### Variables de capacidades de modelo (v2.1.84+)

Permiten declarar explícitamente las capacidades del modelo configurado, necesario cuando Claude Code no puede detectarlas automáticamente (por ejemplo, con modelos personalizados en Bedrock o Vertex).

| Variable | Descripción |
|----------|-------------|
| `ANTHROPIC_DEFAULT_OPUS_MODEL_SUPPORTED_CAPABILITIES` | Capacidades del modelo Opus por defecto. Permite sobreescribir la detección autom de features para el modelo Opus configurado |
| `ANTHROPIC_DEFAULT_SONNET_MODEL_SUPPORTED_CAPABILITIES` | Capacidades del modelo Sonnet por defecto. Idem para el modelo Sonnet configurado |
| `ANTHROPIC_DEFAULT_HAIKU_MODEL_SUPPORTED_CAPABILITIES` | Capacidades del modelo Haiku por defecto. Idem para el modelo Haiku configurado |

### Ejemplo: configuración completa con Bedrock

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

| Variable | Valores | Defecto | Descripción |
|----------|---------|---------|-------------|
| `CLAUDE_CODE_USE_VERTEX` | `1` | — | Activa la integración con Google Vertex AI |
| `CLOUD_ML_REGION` | región GCP | — | Región de Google Cloud para Vertex AI (ej: `us-east5`) |
| `ANTHROPIC_VERTEX_PROJECT_ID` | string | — | ID del proyecto de Google Cloud |

### Ejemplo: configuración con Vertex AI

```bash
export CLAUDE_CODE_USE_VERTEX=1
export CLOUD_ML_REGION=us-east5
export ANTHROPIC_VERTEX_PROJECT_ID=mi-proyecto-gcp
claude
```

---

## Proveedor: Microsoft Azure AI Foundry

| Variable | Valores | Defecto | Descripción |
|----------|---------|---------|-------------|
| `CLAUDE_CODE_USE_FOUNDRY` | `1` | — | Activa la integración con Microsoft Azure AI Foundry |
| `ANTHROPIC_FOUNDRY_API_KEY` | string | — | API key de Azure AI Foundry |
| `ANTHROPIC_FOUNDRY_BASE_URL` | URL | — | URL base del recurso de Azure AI Foundry |
| `ANTHROPIC_FOUNDRY_RESOURCE` | string | — | Nombre del recurso de Azure AI Foundry |

---

## Modelo y razonamiento

| Variable | Valores | Defecto | Descripción |
|----------|---------|---------|-------------|
| `ANTHROPIC_MODEL` | nombre de modelo | — | Modelo por defecto para la sesión. Acepta alias (`sonnet`, `opus`) o nombre completo (`claude-sonnet-4-6`). Equivalente a `--model` |
| `ANTHROPIC_CUSTOM_MODEL_OPTION` | JSON string | — | Permite definir opciones de modelo personalizadas que aparecen en el selector de modelos. Útil para proxies o modelos fine-tuned que no están en la lista estándar (v2.1.77+) |
| `ANTHROPIC_SMALL_FAST_MODEL` | nombre de modelo | Haiku | **[DEPRECATED]** Modelo usado para táreas rápidas y subagentes ligeros |
| `CLAUDE_CODE_OPUS_4_6_FAST_MODE_OVERRIDE` | `1` | — | **[DEPRECATED en v2.1.154, ELIMINADA en v2.1.160]** Forzaba el fast mode para Opus 4.6 al margen de la configuración estándar. Sin efecto desde v2.1.160; usar `/fast` o el flag equivalente en `/config` |
| `MAX_THINKING_TOKENS` | número | — | Limita el número de tokens de razonamiento interno (extended thinking). Útil para controlar costes cuando el extended thinking está activo. Con valor `0`, desactiva por completo el extended thinking para la sesión (v2.1.166) |
| `DISABLE_PROMPT_CACHING` | `1` | — | Desactiva el prompt caching. Útil en regiónes de Bedrock donde el caching no está disponible |
| `ENABLE_PROMPT_CACHING_1H` | `1` | — | Activa TTL de caché de 1 hora en lugar del TTL estándar de 5 minutos. Compatible con API key directa, Bedrock, Vertex y Foundry. Depreca `ENABLE_PROMPT_CACHING_1H_BEDROCK` (v2.1.108) |
| `FORCE_PROMPT_CACHING_5M` | `1` | — | Fuerza el TTL de caché a 5 minutos. Útil para testing o para revertir temporalmente el TTL extendido de `ENABLE_PROMPT_CACHING_1H` |
| `ENABLE_PROMPT_CACHING_1H_BEDROCK` | `1` | — | **[DEPRECATED desde v2.1.108]** Activaba el TTL de 1 hora exclusivamente en Bedrock. Migrar a `ENABLE_PROMPT_CACHING_1H` |

---

## Bash y ejecución

| Variable | Valores | Defecto | Descripción |
|----------|---------|---------|-------------|
| `BASH_DEFAULT_TIMEOUT_MS` | número (ms) | `120000` (2 min) | Timeout por defecto para comandos bash. Aumentar para scripts de larga duración |
| `BASH_MAX_TIMEOUT_MS` | número (ms) | `600000` (10 min) | Timeout máximo permitido para comandos bash. Claude no puede superar este límite aunque el usuario lo pida |
| `BASH_MAX_OUTPUT_LENGTH` | número | `200000` | Limite de caracteres en la salida de un comando bash antes de truncar |
| `CLAUDE_CODE_SHELL` | path | `/bin/bash` | Shell a usar para ejecutar comandos bash |
| `CLAUDE_CODE_TMPDIR` | path | directorio temporal del sistema | Directorio temporal para ficheros de trabajo de Claude Code |
| `CLAUDE_CODE_DISABLE_BACKGROUND_TASKS` | `1` | — | Desactiva toda la funcionalidad de táreas en segundo plano |
| `CLAUDE_CODE_SUBPROCESS_ENV_SCRUB` | `1` | — | Elimina las credenciales del entorno antes de lanzar subprocesos desde Claude Code. Impide que comandos bash ejecutados por Claude hereden `ANTHROPIC_API_KEY` y otras variables sensibles. Recomendado en entornos de producción (v2.1.81+) |
| `CLAUDE_CODE_SCRIPT_CAPS` | número | — | Limita el número máximo de invocaciones de script (Bash tool) por sesión. Útil como medida de seguridad para evitar bucles infinitos o uso excesivo de shell (v2.1.98) |
| `TRACEPARENT` | string (auto) | — | Variable W3C inyectada automáticamente en subprocesos Bash cuando OTEL tracing está activo. Permite propagar el contexto de trazas distribuidas a herramientas externas invocadas por Claude (v2.1.98) |
| `CLAUDE_STREAM_IDLE_TIMEOUT_MS` | número (ms) | `90000` (90s) | Timeout del watchdog de streaming idle. Controla cuanto tiempo espera Claude Code antes de considerar una conexion de streaming como inactiva y cancelarla |
| `CLAUDE_CODE_USE_POWERSHELL_TOOL` | `1` / `0` | — | Opt-in u opt-out explícito del PowerShell tool en Windows (en rollout progresivo). Poner a `1` para forzar la activación, `0` para forzar la desactivación (v2.1.111) |
| `CLAUDE_CODE_SESSION_ID` | string (UUID, auto) | — | Inyectada automáticamente en el entorno de la Bash tool con el ID de la sesión actual. Permite que scripts invocados por Claude sepan desde qué sesión se lanzaron, útil para logging correlacionado (v2.1.132) |
| `CLAUDE_CODE_DISABLE_BG_SHELL_PRESSURE_REAP` | `1` | — | Desactiva la recolección automática de shells en segundo plano cuando el sistema detecta presión de memoria o de procesos. Por defecto, Claude Code puede terminar shells background inactivos bajo presión; esta variable lo impide (v2.1.193) |

### Ejemplo: ajuste de timeouts para CI

```bash
# En un entorno CI con tests de integración lentos
export BASH_DEFAULT_TIMEOUT_MS=300000   # 5 minutos
export BASH_MAX_TIMEOUT_MS=1800000      # 30 minutos
export BASH_MAX_OUTPUT_LENGTH=500000     # Mas output para logs detallados
```

---

## MCP (Model Context Protocol)

| Variable | Valores | Defecto | Descripción |
|----------|---------|---------|-------------|
| `MCP_TIMEOUT` | número (ms) | `30000` | Timeout para operaciones de servidores MCP |
| `MCP_CONNECTION_NONBLOCKING` | `true` | — | En modo `-p` (headless), omite la espera de conexión de servidores MCP al arrancar. Útil en CI/CD donde un MCP lento no debe bloquear la ejecución (v2.1.89) |
| `CLAUDE_CODE_MCP_TOOL_IDLE_TIMEOUT` | número (ms) | — | Timeout específico para herramientas MCP que quedan inactivas a mitad de ejecución (distinto de `MCP_TIMEOUT`, que aplica a la conexión). Evita que una tool MCP colgada bloquee la sesión indefinidamente (v2.1.187) |
| `MAX_MCP_OUTPUT_TOKENS` | número | — | Limite de tokens en la respuesta de una herramienta MCP |
| `CLAUDE_CODE_MCP_SERVER_NAME` | string (auto) | — | Inyectada automáticamente en scripts `headersHelper` con el nombre del servidor MCP que solicita cabeceras. Permite que un solo script sirva a múltiples servidores (v2.1.85+) |
| `CLAUDE_CODE_MCP_SERVER_URL` | URL (auto) | — | Inyectada automáticamente en scripts `headersHelper` con la URL del servidor MCP. Complementa a `CLAUDE_CODE_MCP_SERVER_NAME` (v2.1.85+) |

---

## Memoria y contexto

| Variable | Valores | Defecto | Descripción |
|----------|---------|---------|-------------|
| `CLAUDE_CODE_DISABLE_AUTO_MEMORY` | `0` / `1` | `0` | Desactiva la funcionalidad de auto-memory cuando se establece a `1`. Auto-memory escribe automáticamente entradas en CLAUDE.md basándose en la sesión |
| `CLAUDE_CODE_ENABLE_AWAY_SUMMARY` | `0` / `1` | `1` | Controla el resumen automático de sesión al volver tras una ausencia larga. Establecer a `0` para desactivarlo. El resumen también puede generarse manualmente con `/recap` |
| `CLAUDE_CODE_TASK_LIST_ID` | string | — | Nombre del directorio en `~/.claude/tasks/` para compartir una lista de táreas entre sesiones. Ejemplo: `CLAUDE_CODE_TASK_LIST_ID=mi-proyecto claude` |

---

## Telemetria y diagnóstico

| Variable | Valores | Defecto | Descripción |
|----------|---------|---------|-------------|
| `CLAUDE_CODE_ENABLE_TELEMETRY` | `1` | — | Activa la telemetría de OpenTelemetry. Requiere configurar las variables `OTEL_*` correspondientes |
| `DISABLE_TELEMETRY` | `1` | — | Desactiva el envío de telemetría a Anthropic |
| `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC` | `1` | — | Desactiva todo el tráfico no esencial: telemetría, sugerencias de prompts, actualizaciones de estado en segundo plano |
| `CLAUDE_CODE_ENABLE_FEEDBACK_SURVEY_FOR_OTEL` | `1` | — | Habilita el envío de encuestas de feedback como eventos de OpenTelemetry, para correlacionar satisfacción con métricas de uso en dashboards de observabilidad enterprise (v2.1.136) |

### Variables de OpenTelemetry

Cuando `CLAUDE_CODE_ENABLE_TELEMETRY=1`, configura el destino de trazas con las variables estandar de OTEL:

```bash
export CLAUDE_CODE_ENABLE_TELEMETRY=1
export OTEL_EXPORTER_OTLP_ENDPOINT="https://mi-observabilidad.empresa.com"
export OTEL_EXPORTER_OTLP_HEADERS="Authorization=Bearer mi-token"
export OTEL_SERVICE_NAME="claude-code-mi-equipo"
```

| Variable | Valores | Defecto | Descripción |
|----------|---------|---------|-------------|
| `CLAUDE_CODE_OTEL_LOG_TOOL_DETAILS` | `1` | — | Incluye `tool_parameters` en los eventos `tool_result` de OpenTelemetry. Por defecto no se incluyen para evitar exponer datos sensibles en los logs de observabilidad (v2.1.85+). Desde v2.1.101, alias simplificado: `OTEL_LOG_TOOL_DETAILS` |
| `OTEL_LOG_USER_PROMPTS` | `1` | — | Incluye los prompts del usuario en las trazas de OpenTelemetry. Por defecto desactivado por privacidad (v2.1.101) |
| `OTEL_LOG_TOOL_DETAILS` | `1` | — | Alias simplificado de `CLAUDE_CODE_OTEL_LOG_TOOL_DETAILS`. Incluye parametros de herramientas en trazas OTEL (v2.1.101) |
| `OTEL_LOG_TOOL_CONTENT` | `1` | — | Incluye el contenido completo de resultados de herramientas en trazas OTEL. Puede generar un volumen alto de datos (v2.1.101) |
| `OTEL_LOG_RAW_API_BODIES` | `1` | — | Incluye los cuerpos completos de las peticiones y respuestas API en los logs de OpenTelemetry. Útil para debugging detallado pero aumenta significativamente el volumen de logs (v2.1.111) |
| `OTEL_LOG_ASSISTANT_RESPONSES` | `1` | — | Emite un evento `claude_code.assistant_response` en las trazas de OpenTelemetry con cada respuesta del asistente. Por defecto desactivado por privacidad, igual que `OTEL_LOG_USER_PROMPTS` (v2.1.193). Ver [Formatos de salida](./referencia-cli-formatos-salida.md) |

---

## Renderizado

| Variable | Valores | Defecto | Descripción |
|----------|---------|---------|-------------|
| `CLAUDE_CODE_NO_FLICKER` | `1` | — | Activa el modo de rendering sin parpadeo (alt-screen). Útil en terminales donde el redibujado rápido causa parpadeo visual (v2.1.89) |
| `CLAUDE_CODE_HIDE_CWD` | `1` | — | Oculta el directorio de trabajo actual en el logo de inicio de Claude Code. Útil cuando el path es largo o contiene información sensible |
| `CLAUDE_CODE_DISABLE_ALTERNATE_SCREEN` | `1` | — | Desactiva el uso del alt-screen del terminal (la pantalla alternativa que se restaura al salir). Útil en terminales o multiplexores donde el alt-screen interfiere con el scrollback (v2.1.132) |

---

## Interfaz de usuario

| Variable | Valores | Defecto | Descripción |
|----------|---------|---------|-------------|
| `CLAUDE_CODE_ENABLE_PROMPT_SUGGESTION` | `true` / `false` | `true` | Activa o desactiva las sugerencias de prompts que aparecen en gris. Desactivar ahorra tokens cuando la cache está fría |
| `CLAUDE_CODE_ENABLE_AWAY_SUMMARY` | `0` / `1` | `1` | Controla la feature de resumen automático (`/recap`). Activa por defecto. Poner a `0` para desactivar el resumen de sesión (v2.1.108) |
| `CLAUDE_CODE_DISABLE_MOUSE_CLICKS` | `1` | — | Desactiva la gestión de eventos de clic de ratón en la TUI (por ejemplo, el clic para rellenar comandos del autocompletado). Útil en terminales o multiplexores donde el reporting de ratón interfiere con otras herramientas (v2.1.195) |
| `CLAUDE_CLIENT_PRESENCE_FILE` | path | — | Ruta a un fichero que Claude Code actualiza periódicamente como señal de "presencia" del cliente, usado por integraciones externas (por ejemplo Remote Control) para saber si una sesión local sigue viva (v2.1.181) |

---

## Plugins

| Variable | Valores | Defecto | Descripción |
|----------|---------|---------|-------------|
| `CLAUDE_CODE_PLUGIN_SEED_DIR` | path(s) | — | Directorio(s) adicionales donde buscar plugins locales. Soporta múltiples directorios separados por `:` en Linux/macOS o `;` en Windows. Útil para equipos que mantienen plugins en un directorio compartido fuera del proyecto (v2.1.79+) |
| `CLAUDE_CODE_PLUGIN_KEEP_MARKETPLACE_ON_FAILURE` | `1` | — | Mantiene la cache local del marketplace cuando `git pull` falla. Útil en entornos con conectividad intermitente o que operan offline frecuentemente (v2.1.90) |
| `CLAUDE_CODE_PLUGIN_PREFER_HTTPS` | `1` | — | Fuerza el uso de HTTPS en lugar de SSH al clonar o actualizar marketplaces de plugins basados en git. Útil en redes corporativas que bloquean el protocolo SSH (v2.1.141) |

---

## Modo seguro y troubleshooting

| Variable | Valores | Defecto | Descripción |
|----------|---------|---------|-------------|
| `CLAUDE_CODE_SAFE_MODE` | `1` | — | Equivalente por variable de entorno del flag `--safe-mode`: arranca con CLAUDE.md, plugins, skills, hooks y servidores MCP deshabilitados. Útil para aislar si un problema viene de la configuración del proyecto/usuario o del propio Claude Code (v2.1.169) |

---

## Backends cloud

| Variable | Valores | Defecto | Descripción |
|----------|---------|---------|-------------|
| `CLAUDE_CODE_USE_MANTLE` | `1` | — | Habilita Amazon Bedrock powered by Mantle como backend de inferencia. Requiere configuración Bedrock activa (v2.1.94) |
| `CLAUDE_CODE_PERFORCE_MODE` | `1` | — | Modo de integración con Perforce: las herramientas Edit, Write y NotebookEdit fallan en ficheros read-only con un hint sugiriendo ejecutar `p4 edit` primero. Útil para equipos que usan Perforce como VCS (v2.1.98) |
| `CLAUDE_CODE_CERT_STORE` | `bundled` | sistema operativo | Fuente de certificados TLS. Por defecto (desde v2.1.101) usa el certificate store del sistema operativo, lo que permite funcionar con proxies TLS empresariales sin configuración adicional. Establecer a `bundled` para revertir al comportamiento anterior (solo certificados incluidos en Node.js) |

---

## Actualizaciones

| Variable | Valores | Defecto | Descripción |
|----------|---------|---------|-------------|
| `DISABLE_UPDATES` | `1` | — | Bloquea **todas** las vías de actualización automática, incluido el comando manual `claude update`. Útil en entornos enterprise donde la versión debe gestionarse de forma centralizada |

---

## Integración con herramientas externas

| Variable | Valores | Defecto | Descripción |
|----------|---------|---------|-------------|
| `AI_AGENT` | `1` (auto) | — | Inyectada automáticamente en subprocesos lanzados por Claude Code para que herramientas como `gh` y otras puedan atribuir el tráfico a Claude Code. No es necesario definirla manualmente |

---

## Proveedor: Amazon Bedrock (tier de servicio)

| Variable | Valores | Defecto | Descripción |
|----------|---------|---------|-------------|
| `ANTHROPIC_BEDROCK_SERVICE_TIER` | `default` / `flex` / `priority` | `default` | Selecciona el tier de servicio para inferencia en Amazon Bedrock. `flex` para capacidad bajo demanda con posibles delays; `priority` para acceso prioritario con mayor disponibilidad |

---

## Subagentes fork

| Variable | Valores | Defecto | Descripción |
|----------|---------|---------|-------------|
| `CLAUDE_CODE_FORK_SUBAGENT` | `1` | — | Habilita subagentes fork en builds externas (no-oficial). Desde v2.1.121, los subagentes fork funcionan tanto en sesiones interactivas como no-interactivas |

---

## Funcionalidades experimentales y control de features

| Variable | Valores | Defecto | Descripción |
|----------|---------|---------|-------------|
| `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS` | `1` | — | Habilita la funcionalidad experimental de Agent Teams |
| `ENABLE_TOOL_SEARCH` | `auto:N` | — | Activa Tool Search al N% del contexto. Ejemplo: `auto:5` activa la búsqueda cuando el contexto supera el 5% de uso |
| `CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS` | `1` | — | Desactiva el uso de betas experimentales de la API |
| `CLAUDE_CODE_SIMPLE` | `1` | — | Activa el modo simplificado de Claude Code |
| `CLAUDE_CODE_FORK_SUBAGENT` | `1` | — | Habilita los subagentes bifurcados en builds externas (no-oficiales) de Claude Code. Solo relevante para distribuciones custom; en la distribución oficial este comportamiento se controla internamente (v2.1.117) |
| `DISABLE_UPDATES` | `1` | — | Bloquea todas las rutas de actualización de Claude Code, incluyendo las actualizaciones automáticas y el comando `claude update` manual. Útil en entornos enterprise donde las actualizaciones se gestionan centralizadamente (v2.1.118) |

---

## Ejemplos de configuración por caso de uso

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
export CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1
claude
```

### Entorno enterprise con Bedrock, sin telemetría

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
export CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1
export BASH_DEFAULT_TIMEOUT_MS=60000
export MAX_THINKING_TOKENS=4000
claude -p "ejecuta los tests y reporta fallos" \
  --max-turns 5 \
  --max-budget-usd 1.00 \
  --output-format json
```

### Configuración en settings.json para compartir con el equipo

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

## Ver también

- [Flags de arranque](./referencia-cli-flags-arranque.md) — Muchas variables tienen equivalentes como flags CLI
- [estructura-carpeta-claude.md](./estructura-carpeta-claude.md) — Cómo configurar `settings.json` y variables por proyecto
- [github-actions-claude-code.md](./github-actions-claude-code.md) — Cómo usar variables de entorno en GitHub Actions
