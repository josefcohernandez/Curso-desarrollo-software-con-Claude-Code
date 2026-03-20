#!/bin/bash
# =============================================================================
# Script: Revision Automatica de Codigo con Claude Code
# =============================================================================
#
# Descripcion:
#   Analiza los cambios staged en Git (o un diff proporcionado) y genera
#   una revision de codigo detallada usando Claude Code en modo no interactivo.
#
# Uso:
#   ./script-review-codigo.sh              # Revisa cambios staged
#   ./script-review-codigo.sh --all        # Revisa todos los cambios (staged + unstaged)
#   ./script-review-codigo.sh --branch     # Revisa cambios vs rama principal
#   ./script-review-codigo.sh --file archivo.py  # Revisa un archivo especifico
#
# Requisitos:
#   - Claude Code instalado (curl -fsSL https://claude.ai/install.sh | bash)
#   - ANTHROPIC_API_KEY configurada como variable de entorno
#   - Git inicializado en el directorio actual
#   - jq instalado (para procesar JSON)
#
# Salida:
#   - Imprime la revision en la terminal
#   - Guarda un informe JSON en /tmp/review-YYYYMMDD-HHMMSS.json
#
# =============================================================================

set -euo pipefail

# -----------------------------------------------------------------------------
# Configuracion
# -----------------------------------------------------------------------------

# Colores para la terminal
ROJO='\033[0;31m'
VERDE='\033[0;32m'
AMARILLO='\033[1;33m'
AZUL='\033[0;34m'
GRIS='\033[0;90m'
NEGRITA='\033[1m'
SIN_COLOR='\033[0m'

# Limites por defecto
MAX_TURNS="${CLAUDE_MAX_TURNS:-3}"
MAX_BUDGET="${CLAUDE_MAX_BUDGET:-0.10}"
OUTPUT_DIR="${CLAUDE_OUTPUT_DIR:-/tmp}"

# Rama principal (detectar automaticamente)
RAMA_PRINCIPAL=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@' || echo "main")

# -----------------------------------------------------------------------------
# Funciones auxiliares
# -----------------------------------------------------------------------------

mostrar_ayuda() {
    echo -e "${NEGRITA}Uso:${SIN_COLOR} $0 [OPCIONES]"
    echo ""
    echo "Opciones:"
    echo "  --staged       Revisar solo cambios staged (por defecto)"
    echo "  --all          Revisar todos los cambios (staged + unstaged)"
    echo "  --branch       Revisar cambios respecto a la rama principal ($RAMA_PRINCIPAL)"
    echo "  --file ARCHIVO Revisar un archivo especifico"
    echo "  --max-turns N  Numero maximo de turnos de Claude (por defecto: $MAX_TURNS)"
    echo "  --max-budget N Presupuesto maximo en USD (por defecto: $MAX_BUDGET)"
    echo "  --json         Generar salida estructurada en JSON"
    echo "  --help         Mostrar esta ayuda"
    echo ""
    echo "Variables de entorno:"
    echo "  CLAUDE_MAX_TURNS   Turnos maximos (por defecto: 3)"
    echo "  CLAUDE_MAX_BUDGET  Presupuesto maximo en USD (por defecto: 0.10)"
    echo "  CLAUDE_OUTPUT_DIR  Directorio para informes (por defecto: /tmp)"
}

log_info() {
    echo -e "${AZUL}[INFO]${SIN_COLOR} $1"
}

log_exito() {
    echo -e "${VERDE}[OK]${SIN_COLOR} $1"
}

log_advertencia() {
    echo -e "${AMARILLO}[AVISO]${SIN_COLOR} $1"
}

log_error() {
    echo -e "${ROJO}[ERROR]${SIN_COLOR} $1" >&2
}

verificar_requisitos() {
    # Verificar Claude Code
    if ! command -v claude &>/dev/null; then
        log_error "Claude Code no esta instalado."
        echo "  Instala con: curl -fsSL https://claude.ai/install.sh | bash"
        exit 1
    fi

    # Verificar API key
    if [ -z "${ANTHROPIC_API_KEY:-}" ]; then
        log_error "La variable ANTHROPIC_API_KEY no esta configurada."
        echo "  Configura con: export ANTHROPIC_API_KEY=tu-api-key"
        exit 1
    fi

    # Verificar Git
    if ! git rev-parse --is-inside-work-tree &>/dev/null; then
        log_error "No estas dentro de un repositorio Git."
        exit 1
    fi

    # Verificar jq (opcional, para modo JSON)
    if ! command -v jq &>/dev/null; then
        log_advertencia "jq no esta instalado. La salida JSON no sera formateada."
    fi
}

# -----------------------------------------------------------------------------
# Funcion principal de revision
# -----------------------------------------------------------------------------

revisar_diff() {
    local diff="$1"
    local modo_json="$2"
    local timestamp
    timestamp=$(date +%Y%m%d-%H%M%S)
    local archivo_informe="${OUTPUT_DIR}/review-${timestamp}.json"

    # Verificar que hay cambios
    if [ -z "$diff" ]; then
        log_advertencia "No se encontraron cambios para revisar."
        exit 0
    fi

    # Contar lineas de diff
    local lineas
    lineas=$(echo "$diff" | wc -l)
    log_info "Analizando diff con $lineas lineas..."

    if [ "$modo_json" = "true" ]; then
        # -----------------------------------------------------------------
        # Modo JSON: salida estructurada
        # -----------------------------------------------------------------
        log_info "Ejecutando revision en modo JSON..."

        local schema='{
            "type": "object",
            "properties": {
                "aprobado": { "type": "boolean" },
                "severidad_global": {
                    "type": "string",
                    "enum": ["baja", "media", "alta", "critica"]
                },
                "resumen": { "type": "string" },
                "problemas": {
                    "type": "array",
                    "items": {
                        "type": "object",
                        "properties": {
                            "archivo": { "type": "string" },
                            "linea": { "type": "integer" },
                            "tipo": {
                                "type": "string",
                                "enum": ["seguridad", "bug", "rendimiento", "estilo", "mantenibilidad"]
                            },
                            "severidad": {
                                "type": "string",
                                "enum": ["baja", "media", "alta", "critica"]
                            },
                            "descripcion": { "type": "string" },
                            "sugerencia": { "type": "string" }
                        },
                        "required": ["tipo", "severidad", "descripcion"]
                    }
                },
                "aspectos_positivos": {
                    "type": "array",
                    "items": { "type": "string" }
                }
            },
            "required": ["aprobado", "severidad_global", "resumen", "problemas"]
        }'

        resultado=$(echo "$diff" | claude -p \
            "Revisa este diff de codigo. Analiza seguridad, bugs, rendimiento y estilo. Se exhaustivo pero conciso." \
            --output-format json \
            --json-schema "$schema" \
            --max-turns "$MAX_TURNS" \
            --max-budget-usd "$MAX_BUDGET" \
            2>/dev/null)

        # Guardar informe completo
        echo "$resultado" > "$archivo_informe"

        # Extraer y mostrar resultados
        local result_content
        result_content=$(echo "$resultado" | jq -r '.result // empty' 2>/dev/null || echo "$resultado")

        if [ -n "$result_content" ]; then
            echo ""
            echo -e "${NEGRITA}=== RESULTADO DE LA REVISION ===${SIN_COLOR}"
            echo ""

            # Intentar parsear como JSON la respuesta de Claude
            local aprobado
            aprobado=$(echo "$result_content" | jq -r '.aprobado // empty' 2>/dev/null || echo "")

            if [ -n "$aprobado" ]; then
                local severidad
                severidad=$(echo "$result_content" | jq -r '.severidad_global' 2>/dev/null)
                local resumen
                resumen=$(echo "$result_content" | jq -r '.resumen' 2>/dev/null)
                local num_problemas
                num_problemas=$(echo "$result_content" | jq '.problemas | length' 2>/dev/null)

                if [ "$aprobado" = "true" ]; then
                    echo -e "${VERDE}APROBADO${SIN_COLOR} - Severidad: $severidad"
                else
                    echo -e "${ROJO}NO APROBADO${SIN_COLOR} - Severidad: $severidad"
                fi
                echo ""
                echo "Resumen: $resumen"
                echo "Problemas encontrados: $num_problemas"
                echo ""

                # Mostrar problemas
                if [ "$num_problemas" -gt 0 ] 2>/dev/null; then
                    echo -e "${NEGRITA}Problemas:${SIN_COLOR}"
                    echo "$result_content" | jq -r '.problemas[] | "  [\(.severidad)] \(.tipo): \(.descripcion)"' 2>/dev/null
                fi
            else
                echo "$result_content"
            fi

            echo ""
            log_exito "Informe guardado en: $archivo_informe"
        fi

    else
        # -----------------------------------------------------------------
        # Modo texto: salida legible
        # -----------------------------------------------------------------
        log_info "Ejecutando revision en modo texto..."

        echo ""
        echo -e "${NEGRITA}=== REVISION DE CODIGO CON CLAUDE ===${SIN_COLOR}"
        echo -e "${GRIS}Fecha: $(date)${SIN_COLOR}"
        echo -e "${GRIS}Max turns: $MAX_TURNS | Max budget: \$$MAX_BUDGET${SIN_COLOR}"
        echo ""

        echo "$diff" | claude -p \
            "Revisa este diff de codigo de forma detallada. Organiza tu respuesta en:

1. **Problemas Criticos** - Bugs, vulnerabilidades de seguridad, errores logicos
2. **Mejoras Importantes** - Manejo de errores, rendimiento, mejores practicas
3. **Sugerencias** - Estilo, legibilidad, documentacion
4. **Aspectos Positivos** - Que se hizo bien

Para cada problema, indica:
- El archivo y linea aproximada
- Descripcion del problema
- Sugerencia de como corregirlo con ejemplo de codigo

Se constructivo y especifico. Responde en espanol." \
            --max-turns "$MAX_TURNS" \
            --max-budget-usd "$MAX_BUDGET" \
            --output-format text

        echo ""
        echo -e "${NEGRITA}=== FIN DE LA REVISION ===${SIN_COLOR}"
    fi
}

# -----------------------------------------------------------------------------
# Parseo de argumentos
# -----------------------------------------------------------------------------

MODO="staged"
MODO_JSON="false"
ARCHIVO_ESPECIFICO=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --staged)
            MODO="staged"
            shift
            ;;
        --all)
            MODO="all"
            shift
            ;;
        --branch)
            MODO="branch"
            shift
            ;;
        --file)
            MODO="file"
            ARCHIVO_ESPECIFICO="${2:?Error: --file requiere un argumento}"
            shift 2
            ;;
        --max-turns)
            MAX_TURNS="${2:?Error: --max-turns requiere un numero}"
            shift 2
            ;;
        --max-budget)
            MAX_BUDGET="${2:?Error: --max-budget requiere un numero}"
            shift 2
            ;;
        --json)
            MODO_JSON="true"
            shift
            ;;
        --help|-h)
            mostrar_ayuda
            exit 0
            ;;
        *)
            log_error "Opcion desconocida: $1"
            mostrar_ayuda
            exit 1
            ;;
    esac
done

# -----------------------------------------------------------------------------
# Ejecucion principal
# -----------------------------------------------------------------------------

main() {
    echo -e "${NEGRITA}"
    echo "  ================================================"
    echo "   Revision Automatica de Codigo con Claude Code"
    echo "  ================================================"
    echo -e "${SIN_COLOR}"

    # Verificar requisitos
    verificar_requisitos

    # Obtener el diff segun el modo
    local diff=""

    case $MODO in
        staged)
            log_info "Obteniendo cambios staged..."
            diff=$(git diff --staged --diff-filter=ACMR)
            ;;
        all)
            log_info "Obteniendo todos los cambios..."
            diff=$(git diff --diff-filter=ACMR)
            if [ -z "$diff" ]; then
                diff=$(git diff --staged --diff-filter=ACMR)
            fi
            ;;
        branch)
            log_info "Obteniendo cambios vs $RAMA_PRINCIPAL..."
            diff=$(git diff "$RAMA_PRINCIPAL"...HEAD --diff-filter=ACMR)
            ;;
        file)
            if [ ! -f "$ARCHIVO_ESPECIFICO" ]; then
                log_error "El archivo no existe: $ARCHIVO_ESPECIFICO"
                exit 1
            fi
            log_info "Revisando archivo: $ARCHIVO_ESPECIFICO"
            diff=$(cat "$ARCHIVO_ESPECIFICO")
            ;;
    esac

    # Ejecutar revision
    revisar_diff "$diff" "$MODO_JSON"

    log_exito "Revision completada."
}

main
