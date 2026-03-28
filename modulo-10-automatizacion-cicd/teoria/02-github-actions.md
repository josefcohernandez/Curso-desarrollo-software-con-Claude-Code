# 02 - Integración con GitHub Actions

## Introducción

GitHub Actions es la plataforma de CI/CD nativa de GitHub. Anthropic ofrece una acción oficial, `claude-code-action@v1`, que permite integrar Claude Code directamente en tus workflows de GitHub. Con esta integración puedes automatizar revisiones de código, responder a menciones en PRs, triagear issues y mucho más.

> **Nota sobre versiones:** Este capítulo cubre la versión **v1.0 GA** de `claude-code-action`. Si tienes workflows con la versión `@beta`, consulta la sección [Migración desde beta](#migración-desde-beta) al final de este documento.

---

## Setup Rápido

La forma más rápida de configurar GitHub Actions con Claude Code es:

1. Instala la [GitHub App de Claude](https://github.com/apps/claude) en tu repositorio
2. Configura el secreto `ANTHROPIC_API_KEY` en los settings del repositorio (Settings > Secrets and variables > Actions)
3. Crea el workflow YAML necesario (ver sección siguiente)

**Requisitos:** Debes ser administrador del repositorio.

---

## La Acción Oficial: `claude-code-action@v1`

### Qué es

`claude-code-action` es una acción de GitHub mantenida por Anthropic que ejecuta Claude Code dentro de un workflow de GitHub Actions. Proporciona:

- **Detección automática de modo**: Detecta si debe responder a menciones (`@claude`) o ejecutar un prompt directo
- Acceso automático al contexto del repositorio
- Integración nativa con PRs e issues
- Soporte para menciones `@claude` en comentarios
- Configuración vía `claude_args` (mismos flags que el CLI)
- Soporte para Bedrock y Vertex AI (entornos enterprise)
- Respeta la configuración de `.claude/` del proyecto (CLAUDE.md, skills, rules, agents)

### Casos de uso principales

1. **Revisión automática de PRs**: Claude revisa cada PR nueva y deja comentarios
2. **Corrección automática**: Cuando mencionas `@claude` con una instrucción, Claude hace cambios y los pushea
3. **Generación de descripciones de PR**: Claude genera automáticamente la descripción del PR basándose en los cambios
4. **Triaje de issues**: Claude clasifica y etiqueta issues automáticamente
5. **Respuestas a comentarios**: Claude responde preguntas técnicas directamente en PRs

---

## Configuración Básica

### Paso 1: Crear el secreto de API

En tu repositorio de GitHub, ve a **Settings** > **Secrets and variables** > **Actions**. En la sección **Secrets and variables > Actions**, pulsa **New repository secret**, establece el nombre `ANTHROPIC_API_KEY` y pega tu clave de API de Anthropic como valor.

### Paso 2: Crear el workflow

Crea el archivo `.github/workflows/claude-review.yml` en tu repositorio:

```yaml
name: Claude Code Review

on:
  # Se ejecuta cuando se abre o actualiza un PR
  pull_request:
    types: [opened, synchronize]
  # Se ejecuta cuando alguien comenta en un issue o PR
  issue_comment:
    types: [created]

jobs:
  review:
    # Solo ejecutar si es un PR nuevo/actualizado O si el comentario menciona @claude
    if: |
      github.event_name == 'pull_request' ||
      (github.event_name == 'issue_comment' &&
       contains(github.event.comment.body, '@claude'))
    runs-on: ubuntu-latest
    permissions:
      contents: read
      pull-requests: write
      issues: write
    steps:
      - uses: anthropics/claude-code-action@v1
        with:
          anthropic_api_key: ${{ secrets.ANTHROPIC_API_KEY }}
```

### Paso 3: Probar

1. Crea una rama nueva y haz un cambio
2. Abre un Pull Request
3. Claude dejará automáticamente un comentario con su revisión
4. En cualquier momento, comenta `@claude ¿Puedes mejorar el manejo de errores?` y Claude responderá

---

## Configuración Avanzada

### Parámetros de la acción v1.0

En la versión v1.0 GA, la configuración se simplifica. Los parámetros principales son:

| Parámetro | Descripción | Obligatorio |
|-----------|-------------|-------------|
| `anthropic_api_key` | API key de Anthropic | Sí* |
| `prompt` | Instrucciones para Claude (texto o skill como `/review`) | No |
| `claude_args` | Argumentos CLI pasados a Claude Code | No |
| `github_token` | Token de GitHub para acceso a la API | No |
| `trigger_phrase` | Frase de activación (por defecto: `@claude`) | No |
| `use_bedrock` | Usar AWS Bedrock | No |
| `use_vertex` | Usar Google Vertex AI | No |
| `settings` | Configuración JSON (equivalente a `settings.json`) | No |

*Obligatorio para API directa. No necesario con Bedrock/Vertex.

> **Importante:** En v1.0, parámetros como `model`, `max_turns` y `custom_instructions` se pasan a través de `claude_args`, no como parámetros directos de la acción.

### Selección de modelo

```yaml
- uses: anthropics/claude-code-action@v1
  with:
    anthropic_api_key: ${{ secrets.ANTHROPIC_API_KEY }}
    claude_args: "--model claude-sonnet-4-6"
```

Modelos disponibles:
- `claude-sonnet-4-6` - Rápido y económico, ideal para revisiones de código
- `claude-opus-4-6` - El más potente, para tareas complejas de razonamiento

### Instrucciones personalizadas

Hay dos formas de dar instrucciones a Claude en GitHub Actions:

**Opción 1: Usando `CLAUDE.md` del repositorio (recomendado)**

Claude respeta automáticamente el `CLAUDE.md` de tu repositorio. Simplemente crea o actualiza tu `CLAUDE.md` con las instrucciones de revisión:

```markdown
## Reglas para revisiones automáticas en CI
- Revisa seguridad, rendimiento y legibilidad
- Sé constructivo y específico en tus sugerencias
- Responde siempre en español
```

**Opción 2: Usando `--append-system-prompt` en `claude_args`**

```yaml
- uses: anthropics/claude-code-action@v1
  with:
    anthropic_api_key: ${{ secrets.ANTHROPIC_API_KEY }}
    claude_args: |
      --append-system-prompt "Eres un revisor de código senior. Responde en español. Enfócate en seguridad y rendimiento."
      --model claude-sonnet-4-6
```

### Usar skills del proyecto en workflows

Si tu proyecto tiene skills definidas en `.claude/skills/`, puedes invocarlas directamente:

```yaml
- uses: anthropics/claude-code-action@v1
  with:
    anthropic_api_key: ${{ secrets.ANTHROPIC_API_KEY }}
    prompt: "/review"  # Invoca la skill 'review' del proyecto
    claude_args: "--max-turns 5"
```

Esto permite mantener las instrucciones de revisión centralizadas en `.claude/skills/review/SKILL.md` y reutilizarlas tanto en la terminal como en CI.

### Control de costos

```yaml
- uses: anthropics/claude-code-action@v1
  with:
    anthropic_api_key: ${{ secrets.ANTHROPIC_API_KEY }}
    claude_args: "--max-turns 5 --model claude-sonnet-4-6"
```

### Filtrar por archivos modificados

Puedes ejecutar el workflow solo cuando se modifiquen ciertos tipos de archivos:

```yaml
on:
  pull_request:
    types: [opened, synchronize]
    paths:
      - 'src/**'
      - 'lib/**'
      - '*.ts'
      - '*.py'
      - '*.go'
      # Ignorar archivos de configuración
      - '!*.config.js'
      - '!*.json'
```

---

## Menciones `@claude` en PRs

Una de las funcionalidades más útiles es poder interactuar con Claude directamente en los comentarios de un PR.

### Cómo funciona

1. Alguien comenta en un PR mencionando `@claude`
2. El workflow detecta el comentario
3. Claude Code se ejecuta con el contexto del PR y el comentario
4. Claude responde directamente en el PR como un comentario

### Ejemplos de uso

```
@claude Revisa la seguridad de los cambios en auth.ts

@claude ¿Puedes sugerir tests para la nueva función processPayment?

@claude ¿Hay algún problema de rendimiento en este PR?

@claude Genera la documentación JSDoc para las funciones nuevas

@claude Explica qué hace el cambio en la línea 42 de utils.py
```

### Configurar trigger personalizado

Si prefieres un trigger diferente a `@claude`:

```yaml
jobs:
  review:
    if: |
      github.event_name == 'pull_request' ||
      (github.event_name == 'issue_comment' &&
       contains(github.event.comment.body, '/review'))
```

Ahora puedes usar `/review` en lugar de `@claude`:

```
/review Revisa la seguridad de este PR
```

---

## Soporte Enterprise: Bedrock y Vertex AI

Para equipos que usan Amazon Bedrock o Google Vertex AI en lugar de la API directa de Anthropic. La v1.0 recomienda **autenticación OIDC** (sin credenciales estáticas) para mayor seguridad.

### Amazon Bedrock (con OIDC - recomendado)

```yaml
permissions:
  contents: write
  pull-requests: write
  issues: write
  id-token: write  # Necesario para OIDC

steps:
  - uses: actions/checkout@v4

  # Autenticación OIDC (sin credenciales estáticas)
  - uses: aws-actions/configure-aws-credentials@v4
    with:
      role-to-assume: ${{ secrets.AWS_ROLE_TO_ASSUME }}
      aws-region: us-west-2

  - uses: anthropics/claude-code-action@v1
    with:
      use_bedrock: "true"
      claude_args: "--model us.anthropic.claude-sonnet-4-6-v1:0 --max-turns 10"
```

Configuración necesaria:
1. Habilitar Amazon Bedrock con acceso a modelos Claude
2. Configurar GitHub como OIDC Identity Provider en AWS
3. Crear un IAM Role con permisos de Bedrock que confíe en GitHub Actions
4. Guardar el ARN del rol como secreto `AWS_ROLE_TO_ASSUME`

> **Nota:** OIDC es más seguro que usar access keys estáticas porque las credenciales son temporales y se rotan automáticamente.

### Google Vertex AI (con Workload Identity Federation)

```yaml
permissions:
  contents: write
  pull-requests: write
  issues: write
  id-token: write  # Necesario para Workload Identity Federation

steps:
  - uses: actions/checkout@v4

  - uses: google-github-actions/auth@v2
    id: auth
    with:
      workload_identity_provider: ${{ secrets.GCP_WORKLOAD_IDENTITY_PROVIDER }}
      service_account: ${{ secrets.GCP_SERVICE_ACCOUNT }}

  - uses: anthropics/claude-code-action@v1
    with:
      use_vertex: "true"
      claude_args: "--model claude-sonnet-4@20250514 --max-turns 10"
    env:
      ANTHROPIC_VERTEX_PROJECT_ID: ${{ steps.auth.outputs.project_id }}
      CLOUD_ML_REGION: us-east5
```

Configuración necesaria:
1. Habilitar la API de Vertex AI en tu proyecto GCP
2. Configurar Workload Identity Federation para GitHub Actions
3. Crear una cuenta de servicio con permisos de Vertex AI
4. Guardar los valores como secretos en el repositorio

---

## Patrones Avanzados

### Revisión condicional por etiquetas

```yaml
jobs:
  review:
    # Solo revisar si el PR tiene la etiqueta "needs-review"
    if: contains(github.event.pull_request.labels.*.name, 'needs-review')
    runs-on: ubuntu-latest
    permissions:
      contents: read
      pull-requests: write
    steps:
      - uses: anthropics/claude-code-action@v1
        with:
          anthropic_api_key: ${{ secrets.ANTHROPIC_API_KEY }}
          prompt: |
            Este PR ha sido marcado para revisión.
            Realiza una revisión exhaustiva.
```

### Revisión diferente según el tipo de cambio

```yaml
name: Claude Specialized Review

on:
  pull_request:
    types: [opened, synchronize]

jobs:
  security-review:
    if: contains(github.event.pull_request.title, '[security]')
    runs-on: ubuntu-latest
    permissions:
      contents: read
      pull-requests: write
    steps:
      - uses: anthropics/claude-code-action@v1
        with:
          anthropic_api_key: ${{ secrets.ANTHROPIC_API_KEY }}
          prompt: |
            Enfócate EXCLUSIVAMENTE en seguridad:
            - OWASP Top 10
            - Validación de inputs
            - Autenticación y autorización
            - Manejo de secrets
            - Inyección SQL/XSS/CSRF

  performance-review:
    if: contains(github.event.pull_request.title, '[perf]')
    runs-on: ubuntu-latest
    permissions:
      contents: read
      pull-requests: write
    steps:
      - uses: anthropics/claude-code-action@v1
        with:
          anthropic_api_key: ${{ secrets.ANTHROPIC_API_KEY }}
          prompt: |
            Enfócate EXCLUSIVAMENTE en rendimiento:
            - Complejidad algorítmica (Big O)
            - Uso de memoria
            - Consultas N+1 a base de datos
            - Renderizados innecesarios (si es frontend)
            - Oportunidades de caching
```

### Auto-triaje de issues

```yaml
name: Claude Issue Triage

on:
  issues:
    types: [opened]

jobs:
  triage:
    runs-on: ubuntu-latest
    permissions:
      issues: write
    steps:
      - uses: anthropics/claude-code-action@v1
        with:
          anthropic_api_key: ${{ secrets.ANTHROPIC_API_KEY }}
          prompt: |
            Analiza este issue y:
            1. Clasifica su tipo: bug, feature, question, documentation
            2. Estima su prioridad: critical, high, medium, low
            3. Sugiere a qué área del código se refiere
            4. Si es un bug, intenta sugerir una posible causa
            Responde con etiquetas sugeridas y un breve análisis.
```

---

## Control de Costos y Buenas Prácticas

### Estimación de costos

| Acción | Modelo Sonnet | Modelo Opus |
|--------|--------------|-------------|
| Revisión de PR pequeño | ~$0.02-0.05 | ~$0.10-0.25 |
| Revisión de PR grande | ~$0.10-0.30 | ~$0.50-1.50 |
| Respuesta a mención | ~$0.01-0.05 | ~$0.05-0.20 |
| Triaje de issue | ~$0.01-0.03 | ~$0.05-0.15 |

### Recomendaciones para controlar costos

1. **Usa Sonnet para revisiones rutinarias** - Es suficiente para la mayoría de revisiones
2. **Limita `max_turns`** - 3-5 turnos son suficientes para la mayoría de tareas
3. **Filtra por rutas** - No revises archivos generados o de configuración
4. **Usa etiquetas** - Solo revisa PRs que lo necesiten
5. **Monitorea el uso** - Revisa los logs de GitHub Actions para ver costos

### Seguridad

- **Nunca** pongas la API key directamente en el archivo YAML
- Usa **siempre** secretos de GitHub (`${{ secrets.ANTHROPIC_API_KEY }}`)
- Configura permisos **mínimos** necesarios en el workflow
- En repos públicos, ten cuidado con workflows que se ejecutan en forks
- Revisa los **permisos** que le otorgas al workflow (`contents`, `pull-requests`, `issues`)

---

## Depuración

### Ver logs del workflow

En la pestaña **Actions** de tu repositorio, selecciona la ejecución del workflow que quieras inspeccionar y expande el paso de `claude-code-action` para ver los logs detallados.

### Problemas comunes

| Problema | Solución |
|----------|----------|
| "API key not found" | Verifica que el secreto `ANTHROPIC_API_KEY` está configurado |
| Claude no responde a `@claude` | Verifica que el trigger `issue_comment` está configurado |
| Permisos insuficientes | Añade los permisos necesarios en la sección `permissions` |
| Timeout en la ejecución | Reduce `max_turns` o usa un modelo más rápido |
| Costos elevados | Filtra por archivos, limita turnos, usa Sonnet |

---

## Relación con la configuración `.claude/` del proyecto

Claude Code GitHub Actions **respeta automáticamente** la configuración local del proyecto:

| Fichero/Directorio | Efecto en GitHub Actions |
|---------------------|--------------------------|
| `CLAUDE.md` | Claude sigue las convenciones y reglas definidas |
| `.claude/settings.json` | Permisos y hooks se aplican |
| `.claude/skills/` | Las skills son invocables vía `prompt: "/nombre-skill"` |
| `.claude/agents/` | Los subagentes están disponibles |
| `.claude/rules/` | Las reglas de comportamiento se cargan automáticamente |

Esto significa que puedes **centralizar** tus instrucciones de revisión en el repositorio y reutilizarlas tanto en la terminal como en CI, sin duplicar configuración en los workflows.

---

## Migración desde Beta

Si tienes workflows con `@beta`, estos son los cambios necesarios para migrar a `@v1`:

| Parámetro beta | Equivalente v1.0 |
|----------------|-------------------|
| `mode` | *(Eliminado - se autodetecta)* |
| `direct_prompt` | `prompt` |
| `override_prompt` | `prompt` con variables de GitHub |
| `custom_instructions` | `claude_args: --append-system-prompt` |
| `max_turns` | `claude_args: --max-turns` |
| `model` | `claude_args: --model` |
| `allowed_tools` | `claude_args: --allowedTools` |
| `disallowed_tools` | `claude_args: --disallowedTools` |
| `claude_env` | `settings` (formato JSON) |

**Ejemplo de migración:**

```yaml
# ANTES (beta)
- uses: anthropics/claude-code-action@beta
  with:
    mode: "tag"
    direct_prompt: "Revisa este PR"
    anthropic_api_key: ${{ secrets.ANTHROPIC_API_KEY }}
    custom_instructions: "Responde en español"
    max_turns: "10"
    model: "claude-sonnet-4-6"

# DESPUÉS (v1.0 GA)
- uses: anthropics/claude-code-action@v1
  with:
    prompt: "Revisa este PR"
    anthropic_api_key: ${{ secrets.ANTHROPIC_API_KEY }}
    claude_args: |
      --append-system-prompt "Responde en español"
      --max-turns 10
      --model claude-sonnet-4-6
```

---

## Resumen

| Concepto | Detalle |
|----------|---------|
| Acción oficial | `anthropics/claude-code-action@v1` |
| Setup rápido | Instalar GitHub App de Claude + configurar secreto + crear workflow |
| Secreto necesario | `ANTHROPIC_API_KEY` (API directa) |
| Triggers principales | `pull_request`, `issue_comment`, `issues`, `schedule` |
| Menciones | `@claude` en comentarios de PRs e issues |
| Skills en CI | `prompt: "/nombre-skill"` |
| Configuración CLI | Todo vía `claude_args` (mismos flags que el CLI) |
| Enterprise | Bedrock (`use_bedrock`) y Vertex AI (`use_vertex`) con OIDC |
| Control de costos | `--max-turns`, `--max-budget-usd`, filtro por rutas |
| Config del proyecto | Respeta `CLAUDE.md`, `.claude/settings.json`, skills, rules, agents |

La integración con GitHub Actions transforma a Claude en un miembro más de tu equipo, disponible 24/7 para revisar código, responder preguntas y mantener la calidad del proyecto.
