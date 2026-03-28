# 04 - Hooks de Tipo Agent y Eventos Avanzados

Este tema cubre la configuracion de hooks de tipo `agent` para lanzar subagentes
como respuesta a eventos, los nuevos eventos del ciclo de vida de Claude Code,
la definicion de hooks en subagentes y skills con frontmatter YAML, y el uso de
hooks asincronos para operaciones largas sin bloquear la sesion.

---

## Hooks de tipo Agent (profundizacion)

Ademas de los hooks `command` (que ejecutan un script shell) y `prompt` (que envian texto al modelo), existe un tercer tipo: `agent`. Un hook de tipo `agent` lanza un **subagente completo** como respuesta a un evento. Ese subagente tiene acceso a herramientas y puede tomar acciones autonomas.

### Configuracion basica

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "agent",
            "prompt": "Analiza el output del comando ejecutado. Si detectas errores de seguridad o credenciales expuestas, reportalos con detalle."
          }
        ]
      }
    ]
  }
}
```

### Cuando usar cada tipo de hook

| Tipo | Cuando usarlo | Costo |
|------|---------------|-------|
| `command` | Validaciones rapidas, scripts shell, formateo | Bajo (solo CPU local) |
| `prompt` | Anadir contexto al modelo sin accion autonoma | Medio (tokens de entrada) |
| `agent` | Analisis complejos, acciones que requieren herramientas | Alto (llama al modelo + consume tokens) |

### Casos de uso tipicos para hooks agent

- **Revision automatica de seguridad post-commit:** Despues de cada `Bash` que ejecute `git commit`, lanzar un agente que revise si el commit expone secretos o introduce vulnerabilidades
- **Analisis de calidad post-edicion:** Despues de cada `Write` o `Edit`, lanzar un agente que verifique si el codigo cumple los estandares del proyecto
- **Diagnostico automatico de fallos:** Despues de un `Bash` con exit code distinto de cero, lanzar un agente que analice el error y sugiera una solucion

### Ejemplo completo: revision de seguridad post-commit

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "agent",
            "prompt": "El comando bash que acaba de ejecutarse hizo un commit de git. Revisa el diff del ultimo commit con 'git show HEAD --stat'. Si detectas que se han incluido archivos .env, credenciales, tokens o claves privadas, reporta el problema con la ruta exacta del archivo afectado y el tipo de dato sensible encontrado. Si todo esta bien, responde solo: 'Revision OK'."
          }
        ]
      }
    ]
  }
}
```

> **Importante:** Los hooks de tipo `agent` consumen tokens del modelo para cada ejecucion. Usa `matcher` para limitarlos a las herramientas relevantes y evita activarlos en cada operacion si el volumen es alto.

---

## Nuevos eventos del ciclo de vida

El sistema de hooks de Claude Code va mas alla de los cuatro eventos basicos (`PreToolUse`, `PostToolUse`, `Notification`, `Stop`). Existen eventos adicionales para cubrir casos de uso avanzados:

### SessionStart

Se dispara al **iniciar o reanudar** una sesion de Claude Code.

```json
{
  "hooks": {
    "SessionStart": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "echo \"$(date): Sesion iniciada por $USER\" >> ~/.claude/sessions.log"
          }
        ]
      }
    ]
  }
}
```

Casos de uso: cargar variables de entorno del proyecto, verificar que las dependencias estan instaladas, mostrar el estado del repo al empezar.

### SessionEnd

Se dispara al **terminar** una sesion.

```json
{
  "hooks": {
    "SessionEnd": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "/scripts/cleanup-temp-files.sh"
          }
        ]
      }
    ]
  }
}
```

Casos de uso: cleanup de ficheros temporales, enviar resumen de la sesion por Slack, hacer commit de los cambios pendientes.

### UserPromptSubmit

Se dispara **justo antes de enviar un prompt** al modelo. Puede **bloquear el prompt** si el hook retorna exit code 2.

```json
{
  "hooks": {
    "UserPromptSubmit": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "/scripts/validate-prompt.sh"
          }
        ]
      }
    ]
  }
}
```

```bash
#!/bin/bash
# validate-prompt.sh
# Bloquear prompts que intentan revelar instrucciones del sistema
INPUT=$(cat)
PROMPT=$(echo "$INPUT" | jq -r '.prompt // empty')

FORBIDDEN_PATTERNS=(
  "ignora las instrucciones anteriores"
  "ignore previous instructions"
  "reveal your system prompt"
  "muestra tu CLAUDE.md"
)

for pattern in "${FORBIDDEN_PATTERNS[@]}"; do
  if echo "$PROMPT" | grep -qi "$pattern"; then
    echo "Prompt bloqueado: contiene instruccion prohibida." >&2
    exit 2
  fi
done

exit 0
```

> **Exit code 2 es el unico que bloquea:** Solo exit code 2 bloquea la operacion (ya sea una herramienta en `PreToolUse` o un prompt en `UserPromptSubmit`). Exit code 1 u otros codigos no-zero no bloquean; simplemente muestran stderr en modo verbose.

### PermissionRequest

Se dispara **cuando aparece un dialogo de permisos** (por ejemplo, al intentar ejecutar un comando no permitido). Util para auto-aprobar patrones conocidos y seguros.

```json
{
  "hooks": {
    "PermissionRequest": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "/scripts/auto-approve-safe-commands.sh"
          }
        ]
      }
    ]
  }
}
```

### PostToolUseFailure

Se dispara **despues de que una herramienta falla** (exit code distinto de cero). Permite diagnostico automatico de errores.

```json
{
  "hooks": {
    "PostToolUseFailure": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "agent",
            "prompt": "El comando bash acaba de fallar. Analiza el error en el output, identifica la causa probable y sugiere una solucion concreta."
          }
        ]
      }
    ]
  }
}
```

### StopFailure

Se dispara **cuando ocurre un error de API durante la respuesta de Claude**. Util para logging, reintentos o notificacion de fallos.

```json
{
  "hooks": {
    "StopFailure": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "echo \"$(date): Error API durante respuesta\" >> ~/.claude/api-errors.log"
          }
        ]
      }
    ]
  }
}
```

### SubagentStart

Se dispara **cuando se crea un subagente**. Util para tracking de subagentes activos.

```json
{
  "hooks": {
    "SubagentStart": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "echo \"$(date): Subagente iniciado\" >> ~/.claude/subagents.log"
          }
        ]
      }
    ]
  }
}
```

### TeammateIdle

Se dispara **cuando un teammate de un Agent Team no tiene tareas asignadas**. Util para reasignar trabajo o liberar recursos.

```json
{
  "hooks": {
    "TeammateIdle": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "/scripts/assign-backlog-task.sh"
          }
        ]
      }
    ]
  }
}
```

### TaskCompleted

Se dispara **cuando una tarea de la lista compartida de un Agent Team se marca como completada**. Util para notificaciones o para desencadenar la siguiente fase de trabajo.

```json
{
  "hooks": {
    "TaskCompleted": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "curl -s -X POST $SLACK_WEBHOOK_URL -d '{\"text\": \"Tarea completada en el Agent Team\"}'"
          }
        ]
      }
    ]
  }
}
```

### Notification

Se dispara **cuando Claude Code envia una notificacion al usuario**, por ejemplo al completar una tarea en background o cuando un agente termina su trabajo. Por defecto, estas notificaciones se envian como notificaciones de sistema del SO (desktop notifications).

Un hook en el evento `Notification` permite personalizar ese comportamiento: redirigir a Slack, reproducir un sonido, registrar en un log, etc.

```json
{
  "hooks": {
    "Notification": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "/scripts/custom-notification.sh"
          }
        ]
      }
    ]
  }
}
```

Script `custom-notification.sh`:

```bash
#!/bin/bash
INPUT=$(cat)
MESSAGE=$(echo "$INPUT" | jq -r '.message // empty')

notify-send 'Claude Code' "$MESSAGE"
```

Casos de uso frecuentes:

- Enviar la notificacion a un canal de Slack cuando un agente de larga duracion termina
- Reproducir un sonido con `paplay` o `afplay` ademas de mostrar la notificacion visual
- Registrar todas las notificaciones en un fichero de log para auditoria

---

## Hooks en subagentes y skills

Los hooks no se limitan a la configuracion global de `settings.json`. Tambien pueden definirse en el frontmatter YAML de un subagente o un skill, usando la misma estructura pero con alcance limitado a ese agente o skill en particular.

### Ejemplo: skill con hook PostToolUse

```markdown
---
name: implementar-feature
description: Implementa una nueva feature siguiendo los estandares del proyecto
hooks:
  PostToolUse:
    - matcher: Write
      hooks:
        - type: command
          command: npx prettier --write $FILEPATH && npx eslint --fix $FILEPATH
---

# Skill: Implementar Feature

Al implementar una nueva feature:
1. Crea los archivos necesarios siguiendo la estructura del proyecto
2. Escribe los tests antes que el codigo de produccion
3. Documenta las funciones publicas con JSDoc
```

En este ejemplo, cada vez que el skill escribe un fichero, se ejecuta automaticamente Prettier y ESLint sin necesidad de configurarlo a nivel global.

### Consideraciones sobre alcance

- Los hooks definidos en un skill solo se activan **mientras ese skill esta ejecutandose**
- Los hooks globales (en `settings.json`) se activan en **todas las sesiones**
- Si ambos aplican a la misma herramienta, **se ejecutan ambos** (no se cancelan)

---

## Hooks async para operaciones largas

Por defecto, Claude Code espera a que el hook termine antes de continuar. Para operaciones que pueden tardar varios segundos o minutos (tests, builds, deploys), esto bloquea la interaccion.

La solucion es marcar el hook como `"async": true`:

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write",
        "hooks": [
          {
            "type": "command",
            "command": "/scripts/run-full-test-suite.sh",
            "async": true,
            "timeout": 300
          }
        ]
      }
    ]
  }
}
```

### Comportamiento de hooks async

- El hook se lanza en **background** inmediatamente despues del evento
- Claude Code **no espera** a que termine y continua con la interaccion
- Si el hook falla, el error se registra en el log pero **no interrumpe la sesion**
- El parametro `timeout` (en segundos) define el tiempo maximo antes de cancelar el hook

### Cuando usar async

| Escenario | Sincrono | Async |
|-----------|----------|-------|
| Validacion de seguridad (debe bloquear) | Si | No |
| Suite de tests completa (2-5 min) | No | Si |
| Formateo de codigo (< 1 segundo) | Si | No |
| Build de produccion (varios minutos) | No | Si |
| Registro en log de auditoria | No | Si |
| Notificacion Slack al completar | No | Si |

### Ejemplo practico: build en background

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write",
        "hooks": [
          {
            "type": "command",
            "command": "bash -c 'cd $(git rev-parse --show-toplevel) && npm run build 2>&1 | tail -5 >> ~/.claude/build.log'",
            "async": true,
            "timeout": 120
          }
        ]
      }
    ]
  }
}
```

---

## Nuevos eventos del ciclo de vida (v2.1.76 - v2.1.83)

Los siguientes eventos se anadieron en las versiones mas recientes de Claude Code:

### PostCompact

Se dispara **despues de que el contexto ha sido compactado**, ya sea por `/compact` manual o por la Compaction API automatica. Incluye el campo `compact_summary` con el resumen generado.

```json
{
  "hooks": {
    "PostCompact": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "echo \"$(date): Compactacion realizada\" >> ~/.claude/compaction.log"
          }
        ]
      }
    ]
  }
}
```

Casos de uso: logging de compactaciones, verificar que el resumen mantiene informacion critica, enviar alerta si la compactacion se dispara demasiado frecuentemente.

### CwdChanged

Se dispara **cuando cambia el directorio de trabajo** de la sesion. Util para integracion con herramientas que dependen del directorio, como `direnv`.

```json
{
  "hooks": {
    "CwdChanged": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "if [ -f .env ]; then echo 'Cargando .env del nuevo directorio'; fi"
          }
        ]
      }
    ]
  }
}
```

### FileChanged

Se dispara **cuando se modifica un fichero en el filesystem**. Permite reacciones automaticas a cambios.

```json
{
  "hooks": {
    "FileChanged": [
      {
        "matcher": "*.ts",
        "hooks": [
          {
            "type": "command",
            "command": "npx tsc --noEmit $FILEPATH 2>&1 | head -5"
          }
        ]
      }
    ]
  }
}
```

### InstructionsLoaded

Se dispara **cuando se cargan instrucciones** (CLAUDE.md, ficheros de rules). Util para validar o auditar las reglas que se estan aplicando.

### ConfigChange

Se dispara **cuando cambia la configuracion** de Claude Code (settings.json, permisos). Util para auditoria en entornos enterprise.

### WorktreeCreate / WorktreeRemove

Se disparan cuando se **crea o elimina un worktree** para un subagente. Permiten setup y cleanup de recursos asociados al worktree.

```json
{
  "hooks": {
    "WorktreeCreate": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "/scripts/setup-worktree.sh"
          }
        ]
      }
    ]
  }
}
```

Script `setup-worktree.sh`:

```bash
#!/bin/bash
INPUT=$(cat)
WORKTREE_PATH=$(echo "$INPUT" | jq -r '.worktree_path // empty')

echo "Worktree creado: $WORKTREE_PATH" >> ~/.claude/worktrees.log
```

### Elicitation / ElicitationResult

Se disparan durante el flujo de **MCP Elicitation** (ver [Modulo 07](../../modulo-07-mcp/teoria/05-mcp-elicitation.md)). `Elicitation` intercepta la solicitud de input del servidor MCP; `ElicitationResult` intercepta la respuesta del usuario.

---

## Errores comunes

| Error | Causa | Solucion |
|-------|-------|---------|
| Hook agent muy lento | Se lanza en cada operacion sin matcher | Anadir `matcher` especifico |
| Loop infinito | Hook agent que escribe ficheros y dispara su propio PostToolUse | Usar matcher preciso o flag de guard |
| Usar exit 1 para bloquear | exit 1 no bloquea, solo muestra en verbose | Usar **exit 2** para bloquear operaciones |
| Hooks async que fallan silenciosamente | Los errores de hooks async no interrumpen la sesion | Redirigir stderr a un log |
| Hooks en skills ignorados | Frontmatter YAML mal formateado | Validar el YAML con un linter |
| Leer variables de entorno inexistentes | Los datos llegan via stdin (JSON), no como env vars | Usar `INPUT=$(cat)` y `jq` para extraer campos |

---

## Resumen

- Los hooks de tipo `agent` lanzan subagentes completos como respuesta a eventos; son los mas potentes pero tambien los mas costosos en tokens
- Los eventos avanzados (`SessionStart`, `SessionEnd`, `UserPromptSubmit`, `PermissionRequest`, `PostToolUseFailure`, `StopFailure`, `SubagentStart`, `TeammateIdle`, `TaskCompleted`, `Notification`) cubren todo el ciclo de vida de la sesion
- Los **nuevos eventos v3.0** (`PostCompact`, `CwdChanged`, `FileChanged`, `InstructionsLoaded`, `ConfigChange`, `WorktreeCreate`, `WorktreeRemove`, `Elicitation`, `ElicitationResult`) amplian la cobertura a compactacion, filesystem, configuracion, worktrees y MCP Elicitation
- Los hooks pueden definirse en el frontmatter YAML de skills y subagentes, con alcance limitado a su ejecucion
- El parametro `"async": true` permite ejecutar hooks en background para operaciones largas sin bloquear la sesion
- `"timeout"` limita el tiempo maximo de ejecucion de un hook async
- Solo **exit 2** bloquea operaciones; exit 1 u otros codigos no-zero no bloquean
