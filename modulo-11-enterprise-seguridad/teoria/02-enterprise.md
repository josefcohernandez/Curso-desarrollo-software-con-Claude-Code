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
| Vertex AI mTLS X.509 ADC | Autenticación con certificados en Vertex AI | Todos (v2.1.121) |
| `invocation_trigger` en OTEL `skill_activated` | Origen de la invocación de skills en trazas | Todos (v2.1.126) |
