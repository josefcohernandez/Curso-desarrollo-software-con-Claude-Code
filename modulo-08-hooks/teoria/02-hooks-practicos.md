# 02 - 7 Hooks Practicos

## Hook 1: Auto-formateo con Prettier

Despues de que Claude escriba o edite un archivo, formatearlo automaticamente:

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

## Hook 2: Linter despues de Cambios

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

## Hook 3: Tests Automaticos

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

Registrar todas las operaciones de Claude para auditoria:

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "/scripts/hook-audit-log.sh",
            "async": true
          }
        ]
      }
    ]
  }
}
```

Script `hook-audit-log.sh`:

```bash
#!/bin/bash
INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty')
FILEPATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

echo "$(date +%Y-%m-%dT%H:%M:%S) | ${TOOL_NAME} | ${FILEPATH:-N/A}" >> /tmp/claude-audit.log
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
            "command": "/scripts/hook-block-protected.sh"
          }
        ]
      },
      {
        "matcher": "Edit",
        "hooks": [
          {
            "type": "command",
            "command": "/scripts/hook-block-protected.sh"
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
  exit 2  # Exit 2 = bloquea la operacion
fi

exit 0
```

> **Importante:** Se usa `exit 2` para bloquear. Un `exit 1` no bloquea la operacion, solo muestra el error en modo verbose.

---

## Hook 6: Inyectar Contexto en PreCompact

Cuando el contexto se compacta, asegurar que informacion critica no se pierde:

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

---

## Hook 7: Notificacion al Terminar

Recibir notificacion cuando Claude termina una tarea larga:

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

## Resumen de Hooks

| # | Proposito | Evento | Matcher | Sync? |
|---|----------|--------|---------|-------|
| 1 | Auto-formateo | PostToolUse | Write/Edit(*.ts) | Si |
| 2 | Linter | PostToolUse | Edit(*.ts) | Si |
| 3 | Tests auto | PostToolUse | Edit(src/**) | Si |
| 4 | Logging | PostToolUse | (todos) | No (async) |
| 5 | Bloquear protegido | PreToolUse | Write/Edit | Si |
| 6 | Contexto critico | PreCompact | - | Si |
| 7 | Notificacion | Stop | - | No (async) |
