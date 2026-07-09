# 01 - Agent View: el Dashboard de Sesiones de Claude Code

> **Disponible desde v2.1.139 (Research Preview)**, evolucionado en más de 15 versiones posteriores hasta v2.1.205.

Cuantos más agentes lanzas en segundo plano (M09), más difícil es responder a una pregunta básica: **¿qué está haciendo Claude Code ahora mismo, en todas mis sesiones?** Agent View es la respuesta de Claude Code a ese problema: un comando que muestra, en un solo sitio, todas las sesiones activas — interactivas y en background — con su estado, su directorio de trabajo y en qué están bloqueadas si lo están.

---

## Objetivos de aprendizaje

Al terminar esta sección serás capaz de:

- Abrir y leer el dashboard de `claude agents` para ver todas tus sesiones activas
- Consultar el estado de tus sesiones mediante JSON para integrarlo en scripts
- Lanzar nuevas sesiones background con los flags de dispatch adecuados
- Ejecutar comandos de shell arbitrarios como sesiones background adjuntables
- Configurar sesiones "pinned" que sobreviven a la inactividad y a las actualizaciones
- Recibir notificaciones cuando un agente necesita tu input o termina su trabajo
- Entender qué hace un background agent automáticamente al terminar (commit, push, PR draft) y cómo controlarlo

---

## Conceptos clave

### El comando `claude agents`

```bash
claude agents
```

Abre un dashboard interactivo con **todas las sesiones de Claude Code activas** en tu máquina: sesiones interactivas abiertas en otras terminales, sesiones background lanzadas con `run_in_background: true` desde otra sesión, y sesiones lanzadas directamente con `claude --bg`.

Para cada sesión, el dashboard muestra:

| Campo | Descripción |
|-------|-------------|
| Nombre/ID | Identificador de la sesión (nombre asignado o ID autogenerado) |
| Directorio de trabajo | Ruta del proyecto donde corre la sesión |
| Estado | En ejecución, esperando input, completada, con error |
| Última actividad | Cuánto tiempo lleva la sesión sin producir output nuevo |

Desde el dashboard puedes navegar con las flechas y **adjuntarte** (attach) a cualquier sesión para ver su transcript completo o retomar el control interactivo.

> **Nota:** Agent View se introdujo como Research Preview en v2.1.139. Algunas interacciones del dashboard (atajos de teclado, columnas exactas) pueden variar ligeramente entre versiones; usa `claude agents --help` para ver las opciones disponibles en tu versión instalada.

### `claude agents --json`: listado para scripting

> **Disponible desde v2.1.145**

Para integrar el estado de tus sesiones en scripts, dashboards propios o alertas, usa la salida JSON:

```bash
claude agents --json
```

```json
[
  {
    "id": "sess_8f3a1c",
    "name": "feature-auth",
    "cwd": "/home/dev/proyectos/taskflow-api",
    "status": "running",
    "background": true,
    "waitingFor": null,
    "lastActivity": "2026-07-08T10:42:11Z"
  },
  {
    "id": "sess_2b9d47",
    "name": "backend-audit",
    "cwd": "/home/dev/proyectos/taskflow-api",
    "status": "blocked",
    "background": true,
    "waitingFor": "permission:Bash(npm run migrate)",
    "lastActivity": "2026-07-08T10:41:55Z"
  }
]
```

### `waitingFor`: saber en qué está bloqueada una sesión

> **Disponible desde v2.1.162**

Antes de v2.1.162, una sesión "blocked" en la salida JSON no indicaba **por qué** estaba bloqueada — había que adjuntarse para averiguarlo. El campo `waitingFor` resuelve esto: indica explícitamente el motivo del bloqueo (una petición de permiso, una pregunta al usuario, una dependencia de otro agente).

```bash
# Script que alerta cuando alguna sesión lleva bloqueada esperando permiso
claude agents --json | jq -r '
  .[] | select(.waitingFor != null) |
  "\(.name): bloqueada esperando \(.waitingFor)"
'
```

Este patrón es la base de cualquier automatización que monitorice muchas sesiones en paralelo sin necesidad de adjuntarse manualmente a cada una para comprobar su estado.

### `claude agents --cwd <path>`: acotar por directorio

> **Disponible desde v2.1.141**

Si trabajas con varios proyectos en paralelo, `--cwd` filtra el listado a las sesiones de un directorio concreto:

```bash
# Solo las sesiones activas del proyecto taskflow-api
claude agents --cwd ~/proyectos/taskflow-api
```

Combinado con `--json`, es la forma más directa de construir un script de monitorización específico de un repositorio en un pipeline de CI/CD o en un cron local.

### Flags de dispatch: lanzar sesiones desde el dashboard

> **Disponibles desde v2.1.143**

`claude agents` no es solo de lectura: también permite lanzar nuevas sesiones background con la misma configuración que tendrían si las arrancaras con `claude` directamente:

| Flag | Qué controla |
|------|---------------|
| `--add-dir <ruta>` | Directorios adicionales accesibles para la sesión |
| `--settings <fichero>` | Fichero de settings alternativo |
| `--mcp-config <fichero>` | Configuración de servidores MCP a cargar |
| `--plugin-dir <ruta>` | Plugin local a cargar en la sesión |
| `--permission-mode <modo>` | Modo de permisos (`manual`, `acceptEdits`, `bypassPermissions`, etc.) |
| `--model <modelo>` | Modelo a usar en la sesión |
| `--effort <nivel>` | Nivel de esfuerzo de razonamiento (`low`, `medium`, `high`, `xhigh`) |
| `--dangerously-skip-permissions` | Omite todas las confirmaciones de permisos (usar con extrema precaución) |

```bash
# Lanzar una sesión background con Opus, effort alto y un MCP config específico
claude --bg "Migra los endpoints de src/api/legacy a la nueva convención REST" \
  --model opus \
  --effort high \
  --mcp-config ./.claude/mcp-migracion.json \
  --permission-mode acceptEdits
```

> Consulta [M05](../../modulo-05-configuracion-permisos/README.md) para el detalle de los modos de permiso y [M06](../../modulo-06-planificacion-opus/README.md) para los niveles de `effort`.

### `! <comando>`: shell arbitrario como sesión background

> **Disponible desde v2.1.154**

Dentro del dashboard de `claude agents`, el prefijo `!` ejecuta un comando de shell como si fuera una sesión background más — con la ventaja de que queda listada, es adjuntable y puedes ver su output en cualquier momento:

```text
# Dentro de claude agents, en el prompt de comando:
! npm run build:watch
```

Esto es útil para procesos largos que quieres tener a la vista junto a tus agentes de Claude Code (un watcher, un servidor de desarrollo, un test runner en modo continuo) sin salir del dashboard ni abrir una terminal adicional.

### Sesiones "pinned": persistencia frente a inactividad y actualizaciones

> **Disponible desde v2.1.147**

Por defecto, una sesión background inactiva durante mucho tiempo puede recolectarse (dejar de estar disponible). Una sesión **pinned** ("fijada") se comporta de forma distinta:

- **Permanece viva** aunque esté idle durante horas
- **Se reinicia in-place** cuando Claude Code se actualiza, en vez de perderse

Esto es relevante para agentes de larga duración: por ejemplo, un agente que vigila un pipeline de CI y solo actúa cuando detecta un fallo puede estar idle la mayor parte del tiempo, pero necesitas que siga disponible.

```text
# Desde el dashboard, selecciona la sesión y usa la opción de pin
# (atajo de teclado disponible en claude agents --help de tu versión)
```

### `/resume` con sesiones `--bg`

> **Disponible desde v2.1.144**

El comando `/resume` (cubierto en [M02](../../modulo-02-cli-primeros-pasos/teoria/03-sesiones-y-continuidad.md)) soporta reanudar sesiones que se iniciaron directamente con `claude --bg`, no solo sesiones interactivas previas:

```bash
claude --bg "Audita las dependencias del proyecto y reporta vulnerabilidades"
# ... más tarde, desde cualquier sesión interactiva:
/resume
# El selector incluye la sesión background lanzada con --bg
```

### Detener un agente background es permanente

> **Cambio de comportamiento en v2.1.191**

Antes de v2.1.191, detener un agente background desde el panel de tareas podía "resucitarlo" en ciertas condiciones (por ejemplo, si recibía un nuevo mensaje). Desde v2.1.191, **detener es definitivo**: el agente no vuelve a ejecutarse. Si necesitas continuar el trabajo, debes lanzar una sesión nueva o usar `SendMessage` (M09) sobre una sesión que sigue activa, no sobre una que has detenido.

### Notificaciones: `agent_needs_input` y `agent_completed`

> **Disponible desde v2.1.198**

Claude Code notifica automáticamente cuando una sesión background necesita tu atención. El hook `Notification` (cubierto en [M08](../../modulo-08-hooks/teoria/04-hooks-agent-y-eventos-avanzados.md)) recibe un payload que distingue el motivo:

```json
{
  "hooks": {
    "Notification": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "/scripts/notificar-agente.sh"
          }
        ]
      }
    ]
  }
}
```

`/scripts/notificar-agente.sh`:

```bash
#!/bin/bash
INPUT=$(cat)
REASON=$(echo "$INPUT" | jq -r '.reason // empty')
SESSION=$(echo "$INPUT" | jq -r '.sessionName // empty')

case "$REASON" in
  agent_needs_input)
    # El agente está bloqueado esperando una decisión tuya
    curl -s -X POST "$SLACK_WEBHOOK_URL" \
      -d "{\"text\": \"⚠️ El agente '$SESSION' necesita tu input\"}"
    ;;
  agent_completed)
    # El agente terminó su trabajo con éxito
    curl -s -X POST "$SLACK_WEBHOOK_URL" \
      -d "{\"text\": \"✅ El agente '$SESSION' ha terminado\"}"
    ;;
esac
```

Esto permite construir un flujo de notificación diferenciado: una alerta urgente cuando un agente está bloqueado (puede que estés lejos del teclado y el trabajo esté parado), y una notificación informativa cuando termina sin incidencias.

### Commit, push y PR draft automáticos al terminar

> **Disponible desde v2.1.198**

Cuando un background agent trabaja en un **worktree aislado** (M09) y completa una tarea de código, Claude Code puede hacer automáticamente:

1. `git commit` de los cambios
2. `git push` de la rama del worktree
3. Apertura de un **pull request en modo draft**

Esto cierra el ciclo de "lanzar y olvidar": no necesitas volver a la sesión para hacer commit manualmente, el resultado del agente ya está listo para revisión en forma de PR draft.

> Este comportamiento automático **solo aplica quando el agente trabaja en un worktree aislado con cambios de código**. Un agente que solo analiza o reporta (sin cambios en el repositorio) no genera commits.

### `worktree.bgIsolation: "none"`: editar el working copy directamente

> **Disponible desde v2.1.143**

Por defecto, las sesiones background que hacen cambios de código trabajan en un worktree aislado (ver M09), lo que habilita el flujo de commit/push/PR automático descrito arriba. El setting `worktree.bgIsolation` permite cambiar ese comportamiento:

```json
{
  "worktree": {
    "bgIsolation": "none"
  }
}
```

Con `"none"`, las sesiones background **editan directamente el working copy** en vez de un worktree aislado. Esto es útil cuando:

- Quieres ver los cambios del agente en tiempo real en tu propio checkout
- El proyecto no soporta bien los worktrees de git (por ejemplo, por herramientas que dependen de rutas absolutas fijas)
- Prefieres revisar y hacer commit manualmente en vez del flujo automático de PR draft

> **Trade-off:** con `bgIsolation: "none"`, si lanzas varios agentes background en paralelo sobre el mismo repositorio, sus cambios pueden interferir entre sí. El aislamiento en worktree (comportamiento por defecto) evita ese problema.

---

## Ejemplos prácticos

### Dashboard de monitorización de un sprint con múltiples agentes

```bash
# Lanza tres auditorías en background desde una sesión interactiva
claude
> Lanza tres agentes en background:
  - "audit-deps": revisa dependencias desactualizadas con vulnerabilidades
  - "audit-tests": encuentra archivos sin cobertura de tests
  - "audit-docs": encuentra endpoints de la API sin documentar
  Que cada uno reporte al terminar.

# En otra terminal, abre el dashboard para verlos todos
claude agents
```

### Script de vigilancia de sesiones bloqueadas

```bash
#!/bin/bash
# vigilar-agentes.sh: alerta si alguna sesión lleva bloqueada más de 10 minutos

claude agents --json | jq -r '
  .[] | select(.waitingFor != null) |
  "\(.id)|\(.name)|\(.waitingFor)|\(.lastActivity)"
' | while IFS='|' read -r id name reason last_activity; do
  echo "Sesión bloqueada: $name (motivo: $reason, desde: $last_activity)"
done
```

### Lanzar un agente background con configuración específica de migración

```bash
claude --bg "Convierte todos los tests de Jest a Vitest en src/" \
  --add-dir ./scripts/migracion \
  --settings ./.claude/settings-migracion.json \
  --effort high \
  --permission-mode acceptEdits
```

---

## Errores comunes

| Error | Causa | Solución |
|-------|-------|---------|
| Hacer polling manual del estado de un agente | No usar el campo `waitingFor` ni las notificaciones | Configurar el hook `Notification` o consultar `claude agents --json \| jq` en vez de preguntar repetidamente "¿ya terminaste?" |
| Asumir que detener un agente permite reanudarlo después | Comportamiento antiguo (antes de v2.1.191) | Detener un agente background es permanente desde v2.1.191; lanza una sesión nueva si necesitas continuar |
| Confundir `claude agents` con Agent Teams | Ambos gestionan múltiples agentes, pero con propósitos distintos | `claude agents` es el dashboard de monitorización de **todas** las sesiones; Agent Teams (M09) es un mecanismo de colaboración entre teammates dentro de una sesión |
| Lanzar decenas de agentes background con `bgIsolation: "none"` | Todos editan el mismo working copy sin aislamiento | Mantén el aislamiento en worktree por defecto cuando lances varios agentes en paralelo sobre el mismo repositorio |
| No revisar los PR draft generados automáticamente | Asumir que el trabajo del agente termina en el commit | Los PR draft de background agents requieren revisión y aprobación humana antes de mergear, igual que cualquier otro PR |

---

## Resumen

- `claude agents` (Research Preview desde v2.1.139) abre un dashboard con todas las sesiones activas de Claude Code, interactivas y en background
- `claude agents --json` (v2.1.145) permite scripting; el campo `waitingFor` (v2.1.162) indica el motivo exacto de un bloqueo
- `claude agents --cwd <path>` (v2.1.141) acota el listado a un directorio
- Los flags de dispatch (`--add-dir`, `--settings`, `--mcp-config`, `--plugin-dir`, `--permission-mode`, `--model`, `--effort`, `--dangerously-skip-permissions`, v2.1.143) configuran nuevas sesiones lanzadas desde el dashboard
- `! <comando>` (v2.1.154) ejecuta shell arbitrario como sesión background adjuntable dentro del dashboard
- Las sesiones "pinned" (v2.1.147) sobreviven a la inactividad y se reinician in-place en actualizaciones
- `/resume` soporta sesiones iniciadas con `claude --bg` (v2.1.144)
- Detener un agente background es permanente desde v2.1.191
- El hook `Notification` distingue `agent_needs_input` de `agent_completed` (v2.1.198)
- Los background agents en worktree aislado hacen commit/push/PR draft automáticamente al completar cambios de código (v2.1.198)
- `worktree.bgIsolation: "none"` (v2.1.143) hace que las sesiones background editen el working copy directamente, renunciando al aislamiento

---

## Siguiente paso

Continúa con [02 - Dynamic Workflows](02-dynamic-workflows.md) para aprender a orquestar decenas o cientos de agentes background con una sola instrucción.
