# Modulo 10: Automatizacion y CI/CD con Claude Code

## Descripcion General

Este modulo cubre como integrar Claude Code en pipelines de automatizacion, sistemas de integracion continua (CI) y despliegue continuo (CD). Aprenderemos a usar Claude Code en modo no interactivo, a configurar GitHub Actions con la accion oficial `claude-code-action@v1`, a crear workflows avanzados (revision por rutas, tareas programadas, triaje de issues), y a crear scripts de automatizacion que potencien los flujos de trabajo de tu equipo.

**Tiempo estimado:** 2 horas 20 minutos

---

## Objetivos de Aprendizaje

Al completar este modulo, seras capaz de:

1. **Usar Claude Code en modo no interactivo** con el flag `-p` y pipes de Unix
2. **Configurar GitHub Actions** con `claude-code-action@v1` para revision automatica de PRs
3. **Usar la sintaxis v1.0 GA** con `claude_args`, `prompt` y skills del proyecto en CI
4. **Crear workflows avanzados**: revision por rutas criticas, tareas programadas con cron, triaje automatico de issues
10. **Programar tareas recurrentes** con `CronCreate`/`CronList`/`CronDelete` y el skill `/loop`
5. **Reutilizar skills** de `.claude/skills/` tanto en la terminal como en GitHub Actions
6. **Crear scripts de automatizacion** para tareas repetitivas de desarrollo
7. **Integrar Claude Code** en pipelines de CI/CD existentes (Jenkins, GitLab CI, etc.)
8. **Controlar costos y limites** con `--max-turns` y `--max-budget-usd`
9. **Generar salida estructurada** con `--output-format json` y `--json-schema`

---

## Estructura del Modulo

### Teoria

| Archivo | Tema | Duracion |
|---------|------|----------|
| [01-modo-no-interactivo.md](teoria/01-modo-no-interactivo.md) | Modo no interactivo y pipes Unix | 25 min |
| [02-github-actions.md](teoria/02-github-actions.md) | Integracion con GitHub Actions (v1.0 GA) | 25 min |
| [03-scripts-y-automatizacion.md](teoria/03-scripts-y-automatizacion.md) | Scripts y patrones de automatizacion | 20 min |
| [04-github-actions-avanzado.md](teoria/04-github-actions-avanzado.md) | Workflows avanzados: cron, rutas, triaje, multi-job | 20 min |
| [05-cron-y-tareas-programadas.md](teoria/05-cron-y-tareas-programadas.md) | CronCreate, /loop y scheduling externo | 20 min |

### Ejercicios Practicos

| Archivo | Ejercicio | Duracion |
|---------|-----------|----------|
| [01-scripts-automatizacion.md](ejercicios/01-scripts-automatizacion.md) | Crear scripts de automatizacion | 15 min |
| [02-github-action.md](ejercicios/02-github-action.md) | Configurar GitHub Action para PRs | 15 min |
| [03-workflows-avanzados.md](ejercicios/03-workflows-avanzados.md) | Workflows avanzados: skills en CI, seguridad por rutas, cron, triaje | 20 min |

### Workflows y Scripts de Ejemplo

| Archivo | Descripcion |
|---------|-------------|
| [review-pr.yml](workflows/review-pr.yml) | Workflow para revision de PRs con menciones `@claude` |
| [auto-fix.yml](workflows/auto-fix.yml) | Workflow para correccion automatica via `@claude fix:` |
| [security-review.yml](workflows/security-review.yml) | Workflow de revision de seguridad por rutas criticas |
| [daily-report.yml](workflows/daily-report.yml) | Workflow programado de reporte diario |
| [issue-triage.yml](workflows/issue-triage.yml) | Workflow de triaje automatico de issues |
| [script-review-codigo.sh](workflows/script-review-codigo.sh) | Script Bash para revision automatica de codigo |
| [script-release-notes.sh](workflows/script-release-notes.sh) | Script Bash para generar notas de version |

---

## Prerequisitos

- Haber completado los modulos 1 a 5 (especialmente el modulo 2 sobre CLI)
- Modulos 4 (CLAUDE.md) y 9 (skills) recomendados para la seccion avanzada
- Claude Code instalado y configurado con API key
- Familiaridad basica con:
  - Terminal / linea de comandos
  - Git y GitHub
  - Conceptos basicos de CI/CD
- (Opcional) Cuenta de GitHub con acceso a GitHub Actions

---

## Conceptos Clave

| Concepto | Descripcion |
|----------|-------------|
| **Modo no interactivo** | Ejecucion de Claude Code sin sesion interactiva, ideal para scripts y CI |
| **Flag `-p`** | Activa el modo "pipe" / no interactivo |
| **`claude-code-action@v1`** | Accion oficial de GitHub (version GA) para integrar Claude Code en workflows |
| **`/install-github-app`** | Comando de Claude Code para setup guiado de GitHub Actions (si está disponible) |
| **`prompt`** | Parametro de la accion para instrucciones o invocacion de skills (`/review`) |
| **`claude_args`** | Parametro unificado para pasar flags CLI (modelo, turnos, etc.) |
| **`--output-format`** | Controla el formato de salida: `text`, `json`, `stream-json` |
| **`--max-turns`** | Limita el numero de iteraciones del agente |
| **`--max-budget-usd`** | Establece un tope de gasto en dolares por ejecucion |
| **`--dangerously-skip-permissions`** | Omite confirmaciones de permisos (solo en entornos confiables) |
| **Revision por rutas** | Workflows que se activan solo cuando se modifican archivos especificos |
| **Skills en CI** | Reutilizar skills de `.claude/skills/` en workflows de GitHub Actions |
| **`CronCreate`** | Herramienta nativa para programar tareas recurrentes desde la sesion de Claude Code |
| **`/loop`** | Skill para ejecutar un comando periodicamente durante una sesion activa |

---

## Flujo de Trabajo Recomendado

```
1. Estudiar la teoria basica: modo no interactivo + GitHub Actions (50 min)
   |
2. Ejercicios 01 y 02: scripts basicos + workflow basico (30 min)
   |
3. Estudiar la teoria avanzada: workflows especializados (20 min)
   |
4. Ejercicio 03: workflows avanzados (20 min)
   |
5. Adaptar los workflows de ejemplo a tu proyecto real
```

---

## Notas para Equipos Poliglotas

Los ejemplos de este modulo incluyen scripts en Bash que funcionan en Linux y macOS. Para equipos que trabajan en Windows, se recomienda usar WSL2 o Git Bash. Los workflows de GitHub Actions son multiplataforma y funcionan independientemente del sistema operativo local.

Los scripts de automatizacion pueden adaptarse para analizar codigo en cualquier lenguaje de programacion: Python, TypeScript, Java, Go, Rust, etc. Claude Code detecta automaticamente el lenguaje del archivo que se le proporciona.

---

## Recursos Adicionales

- [Documentacion oficial - GitHub Actions con Claude Code](https://code.claude.com/docs/en/github-actions)
- [Repositorio claude-code-action en GitHub](https://github.com/anthropics/claude-code-action)
- [Ejemplos oficiales de workflows](https://github.com/anthropics/claude-code-action/tree/main/examples)
- [Guia de seguridad de claude-code-action](https://github.com/anthropics/claude-code-action/blob/main/docs/security.md)
- [GitHub Actions - Documentacion](https://docs.github.com/en/actions)
- [Claude Code Action en GitHub Marketplace](https://github.com/marketplace/actions/claude-code-action-official)
