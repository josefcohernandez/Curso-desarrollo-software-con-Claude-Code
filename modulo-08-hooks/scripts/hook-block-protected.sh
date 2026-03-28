#!/bin/bash
# hook-block-protected.sh
# Hook PreToolUse: Bloquear escritura en archivos/directorios protegidos
# Exit 2 = bloquear (blocking error), Exit 0 = permitir
#
# Uso en settings.json:
# {
#   "hooks": {
#     "PreToolUse": [
#       {
#         "matcher": "Write|Edit",
#         "hooks": [
#           {
#             "type": "command",
#             "command": "./scripts/hook-block-protected.sh"
#           }
#         ]
#       }
#     ]
#   }
# }

# Leer datos del hook via JSON en stdin
INPUT=$(cat)
FILEPATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

# Si no hay filepath, permitir (puede ser otro tipo de operacion)
if [ -z "$FILEPATH" ]; then
    exit 0
fi

# Lista de patrones protegidos
PROTECTED_PATTERNS=(
    ".env"
    ".env.production"
    ".env.staging"
    "config/production"
    "secrets/"
    "credentials"
    ".pem"
    ".key"
    "id_rsa"
    "id_ed25519"
    ".secret"
    "password"
    "token.json"
)

for pattern in "${PROTECTED_PATTERNS[@]}"; do
    if echo "$FILEPATH" | grep -qi "$pattern"; then
        echo "BLOQUEADO: No se permite modificar archivo protegido: $FILEPATH" >&2
        echo "Patron detectado: $pattern" >&2
        exit 2
    fi
done

# Permitir
exit 0
