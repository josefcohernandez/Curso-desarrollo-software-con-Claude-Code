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
        "command": "prettier --write $FILEPATH"
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
        "type": "prompt",
        "prompt": "IMPORTANTE: Mantener siempre el schema de la BD en el resumen"
      }
    ]
  }
}
```

### 3. Agent

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

## Variables Disponibles

| Variable | Descripción | Disponible en |
|----------|------------|--------------|
| `$FILEPATH` | Ruta del archivo afectado | PostToolUse (Write/Edit) |
| `$TOOL_NAME` | Nombre de la herramienta | Pre/PostToolUse |
| `$TOOL_INPUT` | Input de la herramienta (JSON) | Pre/PostToolUse |

---

## Comportamiento de PreToolUse

**Exit code importa**:

| Exit code | Comportamiento |
|-----------|---------------|
| `0` | Permite la operación |
| `1` o no-zero | **Bloquea** la operación |

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
