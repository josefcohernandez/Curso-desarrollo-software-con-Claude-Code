# 01 - Sistema de Hooks

## Qué son los Hooks

Los hooks son **comandos shell que se ejecutan automáticamente** cuando ocurren
eventos específicos en Claude Code. Son como "triggers" o "callbacks".

---

## Los 17 Eventos

### Eventos básicos (desde v2.0)

| Evento | Cuándo se dispara | Uso típico |
|--------|------------------|-----------|
| **PreToolUse** | Antes de ejecutar una herramienta | Validar, bloquear |
| **PostToolUse** | Después de ejecutar una herramienta | Formatear, auditar |
| **Stop** | Cuando Claude termina una respuesta | Notificar, limpiar |
| **SubagentStop** | Cuando un subagente termina | Auditar subagentes |
| **PreCompact** | Antes de compactar el contexto | Inyectar contexto crítico |
| **TextInput** | Cuando el usuario escribe texto | Preprocesar input |
| **Notification** | Cuando hay una notificación | Alertas externas |

### Eventos nuevos (v2.1.76 - v2.1.84)

| Evento | Cuándo se dispara | Uso típico |
|--------|------------------|-----------|
| **TaskCreated** | Cuando se crea una tarea (TaskCreate) | Logging, notificacion, asignacion automatica |
| **PostCompact** | Después de compactar el contexto | Verificar resumen, logging. Incluye campo `compact_summary` |
| **CwdChanged** | Cuando cambia el directorio de trabajo | Recargar .env, activar direnv |
| **FileChanged** | Cuando se modifica un fichero | Auto-reload, validación |
| **InstructionsLoaded** | Cuando se cargan instrucciones (CLAUDE.md, rules) | Validar reglas, auditoría |
| **ConfigChange** | Cuando cambia la configuración | Auditar cambios, notificar |
| **WorktreeCreate** | Cuando se crea un worktree para un subagente | Setup del worktree |
| **WorktreeRemove** | Cuando se elimina un worktree | Cleanup de recursos |
| **Elicitation** | Cuando un servidor MCP solicita input (MCP Elicitation) | Interceptar solicitudes de input |
| **ElicitationResult** | Cuando el usuario responde a una elicitation | Interceptar/override respuestas |

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

El campo `if` permite condicionar la ejecución de un hook usando la misma sintaxis de las reglas de permisos. Esto reduce el overhead de spawning de procesos: el hook solo se ejecuta si la condición se cumple, sin necesidad de que el propio script evalúe si debe actuar.

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "if": "Bash(git *)",
        "command": "/scripts/validar-git.sh"
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

### Cuándo usar `if` vs lógica en el script

| Escenario | Recomendación |
|-----------|--------------|
| Filtrar por nombre de herramienta o patrón de fichero | Usar `if` — evita lanzar el proceso |
| Filtrar por contenido del comando o lógica compleja | Usar lógica dentro del script |
| Combinar ambos | Usar `if` para el filtro grueso y el script para el fino |

---

## Configuración

En `.claude/settings.json`:

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write",
        "command": "/ruta/a/script.sh"
      },
      {
        "matcher": "Edit(*.ts)",
        "command": "npx eslint --fix $FILEPATH"
      }
    ],
    "PreToolUse": [
      {
        "matcher": "Bash(rm*)",
        "command": "/ruta/a/validar-rm.sh"
      }
    ],
    "Stop": [
      {
        "command": "echo 'Claude terminó' | notify-send 'Claude Code'"
      }
    ]
  }
}
```

---

## Datos Disponibles

Los hooks de tipo `command` reciben los datos del evento como **JSON vía stdin**. Los campos disponibles incluyen `tool_input`, `tool_name`, `session_id`, `cwd`, entre otros dependiendo del evento.

Variables de entorno disponibles:

| Variable | Descripción |
|----------|------------|
| `$CLAUDE_PROJECT_DIR` | Directorio raíz del proyecto |
| `$CLAUDE_ENV_FILE` | Script de shell que se ejecuta antes de cada comando Bash |

---

## Comportamiento de PreToolUse

**Exit code importa**:

| Exit code | Comportamiento |
|-----------|---------------|
| `0` | Permite la operación |
| `2` | **Bloquea** la operación (el único código que bloquea) |
| `1` u otro no-zero | Error no bloqueante (stderr se muestra en modo verbose, la ejecución continúa) |

Esto permite crear "guardianes" que validan antes de ejecutar.

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
        "command": "/ruta/log-operacion.sh",
        "async": true
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
