# 03 - Hooks de Seguridad

## PreToolUse como Guardián

El evento **PreToolUse** es la herramienta principal de seguridad:
- Se ejecuta **antes** de cada operación
- Si el script retorna **exit 1**, la operación se **bloquea**
- Puede validar comandos, archivos y patrones

---

## Hook: Validar Comandos Bash

Bloquear comandos peligrosos que no están en la lista de deny:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "command": "/ruta/a/validate-bash.sh"
      }
    ]
  }
}
```

```bash
#!/bin/bash
# validate-bash.sh
COMMAND="$TOOL_INPUT"

# Patrones peligrosos
DANGEROUS_PATTERNS=(
    "rm -rf /"
    "rm -rf /*"
    ":(){ :|:& };:"
    "> /dev/sda"
    "mkfs"
    "dd if=/dev"
    "chmod -R 777"
    "curl.*| bash"
    "wget.*| bash"
)

for pattern in "${DANGEROUS_PATTERNS[@]}"; do
    if echo "$COMMAND" | grep -qiF "$pattern"; then
        echo "BLOQUEADO: Comando peligroso detectado: $pattern"
        exit 1
    fi
done

exit 0
```

---

## Hook: Proteger Archivos Sensibles

```bash
#!/bin/bash
# protect-files.sh
FILEPATH="$FILEPATH"

PROTECTED_PATTERNS=(
    ".env"
    ".env.production"
    "credentials"
    "secrets"
    "id_rsa"
    "*.pem"
    "*.key"
    "config/production"
)

for pattern in "${PROTECTED_PATTERNS[@]}"; do
    if echo "$FILEPATH" | grep -qi "$pattern"; then
        echo "BLOQUEADO: Archivo protegido: $FILEPATH"
        exit 1
    fi
done

exit 0
```

---

## Hook: Auditoría de Operaciones

Registrar todas las operaciones para revisión posterior:

```bash
#!/bin/bash
# audit-log.sh
LOG_FILE="${HOME}/.claude/audit.log"

echo "$(date -Iseconds) | USER=${USER} | TOOL=${TOOL_NAME} | FILE=${FILEPATH}" >> "$LOG_FILE"
```

### Formato del log

```
2026-02-11T10:30:00+01:00 | USER=developer | TOOL=Write | FILE=src/auth.ts
2026-02-11T10:30:15+01:00 | USER=developer | TOOL=Bash | FILE=
2026-02-11T10:31:00+01:00 | USER=developer | TOOL=Edit | FILE=src/routes.ts
```

---

## Hook: Prevenir Acceso Fuera del Proyecto

```bash
#!/bin/bash
# check-project-boundary.sh
PROJECT_ROOT="/home/user/mi-proyecto"
FILEPATH="$FILEPATH"

if [ -n "$FILEPATH" ]; then
    REAL_PATH=$(realpath "$FILEPATH" 2>/dev/null || echo "$FILEPATH")
    if [[ "$REAL_PATH" != "$PROJECT_ROOT"* ]]; then
        echo "BLOQUEADO: Acceso fuera del proyecto: $FILEPATH"
        exit 1
    fi
fi

exit 0
```

---

## PreToolUse para Integraciones Headless

> **Novedad v3.2 (v2.1.85)**

Los hooks `PreToolUse` ahora pueden **satisfacer automáticamente** la herramienta `AskUserQuestion` devolviendo `updatedInput` junto con `permissionDecision: "allow"`. Esto permite que integraciones headless (CI/CD, pipelines automatizados, agentes remotos) respondan a preguntas de Claude sin intervención humana.

```bash
#!/bin/bash
# auto-responder-headless.sh
# Responde automáticamente a AskUserQuestion en entornos headless

INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name')

if [ "$TOOL_NAME" = "AskUserQuestion" ]; then
  QUESTION=$(echo "$INPUT" | jq -r '.tool_input.question // empty')

  # Responder automáticamente según el patrón de la pregunta
  if echo "$QUESTION" | grep -qi "continuar"; then
    echo '{"permissionDecision":"allow","updatedInput":"Sí, continúa con la implementación."}'
    exit 0
  fi
fi

# Para cualquier otra herramienta, permitir sin modificar
exit 0
```

Configuración:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "AskUserQuestion",
        "command": "/scripts/auto-responder-headless.sh"
      }
    ]
  }
}
```

Esto es especialmente útil en combinación con el modo no interactivo (`claude -p`) donde no hay un usuario para responder preguntas.

---

## Riesgos de Hooks Mal Configurados

| Riesgo | Consecuencia | Prevención |
|--------|-------------|-----------|
| Hook lento | Bloquea cada operación | Timeout, async cuando posible |
| Hook con bug | Bloquea todo | Probar hooks aislados |
| Hook que expone datos | Log con secrets | No loggear TOOL_INPUT completo |
| Hook sin exit 0 | Bloquea operaciones válidas | Siempre exit 0 al final |
| Hook recursivo | Loop infinito | No llamar Claude desde hooks |

---

## Testing de Hooks

Antes de activar un hook, pruébalo aislado:

```bash
# Simular variables
export FILEPATH="src/auth.ts"
export TOOL_NAME="Write"

# Ejecutar
bash hook-protect-files.sh
echo "Exit code: $?"   # Debe ser 0 (no protegido)

export FILEPATH=".env.production"
bash hook-protect-files.sh
echo "Exit code: $?"   # Debe ser 1 (protegido)
```

---

## Configuración Recomendada de Seguridad

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "command": "/scripts/validate-bash.sh"
      },
      {
        "matcher": "Write",
        "command": "/scripts/protect-files.sh"
      },
      {
        "matcher": "Edit",
        "command": "/scripts/protect-files.sh"
      }
    ],
    "PostToolUse": [
      {
        "command": "/scripts/audit-log.sh",
        "async": true
      }
    ]
  }
}
```
