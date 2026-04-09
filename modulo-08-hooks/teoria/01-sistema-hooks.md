# 01 - Sistema de Hooks

## Que son los Hooks

Los hooks son **comandos shell que se ejecutan automaticamente** cuando ocurren
eventos especificos en Claude Code. Son como "triggers" o "callbacks".

---

## Los 26 Eventos

### Tabla completa de eventos

| Evento | Cuando se dispara | Puede bloquear |
|--------|-------------------|----------------|
| **SessionStart** | Sesion inicia o se reanuda | No |
| **UserPromptSubmit** | Usuario envia un prompt | Si |
| **PreToolUse** | Antes de ejecutar una herramienta | Si |
| **PermissionRequest** | Dialogo de permisos aparece | Si |
| **PostToolUse** | Despues de herramienta exitosa | No |
| **PostToolUseFailure** | Despues de herramienta fallida | No |
| **Notification** | Notificacion enviada | No |
| **SubagentStart** | Subagente creado | No |
| **SubagentStop** | Subagente termina | Si |
| **TaskCreated** | Tarea creada via TaskCreate | Si |
| **TaskCompleted** | Tarea marcada completa | Si |
| **Stop** | Claude termina de responder | Si |
| **StopFailure** | Error API durante respuesta | No |
| **TeammateIdle** | Teammate de equipo va a idle | Si |
| **InstructionsLoaded** | CLAUDE.md o rules cargados | No |
| **ConfigChange** | Fichero de configuracion cambia | Si |
| **CwdChanged** | Directorio de trabajo cambia | No |
| **FileChanged** | Fichero observado cambia | No |
| **WorktreeCreate** | Worktree creado | Si |
| **WorktreeRemove** | Worktree eliminado | No |
| **PreCompact** | Antes de compactacion | No |
| **PostCompact** | Despues de compactacion | No |
| **Elicitation** | Servidor MCP solicita input | Si |
| **ElicitationResult** | Usuario responde a elicitation | Si |
| **PermissionDenied** | Auto mode deniega una acción | Sí |
| **SessionEnd** | Sesion termina | No |

---

## Tipos de Hook

### 1. Command (mas comun)

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

Envia una peticion POST a un endpoint:

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

---

## Matchers

Los matchers filtran para que herramienta se dispara el hook:

| Matcher | Coincide con |
|---------|-------------|
| `"Write"` | Cualquier Write |
| `"Bash"` | Cualquier Bash |
| `"Bash(npm*)"` | Solo comandos npm |
| `"Edit"` | Cualquier Edit |
| `"Edit(src/**)"` | Edit en archivos de src/ |

Sin matcher, el hook se dispara para **todas** las herramientas del evento.

---

## Ejecucion Condicional con `if`

> **Novedad v3.2 (v2.1.85)**

El campo `if` permite condicionar la ejecucion de un hook usando la misma sintaxis de las reglas de permisos. Esto reduce el overhead de spawning de procesos: el hook solo se ejecuta si la condicion se cumple, sin necesidad de que el propio script evalue si debe actuar.

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

En este ejemplo, el hook solo se ejecuta cuando el comando Bash empieza por `git`. Sin el campo `if`, el hook se dispararia para **cualquier** comando Bash y el script tendria que filtrar internamente.

### Sintaxis de `if`

La sintaxis es identica a la de las reglas de permisos (`permissions.allow` / `permissions.deny`):

| Condicion | Se cumple cuando |
|-----------|-----------------|
| `"Bash(git *)"` | El comando empieza por `git` |
| `"Write(src/**/*.ts)"` | Se escribe un fichero `.ts` dentro de `src/` |
| `"Edit(*.json)"` | Se edita cualquier fichero JSON |

### Cuando usar `if` vs logica en el script

| Escenario | Recomendacion |
|-----------|--------------|
| Filtrar por nombre de herramienta o patron de fichero | Usar `if` -- evita lanzar el proceso |
| Filtrar por contenido del comando o logica compleja | Usar logica dentro del script |
| Combinar ambos | Usar `if` para el filtro grueso y el script para el fino |

---

## Configuracion

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
            "command": "echo 'Claude termino' | notify-send 'Claude Code'"
          }
        ]
      }
    ]
  }
}
```

---

## Datos Disponibles

Los hooks de tipo `command` reciben los datos del evento como **JSON via stdin**. Los campos disponibles incluyen `tool_input`, `tool_name`, `session_id`, `cwd`, entre otros dependiendo del evento.

Para leer los datos del evento en un script bash:

```bash
#!/bin/bash
# Leer JSON del evento via stdin
INPUT=$(cat)

# Extraer campos con jq
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty')
FILEPATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // empty')
CWD=$(echo "$INPUT" | jq -r '.cwd // empty')
```

> **Importante:** Los datos llegan por stdin como JSON, **no** como variables de entorno. Usar `jq` para extraer los campos necesarios.

Variables de entorno disponibles (del sistema, no del evento):

| Variable | Descripcion |
|----------|------------|
| `$CLAUDE_PROJECT_DIR` | Directorio raiz del proyecto |
| `$CLAUDE_ENV_FILE` | Script de shell que se ejecuta antes de cada comando Bash |

---

## Comportamiento de Exit Codes

Los exit codes determinan como reacciona Claude Code al resultado de un hook. Es **critico** entenderlos para que los hooks de seguridad funcionen correctamente:

| Exit code | Significado | Comportamiento |
|-----------|-------------|----------------|
| `0` | Exito | Operacion permitida, se parsea stdout como JSON |
| `2` | Error bloqueante | Operacion **bloqueada**, stderr se muestra a Claude/usuario |
| Otro (1, etc.) | Error no bloqueante | stderr en modo verbose, ejecucion continua |

> **Atencion:** Solo `exit 2` bloquea la operacion. Un `exit 1` **no bloquea**: simplemente muestra el stderr en modo verbose y la ejecucion continua normalmente. Si tu hook de seguridad usa `exit 1` para intentar bloquear, **no funcionara**.

### Ejemplo correcto de hook bloqueante

```bash
#!/bin/bash
INPUT=$(cat)
FILEPATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

if echo "$FILEPATH" | grep -q ".env"; then
  echo "BLOQUEADO: No se permite modificar $FILEPATH" >&2
  exit 2  # Exit 2 = bloquea la operacion
fi

exit 0  # Exit 0 = permite la operacion
```

---

## Sincronos vs Asincronos

Por defecto, los hooks son **sincronos**: Claude espera a que terminen.

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
