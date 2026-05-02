#!/usr/bin/env python3
"""
test-modules.py — Script de validacion modular para claude-code-course

Ejecuta checks de estructura, markdown, links, sintaxis de scripts,
YAML, JSON y consistencia de contenido para cada modulo del curso.

Uso:
    python3 test-modules.py           # Ejecutar todos los checks
    python3 test-modules.py --verbose  # Mostrar detalles de cada check
    python3 test-modules.py --module 8 # Testear solo un modulo
"""

import json
import os
import re
import subprocess
import sys
from pathlib import Path

# ---------------------------------------------------------------------------
# Configuracion
# ---------------------------------------------------------------------------

REPO_ROOT = Path(__file__).resolve().parent

MODULES = [
    "modulo-01-introduccion",
    "modulo-02-cli-primeros-pasos",
    "modulo-03-contexto-y-tokens",
    "modulo-04-memoria-claude-md",
    "modulo-05-configuracion-permisos",
    "modulo-06-planificacion-opus",
    "modulo-07-mcp",
    "modulo-08-hooks",
    "modulo-09-agentes-skills-teams",
    "modulo-10-automatizacion-cicd",
    "modulo-11-enterprise-seguridad",
    "modulo-12-metodologias-desarrollo-ia",
    "modulo-13-multimodalidad-notebooks",
    "modulo-14-agent-sdk",
    "modulo-15-plugins-marketplaces",
    "modulo-16-proyecto-final",
]

# Directorios esperados por modulo (minimo requerido)
EXPECTED_DIRS = {
    "modulo-01-introduccion": ["teoria", "ejercicios", "ejemplos"],
    "modulo-02-cli-primeros-pasos": ["teoria", "ejercicios", "cheatsheets"],
    "modulo-03-contexto-y-tokens": ["teoria", "ejercicios", "ejemplos"],
    "modulo-04-memoria-claude-md": ["teoria", "ejercicios", "plantillas"],
    "modulo-05-configuracion-permisos": ["teoria", "ejercicios", "plantillas"],
    "modulo-06-planificacion-opus": ["teoria", "ejercicios", "proyecto-practico"],
    "modulo-07-mcp": ["teoria", "ejercicios", "servidores-ejemplo"],
    "modulo-08-hooks": ["teoria", "ejercicios", "scripts"],
    "modulo-09-agentes-skills-teams": ["teoria", "ejercicios", "agentes", "skills"],
    "modulo-10-automatizacion-cicd": ["teoria", "ejercicios", "workflows"],
    "modulo-11-enterprise-seguridad": ["teoria", "ejercicios", "plantillas"],
    "modulo-12-metodologias-desarrollo-ia": ["teoria", "ejercicios", "plantillas"],
    "modulo-13-multimodalidad-notebooks": ["teoria", "ejercicios"],
    "modulo-14-agent-sdk": ["teoria", "ejercicios"],
    "modulo-15-plugins-marketplaces": ["teoria", "ejercicios"],
    "modulo-16-proyecto-final": ["enunciado", "criterios-evaluacion", "solucion-referencia"],
}

# Nombres de modelo obsoletos que no deberian aparecer
OBSOLETE_MODEL_PATTERNS = [
    (r"\bSonnet 4\.5\b", "Sonnet 4.5 (deberia ser Sonnet 4.6)"),
    (r"\bOpus 4\.5\b", "Opus 4.5 (deberia ser Opus 4.6)"),
    (r"\bHaiku 3\.5\b", "Haiku 3.5 (deberia ser Haiku 4.5)"),
    (r"claude-sonnet-4-5(?!-\d{8})", "claude-sonnet-4-5 (deberia ser claude-sonnet-4-6)"),
]

# ---------------------------------------------------------------------------
# Colores
# ---------------------------------------------------------------------------

class Colors:
    PASS = "\033[92m"   # verde
    FAIL = "\033[91m"   # rojo
    WARN = "\033[93m"   # amarillo
    BOLD = "\033[1m"
    DIM = "\033[2m"
    RESET = "\033[0m"
    CYAN = "\033[96m"

NO_COLOR = os.environ.get("NO_COLOR") is not None

def c(color: str, text: str) -> str:
    if NO_COLOR:
        return text
    return f"{color}{text}{Colors.RESET}"

# ---------------------------------------------------------------------------
# Contadores globales
# ---------------------------------------------------------------------------

counts = {"pass": 0, "fail": 0, "warn": 0}
failures_detail: list[str] = []

def passed(msg: str, verbose: bool = False):
    counts["pass"] += 1
    if verbose:
        print(f"  {c(Colors.PASS, '[PASS]')} {msg}")

def failed(msg: str, module: str = ""):
    counts["fail"] += 1
    detail = f"{module}: {msg}" if module else msg
    failures_detail.append(detail)
    print(f"  {c(Colors.FAIL, '[FAIL]')} {msg}")

def warned(msg: str, verbose: bool = False):
    counts["warn"] += 1
    if verbose:
        print(f"  {c(Colors.WARN, '[WARN]')} {msg}")

# ---------------------------------------------------------------------------
# Checks
# ---------------------------------------------------------------------------

def check_structure(module_path: Path, module_name: str, verbose: bool):
    """Verifica que el modulo tiene los directorios y archivos esperados."""
    expected = EXPECTED_DIRS.get(module_name, [])
    missing = [d for d in expected if not (module_path / d).is_dir()]

    if missing:
        failed(f"Directorios faltantes: {', '.join(missing)}", module_name)
    else:
        passed(f"Estructura de directorios correcta ({len(expected)} dirs)", verbose)

    # README.md en raiz (excepto modulo-16 que no lo tiene)
    if module_name != "modulo-16-proyecto-final":
        readme = module_path / "README.md"
        if not readme.exists():
            failed("README.md no existe en raiz del modulo", module_name)
        elif readme.stat().st_size < 10:
            failed("README.md esta vacio", module_name)
        else:
            passed("README.md existe y tiene contenido", verbose)
    else:
        # Modulo 16 tiene README dentro de enunciado/
        readme = module_path / "enunciado" / "README.md"
        if not readme.exists():
            failed("enunciado/README.md no existe", module_name)
        else:
            passed("enunciado/README.md existe", verbose)


def check_markdown_files(module_path: Path, module_name: str, verbose: bool):
    """Valida todos los archivos .md del modulo."""
    md_files = sorted(module_path.rglob("*.md"))

    if not md_files:
        failed("No se encontraron archivos markdown", module_name)
        return

    empty_files = []
    no_h1_files = []
    heading_skip_files = []

    for md_file in md_files:
        rel = md_file.relative_to(module_path)

        # Check: archivo no vacio
        if md_file.stat().st_size < 10:
            empty_files.append(str(rel))
            continue

        content = md_file.read_text(encoding="utf-8", errors="replace")
        lines = content.splitlines()

        # Check: tiene al menos un heading H1 o H2
        has_heading = any(
            line.startswith("# ") or line.startswith("## ")
            for line in lines
        )
        if not has_heading:
            no_h1_files.append(str(rel))

        # Check: headings no saltan niveles (H1 -> H3 sin H2)
        heading_levels = []
        for line in lines:
            match = re.match(r"^(#{1,6})\s", line)
            if match:
                heading_levels.append(len(match.group(1)))

        for i in range(1, len(heading_levels)):
            if heading_levels[i] > heading_levels[i - 1] + 1:
                heading_skip_files.append(str(rel))
                break

    if empty_files:
        failed(f"Archivos vacios: {', '.join(empty_files)}", module_name)
    else:
        passed(f"{len(md_files)} archivos markdown con contenido", verbose)

    if no_h1_files:
        warned(f"Sin heading principal: {', '.join(no_h1_files[:3])}", verbose)

    if heading_skip_files:
        warned(
            f"Headings saltan niveles en: {', '.join(heading_skip_files[:3])}",
            verbose,
        )


def _strip_code_blocks(content: str) -> str:
    """Remove fenced code blocks from markdown so links inside them are ignored."""
    return re.sub(r"```[^\n]*\n.*?```", "", content, flags=re.DOTALL)


def check_internal_links(module_path: Path, module_name: str, verbose: bool):
    """Verifica que los links relativos internos apuntan a archivos existentes."""
    md_files = sorted(module_path.rglob("*.md"))
    broken_links: list[str] = []

    # Pattern for markdown links: [text](relative/path)
    link_re = re.compile(r"\[([^\]]*)\]\(([^)]+)\)")

    for md_file in md_files:
        content = md_file.read_text(encoding="utf-8", errors="replace")
        # Strip code blocks so we don't check illustrative links inside examples
        content_no_code = _strip_code_blocks(content)
        rel_file = md_file.relative_to(module_path)

        for match in link_re.finditer(content_no_code):
            target = match.group(2)

            # Skip external links, anchors, and special protocols
            if target.startswith(("http://", "https://", "mailto:", "#", "ftp://")):
                continue

            # Strip anchor from path
            target_path = target.split("#")[0]
            if not target_path:
                continue

            # Resolve relative to the file's directory
            resolved = (md_file.parent / target_path).resolve()

            if not resolved.exists():
                broken_links.append(f"{rel_file} -> {target_path}")

    if broken_links:
        # Show first 5
        shown = broken_links[:5]
        extra = f" (+{len(broken_links) - 5} mas)" if len(broken_links) > 5 else ""
        failed(f"{len(broken_links)} links rotos: {'; '.join(shown)}{extra}", module_name)
    else:
        total = sum(
            len(link_re.findall(f.read_text(encoding="utf-8", errors="replace")))
            for f in md_files
        )
        passed(f"Links internos OK (de {total} links totales)", verbose)


def check_shell_scripts(module_path: Path, module_name: str, verbose: bool):
    """Valida sintaxis de scripts .sh con bash -n."""
    sh_files = sorted(module_path.rglob("*.sh"))

    if not sh_files:
        return  # No aplica

    syntax_errors = []
    no_shebang = []
    no_exec = []

    for sh_file in sh_files:
        rel = sh_file.relative_to(module_path)
        content = sh_file.read_text(encoding="utf-8", errors="replace")

        # Check: shebang
        if not content.startswith("#!"):
            no_shebang.append(str(rel))

        # Check: bash -n syntax validation
        result = subprocess.run(
            ["bash", "-n", str(sh_file)],
            capture_output=True,
            text=True,
            timeout=10,
        )
        if result.returncode != 0:
            syntax_errors.append(f"{rel}: {result.stderr.strip()}")

        # Check: execute permissions
        if not os.access(sh_file, os.X_OK):
            no_exec.append(str(rel))

    if syntax_errors:
        failed(f"Errores de sintaxis shell: {'; '.join(syntax_errors)}", module_name)
    else:
        passed(f"{len(sh_files)} scripts shell - sintaxis correcta", verbose)

    if no_shebang:
        warned(f"Sin shebang: {', '.join(no_shebang)}", verbose)

    if no_exec:
        warned(f"Sin permisos de ejecucion: {', '.join(no_exec)}", verbose)


def check_yaml_files(module_path: Path, module_name: str, verbose: bool):
    """Valida sintaxis de archivos YAML."""
    yml_files = sorted(module_path.rglob("*.yml")) + sorted(module_path.rglob("*.yaml"))

    if not yml_files:
        return

    try:
        import yaml
        has_yaml = True
    except ImportError:
        has_yaml = False

    parse_errors = []
    missing_keys = []

    for yml_file in yml_files:
        rel = yml_file.relative_to(module_path)
        content = yml_file.read_text(encoding="utf-8", errors="replace")

        if has_yaml:
            try:
                data = yaml.safe_load(content)
                # Check: GitHub Actions basic structure
                if isinstance(data, dict):
                    if "name" not in data:
                        missing_keys.append(f"{rel}: falta 'name'")
                    # PyYAML parses 'on:' as boolean True key
                    if "on" not in data and True not in data:
                        missing_keys.append(f"{rel}: falta 'on'")
            except yaml.YAMLError as e:
                parse_errors.append(f"{rel}: {e}")
        else:
            # Fallback: basic check - file is not empty and has key: value
            if len(content.strip()) == 0:
                parse_errors.append(f"{rel}: archivo vacio")

    if parse_errors:
        failed(f"Errores YAML: {'; '.join(parse_errors)}", module_name)
    else:
        passed(f"{len(yml_files)} archivos YAML - sintaxis correcta", verbose)

    if missing_keys:
        warned(f"Estructura GitHub Actions incompleta: {'; '.join(missing_keys)}", verbose)


def check_json_files(module_path: Path, module_name: str, verbose: bool):
    """Valida sintaxis de archivos JSON."""
    json_files = sorted(module_path.rglob("*.json"))

    if not json_files:
        return

    parse_errors = []

    for json_file in json_files:
        rel = json_file.relative_to(module_path)
        content = json_file.read_text(encoding="utf-8", errors="replace")

        try:
            json.loads(content)
        except json.JSONDecodeError as e:
            parse_errors.append(f"{rel}: {e}")

    if parse_errors:
        failed(f"Errores JSON: {'; '.join(parse_errors)}", module_name)
    else:
        passed(f"{len(json_files)} archivos JSON - sintaxis correcta", verbose)


def check_model_consistency(module_path: Path, module_name: str, verbose: bool):
    """Busca nombres de modelo obsoletos en el contenido."""
    md_files = sorted(module_path.rglob("*.md"))
    issues: list[str] = []

    for md_file in md_files:
        content = md_file.read_text(encoding="utf-8", errors="replace")
        rel = md_file.relative_to(module_path)

        for pattern, description in OBSOLETE_MODEL_PATTERNS:
            matches = re.findall(pattern, content)
            if matches:
                issues.append(f"{rel}: {description} ({len(matches)}x)")

    if issues:
        failed(
            f"Nombres de modelo obsoletos: {'; '.join(issues[:5])}",
            module_name,
        )
    else:
        passed("Consistencia de nombres de modelo OK", verbose)


def check_embedded_code_blocks(module_path: Path, module_name: str, verbose: bool):
    """Valida bloques de codigo JSON y YAML embebidos en markdown."""
    md_files = sorted(module_path.rglob("*.md"))
    json_errors = []
    total_blocks = 0

    # Regex for fenced code blocks
    block_re = re.compile(r"```(\w+)\n(.*?)```", re.DOTALL)

    for md_file in md_files:
        content = md_file.read_text(encoding="utf-8", errors="replace")
        rel = md_file.relative_to(module_path)

        for match in block_re.finditer(content):
            lang = match.group(1).lower()
            code = match.group(2).strip()
            total_blocks += 1

            # Solo validar JSON puro (no snippets parciales)
            if lang == "json" and code.startswith(("{", "[")):
                try:
                    json.loads(code)
                except json.JSONDecodeError:
                    # Solo reportar si parece un JSON completo (no un snippet)
                    # Heuristica: si tiene mas de 3 lineas y empieza/termina con {}
                    lines = code.splitlines()
                    if (
                        len(lines) >= 3
                        and (code.rstrip().endswith("}") or code.rstrip().endswith("]"))
                    ):
                        json_errors.append(str(rel))

    if json_errors:
        unique = sorted(set(json_errors))
        warned(
            f"Bloques JSON embebidos con errores de sintaxis en: {', '.join(unique[:3])}",
            verbose,
        )

    passed(f"{total_blocks} bloques de codigo encontrados", verbose)


def check_navigation_links(verbose: bool):
    """Verifica la navegacion Anterior/Siguiente entre modulos del README raiz."""
    broken = []

    for module_name in MODULES:
        module_path = REPO_ROOT / module_name
        readme = module_path / "README.md"
        if not readme.exists():
            continue

        content = readme.read_text(encoding="utf-8", errors="replace")
        link_re = re.compile(r"\[([^\]]*)\]\((\.\./[^)]+)\)")

        for match in link_re.finditer(content):
            target = match.group(2).split("#")[0]
            resolved = (readme.parent / target).resolve()
            if not resolved.exists():
                broken.append(f"{module_name}/README.md -> {target}")

    if broken:
        failed(f"Links de navegacion rotos: {'; '.join(broken[:5])}")
    else:
        passed("Navegacion entre modulos (Anterior/Siguiente) correcta", verbose)


def check_recursos(verbose: bool):
    """Valida el directorio de recursos."""
    recursos_path = REPO_ROOT / "recursos"

    if not recursos_path.is_dir():
        failed("Directorio recursos/ no existe")
        return

    print(f"\n{c(Colors.BOLD, '=== Recursos ===')} ")

    # Check subdirectories
    expected_dirs = ["cheatsheets", "plantillas-proyecto"]
    missing = [d for d in expected_dirs if not (recursos_path / d).is_dir()]
    if missing:
        failed(f"Subdirectorios faltantes: {', '.join(missing)}")
    else:
        passed(f"Estructura de recursos correcta ({len(expected_dirs)} dirs)", verbose)

    # Check markdown files
    md_files = sorted(recursos_path.rglob("*.md"))
    empty = [str(f.relative_to(recursos_path)) for f in md_files if f.stat().st_size < 10]
    if empty:
        failed(f"Archivos vacios en recursos: {', '.join(empty)}")
    else:
        passed(f"{len(md_files)} archivos markdown con contenido", verbose)

    # Check JSON files
    json_files = sorted(recursos_path.rglob("*.json"))
    for jf in json_files:
        try:
            json.loads(jf.read_text(encoding="utf-8"))
            passed(f"JSON valido: {jf.relative_to(recursos_path)}", verbose)
        except json.JSONDecodeError as e:
            failed(f"JSON invalido: {jf.relative_to(recursos_path)}: {e}")

    # Check internal links from recursos
    check_internal_links(recursos_path, "recursos", verbose)

    # Check model consistency
    check_model_consistency(recursos_path, "recursos", verbose)


def check_root_files(verbose: bool):
    """Valida archivos en la raiz del repositorio."""
    print(f"\n{c(Colors.BOLD, '=== Archivos raiz ===')} ")

    expected = ["README.md", "LICENSE", "REVISION-ERRORES.md"]
    for fname in expected:
        fpath = REPO_ROOT / fname
        if fpath.exists() and fpath.stat().st_size > 10:
            passed(f"{fname} existe y tiene contenido", verbose)
        elif fpath.exists():
            warned(f"{fname} existe pero esta vacio", verbose)
        else:
            failed(f"{fname} no existe")

    # Validate root README links
    readme = REPO_ROOT / "README.md"
    if readme.exists():
        content = readme.read_text(encoding="utf-8", errors="replace")
        link_re = re.compile(r"\[([^\]]*)\]\(([^)]+)\)")
        broken = []
        for match in link_re.finditer(content):
            target = match.group(2)
            if target.startswith(("http://", "https://", "mailto:", "#")):
                continue
            target_path = target.split("#")[0]
            if not target_path:
                continue
            resolved = (readme.parent / target_path).resolve()
            if not resolved.exists():
                broken.append(target_path)

        if broken:
            failed(f"Links rotos en README raiz: {'; '.join(broken[:5])}")
        else:
            passed("Links del README raiz verificados", verbose)


def count_stats():
    """Cuenta estadisticas generales del repositorio."""
    md_count = len(list(REPO_ROOT.rglob("*.md")))
    sh_count = len(list(REPO_ROOT.rglob("*.sh")))
    yml_count = len(list(REPO_ROOT.rglob("*.yml")))
    json_count = len(list(REPO_ROOT.rglob("*.json")))
    return md_count, sh_count, yml_count, json_count


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main():
    verbose = "--verbose" in sys.argv or "-v" in sys.argv
    module_filter = None

    for i, arg in enumerate(sys.argv):
        if arg in ("--module", "-m") and i + 1 < len(sys.argv):
            module_filter = sys.argv[i + 1]

    md_count, sh_count, yml_count, json_count = count_stats()

    print(c(Colors.BOLD, "\n" + "=" * 60))
    print(c(Colors.BOLD, " Test de Modulos - claude-code-course"))
    print(c(Colors.BOLD, "=" * 60))
    print(
        f"\n{c(Colors.DIM, f'Repositorio: {REPO_ROOT}')}"
        f"\n{c(Colors.DIM, f'Archivos: {md_count} .md, {sh_count} .sh, {yml_count} .yml, {json_count} .json')}\n"
    )

    # --- Test each module ---
    for module_name in MODULES:
        # Filter if --module specified
        if module_filter:
            num = re.search(r"\d+", module_filter)
            module_num = re.search(r"modulo-(\d+)", module_name)
            if num and module_num and num.group() != module_num.group(1):
                continue
            elif not num and module_filter.lower() not in module_name.lower():
                continue

        short_name = module_name.replace("modulo-", "").split("-", 1)
        label = f"Modulo {short_name[0]}: {short_name[1].replace('-', ' ')}"
        print(f"\n{c(Colors.BOLD, f'=== {label} ===')} ")

        module_path = REPO_ROOT / module_name

        if not module_path.is_dir():
            failed(f"Directorio {module_name}/ no existe", module_name)
            continue

        check_structure(module_path, module_name, verbose)
        check_markdown_files(module_path, module_name, verbose)
        check_internal_links(module_path, module_name, verbose)
        check_shell_scripts(module_path, module_name, verbose)
        check_yaml_files(module_path, module_name, verbose)
        check_json_files(module_path, module_name, verbose)
        check_model_consistency(module_path, module_name, verbose)
        check_embedded_code_blocks(module_path, module_name, verbose)

    # --- Test recursos ---
    if not module_filter:
        check_recursos(verbose)
        check_root_files(verbose)

        # --- Navigation check (cross-module) ---
        print(f"\n{c(Colors.BOLD, '=== Navegacion inter-modulos ===')} ")
        check_navigation_links(verbose)

    # --- Summary ---
    total = counts["pass"] + counts["fail"] + counts["warn"]
    print(f"\n{c(Colors.BOLD, '=' * 60)}")
    print(c(Colors.BOLD, " RESUMEN"))
    print(c(Colors.BOLD, "=" * 60))
    print(f"  Total checks:  {total}")
    print(f"  {c(Colors.PASS, 'PASS')}:  {counts['pass']}")
    print(f"  {c(Colors.WARN, 'WARN')}:  {counts['warn']}")
    print(f"  {c(Colors.FAIL, 'FAIL')}:  {counts['fail']}")

    if failures_detail:
        print(f"\n{c(Colors.FAIL, 'Fallos detallados:')}")
        for detail in failures_detail:
            print(f"  - {detail}")

    print()

    if counts["fail"] > 0:
        print(c(Colors.FAIL, "RESULTADO: HAY FALLOS"))
        return 1
    elif counts["warn"] > 0:
        print(c(Colors.WARN, "RESULTADO: OK con advertencias"))
        return 0
    else:
        print(c(Colors.PASS, "RESULTADO: TODO OK"))
        return 0


if __name__ == "__main__":
    sys.exit(main())
