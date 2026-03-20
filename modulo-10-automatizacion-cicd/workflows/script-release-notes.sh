#!/bin/bash
# =============================================================================
# Script: Generador de Notas de Version con Claude Code
# =============================================================================
#
# Descripcion:
#   Genera notas de version profesionales a partir del historial de commits
#   de Git, usando Claude Code para categorizar y redactar el contenido.
#
# Uso:
#   ./script-release-notes.sh <version>                    # Desde ultimo tag
#   ./script-release-notes.sh <version> <tag-anterior>     # Desde tag especifico
#   ./script-release-notes.sh <version> --since="2025-01-01"  # Desde fecha
#
# Ejemplos:
#   ./script-release-notes.sh v2.1.0
#   ./script-release-notes.sh v2.1.0 v2.0.0
#   ./script-release-notes.sh v2.1.0 --since="2025-06-01"
#
# Requisitos:
#   - Claude Code instalado (curl -fsSL https://claude.ai/install.sh | bash)
#   - ANTHROPIC_API_KEY configurada
#   - Git inicializado con historial de commits
#
# Salida:
#   - Imprime las notas de version en la terminal
#   - Guarda archivo RELEASE_NOTES_<version>.md
#
# =============================================================================

set -euo pipefail

# -----------------------------------------------------------------------------
# Configuracion
# -----------------------------------------------------------------------------

# Colores
ROJO='\033[0;31m'
VERDE='\033[0;32m'
AMARILLO='\033[1;33m'
AZUL='\033[0;34m'
GRIS='\033[0;90m'
NEGRITA='\033[1m'
SIN_COLOR='\033[0m'

# Limites
MAX_TURNS="${CLAUDE_MAX_TURNS:-3}"
MAX_BUDGET="${CLAUDE_MAX_BUDGET:-0.10}"

# Directorio de salida
OUTPUT_DIR="${CLAUDE_OUTPUT_DIR:-.}"

# -----------------------------------------------------------------------------
# Funciones auxiliares
# -----------------------------------------------------------------------------

mostrar_ayuda() {
    echo -e "${NEGRITA}Generador de Notas de Version${SIN_COLOR}"
    echo ""
    echo "Uso: $0 <version> [tag-anterior|--since=FECHA]"
    echo ""
    echo "Argumentos:"
    echo "  version        Version a generar (ej: v2.1.0)"
    echo "  tag-anterior   Tag desde el cual contar commits (opcional)"
    echo "  --since=FECHA  Fecha desde la cual contar commits (opcional)"
    echo ""
    echo "Opciones:"
    echo "  --output DIR   Directorio de salida (por defecto: directorio actual)"
    echo "  --max-turns N  Turnos maximos de Claude (por defecto: $MAX_TURNS)"
    echo "  --max-budget N Presupuesto maximo en USD (por defecto: $MAX_BUDGET)"
    echo "  --stdout       Solo imprimir en terminal, no guardar archivo"
    echo "  --help         Mostrar esta ayuda"
    echo ""
    echo "Variables de entorno:"
    echo "  CLAUDE_MAX_TURNS   Turnos maximos (por defecto: 3)"
    echo "  CLAUDE_MAX_BUDGET  Presupuesto maximo (por defecto: 0.10)"
    echo "  CLAUDE_OUTPUT_DIR  Directorio de salida (por defecto: .)"
    echo ""
    echo "Ejemplos:"
    echo "  $0 v2.1.0                         # Desde ultimo tag"
    echo "  $0 v2.1.0 v2.0.0                  # Desde tag especifico"
    echo "  $0 v2.1.0 --since=\"2025-06-01\"    # Desde fecha"
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
    if ! command -v claude &>/dev/null; then
        log_error "Claude Code no esta instalado."
        echo "  Instala con: curl -fsSL https://claude.ai/install.sh | bash"
        exit 1
    fi

    if [ -z "${ANTHROPIC_API_KEY:-}" ]; then
        log_error "La variable ANTHROPIC_API_KEY no esta configurada."
        exit 1
    fi

    if ! git rev-parse --is-inside-work-tree &>/dev/null; then
        log_error "No estas dentro de un repositorio Git."
        exit 1
    fi
}

# Detectar el tag anterior automaticamente
detectar_tag_anterior() {
    # Intentar obtener el tag mas reciente
    local tag
    tag=$(git describe --tags --abbrev=0 HEAD 2>/dev/null || echo "")

    # Si el tag actual coincide con HEAD, buscar el anterior
    if [ -n "$tag" ]; then
        local tag_commit
        tag_commit=$(git rev-list -n 1 "$tag" 2>/dev/null || echo "")
        local head_commit
        head_commit=$(git rev-parse HEAD 2>/dev/null || echo "")

        if [ "$tag_commit" = "$head_commit" ]; then
            tag=$(git describe --tags --abbrev=0 "${tag}^" 2>/dev/null || echo "")
        fi
    fi

    echo "$tag"
}

# Obtener commits en un rango
obtener_commits() {
    local rango="$1"

    if [ -z "$rango" ] || [ "$rango" = "HEAD" ]; then
        git log --pretty=format:"%h|%s|%an|%ad" --date=short --no-merges
    else
        git log "$rango" --pretty=format:"%h|%s|%an|%ad" --date=short --no-merges
    fi
}

# Obtener estadisticas del rango de commits
obtener_estadisticas() {
    local rango="$1"

    local num_commits
    if [ -z "$rango" ] || [ "$rango" = "HEAD" ]; then
        num_commits=$(git log --oneline --no-merges | wc -l | tr -d ' ')
    else
        num_commits=$(git log "$rango" --oneline --no-merges | wc -l | tr -d ' ')
    fi

    local autores
    if [ -z "$rango" ] || [ "$rango" = "HEAD" ]; then
        autores=$(git log --pretty=format:"%an" --no-merges | sort -u)
    else
        autores=$(git log "$rango" --pretty=format:"%an" --no-merges | sort -u)
    fi

    local num_autores
    num_autores=$(echo "$autores" | grep -c . || echo "0")

    local archivos_modificados=""
    local lineas_anadidas=""
    local lineas_eliminadas=""

    if [ -n "$rango" ] && [ "$rango" != "HEAD" ]; then
        local stats
        stats=$(git diff --shortstat "$rango" 2>/dev/null || echo "")
        archivos_modificados=$(echo "$stats" | grep -oP '\d+ file' | grep -oP '\d+' || echo "N/A")
        lineas_anadidas=$(echo "$stats" | grep -oP '\d+ insertion' | grep -oP '\d+' || echo "N/A")
        lineas_eliminadas=$(echo "$stats" | grep -oP '\d+ deletion' | grep -oP '\d+' || echo "N/A")
    fi

    echo "COMMITS:$num_commits"
    echo "AUTORES:$num_autores"
    echo "LISTA_AUTORES:$autores"
    echo "ARCHIVOS:${archivos_modificados:-N/A}"
    echo "LINEAS_ANADIDAS:${lineas_anadidas:-N/A}"
    echo "LINEAS_ELIMINADAS:${lineas_eliminadas:-N/A}"
}

# -----------------------------------------------------------------------------
# Parseo de argumentos
# -----------------------------------------------------------------------------

VERSION=""
TAG_ANTERIOR=""
DESDE_FECHA=""
SOLO_STDOUT="false"

while [[ $# -gt 0 ]]; do
    case $1 in
        --help|-h)
            mostrar_ayuda
            exit 0
            ;;
        --output)
            OUTPUT_DIR="${2:?Error: --output requiere un directorio}"
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
        --stdout)
            SOLO_STDOUT="true"
            shift
            ;;
        --since=*)
            DESDE_FECHA="${1#--since=}"
            shift
            ;;
        -*)
            log_error "Opcion desconocida: $1"
            mostrar_ayuda
            exit 1
            ;;
        *)
            if [ -z "$VERSION" ]; then
                VERSION="$1"
            elif [ -z "$TAG_ANTERIOR" ]; then
                TAG_ANTERIOR="$1"
            else
                log_error "Demasiados argumentos."
                mostrar_ayuda
                exit 1
            fi
            shift
            ;;
    esac
done

# Validar version
if [ -z "$VERSION" ]; then
    log_error "Debes especificar una version."
    echo ""
    mostrar_ayuda
    exit 1
fi

# -----------------------------------------------------------------------------
# Ejecucion principal
# -----------------------------------------------------------------------------

main() {
    echo -e "${NEGRITA}"
    echo "  ================================================"
    echo "   Generador de Notas de Version - Claude Code"
    echo "  ================================================"
    echo -e "${SIN_COLOR}"

    verificar_requisitos

    # Determinar el rango de commits
    local rango=""

    if [ -n "$DESDE_FECHA" ]; then
        log_info "Generando notas desde: $DESDE_FECHA"
        rango="--since=$DESDE_FECHA"
    elif [ -n "$TAG_ANTERIOR" ]; then
        log_info "Generando notas desde tag: $TAG_ANTERIOR"
        rango="${TAG_ANTERIOR}..HEAD"
    else
        TAG_ANTERIOR=$(detectar_tag_anterior)
        if [ -n "$TAG_ANTERIOR" ]; then
            log_info "Tag anterior detectado: $TAG_ANTERIOR"
            rango="${TAG_ANTERIOR}..HEAD"
        else
            log_advertencia "No se encontro un tag anterior. Usando todo el historial."
            rango="HEAD"
        fi
    fi

    # Obtener commits
    log_info "Recopilando commits..."
    local commits
    commits=$(obtener_commits "$rango")

    if [ -z "$commits" ]; then
        log_advertencia "No se encontraron commits en el rango especificado."
        exit 0
    fi

    local num_commits
    num_commits=$(echo "$commits" | wc -l | tr -d ' ')
    log_info "Encontrados $num_commits commits."

    # Obtener estadisticas
    log_info "Calculando estadisticas..."
    local estadisticas
    estadisticas=$(obtener_estadisticas "$rango")

    local total_commits
    total_commits=$(echo "$estadisticas" | grep "^COMMITS:" | cut -d: -f2)
    local total_autores
    total_autores=$(echo "$estadisticas" | grep "^AUTORES:" | cut -d: -f2)
    local lista_autores
    lista_autores=$(echo "$estadisticas" | grep "^LISTA_AUTORES:" | cut -d: -f2-)
    local archivos_mod
    archivos_mod=$(echo "$estadisticas" | grep "^ARCHIVOS:" | cut -d: -f2)
    local lineas_add
    lineas_add=$(echo "$estadisticas" | grep "^LINEAS_ANADIDAS:" | cut -d: -f2)
    local lineas_del
    lineas_del=$(echo "$estadisticas" | grep "^LINEAS_ELIMINADAS:" | cut -d: -f2)

    # Nombre del proyecto
    local nombre_proyecto
    nombre_proyecto=$(basename "$(git rev-parse --show-toplevel 2>/dev/null || pwd)")

    # Fecha actual
    local fecha
    fecha=$(date +%Y-%m-%d)

    # Generar notas con Claude
    log_info "Generando notas de version con Claude Code..."
    echo ""

    local notas
    notas=$(claude -p "Genera notas de version profesionales en espanol para la version $VERSION del proyecto '$nombre_proyecto'.

## Commits (formato: hash|mensaje|autor|fecha)
$commits

## Estadisticas
- Total de commits: $total_commits
- Contribuidores: $total_autores
- Archivos modificados: $archivos_mod
- Lineas anadidas: $lineas_add
- Lineas eliminadas: $lineas_del

## Contribuidores
$lista_autores

## Instrucciones de formato

Genera las notas de version en Markdown con esta estructura exacta:

# $nombre_proyecto - Version $VERSION

**Fecha de lanzamiento:** $fecha

## Resumen
[2-3 oraciones describiendo los cambios mas importantes de esta version]

## Nuevas Funcionalidades
- [Listar las funcionalidades nuevas basandote en commits tipo feat:]

## Correcciones de Bugs
- [Listar las correcciones basandote en commits tipo fix:]

## Mejoras de Rendimiento
- [Si hay commits tipo perf:]

## Refactorizacion
- [Si hay commits tipo refactor:]

## Documentacion
- [Si hay commits tipo docs:]

## Otros Cambios
- [Commits tipo chore:, ci:, test:, build:, etc.]

## Estadisticas
- Commits: $total_commits
- Contribuidores: $total_autores
- Archivos modificados: $archivos_mod
- Lineas anadidas: ${lineas_add}
- Lineas eliminadas: ${lineas_del}

## Contribuidores
[Lista de contribuidores con formato: - @nombre]

---
*Notas generadas automaticamente con Claude Code*

REGLAS:
- Omite secciones que no tengan contenido
- No inventes informacion que no este en los commits
- Redacta descripciones claras y concisas
- Agrupa commits relacionados en un solo punto
- Usa verbos en infinitivo (Agregar, Corregir, Mejorar...)" \
        --max-turns "$MAX_TURNS" \
        --max-budget-usd "$MAX_BUDGET" \
        --output-format text)

    # Mostrar en terminal
    echo -e "${NEGRITA}=== NOTAS DE VERSION ===${SIN_COLOR}"
    echo ""
    echo "$notas"
    echo ""

    # Guardar archivo
    if [ "$SOLO_STDOUT" = "false" ]; then
        local archivo_salida="${OUTPUT_DIR}/RELEASE_NOTES_${VERSION}.md"

        # Crear directorio si no existe
        mkdir -p "$OUTPUT_DIR"

        echo "$notas" > "$archivo_salida"

        echo -e "${NEGRITA}=== FIN DE LAS NOTAS ===${SIN_COLOR}"
        echo ""
        log_exito "Notas de version guardadas en: $archivo_salida"
        log_info "Para ver: cat $archivo_salida"
    else
        echo -e "${NEGRITA}=== FIN DE LAS NOTAS ===${SIN_COLOR}"
    fi

    # Mostrar resumen de costos
    echo ""
    log_info "Parametros utilizados:"
    echo -e "  ${GRIS}Version:    $VERSION${SIN_COLOR}"
    echo -e "  ${GRIS}Rango:      ${rango:-todo el historial}${SIN_COLOR}"
    echo -e "  ${GRIS}Commits:    $total_commits${SIN_COLOR}"
    echo -e "  ${GRIS}Max turns:  $MAX_TURNS${SIN_COLOR}"
    echo -e "  ${GRIS}Max budget: \$$MAX_BUDGET${SIN_COLOR}"

    log_exito "Generacion de notas de version completada."
}

main
