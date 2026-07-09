# 01 - Sistema de Hooks

## Qué son los Hooks

Los hooks son **comandos shell que se ejecutan automáticamente** cuando ocurren
eventos específicos en Claude Code. Son como "triggers" o "callbacks".

---

## Los 27 Eventos

### Tabla completa de eventos

| Evento | Cuando se dispara | Puede bloquear |
|--------|-------------------|----------------|
| **SessionStart** | La sesión se inicia o se reanuda | No |
| **UserPromptSubmit** | El usuario envía un prompt | Si |
| **PreToolUse** | Antes de ejecutar una herramienta | Si |
| **PermissionRequest** | Aparece un diálogo de permisos | Si |
| **PostToolUse** | Después de una herramienta exitosa | No |
| **PostToolUseFailure** | Después de una herramienta fallida | No |
| **MessageDisplay** | Justo antes de mostrar el texto del asistente al usuario | Puede ocultar/transformar |
| **Notification** | Se envía una notificación | No |
| **SubagentStart** | Subagente creado | No |
| **SubagentStop** | El subagente termina | Si |
| **TaskCreated** | Tarea creada vía TaskCreate | Si |
| **TaskCompleted** | Tarea marcada completa | Si |
| **Stop** | Claude termina de responder | Si |
| **StopFailure** | Error API durante respuesta | No |
| **TeammateIdle** | Un teammate del equipo queda en idle | Si |
| **InstructionsLoaded** | Se cargan `CLAUDE.md` o rules | No |
| **ConfigChange** | Cambia un fichero de configuración | Si |
| **CwdChanged** | Cambia el directorio de trabajo | No |
| **FileChanged** | Cambia un fichero observado | No |
| **WorktreeCreate** | Worktree creado | Si |
| **WorktreeRemove** | Worktree eliminado | No |
| **PreCompact** | Antes de la compactación | No |
| **PostCompact** | Después de la compactación | No |
| **Elicitation** | Servidor MCP solicita input | Si |
| **ElicitationResult** | Usuario responde a elicitation | Si |
| **PermissionDenied** | Auto mode deniega una acción | Sí |
| **SessionEnd** | La sesión termina | No |

---

## Tipos de Hook

### 1. Command (más común)

Ejecuta un comando shell:

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write",
        "hooks": [
          {
            "type": "command",
            "command": "prettier --write $FILEPATH"
          }
        ]
      }
    ]
  }
}
```

#### Forma `exec` sin shell: campo `args` (v2.1.139)

Por defecto, `command` se ejecuta a través de un shell (`sh -c "..."`), lo que permite pipes, variables y expansión de globs, pero también implica el overhead de lanzar un shell intermedio y el riesgo de errores de escaping en comandos con caracteres especiales. Desde v2.1.139, un hook de tipo `command` puede añadir el campo `args` (array de strings) para lanzar el ejecutable **directamente**, sin pasar por shell:

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write(*.py)",
        "hooks": [
          {
            "type": "command",
            "command": "ruff",
            "args": ["format", "$FILEPATH"]
          }
        ]
      }
    ]
  }
}
```

| Forma | Cómo se ejecuta | Cuándo usarla |
|-------|-----------------|----------------|
| Solo `command` (string) | Vía shell (`sh -c`) | Necesitas pipes, `&&`, redirecciones o expansión de variables de shell |
| `command` + `args` (array) | Exec directo del proceso, sin shell | Comando simple con argumentos fijos; evita problemas de escaping y el overhead de un shell intermedio |

> **Nota:** Con la forma `exec`, `$FILEPATH` y otras variables del entorno de hooks se siguen sustituyendo antes de invocar el proceso, pero no hay interpretación de shell (sin `|`, `&&`, comillas de shell, etc.) dentro de cada elemento de `args`.

### 2. Prompt

Inyecta texto en el prompt de Claude:

```json
{
  "hooks": {
    "PreCompact": [
      {
        "hooks": [
          {
            "type": "prompt",
            "prompt": "IMPORTANTE: Mantener siempre el schema de la BD en el resumen"
          }
        ]
      }
    ]
  }
}
```

### 3. HTTP

Envía una petición POST a un endpoint:

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write",
        "hooks": [
          {
            "type": "http",
            "url": "http://localhost:3000/on-file-write"
          }
        ]
      }
    ]
  }
}
```

### 4. Agent

Ejecuta un agente personalizado.

### 5. MCP Tool

> **Novedad v3.7 (v2.1.118)**

Invoca directamente una herramienta de un servidor MCP, sin necesidad de escribir un script shell intermediario. Es la forma más directa de integrar hooks con servidores MCP ya configurados en el proyecto.

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write",
        "hooks": [
          {
            "type": "mcp_tool",
            "server": "nombre-servidor",
            "tool": "nombre-herramienta",
            "input": { "param": "valor" }
          }
        ]
      }
    ]
  }
}
```

Campos obligatorios del tipo `mcp_tool`:

| Campo | Descripción |
|-------|-------------|
| `server` | Nombre del servidor MCP tal como aparece en la configuración |
| `tool` | Nombre de la herramienta a invocar en ese servidor |
| `input` | Objeto con los parámetros de entrada que requiere la herramienta |

Ejemplo de uso real: notificar a un servidor MCP de métricas cada vez que Claude escribe un fichero de código:

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write(src/**/*.ts)",
        "hooks": [
          {
            "type": "mcp_tool",
            "server": "metrics-server",
            "tool": "record_file_write",
            "input": { "project": "mi-proyecto", "language": "typescript" }
          }
        ]
      }
    ]
  }
}
```

> **Cuándo usar `mcp_tool` vs `command`:** Usa `mcp_tool` cuando ya tienes un servidor MCP configurado que expone la funcionalidad que necesitas (notificaciones, métricas, base de datos). Usa `command` para lógica de shell local sin dependencia de un servidor MCP.

---

## Matchers

Los matchers filtran para qué herramienta se dispara el hook:

| Matcher | Coincide con |
|---------|-------------|
| `"Write"` | Cualquier Write |
| `"Bash"` | Cualquier Bash |
| `"Bash(npm*)"` | Solo comandos npm |
| `"Edit"` | Cualquier Edit |
| `"Edit(src/**)"` | Edit en archivos de src/ |

Sin matcher, el hook se dispara para **todas** las herramientas del evento.

---

## Ejecución Condicional con `if`

> **Novedad v3.2 (v2.1.85)**

El campo `if` permite condicionar la ejecución de un hook usando la misma sintaxis de las reglas de permisos. Esto reduce el overhead de creación de procesos: el hook solo se ejecuta si la condición se cumple, sin necesidad de que el propio script evalúe si debe actuar.

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "if": "Bash(git *)",
        "hooks": [
          {
            "type": "command",
            "command": "/scripts/validar-git.sh"
          }
        ]
      }
    ]
  }
}
```

En este ejemplo, el hook solo se ejecuta cuando el comando Bash empieza por `git`. Sin el campo `if`, el hook se dispararía para **cualquier** comando Bash y el script tendría que filtrar internamente.

### Sintaxis de `if`

La sintaxis es idéntica a la de las reglas de permisos (`permissions.allow` / `permissions.deny`):

| Condición | Se cumple cuando |
|-----------|-----------------|
| `"Bash(git *)"` | El comando empieza por `git` |
| `"Write(src/**/*.ts)"` | Se escribe un fichero `.ts` dentro de `src/` |
| `"Edit(*.json)"` | Se edita cualquier fichero JSON |

### Cuándo usar `if` vs. lógica en el script

| Escenario | Recomendación |
|-----------|--------------|
| Filtrar por nombre de herramienta o patrón de fichero | Usar `if`: evita lanzar el proceso |
| Filtrar por contenido del comando o lógica compleja | Usar lógica dentro del script |
| Combinar ambos | Usar `if` para el filtro grueso y el script para el fino |

---

## `continueOnBlock` en `PostToolUse` (v2.1.139)

Cuando varios hooks `PostToolUse` están configurados para el mismo evento (por ejemplo, uno de logging y otro de linting), por defecto si uno de ellos produce una decisión de bloqueo, los hooks restantes de la cadena no se ejecutan. El campo `continueOnBlock: true` cambia ese comportamiento: fuerza a que el resto de hooks del mismo evento se ejecuten igualmente, aunque un hook anterior ya haya señalado un bloqueo.

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write",
        "hooks": [
          {
            "type": "command",
            "command": "/scripts/lint-estricto.sh"
          },
          {
            "type": "command",
            "command": "/scripts/registrar-auditoria.sh",
            "continueOnBlock": true
          }
        ]
      }
    ]
  }
}
```

En este ejemplo, aunque `lint-estricto.sh` señale un problema de calidad de código, `registrar-auditoria.sh` se ejecuta igualmente porque tiene `continueOnBlock: true`. Sin este campo, un bloqueo del linter impediría que el hook de auditoría llegara a ejecutarse.

> **Cuándo usarlo:** Hooks independientes entre sí (logging, métricas, notificaciones) que deben ejecutarse siempre, incluso cuando otro hook del mismo evento reporta un problema. No lo actives en hooks que dependen del resultado de uno anterior para decidir si tiene sentido ejecutarse.

---

## Configuración

En `.claude/settings.json`:

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write",
        "hooks": [
          {
            "type": "command",
            "command": "/ruta/a/script.sh"
          }
        ]
      },
      {
        "matcher": "Edit(*.ts)",
        "hooks": [
          {
            "type": "command",
            "command": "npx eslint --fix $FILEPATH"
          }
        ]
      }
    ],
    "PreToolUse": [
      {
        "matcher": "Bash(rm*)",
        "hooks": [
          {
            "type": "command",
            "command": "/ruta/a/validar-rm.sh"
          }
        ]
      }
    ],
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "echo 'Claude terminó' | notify-send 'Claude Code'"
          }
        ]
      }
    ]
  }
}
```

---

## Datos Disponibles

Los hooks de tipo `command` reciben los datos del evento como **JSON vía stdin**. Los campos disponibles incluyen `tool_input`, `tool_name`, `session_id`, `cwd`, entre otros según el evento.

Para leer los datos del evento en un script bash:

```bash
#!/bin/bash
# Leer JSON del evento vía stdin
INPUT=$(cat)

# Extraer campos con jq
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty')
FILEPATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // empty')
CWD=$(echo "$INPUT" | jq -r '.cwd // empty')
```

> **Importante:** Los datos llegan por stdin como JSON, **no** como variables de entorno. Usar `jq` para extraer los campos necesarios.

### Campo `duration_ms` en PostToolUse y PostToolUseFailure

> **Novedad v3.7 (v2.1.119)**

Los hooks de los eventos `PostToolUse` y `PostToolUseFailure` reciben ahora el campo `duration_ms` en el JSON de entrada: el tiempo en milisegundos que tardó en ejecutarse la herramienta. Este campo es útil para detectar herramientas lentas o construir métricas de rendimiento.

```bash
#!/bin/bash
# Ejemplo: registrar en log las herramientas que tardan más de 2 segundos
INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty')
DURATION=$(echo "$INPUT" | jq -r '.duration_ms // 0')

if [ "$DURATION" -gt 2000 ]; then
  echo "$(date -Iseconds) | LENTO | ${TOOL_NAME} | ${DURATION}ms" >> ~/.claude/perf.log
fi
exit 0
```

Campos de input actualizados para `PostToolUse` y `PostToolUseFailure`:

| Campo | Descripción |
|-------|-------------|
| `tool_name` | Nombre de la herramienta ejecutada |
| `tool_input` | Parámetros de entrada de la herramienta |
| `tool_response` | Respuesta devuelta por la herramienta |
| `duration_ms` | Tiempo de ejecución de la herramienta en milisegundos |
| `session_id` | Identificador de la sesión activa |
| `cwd` | Directorio de trabajo en el momento del evento |

Variables de entorno disponibles (del sistema, no del evento):

| Variable | Descripción |
|----------|------------|
| `$CLAUDE_PROJECT_DIR` | Directorio raiz del proyecto |
| `$CLAUDE_ENV_FILE` | Script de shell que se ejecuta antes de cada comando Bash |

### Effort level en el JSON de entrada (v2.1.133)

Desde v2.1.133, los hooks reciben el **effort level** activo de la sesión (ver `CLAUDE_CODE_EFFORT_LEVEL` en el [Módulo 06](../../modulo-06-planificacion-opus/teoria/04-fast-mode-y-modelos.md)) tanto en el JSON de entrada por stdin como en una variable de entorno, sin necesidad de leer configuración adicional:

```bash
#!/bin/bash
INPUT=$(cat)

# Desde el JSON de entrada
EFFORT_JSON=$(echo "$INPUT" | jq -r '.effort_level // empty')

# Desde la variable de entorno equivalente
EFFORT_ENV="$CLAUDE_CODE_EFFORT_LEVEL"

echo "Effort activo: ${EFFORT_JSON:-$EFFORT_ENV}"
```

| Fuente | Campo/Variable | Disponible en |
|--------|-----------------|----------------|
| JSON por stdin | `effort_level` | Todos los hooks de tipo `command` |
| Variable de entorno | `$CLAUDE_CODE_EFFORT_LEVEL` | Todos los hooks de tipo `command` |

Esto es útil para hooks que adaptan su comportamiento al nivel de razonamiento de la sesión: por ejemplo, un hook de auditoría que solo registra en detalle las operaciones cuando el effort es `high` o `xhigh`, o un hook que evita lanzar un subagente costoso (`type: "agent"`) si la sesión está en `low` porque el usuario ha priorizado velocidad sobre profundidad.

---

## Comportamiento de Exit Codes

Los exit codes determinan cómo reacciona Claude Code al resultado de un hook. Es **crítico** entenderlos para que los hooks de seguridad funcionen correctamente:

| Exit code | Significado | Comportamiento |
|-----------|-------------|----------------|
| `0` | Éxito | Operación permitida; se parsea stdout como JSON |
| `2` | Error bloqueante | Operación **bloqueada**; stderr se muestra a Claude o al usuario |
| Otro (1, etc.) | Error no bloqueante | stderr en modo verbose; la ejecución continúa |

> **Atención:** Solo `exit 2` bloquea la operación. Un `exit 1` **no bloquea**: simplemente muestra stderr en modo verbose y la ejecución continúa normalmente. Si tu hook de seguridad usa `exit 1` para intentar bloquear, **no funcionará**.

### Ejemplo correcto de hook bloqueante

```bash
#!/bin/bash
INPUT=$(cat)
FILEPATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

if echo "$FILEPATH" | grep -q ".env"; then
  echo "BLOQUEADO: No se permite modificar $FILEPATH" >&2
  exit 2  # Exit 2 = bloquea la operación
fi

exit 0  # Exit 0 = permite la operación
```

---

## Síncronos vs Asíncronos

Por defecto, los hooks son **síncronos**: Claude espera a que terminen.

Para hooks que no necesitan bloquear (logging, notificaciones):

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write",
        "hooks": [
          {
            "type": "command",
            "command": "/ruta/log-operacion.sh",
            "async": true
          }
        ]
      }
    ]
  }
}
```

---

## Ver Hooks Activos

```bash
claude
> /hooks    # Lista todos los hooks configurados
```
