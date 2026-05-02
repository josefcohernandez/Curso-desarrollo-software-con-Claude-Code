# Ejercicio 02: Hooks de Seguridad

## Objetivo

Implementar hooks que protejan archivos sensibles y auditen operaciones
y notifiquen al terminar.

---

## Parte 1: Hook Bloquear Directorios Protegidos (15 min)

Crea `scripts/hook-block-protected.sh`:

```bash
#!/bin/bash
# Leer datos del evento vía stdin (JSON)
INPUT=$(cat)
FILEPATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

PROTECTED=("config/production" ".env" "secrets/" "credentials" ".pem" ".key")

for pattern in "${PROTECTED[@]}"; do
    if echo "$FILEPATH" | grep -qi "$pattern"; then
        echo "BLOQUEADO: Archivo protegido: $FILEPATH" >&2
        exit 2  # Exit 2 = bloquea la operación
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

Debería ser **bloqueado** por el hook.

```
> "Crea un archivo src/app.js con un hello world"
```

Debería funcionar normalmente.

---

## Parte 2: Hook de Auditoria (10 min)

Crea `scripts/hook-security-audit.sh` (puedes partir del script
de ejemplo incluido en este modulo):

```bash
#!/bin/bash
# Leer datos del evento vía stdin (JSON)
INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty')
FILEPATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

LOG_DIR="$HOME/.claude/audit"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/$(date +%Y-%m-%d).log"

echo "$(date +%H:%M:%S) | ${TOOL_NAME:-unknown} | ${FILEPATH:-N/A}" >> "$LOG_FILE"
```

```bash
chmod +x scripts/hook-security-audit.sh
```

Añade al settings.json:

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

### Verificar

Haz algunas operaciones con Claude y luego:

```bash
cat ~/.claude/audit/$(date +%Y-%m-%d).log
```

---

## Parte 3: Hook de Notificacion (5 min)

Añade al settings.json:

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

O con notificación de sistema (Linux):

```json
{
  "hooks": {
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "notify-send 'Claude Code' 'Tarea completada' 2>/dev/null || true",
            "async": true
          }
        ]
      }
    ]
  }
}
```

---

## Parte 4: Testing de Hooks (10 min)

Prueba cada hook aislado. Dado que los hooks reciben datos vía stdin (JSON), se simulan con un pipe:

```bash
# Test 1: Archivo protegido (debe bloquear con exit 2)
echo '{"tool_name":"Write","tool_input":{"file_path":".env"}}' | ./scripts/hook-block-protected.sh
echo "Exit: $?"  # Debe ser 2

# Test 2: Archivo normal (debe permitir con exit 0)
echo '{"tool_name":"Write","tool_input":{"file_path":"src/app.js"}}' | ./scripts/hook-block-protected.sh
echo "Exit: $?"  # Debe ser 0

# Test 3: Auditoría
echo '{"tool_name":"Write","tool_input":{"file_path":"src/test.js"}}' | ./scripts/hook-security-audit.sh
cat ~/.claude/audit/$(date +%Y-%m-%d).log
```

---

## Criterios de Completitud

- [ ] Hook de protección creado y funcionando
- [ ] Archivo .env bloqueado (exit 2)
- [ ] Archivo normal permitido (exit 0)
- [ ] Hook de auditoría creado y log generándose
- [ ] Hook de notificación configurado
- [ ] Hooks testeados aisladamente con JSON vía stdin
