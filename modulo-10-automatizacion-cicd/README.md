# Módulo 10: Automatización y CI/CD

## Descripción general

Este módulo cubre cómo integrar Claude Code en pipelines de automatización, sistemas de integración continua (CI) y despliegue continuo (CD). Aprenderemos a usar Claude Code en modo no interactivo, a configurar GitHub Actions con la acción oficial `claude-code-action@v1`, a crear workflows avanzados (revisión por rutas, tareas programadas y triaje de issues), a crear scripts de automatización que potencien los flujos de trabajo de tu equipo, a aprovechar los servicios cloud de Anthropic (Routines, Code Review managed service, integraciones Slack y web) para automatizar sin infraestructura propia, y a cerrar tareas largas de forma autónoma con `/goal` y gestionar el ciclo de vida de self-hosted runners.

**Tiempo estimado:** 3 horas y 40 minutos

---

## Objetivos de aprendizaje

Al completar este módulo, serás capaz de:

1. **Usar Claude Code en modo no interactivo** con el flag `-p` y pipes de Unix.
2. **Configurar GitHub Actions** con `claude-code-action@v1` para revisión automática de PRs.
3. **Usar la sintaxis v1.0 GA** con `claude_args`, `prompt` y skills del proyecto en CI.
4. **Crear workflows avanzados**: revisión por rutas críticas, tareas programadas con cron y triaje automático de issues.
5. **Programar tareas recurrentes** con `CronCreate` / `CronList` / `CronDelete` y el skill `/loop`.
6. **Reutilizar skills** de `.claude/skills/` tanto en la terminal como en GitHub Actions.
7. **Crear scripts de automatización** para tareas repetitivas de desarrollo, incluyendo `claude ultrareview` para revisiones exhaustivas en CI.
8. **Integrar Claude Code** en pipelines de CI/CD existentes (Jenkins, GitLab CI, etc.).
9. **Controlar costes y límites** con `--max-turns` y `--max-budget-usd`.
10. **Generar salida estructurada** con `--output-format json` y `--json-schema`.
11. **Crear y configurar Routines** cloud con triggers de schedule, API HTTP y GitHub events.
12. **Activar el Code Review managed service** y personalizar el comportamiento con `REVIEW.md`.
13. **Invocar Claude Code desde Slack** con `@Claude` y desde la interfaz web de claude.ai.
14. **Fijar condiciones de finalización con `/goal`** para que Claude complete tareas largas a través de múltiples turnos sin supervisión constante.
15. **Configurar el hook `post-session`** en self-hosted runners para preservar artefactos y logs antes de que se destruya el workspace efímero.

---

## Estructura del módulo

### Teoría

| Archivo | Tema | Duración |
|---------|------|----------|
| [01-modo-no-interactivo.md](teoria/01-modo-no-interactivo.md) | Modo no interactivo y pipes Unix | 25 min |
| [02-github-actions.md](teoria/02-github-actions.md) | Integración con GitHub Actions (v1.0 GA) | 25 min |
| [03-scripts-y-automatizacion.md](teoria/03-scripts-y-automatizacion.md) | Scripts y patrones de automatización | 20 min |
| [04-github-actions-avanzado.md](teoria/04-github-actions-avanzado.md) | Workflows avanzados: cron, rutas, triaje y multi-job | 20 min |
| [05-cron-y-tareas-programadas.md](teoria/05-cron-y-tareas-programadas.md) | `CronCreate`, `/loop` y scheduling externo | 20 min |
| [06-routines-cloud.md](teoria/06-routines-cloud.md) | Routines: automatización cloud sin sesión local | 20 min |
| [07-code-review-managed.md](teoria/07-code-review-managed.md) | Code Review managed service: revisión de PRs sin CI propio | 20 min |
| [08-integraciones-slack-y-web.md](teoria/08-integraciones-slack-y-web.md) | Claude Code en Slack y en la web | 20 min |
| [09-goal-y-self-hosted-runners.md](teoria/09-goal-y-self-hosted-runners.md) | `/goal`: cierre de tareas largas y hook `post-session` en self-hosted runners | 20 min |

### Ejercicios prácticos

| Archivo | Ejercicio | Duración |
|---------|-----------|----------|
| [01-scripts-automatizacion.md](ejercicios/01-scripts-automatizacion.md) | Crear scripts de automatización | 15 min |
| [02-github-action.md](ejercicios/02-github-action.md) | Configurar GitHub Action para PRs | 15 min |
| [03-workflows-avanzados.md](ejercicios/03-workflows-avanzados.md) | Workflows avanzados: skills en CI, seguridad por rutas, cron y triaje | 20 min |

### Workflows y scripts de ejemplo

| Archivo | Descripción |
|---------|-------------|
| [review-pr.yml](workflows/review-pr.yml) | Workflow para revisión de PRs con menciones `@claude` |
| [auto-fix.yml](workflows/auto-fix.yml) | Workflow para corrección automática vía `@claude fix:` |
| [security-review.yml](workflows/security-review.yml) | Workflow de revisión de seguridad por rutas críticas |
| [daily-report.yml](workflows/daily-report.yml) | Workflow programado de reporte diario |
| [issue-triage.yml](workflows/issue-triage.yml) | Workflow de triaje automático de issues |
| [script-review-codigo.sh](workflows/script-review-codigo.sh) | Script Bash para revisión automática de código |
| [script-release-notes.sh](workflows/script-release-notes.sh) | Script Bash para generar notas de versión |

---

## Prerrequisitos

- Haber completado los módulos 1 a 5 (especialmente el módulo 2 sobre CLI)
- Módulos 4 (`CLAUDE.md`) y 9 (skills) recomendados para la sección avanzada
- Claude Code instalado y configurado con API key
- Familiaridad básica con:
  - terminal o línea de comandos
  - Git y GitHub
  - conceptos básicos de CI/CD
- (Opcional) Cuenta de GitHub con acceso a GitHub Actions

---

## Conceptos clave

| Concepto | Descripción |
|----------|-------------|
| **Modo no interactivo** | Ejecución de Claude Code sin sesión interactiva, ideal para scripts y CI |
| **Flag `-p`** | Activa el modo "pipe" o no interactivo |
| **`claude-code-action@v1`** | Acción oficial de GitHub (versión GA) para integrar Claude Code en workflows |
| **`/install-github-app`** | Comando de Claude Code para setup guiado de GitHub Actions (si está disponible) |
| **`prompt`** | Parámetro de la acción para instrucciones o invocación de skills (`/review`) |
| **`claude_args`** | Parámetro unificado para pasar flags CLI (modelo, turnos, etc.) |
| **`--output-format`** | Controla el formato de salida: `text`, `json`, `stream-json` |
| **`--max-turns`** | Limita el número de iteraciones del agente |
| **`--max-budget-usd`** | Establece un tope de gasto en dólares por ejecución |
| **`--dangerously-skip-permissions`** | Omite confirmaciones de permisos (solo en entornos confiables) |
| **Revisión por rutas** | Workflows que se activan solo cuando se modifican archivos específicos |
| **Skills en CI** | Reutilizar skills de `.claude/skills/` en workflows de GitHub Actions |
| **`CronCreate`** | Herramienta nativa para programar tareas recurrentes desde la sesión de Claude Code |
| **`/loop`** | Skill para ejecutar un comando periódicamente durante una sesión activa |
| **`claude ultrareview`** | Subcomando CLI (v2.1.120+) para ejecutar `/ultrareview` de forma no-interactiva en CI/scripts |
| **Routines** | Sistema de automatización cloud de Anthropic: tareas programadas sin sesión local activa |
| **API trigger** | Endpoint HTTP `/fire` de una Routine para dispararla desde scripts externos |
| **GitHub events trigger** | Trigger de Routine que reacciona a eventos de PR, release o issue en GitHub |
| **Code Review managed** | Servicio gestionado de revisión de PRs activado con `@claude review`; solo planes Team/Enterprise |
| **`REVIEW.md`** | Fichero en la raíz del repo que personaliza el foco y el idioma del managed service |
| **Findings** | Hallazgos del managed service: `Important`, `Nit` y `Pre-existing` |
| **`@Claude` en Slack** | Integración que permite invocar Claude Code desde un canal de Slack |
| **`/goal`** | Fija una condición de finalización que Claude verifica tras cada turno con un modelo clasificador rápido; sigue trabajando hasta cumplirla |
| **Self-hosted runner** | Proceso que ejecuta sesiones de Claude Code en infraestructura propia dentro de workspaces efímeros |
| **Hook `post-session`** | Hook de ciclo de vida del self-hosted runner que se ejecuta tras terminar la sesión y antes de destruir el workspace |

---

## Flujo de trabajo recomendado

```text
1. Estudiar la teoría básica: modo no interactivo + GitHub Actions (50 min)
   |
2. Ejercicios 01 y 02: scripts básicos + workflow básico (30 min)
   |
3. Estudiar la teoría avanzada: workflows especializados + cron (40 min)
   |
4. Ejercicio 03: workflows avanzados (20 min)
   |
5. Estudiar servicios cloud: Routines, Code Review managed, Slack/web (60 min)
   |
6. Estudiar `/goal` y self-hosted runners (20 min)
   |
7. Adaptar los workflows de ejemplo a tu proyecto real
```

---

## Notas para equipos políglotas

Los ejemplos de este módulo incluyen scripts en Bash que funcionan en Linux y macOS. Para equipos que trabajan en Windows, se recomienda usar WSL2 o Git Bash. Los workflows de GitHub Actions son multiplataforma y funcionan independientemente del sistema operativo local.

Los scripts de automatización pueden adaptarse para analizar código en cualquier lenguaje de programación: Python, TypeScript, Java, Go, Rust, etc. Claude Code detecta automáticamente el lenguaje del archivo que se le proporciona.

---

## Recursos adicionales

- [Documentación oficial - GitHub Actions con Claude Code](https://code.claude.com/docs/en/github-actions)
- [Repositorio claude-code-action en GitHub](https://github.com/anthropics/claude-code-action)
- [Ejemplos oficiales de workflows](https://github.com/anthropics/claude-code-action/tree/main/examples)
- [Guía de seguridad de claude-code-action](https://github.com/anthropics/claude-code-action/blob/main/docs/security.md)
- [GitHub Actions - Documentación](https://docs.github.com/en/actions)
- [Claude Code Action en GitHub Marketplace](https://github.com/marketplace/actions/claude-code-action-official)

---

## Navegación

| Anterior | Siguiente |
|----------|-----------|
| [Módulo 09: Subagentes, Skills y Agent Teams](../modulo-09-agentes-skills-teams/README.md) | [Módulo 11: Enterprise y Seguridad](../modulo-11-enterprise-seguridad/README.md) |
