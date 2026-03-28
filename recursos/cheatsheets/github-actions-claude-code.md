# GitHub Actions con Claude Code - Referencia Rapida

> Guia de referencia para integrar Claude Code en workflows de GitHub Actions usando la accion oficial `anthropics/claude-code-action@v1`.

---

## Setup rapido

La forma mas sencilla es desde la terminal de Claude Code:

```
/install-github-app
```

Esto guía la configuración de la GitHub App y los secretos necesarios. Si el comando no está disponible en tu versión, sigue el setup manual.

### Setup manual

1. **Instalar la GitHub App** de Claude: [github.com/apps/claude](https://github.com/apps/claude)
2. **Agregar secreto** `ANTHROPIC_API_KEY` en Settings > Secrets > Actions del repositorio
3. **Copiar un workflow** YAML en `.github/workflows/`

---

## Workflow basico: responder a `@claude`

```yaml
# .github/workflows/claude.yml
name: Claude Code

on:
  issue_comment:
    types: [created]
  pull_request_review_comment:
    types: [created]
  issues:
    types: [opened, assigned]

permissions:
  contents: write
  pull-requests: write
  issues: write

jobs:
  claude:
    if: |
      contains(github.event.comment.body, '@claude') ||
      (github.event_name == 'issues' && contains(github.event.issue.body, '@claude'))
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: anthropics/claude-code-action@v1
        with:
          anthropic_api_key: ${{ secrets.ANTHROPIC_API_KEY }}
```

**Uso:** Escribe `@claude <instruccion>` en cualquier issue o comentario de PR.

---

## Workflow: revision automatica de PRs

```yaml
# .github/workflows/claude-review.yml
name: Claude Code Review

on:
  pull_request:
    types: [opened, synchronize]

permissions:
  contents: read
  pull-requests: write

jobs:
  review:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: anthropics/claude-code-action@v1
        with:
          anthropic_api_key: ${{ secrets.ANTHROPIC_API_KEY }}
          prompt: "/review"
          claude_args: "--max-turns 5"
```

---

## Workflow: reporte programado

```yaml
# .github/workflows/claude-daily-report.yml
name: Daily Report

on:
  schedule:
    - cron: "0 9 * * 1-5"  # Lunes a viernes a las 9:00 UTC

jobs:
  report:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: anthropics/claude-code-action@v1
        with:
          anthropic_api_key: ${{ secrets.ANTHROPIC_API_KEY }}
          prompt: "Genera un resumen de los commits de ayer y los issues abiertos"
          claude_args: "--model claude-sonnet-4-5-20250929 --max-turns 5"
```

---

## Workflow: revision de seguridad en rutas criticas

```yaml
# .github/workflows/claude-security.yml
name: Security Review

on:
  pull_request:
    paths:
      - 'src/auth/**'
      - 'src/api/**'
      - '*.config.*'

permissions:
  contents: read
  pull-requests: write

jobs:
  security-review:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: anthropics/claude-code-action@v1
        with:
          anthropic_api_key: ${{ secrets.ANTHROPIC_API_KEY }}
          prompt: |
            Revisa este PR enfocandote en seguridad:
            - Vulnerabilidades OWASP Top 10
            - Secretos o credenciales expuestas
            - Inyeccion SQL o XSS
            - Validacion de inputs
            - Autenticacion y autorizacion
          claude_args: "--max-turns 10"
```

---

## Parametros de la accion

| Parametro | Descripcion | Obligatorio |
|-----------|-------------|-------------|
| `anthropic_api_key` | API key de Anthropic | Si* |
| `prompt` | Instrucciones para Claude (texto o skill como `/review`) | No |
| `claude_args` | Argumentos CLI pasados a Claude Code | No |
| `github_token` | Token de GitHub para acceso a la API | No |
| `trigger_phrase` | Frase de activacion (por defecto: `@claude`) | No |
| `use_bedrock` | Usar AWS Bedrock en vez de API directa | No |
| `use_vertex` | Usar Google Vertex AI en vez de API directa | No |
| `settings` | Configuracion JSON (equivalente a `settings.json`) | No |

*Obligatorio para API directa. No necesario con Bedrock/Vertex.

---

## Argumentos CLI comunes (`claude_args`)

```yaml
claude_args: "--max-turns 10 --model claude-sonnet-4-5-20250929"
```

| Argumento | Descripcion |
|-----------|-------------|
| `--max-turns N` | Maximo de turnos de conversacion (defecto: 10) |
| `--model <modelo>` | Modelo a usar (ej: `claude-opus-4-6`, `claude-sonnet-4-5-20250929`) |
| `--max-budget-usd N` | Tope de gasto por ejecucion en dolares |
| `--append-system-prompt "texto"` | Instrucciones adicionales al system prompt |
| `--allowedTools "tool1,tool2"` | Herramientas permitidas |
| `--disallowedTools "tool1"` | Herramientas prohibidas |
| `--mcp-config /ruta/config.json` | Configuracion de servidores MCP |
| `--debug` | Activar salida de depuracion |

---

## Proveedores de autenticacion

### API directa de Anthropic

```yaml
- uses: anthropics/claude-code-action@v1
  with:
    anthropic_api_key: ${{ secrets.ANTHROPIC_API_KEY }}
```

### AWS Bedrock

```yaml
- uses: aws-actions/configure-aws-credentials@v4
  with:
    role-to-assume: ${{ secrets.AWS_ROLE_TO_ASSUME }}
    aws-region: us-west-2

- uses: anthropics/claude-code-action@v1
  with:
    use_bedrock: "true"
    claude_args: "--model us.anthropic.claude-sonnet-4-5-20250929-v1:0"
```

### Google Vertex AI

```yaml
- uses: google-github-actions/auth@v2
  id: auth
  with:
    workload_identity_provider: ${{ secrets.GCP_WORKLOAD_IDENTITY_PROVIDER }}
    service_account: ${{ secrets.GCP_SERVICE_ACCOUNT }}

- uses: anthropics/claude-code-action@v1
  with:
    use_vertex: "true"
    claude_args: "--model claude-sonnet-4@20250514"
  env:
    ANTHROPIC_VERTEX_PROJECT_ID: ${{ steps.auth.outputs.project_id }}
    CLOUD_ML_REGION: us-east5
```

---

## Que puede hacer Claude en un workflow

| Caso de uso | Trigger | Ejemplo |
|-------------|---------|---------|
| **Responder a @claude** | `issue_comment`, `pull_request_review_comment` | `@claude implementa esta feature` |
| **Revision de PRs** | `pull_request: [opened, synchronize]` | Revision automatica al abrir PR |
| **Implementar issues** | `issues: [opened, assigned]` | Asignar issue a Claude |
| **Reportes programados** | `schedule: cron` | Resumen diario de actividad |
| **Revision de seguridad** | `pull_request: paths` | Revisar cambios en rutas criticas |
| **Fix de CI** | `workflow_run: [completed]` | Corregir errores de CI automaticamente |
| **Triaje de issues** | `issues: [opened]` | Etiquetar y categorizar issues |
| **Sync de documentacion** | `push: paths` | Actualizar docs cuando cambia el codigo |

---

## Comandos utiles en issues/PRs

```
@claude implementa esta feature segun la descripcion del issue
@claude como deberia implementar autenticacion en este endpoint?
@claude arregla el TypeError en el componente del dashboard
@claude /review              # Usa la skill de review del proyecto
@claude /fix                 # Usa la skill de fix del proyecto
```

---

## Relacion con `.claude/` del proyecto

Claude Code GitHub Actions **respeta automaticamente** la configuracion de tu proyecto:

| Fichero | Efecto en GitHub Actions |
|---------|--------------------------|
| `CLAUDE.md` | Claude sigue las convenciones y reglas definidas |
| `.claude/settings.json` | Permisos y hooks se aplican |
| `.claude/skills/` | Las skills son invocables con `prompt: "/nombre-skill"` |
| `.claude/agents/` | Los agentes estan disponibles |
| `.claude/rules/` | Las reglas de comportamiento se cargan |

---

## Buenas practicas

1. **Usar GitHub Secrets** para las API keys - nunca hardcodear
2. **Limitar permisos** del workflow al minimo necesario
3. **Configurar `--max-turns`** para evitar ejecuciones sin fin
4. **Configurar `--max-budget-usd`** para controlar costes
5. **Usar `CLAUDE.md`** para que Claude siga los estandares del proyecto
6. **Revisar siempre** las sugerencias de Claude antes de hacer merge
7. **Activar por rutas** (`paths:`) para evitar ejecuciones innecesarias
8. **Usar concurrency controls** de GitHub para limitar ejecuciones paralelas

---

## Costes a considerar

- **GitHub Actions:** Consume minutos de tu plan de GitHub Actions
- **API de Claude:** Cada interaccion consume tokens segun la complejidad
- **Optimizacion:** Usar `--max-turns` bajo, triggers especificos por ruta, y `--max-budget-usd`

---

## Referencias

- [Documentacion oficial - GitHub Actions](https://code.claude.com/docs/en/github-actions)
- [Repositorio claude-code-action](https://github.com/anthropics/claude-code-action)
- [Ejemplos de workflows](https://github.com/anthropics/claude-code-action/tree/main/examples)
- [Guia de seguridad](https://github.com/anthropics/claude-code-action/blob/main/docs/security.md)
- [Marketplace de GitHub](https://github.com/marketplace/actions/claude-code-action-official)
