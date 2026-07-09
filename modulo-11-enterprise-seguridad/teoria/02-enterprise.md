# Funcionalidades Enterprise de Claude Code

## Políticas gestionadas (Managed Policy)

Las políticas gestionadas permiten a los administradores de la organización definir configuraciones que **no pueden ser sobrescritas** por los usuarios individuales. Esto es esencial para garantizar cumplimiento y seguridad a nivel de toda la empresa.

### Ubicación del archivo de políticas

```
/etc/claude-code/managed-settings.json                    # Linux/WSL
/Library/Application Support/ClaudeCode/managed-settings.json  # macOS
C:\Program Files\ClaudeCode\managed-settings.json          # Windows
```

> **Importante**: Este archivo requiere permisos de administrador para ser creado o modificado. Los usuarios normales no pueden alterarlo.

### Estructura de la política gestionada

```json
{
  "permissions": {
    "allow": [
      "Read",
      "Glob",
      "Grep",
      "Bash(npm test)",
      "Bash(npm run build)",
      "Bash(npm run lint)",
      "Bash(git *)"
    ],
    "deny": [
      "Bash(rm -rf /)",
      "Bash(curl * | bash)",
      "Bash(wget * | bash)",
      "Bash(env)",
      "Bash(printenv)",
      "Bash(cat /etc/shadow)",
      "Bash(chmod 777 *)",
      "Bash(sudo *)"
    ]
  },
  "env": {
    "CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC": "1"
  },
  "sandbox": {
    "enabled": true
  },
  "model": "claude-sonnet-4-20250514"
}
```

### Qué se puede controlar con políticas gestionadas

| Aspecto | Descripción | Ejemplo |
|---------|-------------|---------|
| Permisos permitidos | Comandos y herramientas autorizados | `"allow": ["Bash(npm test)"]` |
| Permisos denegados | Comandos y herramientas bloqueados | `"deny": ["Bash(sudo *)"]` |
| Modelo por defecto | Modelo que usarán todos los usuarios | `"model": "claude-sonnet-4-20250514"` |
| Variables de entorno | Variables forzadas para todas las sesiones | `"env": {"SANDBOX": "1"}` |
| Servidores MCP | Servidores MCP obligatorios o bloqueados | Ver sección MCP gestionado |

### Herencia de políticas Windows en WSL: `wslInheritsWindowsSettings` (v2.1.118)

En entornos Windows con WSL (Windows Subsystem for Linux), los administradores de IT pueden mantener una **única fuente de verdad** para las políticas gestionadas usando la clave `wslInheritsWindowsSettings`:

```json
{
  "wslInheritsWindowsSettings": true
}
```

Cuando esta clave está activa en el `managed-settings.json` de Windows (`C:\Program Files\ClaudeCode\managed-settings.json`), Claude Code ejecutándose dentro de WSL hereda automáticamente esa configuración gestionada. El resultado es que la política definida en Windows se aplica también a todas las sesiones de Claude Code dentro de WSL, sin necesidad de mantener un fichero de políticas separado en `/etc/claude-code/managed-settings.json` dentro de la distribución WSL.

| Escenario | Sin `wslInheritsWindowsSettings` | Con `wslInheritsWindowsSettings` |
|-----------|--------------------------------|----------------------------------|
| Políticas en Windows | Se aplican solo a sesiones Windows | Se aplican también a sesiones WSL |
| Políticas en WSL (`/etc/claude-code/`) | Independientes de Windows | Complementarias (se fusionan) |
| Mantenimiento | Dos ficheros a sincronizar | Un único fichero fuente de verdad |

> **Caso de uso**: Organizaciones donde los desarrolladores usan Claude Code tanto desde PowerShell/Windows Terminal como desde distribuciones WSL (Ubuntu, Debian). Con esta clave, el equipo de IT despliega las políticas una sola vez en el lado Windows y se aplican de forma consistente en ambos entornos.

---

### Jerarquía de configuración

Las políticas gestionadas tienen la **máxima prioridad**:

```
Prioridad más alta
  |
  |  1. /etc/claude-code/managed-settings.json  (GESTIONADO - no modificable)
  |  2. Proyecto: .claude/settings.json
  |  3. Usuario: ~/.claude/settings.json
  |
Prioridad más baja
```

Si la política gestionada define una regla `deny`, **ningún otro nivel** puede sobrescribirla con un `allow`.

---

## CLAUDE.md gestionado

Similar a las políticas gestionadas, existe un CLAUDE.md a nivel de organización.

### Ubicación

```
/etc/claude-code/CLAUDE.md    # Linux/macOS
```

### Propósito

Contiene instrucciones que se aplican a **todos los usuarios** de la organización:

```markdown
# Políticas de la Organización

## Estándares de código
- Todo el código debe pasar linting antes de commit
- Los tests son obligatorios para cualquier nueva funcionalidad
- La cobertura mínima de tests es del 80%

## Seguridad
- NUNCA incluir credenciales en el código fuente
- Usar siempre consultas parametrizadas para bases de datos
- Todas las entradas de usuario deben ser validadas y sanitizadas

## Proceso
- Todo cambio requiere Pull Request con al menos una revisión
- Los commits deben seguir Conventional Commits (feat:, fix:, chore:, etc.)
- Documentar toda API pública

## Lenguajes y frameworks aprobados
- Backend: Python 3.11+, TypeScript 5+, Go 1.21+, Rust 1.75+
- Frontend: React 18+, Vue 3+
- Base de datos: PostgreSQL 15+, Redis 7+
- No usar frameworks o librerías no aprobados sin autorización
```

### Jerarquía de memoria con CLAUDE.md gestionado

```
Prioridad más alta
  |
  |  1. /etc/claude-code/CLAUDE.md    (GESTIONADO)
  |  2. Proyecto: CLAUDE.md
  |  3. Proyecto: CLAUDE.local.md
  |  4. Subdirectorios: */CLAUDE.md
  |  5. Usuario: ~/.claude/CLAUDE.md
  |
Prioridad más baja
```

---

## MCP gestionado

Los administradores pueden configurar servidores MCP de forma centralizada para toda la organización.

### Configuración centralizada de servidores MCP

```json
{
  "mcpServers": {
    "jira-corporativo": {
      "command": "mcp-server-jira",
      "args": ["--instance", "empresa.atlassian.net"],
      "env": {
        "JIRA_API_TOKEN": "${JIRA_API_TOKEN}"
      }
    },
    "base-datos-interna": {
      "command": "mcp-server-postgres",
      "args": ["--read-only"],
      "env": {
        "DATABASE_URL": "${INTERNAL_DB_URL}"
      }
    },
    "documentacion-interna": {
      "command": "mcp-server-confluence",
      "args": ["--space", "DEV"],
      "env": {
        "CONFLUENCE_TOKEN": "${CONFLUENCE_TOKEN}"
      }
    }
  }
}
```

### Autenticación OAuth 2.0

Para servidores MCP que requieren autenticación segura:

```json
{
  "mcpServers": {
    "api-interna": {
      "command": "mcp-server-api",
      "auth": {
        "type": "oauth2",
        "clientId": "claude-code-enterprise",
        "tokenUrl": "https://auth.empresa.com/oauth/token",
        "scopes": ["read:api", "write:api"]
      }
    }
  }
}
```

### Control de alcance (scope)

Limita qué pueden hacer los servidores MCP:

```json
{
  "mcpServers": {
    "database": {
      "command": "mcp-server-postgres",
      "args": ["--read-only"],
      "scope": {
        "allowedTools": ["query", "describe_table"],
        "deniedTools": ["execute", "drop_table", "truncate"]
      }
    }
  }
}
```

### Conectores cloud MCP de claude.ai: `allowAllClaudeAiMcps` (v2.1.149)

Además de los servidores MCP declarados explícitamente en `mcpServers`, claude.ai ofrece **conectores cloud MCP** preconfigurados (Google Drive, Jira, Notion, Linear, y otros) que el usuario puede activar desde su cuenta. Por defecto, en un despliegue enterprise con managed settings, estos conectores cloud no están disponibles: solo se cargan los servidores MCP definidos explícitamente en `managed-mcp.json`.

El managed setting `allowAllClaudeAiMcps` permite que los conectores cloud MCP configurados en la cuenta de claude.ai del usuario se carguen **junto con** los servidores definidos en `managed-mcp.json`, en lugar de sustituirlos:

```json
{
  "allowAllClaudeAiMcps": true
}
```

| Valor | Comportamiento |
|-------|---------------|
| `false` (por defecto en managed) | Solo se cargan los servidores MCP de `managed-mcp.json`; los conectores cloud de claude.ai se ignoran |
| `true` | Se cargan los servidores de `managed-mcp.json` **y** los conectores cloud MCP que el usuario tenga activados en claude.ai |

**Cuándo activarlo**: organizaciones donde los usuarios ya gestionan sus propias integraciones cloud (por ejemplo, cada desarrollador conecta su propio Google Drive o su propia cuenta de Jira) y el equipo de plataforma no quiere mantener una configuración centralizada para cada conector individual, pero sí quiere seguir imponiendo los servidores MCP corporativos obligatorios definidos en `managed-mcp.json`.

**Cuándo mantenerlo desactivado**: entornos regulados donde todo servidor MCP debe pasar por revisión y aprobación explícita del equipo de seguridad antes de estar disponible para cualquier sesión de Claude Code.

---

## Modelos por Defecto Organizacionales

Anthropic ha ampliado el control que los administradores tienen sobre qué modelos usan los miembros de la organización, tanto a nivel de valor por defecto como de restricción dura.

### Modelo por defecto de organización o de rol (v2.1.196)

Los administradores de organizaciones en planes Enterprise pueden fijar un **modelo por defecto** para los miembros que usan Claude Code, configurable desde la consola de administración de claude.ai:

- **A nivel de organización**: se aplica a todos los miembros que no tengan un modelo seleccionado manualmente.
- **A nivel de rol personalizado**: se aplica solo a los miembros de ese rol, y tiene prioridad sobre el valor de organización. Si un miembro pertenece a varios roles con valores por defecto distintos, se aplica el modelo más capaz de los configurados.

Cuando un administrador fija o cambia el modelo por defecto, este sustituye al modelo seleccionado actualmente en el picker de cada miembro para **nuevas conversaciones**. El desarrollador conserva la libertad de elegir otro modelo para cualquier conversación concreta: el valor de organización es un punto de partida, no una restricción dura (para restricciones duras, ver `enforceAvailableModels` a continuación).

En el comando `/model`, la fila del modelo por defecto muestra la etiqueta correspondiente según el origen de la configuración:

```text
$ /model

  Sonnet 4.6                    (seleccionado)
  Opus 4.8
> Default — Org default          <-- fijado por el administrador de la organización
  Haiku 4.5
```

Si el valor proviene de un rol específico en lugar de la organización completa, la etiqueta cambia a `Role default`.

### `enforceAvailableModels`: restricción dura sobre el modelo Default (v2.1.175)

La lista blanca `availableModels` en managed settings ya restringía qué modelos podían **seleccionarse manualmente** desde el picker o con `/model`. Sin embargo, antes de v2.1.175, el modelo `Default` (el que Claude Code usa si el usuario no ha elegido explícitamente ninguno) podía seguir resolviendo a un modelo fuera de esa lista, porque `Default` no pasaba por la comprobación de `availableModels`.

El managed setting `enforceAvailableModels` cierra esa brecha: cuando está activo, el modelo `Default` se resuelve **dentro** de `availableModels` en lugar de usar el valor por defecto interno de Claude Code.

```json
{
  "availableModels": ["claude-sonnet-4-6", "claude-haiku-4-5"],
  "enforceAvailableModels": true
}
```

| Configuración | Comportamiento de `Default` |
|----------------|------------------------------|
| `availableModels` sin `enforceAvailableModels` | `Default` sigue resolviendo al modelo interno de Claude Code, aunque no esté en la lista; la petición se rechaza en tiempo de ejecución si ese modelo no está autorizado |
| `availableModels` con `enforceAvailableModels: true` | `Default` resuelve a un modelo dentro de la lista `availableModels`, evitando el rechazo en tiempo de ejecución |

**Recomendación**: si defines `availableModels` en tu política gestionada, activa siempre `enforceAvailableModels` junto a ella. De lo contrario, los usuarios que no seleccionan modelo manualmente pueden encontrarse con peticiones rechazadas de forma intermitente sin entender por qué.

### Restricciones aplicadas de forma consistente en todas las superficies (v2.1.187)

Desde v2.1.187, las restricciones de modelo organizacionales (`availableModels`, `enforceAvailableModels`) se aplican de forma uniforme en **todas** las formas de seleccionar un modelo, cerrando vías que antes podían eludir la política:

| Superficie | Antes de v2.1.187 | Desde v2.1.187 |
|------------|--------------------|-----------------|
| Model picker interactivo (`/model`) | Filtrado por `availableModels` | Filtrado por `availableModels` |
| Flag `--model` en CLI | Podía forzar un modelo fuera de la lista | Rechazado si el modelo no está en `availableModels` |
| Comando `/model <nombre>` con argumento directo | Inconsistente según el punto de entrada | Rechazado si el modelo no está en `availableModels` |
| Variable de entorno `ANTHROPIC_MODEL` | Podía saltarse el filtrado del picker | Rechazado si el modelo no está en `availableModels` |

Esto es relevante para automatizaciones y scripts: un pipeline de CI que fije `ANTHROPIC_MODEL` a un modelo no autorizado por la política de la organización fallará explícitamente en lugar de ejecutarse con un modelo fuera de política. Para la configuración general de `/model` y selección de modelos, consulta el [Módulo 06](../../modulo-06-planificacion-opus/teoria/04-fast-mode-y-modelos.md).

---

## Claude Code Gateway: Proxy Centralizado Multi-Nube

> **Novedad**: soporte para el proveedor `anthropicAws` (v2.1.198)

Para organizaciones que necesitan un único punto de control sobre el acceso, el coste y las políticas de Claude Code sin depender de la consola de administración de claude.ai, Anthropic ofrece el **Claude Code Gateway**: un servicio autoalojado (self-hosted) que se sitúa entre los clientes de Claude Code de los desarrolladores y el proveedor de modelo elegido por la organización.

### Qué resuelve el Gateway

En lugar de que cada desarrollador gestione su propia API key o sus propias credenciales cloud, el Gateway centraliza:

- **Autenticación**: los desarrolladores inician sesión con el IdP corporativo (SSO vía OIDC); el Gateway es quien posee la credencial upstream real.
- **Control de acceso por grupo**: los grupos del IdP se mapean a listas de modelos permitidos y a políticas de managed settings, aplicadas del lado servidor.
- **Enrutado a múltiples proveedores**: el Gateway traduce las peticiones de los clientes al formato de cada proveedor upstream configurado, con failover entre ellos.
- **Telemetría centralizada**: exporta métricas OTLP a la plataforma de observabilidad de la organización (Datadog, Splunk, ClickHouse, etc.).

El Gateway se incluye en el propio binario `claude`, por lo que el mismo ejecutable que corre Claude Code en un portátil sirve el proceso del Gateway con `claude gateway --config gateway.yaml`.

### Proveedores upstream soportados

```yaml
# gateway.yaml (fragmento)
upstreams:
  - provider: bedrock
    region: us-east-1
  - provider: anthropicAws
    region: us-east-1
  - provider: anthropic
```

| Proveedor (`provider`) | Corresponde a |
|--------------------------|----------------|
| `bedrock` | Amazon Bedrock |
| `anthropicAws` | **Claude Platform on AWS** (v2.1.198) — acceso nativo a la plataforma de Anthropic a través de la cuenta AWS del cliente |
| `googleCloud` | Google Cloud Agent Platform / Vertex AI |
| `microsoftFoundry` | Microsoft Foundry |
| `anthropic` | API directa de Anthropic |

### `anthropicAws`: Claude Platform on AWS como upstream (v2.1.198)

A diferencia de Amazon Bedrock —donde AWS opera la infraestructura de inferencia— **Claude Platform on AWS** da acceso a la experiencia nativa de la plataforma de Anthropic (Messages API, Agent Skills, ejecución de código, features beta) directamente a través de la cuenta AWS de la organización, con Anthropic operando la infraestructura de inferencia. El Gateway mantiene la credencial de AWS y enruta las peticiones en nombre de los desarrolladores usando un rol IAM de tarea, sin que cada desarrollador necesite gestionar sus propias credenciales AWS.

Desde v2.1.198, los equipos que configuran el Gateway pueden referenciar `anthropicAws` como un upstream con nombre, sin tener que construir manualmente cadenas de endpoint compatibles con Bedrock. Esto simplifica la migración de organizaciones que ya usan Bedrock como upstream y quieren evaluar Claude Platform on AWS sin reescribir la configuración de enrutado del Gateway.

> **Requisito de versión**: el upstream `anthropicAws` requiere Claude Code v2.1.198 o superior en el servidor donde corre el Gateway.

### Cuándo usar el Gateway frente a Claude Enterprise

| Necesidad | Solución recomendada |
|-----------|------------------------|
| Requisitos de residencia de datos que exigen enrutar la inferencia por tu propia nube | Gateway (Bedrock, Claude Platform on AWS, Google Cloud, Microsoft Foundry) |
| SCIM provisioning, Claude Code en web/móvil, gestión centralizada sin infraestructura propia | Claude Enterprise (consola de administración de claude.ai) |
| Organizaciones que ya operan su propio LLM Gateway o API Gateway | Reutilizar esa infraestructura; Claude Code soporta gateways de terceros compatibles con el protocolo documentado por Anthropic |

El Gateway y las políticas gestionadas (`managed-settings.json` / `managed-settings.d/`) son complementarios: el Gateway aplica el control de acceso a modelos y entrega managed settings por grupo de IdP en el momento del login, mientras que las managed settings tradicionales siguen aplicándose localmente en la jerarquía de configuración del cliente.

---

## Backends de proveedores cloud

Para organizaciones que necesitan mantener los datos dentro de su propio entorno cloud, Claude Code soporta backends alternativos.

### AWS Bedrock

```bash
# Activar el backend de Bedrock
export CLAUDE_CODE_USE_BEDROCK=1

# Configurar credenciales de AWS (las habituales)
export AWS_REGION=eu-west-1
export AWS_ACCESS_KEY_ID=AKIA...
export AWS_SECRET_ACCESS_KEY=...

# O usar un perfil configurado
export AWS_PROFILE=mi-perfil-enterprise

# Opcionalmente, especificar el modelo
export ANTHROPIC_MODEL=us.anthropic.claude-sonnet-4-20250514-v1:0
```

Para organizaciones que usan Amazon Bedrock powered by Mantle, activar también:

```bash
export CLAUDE_CODE_USE_MANTLE=1
```

#### Tier de servicio de Bedrock: `ANTHROPIC_BEDROCK_SERVICE_TIER` (v2.1.122)

Las organizaciones con acuerdos de nivel de servicio en Amazon Bedrock pueden controlar el tier de servicio que se solicita en cada petición mediante la variable de entorno `ANTHROPIC_BEDROCK_SERVICE_TIER`. Su valor se envía como cabecera HTTP `X-Amzn-Bedrock-Service-Tier` en cada llamada a la API.

| Valor | Comportamiento |
|-------|---------------|
| `default` | Tier estándar de Bedrock (comportamiento por defecto si no se configura) |
| `flex` | Tier flexible, con mayor elasticidad en capacidad pero sin garantías de latencia |
| `priority` | Tier priority, reserva capacidad dedicada; disponible con acuerdos específicos de AWS |

```bash
# Tier estándar (equivale a no definir la variable)
export ANTHROPIC_BEDROCK_SERVICE_TIER=default

# Tier flexible
export ANTHROPIC_BEDROCK_SERVICE_TIER=flex

# Tier priority (requiere acuerdo de servicio priority con AWS)
export ANTHROPIC_BEDROCK_SERVICE_TIER=priority
```

> **Nota**: El tier `priority` solo tiene efecto si tu cuenta AWS tiene un acuerdo de servicio priority con Amazon Bedrock. Si se configura sin ese acuerdo, Bedrock ignorará la cabecera y usará el tier disponible.

**Ventajas de Bedrock**:
- Los datos no salen de tu cuenta de AWS
- Cumplimiento con políticas de residencia de datos (EU, APAC, etc.)
- Integración con IAM, CloudTrail, VPC
- Facturación unificada con AWS

### Google Vertex AI

```bash
# Activar el backend de Vertex AI
export CLAUDE_CODE_USE_VERTEX=1

# Configurar credenciales de GCP
export CLOUD_ML_REGION=europe-west1
export ANTHROPIC_VERTEX_PROJECT_ID=mi-proyecto-gcp

# Autenticación vía gcloud
gcloud auth application-default login

# Opcionalmente, especificar el modelo
export ANTHROPIC_MODEL=claude-sonnet-4@20250514
```

**Ventajas de Vertex AI**:
- Los datos permanecen en tu proyecto de GCP
- Integración con IAM de GCP, Cloud Audit Logs
- Soporte para VPC Service Controls
- Facturación unificada con GCP

### Asistente interactivo de configuración de Vertex AI (v2.1.98)

Desde v2.1.98, al seleccionar **"3rd-party platform"** en la pantalla de login de Claude Code, el asistente interactivo incluye soporte para Google Vertex AI con un flujo guiado que cubre:

1. **Autenticación GCP**: Verifica si existe una sesión activa de `gcloud` o guía la ejecución de `gcloud auth application-default login` para obtener credenciales de aplicación
2. **Selección de proyecto GCP**: Lista los proyectos GCP accesibles con la cuenta autenticada y permite seleccionar el destino de la inferencia
3. **Selección de región**: Muestra únicamente las regiones con modelos Claude disponibles (por ejemplo, `europe-west1`, `us-east4`) y permite elegir la más adecuada para requisitos de residencia de datos
4. **Verificación de credenciales y permisos**: Prueba la conexión con Vertex AI y confirma que la cuenta tiene los permisos IAM necesarios (`aiplatform.endpoints.predict`)

El asistente genera y exporta automáticamente las variables `CLOUD_ML_REGION` y `ANTHROPIC_VERTEX_PROJECT_ID` una vez completada la verificación, eliminando la configuración manual de entorno.

#### Autenticación con certificados X.509 via mTLS ADC en Vertex AI (v2.1.121)

Desde v2.1.121, Claude Code soporta autenticación mediante certificados X.509 via mTLS Application Default Credentials (ADC) cuando se usa el backend de Vertex AI. Este mecanismo es el estándar en entornos enterprise con infraestructura de certificados gestionada (PKI corporativa):

```bash
# Vertex AI con mTLS ADC: las credenciales se obtienen automáticamente
# del certificado X.509 configurado en el Application Default Credentials
export CLAUDE_CODE_USE_VERTEX=1
export CLOUD_ML_REGION=europe-west1
export ANTHROPIC_VERTEX_PROJECT_ID=mi-proyecto-gcp

# Las credenciales mTLS se gestionan a través de gcloud o del agente
# de certificados del sistema (workload certificate provider)
# No es necesario ejecutar gcloud auth application-default login
# si el entorno ya dispone de mTLS ADC configurado
```

**Cuándo es útil**: En organizaciones donde los equipos de seguridad gestionan una PKI interna y distribuyen certificados de cliente a las máquinas de los desarrolladores o a los nodos de CI/CD. En lugar de gestionar credenciales de usuario o service account keys, la autenticación se basa en el certificado de la máquina, lo que reduce la superficie de ataque y simplifica la rotación de credenciales.

> **Prerequisito**: Requiere que el entorno tenga configurado un proveedor de certificados de carga de trabajo (workload certificate provider) compatible con la especificación ADC de Google. Consulta la documentación de [Workload Identity Federation with X.509 certificates](https://cloud.google.com/iam/docs/workload-identity-federation-with-x509-certificates) para los detalles de configuración.

### Asistente interactivo de configuración de Bedrock (v2.1.92)

Desde v2.1.92, al seleccionar **"3rd-party platform"** en la pantalla de login de Claude Code, se inicia un asistente interactivo que guía paso a paso la configuración de AWS Bedrock:

1. **Autenticación AWS**: Verifica credenciales existentes o guía la configuración de `AWS_PROFILE`, access keys o SSO
2. **Selección de región**: Muestra las regiones con modelos Claude disponibles y permite seleccionar
3. **Verificación de credenciales**: Prueba la conexión con Bedrock y confirma que las credenciales tienen los permisos necesarios
4. **Model pinning**: Permite anclar versiones específicas de modelo para garantizar consistencia en el equipo

El asistente reduce significativamente la fricción de onboarding en organizaciones que usan Bedrock, eliminando la necesidad de configurar manualmente las variables de entorno.

### Comparativa de backends

| Aspecto | API directa | AWS Bedrock | Google Vertex AI |
|---------|-------------|-------------|-----------------|
| Residencia de datos | Servidores Anthropic (US) | Tu cuenta AWS | Tu proyecto GCP |
| Autenticación | API key de Anthropic | IAM de AWS | IAM de GCP |
| Facturación | Anthropic | AWS | GCP |
| Modelos disponibles | Todos | Selección | Selección |
| Latencia | Baja | Variable según región | Variable según región |
| Zero Data Retention | Disponible | Nativo | Nativo |
| Cumplimiento | SOC 2, HIPAA | SOC 2, HIPAA, FedRAMP, etc. | SOC 2, HIPAA, ISO 27001 |

---

## Integración SSO

Claude Code soporta Single Sign-On para organizaciones:

- **SAML 2.0**: Integración con Okta, Azure AD, OneLogin
- **OpenID Connect**: Proveedores compatibles con OIDC
- **Gestión centralizada**: Altas y bajas automáticas de usuarios
- **MFA**: Herencia de políticas de autenticación multifactor

---

## Audit logging

El registro de auditoría permite rastrear el uso de Claude Code en la organización:

```json
{
  "audit_log_entry": {
    "timestamp": "2025-01-15T10:30:00Z",
    "user": "dev@empresa.com",
    "action": "bash_execute",
    "command": "npm test",
    "project": "api-backend",
    "model": "claude-sonnet-4-20250514",
    "tokens_used": 15420,
    "duration_ms": 3200,
    "result": "success"
  }
}
```

Aspectos que se pueden auditar:
- Comandos ejecutados
- Archivos leídos y modificados
- Modelos utilizados
- Tokens consumidos
- Herramientas MCP invocadas
- Sesiones iniciadas y cerradas

> **Novedad v3.2 (v2.1.85):** Para incluir los parámetros de las herramientas en los eventos `tool_result` de OpenTelemetry, activa la variable `CLAUDE_CODE_OTEL_LOG_TOOL_DETAILS=1`. Por defecto estos datos no se incluyen para evitar exponer información sensible en los logs de observabilidad.

### Campos de trazabilidad en eventos OTEL (v2.1.117)

Desde v2.1.117, los eventos de OpenTelemetry incluyen campos adicionales que mejoran la trazabilidad de las sesiones:

**Campos `command_name` y `command_source` en eventos `user_prompt`**

Cuando un prompt se genera desde un slash command (por ejemplo, `/review` o un skill personalizado), el evento `user_prompt` incluye ahora los campos `command_name` y `command_source`. Esto permite saber exactamente qué slash command originó cada prompt, sin necesidad de parsear el contenido del propio prompt:

```json
{
  "event": "user_prompt",
  "command_name": "review",
  "command_source": "project",
  "tokens": 1240
}
```

**Atributo `effort` en eventos de coste y API**

El atributo `effort` (nivel de esfuerzo del modelo) se añade ahora a los eventos `cost.usage`, `token.usage`, `api_request` y `api_error`. Esto permite correlacionar el nivel de esfuerzo configurado con el coste real y el consumo de tokens, facilitando el análisis de la relación esfuerzo-coste en los dashboards de observabilidad.

```json
{
  "event": "cost.usage",
  "effort": "high",
  "input_tokens": 12500,
  "output_tokens": 3200,
  "cost_usd": 0.0487
}
```

---

### Variables OTEL ampliadas (v2.1.101)

Desde v2.1.101 están disponibles tres nuevas variables de tracing que ofrecen control granular sobre el nivel de detalle en las trazas OpenTelemetry:

| Variable | Efecto |
|----------|--------|
| `OTEL_LOG_USER_PROMPTS=1` | Incluye los prompts del usuario en las trazas OTEL. Útil para depuración, pero puede exponer información sensible; desactivar en producción salvo que sea necesario. |
| `OTEL_LOG_TOOL_DETAILS=1` | Incluye los parámetros de las herramientas invocadas. Reemplaza a `CLAUDE_CODE_OTEL_LOG_TOOL_DETAILS`, que queda deprecada. |
| `OTEL_LOG_TOOL_CONTENT=1` | Incluye el contenido completo de los resultados devueltos por las herramientas (salida de comandos, contenido de ficheros leídos, respuestas MCP). |

```bash
# Ejemplo: tracing completo para depuración en staging
export OTEL_LOG_USER_PROMPTS=1
export OTEL_LOG_TOOL_DETAILS=1
export OTEL_LOG_TOOL_CONTENT=1

# Ejemplo: solo detalles de herramientas en producción
export OTEL_LOG_TOOL_DETAILS=1
```

> **Nota de migración**: Si usabas `CLAUDE_CODE_OTEL_LOG_TOOL_DETAILS=1`, migra a `OTEL_LOG_TOOL_DETAILS=1`. Ambas variables funcionan en v2.1.101, pero la variante `CLAUDE_CODE_` quedará eliminada en versiones futuras.

### Evento OTEL `claude_code.skill_activated`: atributo `invocation_trigger` (v2.1.126)

El evento OpenTelemetry `claude_code.skill_activated`, que se emite cada vez que se activa un skill (comando personalizado), incluye desde v2.1.126 el atributo `invocation_trigger`. Este atributo permite distinguir cómo fue invocado el skill:

| Valor de `invocation_trigger` | Significado |
|-------------------------------|-------------|
| `"user-slash"` | El usuario invocó el skill escribiendo `/nombre` en la sesión interactiva |
| `"claude-proactive"` | Claude decidió invocar el skill de forma autónoma, sin instrucción directa del usuario |
| `"nested-skill"` | El skill fue invocado desde dentro de otro skill en ejecución |

**Utilidad en observabilidad enterprise**:

- **Diferenciar uso interactivo del uso agentivo**: Si la mayoría de invocaciones tienen `invocation_trigger=claude-proactive`, los skills están siendo usados en flujos autónomos, lo que ayuda a calibrar la confianza en esos flujos.
- **Detectar bucles de skills**: Un número elevado de eventos con `invocation_trigger=nested-skill` puede indicar recursión no intencionada entre skills.
- **Auditoría de autoría de acciones**: En entornos con auditoría estricta, es posible distinguir qué acciones fueron iniciadas por el usuario y cuáles fueron tomadas autónomamente por Claude.

```bash
# Ejemplo de evento OTEL con el nuevo atributo (pseudocódigo de traza):
# {
#   "name": "claude_code.skill_activated",
#   "attributes": {
#     "skill.name": "review-pr",
#     "invocation_trigger": "user-slash",
#     "session.id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890"
#   }
# }
```

Para recibir este atributo en tus trazas, asegúrate de tener OTEL configurado y activado. No requiere variables adicionales: el atributo se incluye automáticamente en el evento `claude_code.skill_activated` desde v2.1.126.

### Propagación de contexto W3C TraceContext (v2.1.98)

Cuando OTEL está activo, Claude Code inyecta automáticamente la variable de entorno `TRACEPARENT` (estándar W3C TraceContext) en todos los subprocesos Bash que lanza. Esto permite que los comandos ejecutados por Claude propaguen el contexto de traza al sistema de observabilidad sin configuración adicional:

```bash
# TRACEPARENT se inyecta automáticamente en subprocesos cuando OTEL está activo.
# Formato W3C: 00-<trace-id>-<parent-id>-<flags>
# Ejemplo:
# TRACEPARENT=00-4bf92f3577b34da6a3ce929d0e0e4736-00f067aa0ba902b7-01
```

Esta propagación garantiza que los comandos de shell, scripts de build y herramientas externas invocadas por Claude formen parte de la misma traza distribuida, facilitando la correlación end-to-end en plataformas como Jaeger, Zipkin o Datadog.

### Evento OTEL `claude_code.assistant_response`: texto redactado por defecto (v2.1.193)

El evento OpenTelemetry `claude_code.assistant_response` se emite cada vez que el modelo genera una respuesta. Desde v2.1.193, este evento incluye un campo con el **texto de la respuesta del modelo**, pero por defecto ese campo se envía **redactado** (vacío o sustituido por un marcador) para evitar exponer contenido potencialmente sensible en el backend de observabilidad.

Para incluir el texto real de las respuestas en las trazas OTEL, activa explícitamente:

```bash
export OTEL_LOG_ASSISTANT_RESPONSES=1
```

| Configuración | Contenido del campo de respuesta en `claude_code.assistant_response` |
|----------------|--------------------------------------------------------------------|
| Por defecto (sin la variable) | Redactado — el evento se emite, pero sin el texto de la respuesta |
| `OTEL_LOG_ASSISTANT_RESPONSES=1` | Texto completo de la respuesta del modelo incluido en el evento |

> **Precaución**: activar esta variable envía el contenido completo de las respuestas del modelo a tu backend de observabilidad. Úsala solo en entornos donde ese backend cumple los mismos requisitos de seguridad y retención que el resto del pipeline de datos sensibles, y evita activarla en producción salvo necesidad justificada de auditoría o depuración.

### Etiquetas de recurso en métricas: `OTEL_RESOURCE_ATTRIBUTES` (v2.1.161)

Desde v2.1.161, los pares clave-valor definidos en la variable estándar de OpenTelemetry `OTEL_RESOURCE_ATTRIBUTES` se incluyen como **labels en los datapoints de métricas** que Claude Code exporta, no solo como atributos de resource a nivel de proceso. Esto permite segmentar y filtrar métricas de coste, tokens y latencia por cualquier dimensión organizacional sin necesidad de un backend que procese atributos de resource por separado.

```bash
export OTEL_RESOURCE_ATTRIBUTES="team=platform,cost_center=eng-412,environment=staging"
```

Con esta configuración, cada datapoint de métrica (por ejemplo, `claude_code.token.usage` o `claude_code.cost.usage`) incluye las etiquetas `team`, `cost_center` y `environment`, lo que permite construir dashboards y alertas agrupados por equipo o centro de coste directamente desde las métricas, sin depender de joins adicionales con datos de resource.

### Atributos `workflow.run_id` y `workflow.name` en agentes de Dynamic Workflows (v2.1.202)

Los agentes lanzados por **Dynamic Workflows** —cubiertos en detalle en el [Módulo 16: Agentes en Segundo Plano y Workflows Dinámicos](../../modulo-16-agentes-background-workflows/README.md)— incluyen desde v2.1.202 los atributos `workflow.run_id` y `workflow.name` en su telemetría OTEL. Esto permite correlacionar los eventos de coste, tokens y herramientas de cada agente individual con la ejecución de workflow concreta que lo originó, algo especialmente útil cuando un mismo workflow dinámico lanza múltiples agentes en paralelo y es necesario atribuir el consumo de cada uno a su rama de ejecución.

```json
{
  "event": "cost.usage",
  "workflow.run_id": "wf-run-8f3a2c1e",
  "workflow.name": "migracion-esquema-api",
  "cost_usd": 0.34
}
```

### `CLAUDE_CODE_ENABLE_FEEDBACK_SURVEY_FOR_OTEL` (v2.1.136)

Claude Code puede mostrar ocasionalmente una encuesta breve de satisfacción al finalizar una sesión. En entornos con OTEL activo y sesiones automatizadas (CI/CD, self-hosted runners), estas encuestas interactivas no tienen sentido y pueden interferir con la ejecución no interactiva. La variable `CLAUDE_CODE_ENABLE_FEEDBACK_SURVEY_FOR_OTEL` controla si la encuesta se activa cuando OTEL está configurado:

```bash
# Desactivar explícitamente la encuesta de feedback en entornos con OTEL activo
export CLAUDE_CODE_ENABLE_FEEDBACK_SURVEY_FOR_OTEL=0
```

**Recomendación**: en pipelines de CI/CD, self-hosted runners y cualquier ejecución no interactiva con OTEL configurado, fija esta variable a `0` a nivel de managed settings o de entorno del runner para evitar prompts interactivos inesperados en procesos automatizados.

### Header de sesión en peticiones API

Claude Code incluye el header `X-Claude-Code-Session-Id` en todas las peticiones que realiza a la API. Este identificador de sesión es constante durante toda la sesión interactiva o de automatización, y cambia en cada nueva invocación de Claude Code.

**Utilidad para proxies enterprise (Bedrock, Vertex AI, Azure Foundry):**
- Agregar métricas de uso y coste por sesión sin necesidad de parsear el body de cada petición
- Implementar rate limiting a nivel de sesión en el proxy o API gateway
- Correlacionar trazas de observabilidad con sesiones concretas de un desarrollador o pipeline CI/CD
- Identificar sesiones de larga duración que consumen una cantidad desproporcionada de tokens

```
X-Claude-Code-Session-Id: a1b2c3d4-e5f6-7890-abcd-ef1234567890
```

> Este header es especialmente valioso en entornos donde varias peticiones independientes forman parte de un único flujo de trabajo agentivo: el header permite al proxy tratarlas como una unidad de observabilidad. *(Novedad v2.1.86)*

---

## Confianza en el certificate store del sistema operativo (v2.1.101)

Desde v2.1.101, Claude Code confía de forma predeterminada en el certificate store del sistema operativo, además de los certificados bundled de Node.js. Esto resuelve un problema habitual en entornos enterprise donde el tráfico HTTPS pasa por un proxy TLS corporativo firmado con una CA interna (no reconocida por las CAs públicas estándar).

**Antes de v2.1.101**, los equipos de seguridad debían distribuir manualmente el certificado de la CA corporativa y configurarlo en la variable `NODE_EXTRA_CA_CERTS`. Desde v2.1.101, si la CA corporativa está instalada en el store del sistema operativo (que es la práctica habitual de los departamentos de IT), Claude Code la reconoce automáticamente sin configuración adicional.

```bash
# Comportamiento por defecto desde v2.1.101:
# Claude Code confía en el OS CA store (incluye CAs corporativas instaladas por IT)

# Para revertir al comportamiento anterior (solo certificados bundled de Node.js):
export CLAUDE_CODE_CERT_STORE=bundled
```

| Valor de `CLAUDE_CODE_CERT_STORE` | Certificados de confianza |
|-----------------------------------|--------------------------|
| (no configurada) | OS CA store + certificados bundled |
| `bundled` | Solo certificados bundled de Node.js |
| `system` | Solo OS CA store |

> **Recomendación**: En entornos enterprise con proxies TLS corporativos, dejar la variable sin configurar (comportamiento por defecto) es la opción correcta. Solo establecer `CLAUDE_CODE_CERT_STORE=bundled` si existe un conflicto específico con CAs del sistema.

---

## Dimensionamiento y rate limiting por tamaño de equipo

### Recomendaciones por tamaño de equipo

| Tamaño del equipo | Tier recomendado | Rate limit aprox. | Tokens/min aprox. | Coste mensual estimado |
|-------------------|------------------|--------------------|--------------------|----------------------|
| 1-5 desarrolladores | Build | Compartido | 40K-80K | $50-200/dev |
| 5-15 desarrolladores | Scale | Dedicado | 80K-200K | $100-300/dev |
| 15-30 desarrolladores | Scale (límites altos) | Dedicado premium | 200K-500K | $200-400/dev |
| 30+ desarrolladores | Enterprise | Personalizado | Negociable | Contactar ventas |

### Configuración de rate limiting

Para distribuir los límites de forma equitativa en el equipo:

```json
{
  "rateLimiting": {
    "maxRequestsPerMinute": 10,
    "maxTokensPerMinute": 100000,
    "maxConcurrentSessions": 3,
    "priorityQueue": {
      "cicd": "high",
      "interactive": "medium",
      "batch": "low"
    }
  }
}
```

---

## Gestión de costes

### Presupuesto por sesión

```bash
# Limitar el gasto máximo por sesión a 5 dólares
claude --max-budget-usd 5

# En scripts de CI/CD, siempre usar presupuesto
claude -p "Run tests and fix failures" --max-budget-usd 2
```

### Alertas de presupuesto

Configura alertas para controlar el gasto del equipo:

```bash
# Verificar el gasto actual de la sesión
# (dentro de una sesión de Claude Code)
/cost
```

### Estrategias de optimización de costes

1. **Sonnet como modelo por defecto**: Usar Sonnet para tareas cotidianas

```json
{
  "model": "claude-sonnet-4-20250514"
}
```

2. **Opus bajo demanda**: Reservar Opus para tareas complejas

```bash
# Solo cuando sea necesario
/model claude-opus-4-20250514

# Volver a Sonnet después
/model claude-sonnet-4-20250514
```

3. **Limpiar contexto frecuentemente**: Reducir tokens acumulados

```bash
# Limpiar contexto cuando la conversación crece
/clear
```

4. **Presupuestos por desarrollador**: Asignar límites mensuales y monitorizar

---

## Consideraciones de cumplimiento normativo

### HIPAA (Health Insurance Portability and Accountability Act)

Para proyectos que manejan datos de salud:

- Usar Bedrock o Vertex AI con BAA (Business Associate Agreement) firmado
- Activar ZDR si se usa la API directa
- No incluir PHI (Protected Health Information) en CLAUDE.md
- Auditar todas las interacciones con datos de pacientes
- Configurar permisos para impedir acceso a archivos con datos de salud

### SOC 2

Para cumplimiento SOC 2:

- Anthropic tiene certificación SOC 2 Type II
- Implementar controles de acceso vía políticas gestionadas
- Activar audit logging
- Documentar procedimientos de uso de Claude Code
- Revisiones periódicas de configuración de seguridad

### GDPR (General Data Protection Regulation)

Para cumplimiento con GDPR (relevante para equipos europeos):

- Evaluar si los datos enviados contienen datos personales
- Utilizar Bedrock (eu-west-1) o Vertex AI (europe-west1) para residencia en la UE
- Documentar el procesamiento de datos en el registro de actividades
- Asegurar que los DPA (Data Processing Agreements) están firmados
- Implementar mecanismos de borrado si se procesan datos de interesados

### Ejemplo de configuración compliant

```json
{
  "permissions": {
    "deny": [
      "Bash(cat *patient*)",
      "Bash(cat *personal*)",
      "Bash(grep -r *@*.com *)"
    ]
  },
  "env": {
    "CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC": "1",
    "CLAUDE_CODE_USE_BEDROCK": "1"
  },
  "sandbox": {
    "enabled": true
  },
  "model": "claude-sonnet-4-20250514"
}
```

---

## Data Residency Controls

> **Novedad v3.0**

El parámetro `inference_geo` permite controlar en qué región geográfica se procesa la inferencia:

| Valor | Comportamiento |
|-------|---------------|
| `global` | Procesamiento en cualquier región disponible (por defecto) |
| `us-only` | Procesamiento exclusivamente en servidores de EE.UU. |

```json
{
  "inference_geo": "us-only"
}
```

Esto es complementario a los backends de Bedrock/Vertex AI. Mientras que Bedrock y Vertex ejecutan la inferencia dentro de tu propia cuenta cloud, `inference_geo` controla la ubicación cuando usas la API directa de Anthropic.

---

## Auto Mode en entornos enterprise

> **Novedad v3.0 (research preview)**

Auto Mode permite que Claude Code tome decisiones de permisos automáticamente usando un clasificador IA dual de seguridad (ver [Módulo 05](../../modulo-05-configuracion-permisos/teoria/05-auto-mode.md)).

**Consideraciones enterprise:**
- Los teammates en Agent Teams heredan Auto Mode del lead si está activado
- Las políticas gestionadas (`/etc/claude-code/managed-settings.json`) tienen prioridad sobre Auto Mode: si una política deniega una acción, Auto Mode no puede aprobarla
- Disponible primero en plan Team, desplegándose progresivamente a Enterprise
- Recomendado para entornos de desarrollo y staging, **no para producción** sin validación previa

---

## Resumen de funcionalidades enterprise

| Funcionalidad | Propósito | Disponible en |
|---------------|-----------|---------------|
| Políticas gestionadas | Control centralizado | Enterprise |
| CLAUDE.md gestionado | Instrucciones organizacionales | Enterprise |
| MCP gestionado | Servidores centralizados | Enterprise |
| AWS Bedrock | Residencia de datos AWS | API / Enterprise |
| Google Vertex AI | Residencia de datos GCP | API / Enterprise |
| SSO | Autenticación centralizada | Enterprise |
| Audit logging | Rastreo de uso | Enterprise |
| Rate limiting configurable | Control de capacidad | Scale / Enterprise |
| --max-budget-usd | Control de costes por sesión | Todos |
| ZDR | Cero retención de datos | API / Enterprise |
| Data residency (`inference_geo`) | Control de región de procesamiento | API / Enterprise |
| Auto Mode | Permisos automáticos con IA de seguridad | Team (research preview) |
| `managed-settings.d/` | Fragmentos de políticas drop-in | Enterprise |
| `X-Claude-Code-Session-Id` | Header de sesión para observabilidad en proxies | Todos (v2.1.86) |
| `forceRemoteSettingsRefresh` | Arranque fail-closed sin políticas frescas | Enterprise (v2.1.92) |
| Asistente Bedrock interactivo | Configuración guiada de AWS Bedrock | Todos (v2.1.92) |
| Asistente Vertex AI interactivo | Configuración guiada de Google Vertex AI | Todos (v2.1.98) |
| `CLAUDE_CODE_USE_MANTLE=1` | Soporte Bedrock powered by Mantle | Todos |
| `OTEL_LOG_USER_PROMPTS` | Incluye prompts en trazas OTEL | Todos (v2.1.101) |
| `OTEL_LOG_TOOL_DETAILS` | Incluye parámetros de herramientas en OTEL | Todos (v2.1.101) |
| `OTEL_LOG_TOOL_CONTENT` | Incluye resultados de herramientas en OTEL | Todos (v2.1.101) |
| `TRACEPARENT` W3C | Propagación de traza en subprocesos Bash | Todos (v2.1.98) |
| OS CA certificate store | Confianza automática en CAs corporativas | Todos (v2.1.101) |
| `CLAUDE_CODE_CERT_STORE=bundled` | Revertir a certificados bundled únicamente | Todos (v2.1.101) |
| `ANTHROPIC_BEDROCK_SERVICE_TIER` | Tier de servicio de Bedrock (`default`/`flex`/`priority`) | Todos (v2.1.122) |
| `wslInheritsWindowsSettings` | Herencia de managed settings de Windows en WSL | Enterprise (v2.1.118) |
| `command_name`/`command_source` en OTEL | Trazabilidad de slash commands en eventos `user_prompt` | Todos (v2.1.117) |
| Atributo `effort` en OTEL | Correlación esfuerzo-coste en eventos de uso y API | Todos (v2.1.117) |
| `blockedMarketplaces`/`strictKnownMarketplaces` | Bloqueo efectivo en operaciones de instalación de plugins | Enterprise (v2.1.117) |
| Vertex AI mTLS X.509 ADC | Autenticación con certificados en Vertex AI | Todos (v2.1.121) |
| `invocation_trigger` en OTEL `skill_activated` | Origen de la invocación de skills en trazas | Todos (v2.1.126) |
| `allowAllClaudeAiMcps` | Combina conectores cloud MCP de claude.ai con `managed-mcp.json` | Enterprise (v2.1.149) |
| Modelo por defecto de organización/rol | "Org default"/"Role default" en `/model` | Enterprise (v2.1.196) |
| `enforceAvailableModels` | El modelo Default también respeta la allowlist `availableModels` | Enterprise (v2.1.175) |
| Restricciones de modelo consistentes | `availableModels` aplicado en picker, `--model`, `/model` y `ANTHROPIC_MODEL` | Enterprise (v2.1.187) |
| Claude Code Gateway | Proxy autoalojado multi-nube con SSO y control de modelos por grupo | Enterprise |
| `anthropicAws` en Gateway | Claude Platform on AWS como upstream con nombre | Enterprise (v2.1.198) |
| `claude_code.assistant_response` | Evento OTEL con texto de respuesta redactado por defecto | Todos (v2.1.193) |
| `OTEL_LOG_ASSISTANT_RESPONSES` | Incluye el texto real de las respuestas en OTEL | Todos (v2.1.193) |
| `OTEL_RESOURCE_ATTRIBUTES` en métricas | Labels de resource en datapoints de métricas | Todos (v2.1.161) |
| `workflow.run_id`/`workflow.name` en OTEL | Trazabilidad de agentes de Dynamic Workflows | Todos (v2.1.202) |
| `CLAUDE_CODE_ENABLE_FEEDBACK_SURVEY_FOR_OTEL` | Controla la encuesta de feedback en entornos con OTEL | Todos (v2.1.136) |
| `sandbox.bwrapPath`/`sandbox.socatPath` | Rutas explícitas a binarios del sandbox en Linux | Todos (v2.1.133) |
| `pluginSuggestionMarketplaces` | Marketplaces cuyos plugins se sugieren vía tips | Enterprise (v2.1.152) |
