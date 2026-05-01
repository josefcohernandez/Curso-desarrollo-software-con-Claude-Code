# 04 - Hooks de Tipo Agent y Eventos Avanzados

Este tema cubre la configuración de hooks de tipo `agent` para lanzar subagentes
como respuesta a eventos, los nuevos eventos del ciclo de vida de Claude Code,
la definición de hooks en subagentes y skills con frontmatter YAML, y el uso de
hooks asíncronos para operaciones largas sin bloquear la sesión.

---

## Hooks de tipo Agent (profundización)

Además de los hooks `command` (que ejecutan un script shell) y `prompt` (que envían texto al modelo), existe un tercer tipo: `agent`. Un hook de tipo `agent` lanza un **subagente completo** como respuesta a un evento. Ese subagente tiene acceso a herramientas y puede tomar acciones autónomas.

### Configuración básica

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "agent",
            "prompt": "Analiza el output del comando ejecutado. Si detectas errores de seguridad o credenciales expuestas, repórtalos con detalle."
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
| `command` | Validaciones rápidas, scripts shell, formateo | Bajo (solo CPU local) |
| `prompt` | Añadir contexto al modelo sin acción autónoma | Medio (tokens de entrada) |
| `http` | Notificar a un endpoint web externo sin lógica local | Bajo (latencia de red) |
| `mcp_tool` | Invocar una herramienta de un servidor MCP ya configurado | Bajo-medio (depende del servidor) |
| `agent` | Análisis complejos, acciones que requieren herramientas | Alto (llama al modelo + consume tokens) |

### Casos de uso típicos para hooks agent

- **Revisión automática de seguridad post-commit:** Después de cada `Bash` que ejecute `git commit`, lanzar un agente que revise si el commit expone secretos o introduce vulnerabilidades
- **Análisis de calidad postedición:** Después de cada `Write` o `Edit`, lanzar un agente que verifique si el código cumple los estándares del proyecto
- **Diagnóstico automático de fallos:** Después de un `Bash` con exit code distinto de cero, lanzar un agente que analice el error y sugiera una solución

### Ejemplo completo: revisión de seguridad post-commit

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "agent",
            "prompt": "El comando bash que acaba de ejecutarse hizo un commit de git. Revisa el diff del último commit con 'git show HEAD --stat'. Si detectas que se han incluido archivos .env, credenciales, tokens o claves privadas, reporta el problema con la ruta exacta del archivo afectado y el tipo de dato sensible encontrado. Si todo está bien, responde solo: 'Revisión OK'."
          }
        ]
      }
    ]
  }
}
```

> **Importante:** Los hooks de tipo `agent` consumen tokens del modelo para cada ejecución. Usa `matcher` para limitarlos a las herramientas relevantes y evita activarlos en cada operación si el volumen es alto.

---

## Nuevos eventos del ciclo de vida

El sistema de hooks de Claude Code va más allá de los cuatro eventos básicos (`PreToolUse`, `PostToolUse`, `Notification`, `Stop`). Existen eventos adicionales para cubrir casos de uso avanzados:

### SessionStart

Se dispara al **iniciar o reanudar** una sesión de Claude Code.

```json
{
  "hooks": {
    "SessionStart": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "echo \"$(date): Sesión iniciada por $USER\" >> ~/.claude/sessions.log"
          }
        ]
      }
    ]
  }
}
```

Casos de uso: cargar variables de entorno del proyecto, verificar que las dependencias están instaladas, mostrar el estado del repo al empezar.

### SessionEnd

Se dispara al **terminar** una sesión.

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

Casos de uso: cleanup de ficheros temporales, enviar resumen de la sesión por Slack, hacer commit de los cambios pendientes.

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
    echo "Prompt bloqueado: contiene una instrucción prohibida." >&2
    exit 2
  fi
done

exit 0
```

> **Exit code 2 es el único que bloquea:** Solo exit code 2 bloquea la operación (ya sea una herramienta en `PreToolUse` o un prompt en `UserPromptSubmit`). Exit code 1 u otros códigos no-zero no bloquean; simplemente muestran stderr en modo verbose.

### Definir el título de sesión programáticamente (desde v2.1.94)

Desde la versión 2.1.94, los hooks `UserPromptSubmit` pueden devolver un campo `hookSpecificOutput.sessionTitle` en su respuesta JSON para **asignar el título de la sesión** de forma automática. El título aparece en el historial de sesiones y facilita identificar conversaciones en proyectos con múltiples sesiones activas.

```bash
#!/bin/bash
# Hook que asigna título de sesión basado en el branch actual
BRANCH=$(git branch --show-current 2>/dev/null || echo "sin-repo")
echo "{\"hookSpecificOutput\": {\"sessionTitle\": \"[$BRANCH] $(date +%H:%M)\"}}"
```

Configuración correspondiente en `settings.json`:

```json
{
  "hooks": {
    "UserPromptSubmit": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "/scripts/set-session-title.sh"
          }
        ]
      }
    ]
  }
}
```

El campo `sessionTitle` solo se procesa cuando lo devuelve un hook `UserPromptSubmit`. Si el hook devuelve además otros campos (como `stopReason` o stderr con exit 2 para bloquear), estos se siguen procesando con independencia del título.

Casos de uso habituales:

- Identificar la sesión por branch de git y hora de inicio
- Incluir el nombre del ticket o issue activo (leyendo desde un fichero `.claude/ticket`)
- Mostrar el entorno activo (`[prod]`, `[staging]`, `[local]`) al inicio de cada sesión

### PermissionRequest

Se dispara **cuando aparece un diálogo de permisos** (por ejemplo, al intentar ejecutar un comando no permitido). Útil para autoaprobar patrones conocidos y seguros.

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

Se dispara **después de que una herramienta falla** (exit code distinto de cero). Permite diagnóstico automático de errores.

```json
{
  "hooks": {
    "PostToolUseFailure": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "agent",
            "prompt": "El comando bash acaba de fallar. Analiza el error en el output, identifica la causa probable y sugiere una solución concreta."
          }
        ]
      }
    ]
  }
}
```

> **Novedad v3.7 (v2.1.119):** Los eventos `PostToolUse` y `PostToolUseFailure` incluyen ahora el campo `duration_ms` en el JSON de entrada, con el tiempo en milisegundos que tardó en ejecutarse la herramienta. Ver la sección "Campo `duration_ms`" en [01-sistema-hooks.md](01-sistema-hooks.md) para ejemplos de uso.

### Reemplazar el output de cualquier herramienta con `updatedToolOutput`

> **Novedad v3.7 (v2.1.121)**

Un hook `PostToolUse` puede devolver el campo `hookSpecificOutput.updatedToolOutput` en su respuesta JSON para **reemplazar el output** que Claude recibe de la herramienta, antes de que lo procese. Esto permite filtrar, transformar o enriquecer la respuesta de cualquier herramienta de forma transparente.

Hasta v2.1.121, este mecanismo solo funcionaba cuando el `PostToolUse` se disparaba sobre herramientas MCP. Ahora funciona para **cualquier herramienta**: `Bash`, `Read`, `Write`, `Edit`, herramientas MCP, y cualquier otra.

#### Estructura de la respuesta del hook

```bash
#!/bin/bash
# El hook devuelve el output modificado como JSON en stdout
INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty')
ORIGINAL_OUTPUT=$(echo "$INPUT" | jq -r '.tool_response // empty')

# Transformar el output antes de que Claude lo procese
FILTERED_OUTPUT=$(echo "$ORIGINAL_OUTPUT" | grep -v "^DEBUG:")

echo "{\"hookSpecificOutput\": {\"updatedToolOutput\": $(echo "$FILTERED_OUTPUT" | jq -Rs .)}}"
exit 0
```

#### Ejemplo: filtrar líneas de debug del output de Bash

En proyectos donde los comandos emiten muchas líneas de debug que no son relevantes para Claude, un hook puede eliminarlas antes de que entren en el contexto:

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "/scripts/filter-debug-output.sh"
          }
        ]
      }
    ]
  }
}
```

```bash
#!/bin/bash
# filter-debug-output.sh
# Elimina líneas de debug del output de comandos bash antes de que Claude las procese

INPUT=$(cat)
ORIGINAL=$(echo "$INPUT" | jq -r '.tool_response // empty')

# Filtrar líneas que empiecen por [DEBUG] o [TRACE]
CLEAN=$(echo "$ORIGINAL" | grep -vE "^\[(DEBUG|TRACE)\]")

# Devolver el output filtrado
echo "{\"hookSpecificOutput\": {\"updatedToolOutput\": $(echo "$CLEAN" | jq -Rs .)}}"
exit 0
```

#### Ejemplo: enriquecer el output de Read con metadatos

```bash
#!/bin/bash
# enrich-read-output.sh
# Añade información de contexto al output de la herramienta Read

INPUT=$(cat)
FILEPATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')
ORIGINAL=$(echo "$INPUT" | jq -r '.tool_response // empty')

if [ -n "$FILEPATH" ] && [ -f "$FILEPATH" ]; then
  LINES=$(wc -l < "$FILEPATH")
  LAST_MODIFIED=$(date -r "$FILEPATH" +%Y-%m-%dT%H:%M:%S 2>/dev/null || echo "desconocido")
  HEADER="[Metadatos: $LINES líneas, última modificación: $LAST_MODIFIED]"
  ENRICHED="${HEADER}"$'\n'"${ORIGINAL}"
  echo "{\"hookSpecificOutput\": {\"updatedToolOutput\": $(echo "$ENRICHED" | jq -Rs .)}}"
else
  # Sin fichero o sin path, no modificar el output
  exit 0
fi
```

> **Nota:** Si el hook termina con exit 0 y no produce JSON en stdout (o no incluye `hookSpecificOutput.updatedToolOutput`), el output original de la herramienta llega a Claude sin modificaciones. Solo cuando el campo está presente en la respuesta del hook se sustituye el output.

### StopFailure

Se dispara **cuando ocurre un error de API durante la respuesta de Claude**. Útil para logging, reintentos o notificación de fallos.

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

Se dispara **cuando se crea un subagente**. Útil para tracking de subagentes activos.

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

Se dispara **cuando un teammate de un Agent Team no tiene tareas asignadas**. Útil para reasignar trabajo o liberar recursos.

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

Se dispara **cuando una tarea de la lista compartida de un Agent Team se marca como completada**. Útil para notificaciones o para desencadenar la siguiente fase de trabajo.

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

Se dispara **cuando Claude Code envía una notificación al usuario**, por ejemplo al completar una tarea en background o cuando un agente termina su trabajo. Por defecto, estas notificaciones se envían como notificaciones de sistema del sistema operativo (desktop notifications).

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

- Enviar la notificación a un canal de Slack cuando un agente de larga duración termina
- Reproducir un sonido con `paplay` o `afplay` además de mostrar la notificación visual
- Registrar todas las notificaciones en un fichero de log para auditoría

---

## Hooks en subagentes y skills

Los hooks no se limitan a la configuración global de `settings.json`. También pueden definirse en el frontmatter YAML de un subagente o un skill, usando la misma estructura pero con alcance limitado a ese agente o skill en particular.

### Ejemplo: skill con hook PostToolUse

```markdown
---
name: implementar-feature
description: Implementa una nueva feature siguiendo los estándares del proyecto
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
2. Escribe los tests antes que el código de producción
3. Documenta las funciones públicas con JSDoc
```

En este ejemplo, cada vez que el skill escribe un fichero, se ejecuta automáticamente Prettier y ESLint sin necesidad de configurarlo a nivel global.

### Consideraciones sobre alcance

- Los hooks definidos en un skill solo se activan **mientras ese skill está ejecutándose**
- Los hooks globales (en `settings.json`) se activan en **todas las sesiones**
- Si ambos aplican a la misma herramienta, **se ejecutan ambos** (no se cancelan)

> **Novedad v3.7 (v2.1.116):** Los hooks definidos en el campo `hooks:` del frontmatter de un agente ahora se disparan correctamente cuando ese agente se invoca desde el hilo principal mediante `--agent <nombre>`. Antes de esta versión, los hooks del frontmatter solo se activaban en subagentes lanzados de forma interna; con sesiones `--agent` se ignoraban. Si tus agentes definen hooks en el frontmatter, ya no es necesario duplicarlos en `settings.json` para que funcionen en sesiones invocadas con `--agent`.

---

## Hooks async para operaciones largas

Por defecto, Claude Code espera a que el hook termine antes de continuar. Para operaciones que pueden tardar varios segundos o minutos (tests, builds, deploys), esto bloquea la interacción.

La solución es marcar el hook como `"async": true`:

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

- El hook se lanza en **background** inmediatamente después del evento
- Claude Code **no espera** a que termine y continúa con la interacción
- Si el hook falla, el error se registra en el log pero **no interrumpe la sesión**
- El parámetro `timeout` (en segundos) define el tiempo máximo antes de cancelar el hook

### Cuando usar async

| Escenario | Síncrono | Async |
|-----------|----------|-------|
| Validación de seguridad (debe bloquear) | Si | No |
| Suite de tests completa (2-5 min) | No | Si |
| Formateo de código (< 1 segundo) | Si | No |
| Build de producción (varios minutos) | No | Si |
| Registro en log de auditoría | No | Si |
| Notificación a Slack al completar | No | Si |

### Ejemplo práctico: build en background

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

Los siguientes eventos se añadieron en las versiones más recientes de Claude Code:

### PostCompact

Se dispara **después de que el contexto ha sido compactado**, ya sea por `/compact` manual o por la Compaction API automática. Incluye el campo `compact_summary` con el resumen generado.

```json
{
  "hooks": {
    "PostCompact": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "echo \"$(date): Compactación realizada\" >> ~/.claude/compaction.log"
          }
        ]
      }
    ]
  }
}
```

Casos de uso: logging de compactaciones, verificar que el resumen mantiene información crítica, enviar alerta si la compactación se dispara demasiado frecuentemente.

### CwdChanged

Se dispara **cuando cambia el directorio de trabajo** de la sesión. Útil para la integración con herramientas que dependen del directorio, como `direnv`.

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

Se dispara **cuando se modifica un fichero en el filesystem**. Permite reacciones automáticas a cambios.

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

Se dispara **cuando se cargan instrucciones** (CLAUDE.md, ficheros de rules). Útil para validar o auditar las reglas que se están aplicando.

### ConfigChange

Se dispara **cuando cambia la configuración** de Claude Code (settings.json, permisos). Útil para auditoría en entornos enterprise.

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

Se disparan durante el flujo de **MCP Elicitation** (ver [Módulo 07](../../modulo-07-mcp/teoria/05-mcp-elicitation.md)). `Elicitation` intercepta la solicitud de input del servidor MCP; `ElicitationResult` intercepta la respuesta del usuario.

### PermissionDenied (v2.1.89)

Se dispara **cuando el clasificador de Auto Mode deniega una acción**. Permite reaccionar a denegaciones automáticas: registrar el evento, reintentar la acción con ajustes, o notificar al usuario.

```json
{
  "hooks": {
    "PermissionDenied": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "/scripts/on-permission-denied.sh"
          }
        ]
      }
    ]
  }
}
```

El hook puede devolver `{"retry": true}` en stdout para indicar a Claude Code que reintente la acción denegada. Esto es útil cuando el hook ajusta permisos o configuración antes del reintento:

```bash
#!/bin/bash
# on-permission-denied.sh
INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty')
REASON=$(echo "$INPUT" | jq -r '.reason // empty')

echo "$(date): PermissionDenied - $TOOL_NAME: $REASON" >> ~/.claude/denied.log

# Reintentar si es un comando git conocido y seguro
if echo "$TOOL_NAME" | grep -q "Bash" && echo "$REASON" | grep -q "git"; then
  echo '{"retry": true}'
  exit 0
fi

exit 0
```

> **Nota:** El evento `PermissionDenied` solo se dispara en sesiones con Auto Mode activo. En el modo de permisos normal, las denegaciones se gestionan por el propio diálogo de permisos.

---

## Decisión "defer" en PreToolUse (v2.1.89)

En sesiones headless (`-p`), los hooks `PreToolUse` ahora pueden devolver la decisión `"defer"` para **pausar la ejecución** de un tool call sin bloquearla ni permitirla. La sesión se detiene en ese punto y puede reanudarse manualmente con `-p --resume`.

```bash
#!/bin/bash
# Hook PreToolUse que difiere operaciones destructivas en headless
INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

if echo "$COMMAND" | grep -qE "(rm -rf|DROP TABLE|docker rmi)"; then
  echo '{"decision": "defer", "reason": "Operación destructiva detectada. Requiere aprobación manual."}'
  exit 0
fi

exit 0
```

Cuando un hook devuelve `"defer"`, la sesión headless se pausa. Para reanudarla:

```bash
claude -p --resume <session-id>
```

Esto es útil en pipelines CI/CD donde ciertas operaciones necesitan aprobación humana antes de continuar.

---

## Hook output superior a 50K caracteres (v2.1.89)

Cuando un hook de tipo `command` produce una salida superior a **50.000 caracteres**, Claude Code guarda el output completo en un fichero temporal en disco y lo reemplaza en la sesión con la **ruta al fichero más un preview** de las primeras líneas. Esto evita que hooks con output masivo (logs, dumps de datos) saturen la ventana de contexto.

El comportamiento es automático y no requiere configuración. El fichero temporal se limpia al cerrar la sesión.

---

## Errores comunes

| Error | Causa | Solución |
|-------|-------|---------|
| Hook agent muy lento | Se lanza en cada operación sin matcher | Añadir `matcher` específico |
| Loop infinito | Hook agent que escribe ficheros y dispara su propio PostToolUse | Usar matcher preciso o flag de guard |
| Usar exit 1 para bloquear | exit 1 no bloquea, solo muestra en verbose | Usar **exit 2** para bloquear operaciones |
| Hooks async que fallan silenciosamente | Los errores de hooks async no interrumpen la sesión | Redirigir stderr a un log |
| Hooks en skills ignorados | Frontmatter YAML mal formateado | Validar el YAML con un linter |
| Leer variables de entorno inexistentes | Los datos llegan vía stdin (JSON), no como env vars | Usar `INPUT=$(cat)` y `jq` para extraer campos |

---

## Resumen

- Los hooks de tipo `agent` lanzan subagentes completos como respuesta a eventos; son los más potentes, pero también los más costosos en tokens
- El nuevo tipo `mcp_tool` (v3.7) permite invocar herramientas de servidores MCP directamente desde un hook, sin script shell intermediario
- Los eventos avanzados (`SessionStart`, `SessionEnd`, `UserPromptSubmit`, `PermissionRequest`, `PostToolUseFailure`, `StopFailure`, `SubagentStart`, `TeammateIdle`, `TaskCompleted`, `Notification`) cubren todo el ciclo de vida de la sesión
- Los **nuevos eventos v3.0** (`PostCompact`, `CwdChanged`, `FileChanged`, `InstructionsLoaded`, `ConfigChange`, `WorktreeCreate`, `WorktreeRemove`, `Elicitation`, `ElicitationResult`) amplían la cobertura a compactación, filesystem, configuración, worktrees y MCP Elicitation
- `PostToolUse` y `PostToolUseFailure` incluyen ahora el campo `duration_ms` (v3.7) con el tiempo de ejecución de la herramienta en milisegundos
- `hookSpecificOutput.updatedToolOutput` en `PostToolUse` permite reemplazar el output de **cualquier herramienta** antes de que Claude lo procese (v3.7); ya no es exclusivo de herramientas MCP
- Los hooks pueden definirse en el frontmatter YAML de skills y subagentes, con alcance limitado a su ejecución; desde v3.7 también se disparan correctamente en sesiones `--agent <nombre>`
- El parámetro `"async": true` permite ejecutar hooks en background para operaciones largas sin bloquear la sesión
- `"timeout"` limita el tiempo máximo de ejecución de un hook async
- Solo **exit 2** bloquea operaciones; exit 1 u otros códigos no-zero no bloquean
