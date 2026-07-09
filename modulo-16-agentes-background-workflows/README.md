# Módulo 16: Agentes en Segundo Plano y Workflows Dinámicos

## Monitorizar sesiones background y orquestar trabajo a gran escala

> **Tiempo estimado:** 2 horas
> **Nivel:** Experto (Bloque 4)
> **Prerrequisitos:** Módulos 02 (CLI), 08 (Hooks) y 09 (Subagentes, Skills y Agent Teams)

---

## Objetivos de aprendizaje

Al terminar este módulo serás capaz de:

- Usar `claude agents` (Agent View) para monitorizar todas las sesiones de Claude Code activas, incluidas las que corren en segundo plano
- Filtrar y automatizar la consulta de sesiones con `claude agents --json` y el campo `waitingFor`
- Lanzar y adjuntarte a sesiones background desde el propio dashboard, incluyendo comandos shell con `! <comando>`
- Configurar notificaciones (hook `Notification`) para saber cuándo un agente necesita input o ha terminado
- Distinguir cuándo un background agent hace commit/push/PR draft automáticamente y cómo controlar ese comportamiento con `worktree.bgIsolation`
- Pedir a Claude que cree un **Dynamic Workflow** (`ultracode`) para orquestar trabajo entre decenas o cientos de agentes en background
- Monitorizar y filtrar la ejecución de un workflow dinámico con `/workflows`
- Decidir cuándo orquestar un Dynamic Workflow tiene sentido y cuándo es sobre-ingeniería para la tarea

---

## Prerrequisitos

| Módulo | Por qué es necesario |
|--------|----------------------|
| [M02](../modulo-02-cli-primeros-pasos/README.md) | Comandos CLI, sesiones y `/resume`: base para entender `claude agents` |
| [M08](../modulo-08-hooks/README.md) | Hooks del ciclo de vida: necesarios para configurar notificaciones de agentes |
| [M09](../modulo-09-agentes-skills-teams/README.md) | Subagentes, background agents y worktree isolation: la mecánica que este módulo monitoriza y escala |

---

## Duración estimada

| Sección | Tiempo |
|---------|--------|
| Teoría (2 ficheros) | 70 min |
| Ejercicios prácticos | 50 min |
| **Total** | **2 horas** |

---

## Contenido

### Teoría

| Archivo | Tema | Duración |
|---------|------|----------|
| [01-agent-view.md](teoria/01-agent-view.md) | Dashboard `claude agents`, `--json`, flags de dispatch, sesiones pinned, notificaciones y PR automático | 40 min |
| [02-dynamic-workflows.md](teoria/02-dynamic-workflows.md) | Dynamic Workflows, `ultracode`, `/workflows`, tamaño configurable y cuándo usarlos | 30 min |

### Ejercicios prácticos

| Archivo | Tema | Duración |
|---------|------|----------|
| [01-monitorizar-agentes.md](ejercicios/01-monitorizar-agentes.md) | Lanzar y monitorizar 2-3 sesiones background simultáneas con `claude agents` | 25 min |
| [02-dynamic-workflow.md](ejercicios/02-dynamic-workflow.md) | Crear y monitorizar un Dynamic Workflow para una tarea de refactor a gran escala | 25 min |

---

## Conceptos clave

| Concepto | Descripción |
|----------|-------------|
| Agent View (`claude agents`) | Dashboard que lista todas las sesiones de Claude Code activas, incluidas las que corren en segundo plano |
| `claude agents --json` | Listado de sesiones en JSON para scripting y automatización |
| `waitingFor` | Campo del JSON que indica en qué está bloqueada una sesión (permiso, input del usuario, etc.) |
| `claude agents --cwd <path>` | Acota el listado de sesiones a un directorio concreto |
| Flags de dispatch | `--add-dir`, `--settings`, `--mcp-config`, `--plugin-dir`, `--permission-mode`, `--model`, `--effort`, `--dangerously-skip-permissions`: configuran cómo se lanza una nueva sesión desde el dashboard |
| `! <comando>` | Dentro de `claude agents`, ejecuta un comando de shell como una sesión background adjuntable |
| Sesión pinned | Sesión background que permanece viva mientras está idle y se reinicia in-place en actualizaciones de Claude Code |
| Notificación `agent_needs_input` / `agent_completed` | Payload del hook `Notification` que distingue si un agente espera input o ha terminado su trabajo |
| `worktree.bgIsolation: "none"` | Setting que hace que las sesiones background editen directamente el working copy en vez de un worktree aislado |
| Dynamic Workflow | Orquestación automática de decenas o cientos de agentes background para una tarea grande, creada a partir de una instrucción en lenguaje natural |
| `ultracode` | Palabra clave que dispara la creación de un Dynamic Workflow (antes llamada `workflow`) |
| `/workflows` | Comando para ver el estado y progreso de los runs de Dynamic Workflows |
| Dynamic workflow size | Setting en `/config` (`small`/`medium`/`large`) que controla cuántos agentes puede lanzar un workflow dinámico |

---

## Flujo de trabajo recomendado

```text
1. LANZAR trabajo en background
   "Lanza un agente en background para..." / claude --bg "..."
        |
        v
2. MONITORIZAR con Agent View
   claude agents  →  ver estado, waitingFor, adjuntarse si hace falta
        |
        v
3. CONFIGURAR notificaciones
   Hook Notification (agent_needs_input / agent_completed) → Slack, sonido, log
        |
        v
4. Si la tarea es GRANDE (decenas/cientos de sub-tareas independientes):
   Pedir a Claude que cree un Dynamic Workflow ("ultracode")
        |
        v
5. MONITORIZAR el workflow
   /workflows  →  progreso, filtrado por estado (f), agentes individuales
        |
        v
6. REVISAR resultados
   Background agents completan con commit/push/PR draft automático (en worktree)
        |
        v
7. Si la tarea es PEQUEÑA o secuencial:
   Usar subagentes normales (M09) en vez de un Dynamic Workflow
```

---

## Relación con otros módulos

Este módulo es la capa de **observabilidad y escalado** por encima de los mecanismos de agentes que ya conoces:

| Componente | Módulo donde se aprende | Cómo encaja aquí |
|------------|--------------------------|-------------------|
| Subagentes y background agents | [M09](../modulo-09-agentes-skills-teams/README.md) | Este módulo cubre el dashboard (`claude agents`) para monitorizarlos, no su mecánica interna |
| Worktree isolation | [M09](../modulo-09-agentes-skills-teams/README.md) | `worktree.bgIsolation` decide si el background agent aísla su trabajo o edita el working copy directamente |
| Hooks del ciclo de vida | [M08](../modulo-08-hooks/README.md) | El evento `Notification` es la base de las alertas de agentes de este módulo |
| Sesiones y `/resume` | [M02](../modulo-02-cli-primeros-pasos/README.md) | `/resume` soporta reanudar sesiones iniciadas con `claude --bg` |
| Agent Teams | [M09](../modulo-09-agentes-skills-teams/README.md) | Los Dynamic Workflows orquestan agentes independientes a mayor escala que un Agent Team clásico |
| Telemetría OTEL | [M11](../modulo-11-enterprise-seguridad/README.md) | Los atributos `workflow.run_id` y `workflow.name` se integran con la observabilidad enterprise |

> **Nota importante:** el cambio arquitectural de v2.1.198 por el que los subagentes corren en background por defecto (Claude sigue trabajando y notifica al terminar) se explica en [M09](../modulo-09-agentes-skills-teams/README.md). Este módulo asume ese comportamiento y se centra en cómo **observarlo y escalarlo** con Agent View y Dynamic Workflows.

---

## Navegación

| Anterior | Siguiente |
|----------|-----------|
| [Módulo 15: Plugins y Marketplaces](../modulo-15-plugins-marketplaces/README.md) | [Módulo 17: Proyecto Final Integrador](../modulo-17-proyecto-final/enunciado/README.md) |
