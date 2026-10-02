#!/usr/bin/env bash
# Verificación completa del proyecto: lo mismo en local (antes de abrir el PR) y en CI.
# Tiene que acabar en error si algo falla. Necesita python3 con PyYAML.
set -euo pipefail
cd "$(dirname "$0")/.."

paso() { printf '\n\033[1;34m== %s\033[0m\n' "$*"; }

paso "Sintaxis de los scripts de shell"
git ls-files -z '*.sh' '.githooks/*' | xargs -0 -r -n1 bash -n

paso "YAML y JSON válidos"
git ls-files -z '*.yml' '*.yaml' '*.json' | python3 -c '
import json, sys, yaml
for f in sys.stdin.read().split("\0"):
    if not f:
        continue
    with open(f, encoding="utf-8") as fh:
        json.load(fh) if f.endswith(".json") else yaml.safe_load(fh)
'

# test-modules.py valida estructura, markdown, enlaces internos, scripts, YAML, JSON y bloques
# de código de cada módulo. Se ejecuta por módulo y solo con los que conoce (M01-M15): su lista
# MODULES no está al día con la estructura de 17 módulos y la pasada completa falla hoy
# (modulo-16-proyecto-final, REVISION-ERRORES.md y ../CURSO_CLAUDE_CODE.md). Cuando se ponga al
# día, este bucle se sustituye por `python3 test-modules.py`.
paso "Módulos M01-M15 (test-modules.py)"
for n in 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15; do
  if ! salida="$(python3 test-modules.py --module "$n" 2>&1)"; then
    printf '%s\n' "$salida"
    echo "test-modules.py --module $n: falla" >&2
    exit 1
  fi
  printf 'M%s ok  ' "$n"
done
echo

paso "Enlaces relativos de todo el curso (incluye M16, M17 y recursos/)"
python3 scripts/check-enlaces.py

echo
echo "check.sh: todo bien"
