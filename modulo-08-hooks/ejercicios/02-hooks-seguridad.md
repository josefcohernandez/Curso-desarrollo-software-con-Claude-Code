# Ejercicio 02: Hooks de Seguridad

## Objetivo

Implementar hooks que protejan archivos sensibles, auditen operaciones
y notifiquen al terminar.

---

## Parte 1: Hook Bloquear Directorios Protegidos (15 min)

Crea `scripts/hook-block-protected.sh`:

```bash
#!/bin/bash
# Leer datos del evento via stdin (JSON)
INPUT=$(cat)
FILEPATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

PROTECTED=("config/production" ".env" "secrets/" "credentials" ".pem" ".key")

for pattern in "${PROTECTED[@]}"; do
    if echo "$FILEPATH" | grep -qi "$pattern"; then
        echo "BLOQUEADO: Archivo protegido: $FILEPATH" >&2
        exit 2  # Exit 2 = bloquea la operacion
    fi
done
exit 0
```

```bash
chmod +x scripts/hook-block-protected.sh
```

Configura en `.claude/settings.json`:

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

### Verificar

```bash
claude
> "Crea un archivo .env con DATABASE_URL=..."
```

Deberia ser **bloqueado** por el hook.

```
> "Crea un archivo src/app.js con un hello world"
```

Deberia funcionar normalmente.

---

## Parte 2: Hook de Auditoria (10 min)

Crea `scripts/hook-audit.sh`:

```bash
#!/bin/bash
# Leer datos del evento via stdin (JSON)
INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty')
FILEPATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

LOG_DIR="$HOME/.claude/audit"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/$(date +%Y-%m-%d).log"

echo "$(date +%H:%M:%S) | ${TOOL_NAME:-unknown} | ${FILEPATH:-N/A}" >> "$LOG_FILE"
```

```bash
chmod +x scripts/hook-audit.sh
```

Anade al settings.json:

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "./scripts/hook-audit.sh",
            "async": true
          }
        ]
      }
    ]
  }
}
```

### Verificar

Haz algunas operaciones con Claude y luego:

```bash
cat ~/.claude/audit/$(date +%Y-%m-%d).log
```

---

## Parte 3: Hook de Notificacion (5 min)

Anade al settings.json:

```json
{
  "hooks": {
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "echo '\\a'",
            "async": true
          }
        ]
      }
    ]
  }
}
```

O con notificacion de sistema (Linux):

```json
{
  "hooks": [
    {
      "type": "command",
      "command": "notify-send 'Claude Code' 'Tarea completada' 2>/dev/null || true"
    }
  ]
}
```

---

## Parte 4: Testing de Hooks (10 min)

Prueba cada hook aislado. Dado que los hooks reciben datos via stdin (JSON), se simulan con un pipe:

```bash
# Test 1: Archivo protegido (debe bloquear con exit 2)
echo '{"tool_name":"Write","tool_input":{"file_path":".env"}}' | ./scripts/hook-block-protected.sh
echo "Exit: $?"  # Debe ser 2

# Test 2: Archivo normal (debe permitir con exit 0)
echo '{"tool_name":"Write","tool_input":{"file_path":"src/app.js"}}' | ./scripts/hook-block-protected.sh
echo "Exit: $?"  # Debe ser 0

# Test 3: Auditoria
echo '{"tool_name":"Write","tool_input":{"file_path":"src/test.js"}}' | ./scripts/hook-audit.sh
cat ~/.claude/audit/$(date +%Y-%m-%d).log
```

---

## Criterios de Completitud

- [ ] Hook de proteccion creado y funcionando
- [ ] Archivo .env bloqueado (exit 2)
- [ ] Archivo normal permitido (exit 0)
- [ ] Hook de auditoria creado y log generandose
- [ ] Hook de notificacion configurado
- [ ] Hooks testeados aisladamente con JSON via stdin
