# 02 - 7 Hooks Prácticos

## Hook 1: Auto-formateo con Prettier

Después de que Claude escriba o edite un archivo, formatearlo automáticamente:

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write(*.{ts,tsx,js,jsx,json,css,md})",
        "hooks": [
          {
            "type": "command",
            "command": "npx prettier --write $FILEPATH"
          }
        ]
      },
      {
        "matcher": "Edit(*.{ts,tsx,js,jsx,json,css,md})",
        "hooks": [
          {
            "type": "command",
            "command": "npx prettier --write $FILEPATH"
          }
        ]
      }
    ]
  }
}
```

Para Python:

```json
{
  "matcher": "Write(*.py)",
  "hooks": [
    {
      "type": "command",
      "command": "ruff format $FILEPATH && ruff check --fix $FILEPATH"
    }
  ]
}
```

---

## Hook 2: Linter después de Cambios

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit(*.ts)",
        "hooks": [
          {
            "type": "command",
            "command": "npx eslint $FILEPATH --max-warnings 0"
          }
        ]
      }
    ]
  }
}
```

Si el linter falla (exit code no-zero), Claude ve el error y puede corregir.

---

## Hook 3: Tests Automáticos

Ejecutar tests del archivo modificado:

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit(src/**/*.ts)",
        "hooks": [
          {
            "type": "command",
            "command": "npx vitest run --reporter=verbose $(echo $FILEPATH | sed 's/src/tests/' | sed 's/.ts/.test.ts/')"
          }
        ]
      }
    ]
  }
}
```

---

## Hook 4: Logging de Operaciones

Registrar todas las operaciones de Claude para auditoría:

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "./scripts/hook-security-audit.sh",
            "async": true
          }
        ]
      }
    ]
  }
}
```

Script `hook-security-audit.sh`:

```bash
#!/bin/bash
INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // "unknown"')
FILEPATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // "N/A"')

LOG_DIR="$HOME/.claude/audit"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/$(date +%Y-%m-%d).log"

echo "$(date +%H:%M:%S) | ${TOOL_NAME} | ${FILEPATH}" >> "$LOG_FILE"
```

---

## Hook 5: Bloquear Escritura en Directorios Protegidos

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Write",
        "hooks": [
          {
            "type": "command",
            "command": "./scripts/hook-block-protected.sh"
          }
        ]
      },
      {
        "matcher": "Edit",
        "hooks": [
          {
            "type": "command",
            "command": "./scripts/hook-block-protected.sh"
          }
        ]
      }
    ]
  }
}
```

Script `hook-block-protected.sh`:

```bash
#!/bin/bash
INPUT=$(cat)
FILEPATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

if echo "$FILEPATH" | grep -qE "(config/production|\.env|secrets/)"; then
  echo "BLOQUEADO: Archivo protegido: $FILEPATH" >&2
  exit 2  # Exit 2 = bloquea la operación
fi

exit 0
```

> **Importante:** Se usa `exit 2` para bloquear. Un `exit 1` no bloquea la operación; solo muestra el error en modo verbose.

---

## Hook 6: Inyectar Contexto en PreCompact

Cuando el contexto se compacta, hay que asegurar que la información crítica no se pierda:

```json
{
  "hooks": {
    "PreCompact": [
      {
        "hooks": [
          {
            "type": "prompt",
            "prompt": "CRITICO: Mantener en el resumen: schema actual de BD (users, orders, products), endpoints implementados, y decisiones de arquitectura pendientes."
          }
        ]
      }
    ]
  }
}
```

### Bloquear la compactación (desde v2.1.105)

Además de inyectar contexto con `prompt`, desde la versión 2.1.105 un hook `PreCompact` puede **bloquear completamente la compactación**. Esto es útil cuando la sesión contiene contexto crítico que no puede perderse bajo ningún concepto (por ejemplo, un estado de depuración complejo o un conjunto de decisiones de diseño aún no documentadas).

Dos mecanismos equivalentes para bloquear:

- **Exit code 2** en el script shell
- Devolver `{"decision": "block"}` en stdout como JSON

```json
{
  "hooks": {
    "PreCompact": [
      {
        "type": "command",
        "command": "echo '{\"decision\": \"block\"}'",
        "description": "Bloquea compactación cuando hay contexto crítico activo"
      }
    ]
  }
}
```

Ejemplo con lógica condicional: bloquear solo si existe un fichero centinela que indica que la sesión tiene estado crítico activo.

```bash
#!/bin/bash
# precompact-guard.sh
# Bloquea la compactación si el proyecto está en modo depuración activa

if [ -f ".claude/no-compact" ]; then
  echo "Compactación bloqueada: fichero .claude/no-compact presente." >&2
  exit 2
fi

exit 0
```

> **Nota:** Al bloquear la compactación, el contexto continúa creciendo hasta alcanzar el límite de la context window. Usar este mecanismo de forma puntual y eliminar el bloqueo (o el fichero centinela) en cuanto el contexto crítico ya no sea necesario.

---

## Hook 7: Notificación al Terminar

Recibir una notificación cuando Claude termina una tarea larga:

### Linux

```json
{
  "hooks": {
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "notify-send 'Claude Code' 'Tarea completada'",
            "async": true
          }
        ]
      }
    ]
  }
}
```

### macOS

```json
{
  "hooks": {
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "osascript -e 'display notification \"Tarea completada\" with title \"Claude Code\"'",
            "async": true
          }
        ]
      }
    ]
  }
}
```

---

## Hook 8: Registro de escrituras via MCP Tool

> **Novedad v2.1.118**

En lugar de escribir un script de logging, es posible invocar directamente una herramienta MCP de filesystem para registrar cada escritura. Esto elimina el proceso intermediario y simplifica la configuración:

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write",
        "hooks": [
          {
            "type": "mcp_tool",
            "tool": "filesystem/log_write",
            "input": {
              "path": "/tmp/claude-writes.log",
              "content": "Fichero escrito: {{ timestamp }}"
            }
          }
        ]
      }
    ]
  }
}
```

La diferencia respecto al tipo `command` es que no se lanza ningún proceso bash: el hook llama directamente a la herramienta MCP `filesystem/log_write` del servidor `filesystem`. La variable de plantilla `{{ timestamp }}` se sustituye automáticamente por la fecha y hora del evento.

Este tipo de hook es especialmente útil cuando ya se usa un servidor MCP de filesystem (como el servidor oficial `@modelcontextprotocol/server-filesystem`) y se quiere centralizar el logging sin añadir scripts auxiliares.

---

## Resumen de Hooks

| # | Propósito | Evento | Matcher | Tipo | Sync? |
|---|----------|--------|---------|------|-------|
| 1 | Auto-formateo | PostToolUse | Write/Edit(*.ts) | command | Si |
| 2 | Linter | PostToolUse | Edit(*.ts) | command | Si |
| 3 | Tests auto | PostToolUse | Edit(src/**) | command | Si |
| 4 | Logging | PostToolUse | (todos) | command | No (async) |
| 5 | Bloquear protegido | PreToolUse | Write/Edit | command | Si |
| 6 | Contexto crítico | PreCompact | - | prompt | Si |
| 7 | Notificación | Stop | - | command | No (async) |
| 8 | Registro via MCP | PostToolUse | Write | mcp_tool | Si |
