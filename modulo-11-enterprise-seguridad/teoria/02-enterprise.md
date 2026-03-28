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
    "DISABLE_NONESSENTIAL_TRAFFIC": "1",
    "CLAUDE_CODE_ENABLE_SANDBOX": "1"
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
  |  1. /etc/claude-code/settings.json  (GESTIONADO - no modificable)
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
    "DISABLE_NONESSENTIAL_TRAFFIC": "1",
    "CLAUDE_CODE_ENABLE_SANDBOX": "1",
    "CLAUDE_CODE_USE_BEDROCK": "1"
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
- Las políticas gestionadas (`/etc/claude-code/settings.json`) tienen prioridad sobre Auto Mode: si una política deniega una acción, Auto Mode no puede aprobarla
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
