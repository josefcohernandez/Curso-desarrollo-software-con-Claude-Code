#!/bin/bash
# hook-autoformat.sh
# Hook PostToolUse: Auto-formatear archivos despues de Write/Edit
#
# Uso en settings.json:
# {
#   "hooks": {
#     "PostToolUse": [
#       {
#         "matcher": "Write|Edit",
#         "hooks": [
#           {
#             "type": "command",
#             "command": "./scripts/hook-autoformat.sh"
#           }
#         ]
#       }
#     ]
#   }
# }

# Leer datos del hook via JSON en stdin
INPUT=$(cat)
FILEPATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

if [ -z "$FILEPATH" ] || [ ! -f "$FILEPATH" ]; then
    exit 0
fi

# Detectar extension
EXT="${FILEPATH##*.}"

case "$EXT" in
    js|ts|tsx|jsx|json|css|md|yaml|yml)
        # Formatear con Prettier si esta disponible
        if command -v npx &> /dev/null; then
            npx prettier --write "$FILEPATH" 2>/dev/null
        fi
        ;;
    py)
        # Formatear con Ruff/Black si esta disponible
        if command -v ruff &> /dev/null; then
            ruff format "$FILEPATH" 2>/dev/null
            ruff check --fix "$FILEPATH" 2>/dev/null
        elif command -v black &> /dev/null; then
            black "$FILEPATH" 2>/dev/null
        fi
        ;;
    go)
        # Formatear con gofmt
        if command -v gofmt &> /dev/null; then
            gofmt -w "$FILEPATH" 2>/dev/null
        fi
        ;;
    rs)
        # Formatear con rustfmt
        if command -v rustfmt &> /dev/null; then
            rustfmt "$FILEPATH" 2>/dev/null
        fi
        ;;
esac

exit 0
