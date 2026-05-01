# 03 - Scripts y Patrones de Automatización

## Introducción

Más allá de GitHub Actions, Claude Code puede integrarse en cualquier flujo de trabajo de automatización: git hooks, scripts de batch processing, jobs programados, y pipelines de CI/CD en Jenkins, GitLab CI, CircleCI o Azure DevOps. En esta sección exploramos patrones prácticos y reutilizables.

---

## Git Hooks con Claude

Los git hooks son scripts que Git ejecuta automáticamente antes o después de ciertos eventos. Combinarlos con Claude Code automatiza controles de calidad directamente en tu flujo de trabajo local.

### Pre-commit: Revisión automática de cambios staged

```bash
#!/bin/bash
# .git/hooks/pre-commit
# Revisa automáticamente los cambios antes de permitir el commit

echo "Ejecutando revisión con Claude Code..."

# Obtener los cambios staged
diff=$(git diff --staged --diff-filter=ACMR)

if [ -z "$diff" ]; then
    exit 0
fi

# Revisar con Claude
resultado=$(echo "$diff" | claude -p \
    "Revisa estos cambios de código. Si encuentras bugs críticos o problemas de seguridad graves, responde SOLO con la palabra BLOQUEAR seguida de la explicación. Si todo está bien, responde SOLO con la palabra APROBAR." \
    --max-turns 1 \
    --max-budget-usd 0.05 \
    --output-format text)

if echo "$resultado" | grep -q "BLOQUEAR"; then
    echo ""
    echo "== COMMIT BLOQUEADO POR CLAUDE =="
    echo "$resultado"
    echo ""
    echo "Corrige los problemas indicados y vuelve a intentar."
    exit 1
fi

echo "Revisión aprobada por Claude."
exit 0
```

### Commit-msg: Validar y mejorar mensajes de commit

```bash
#!/bin/bash
# .git/hooks/commit-msg
# Valida y opcionalmente mejora el mensaje de commit

mensaje_original=$(cat "$1")

# Verificar que el mensaje sigue conventional commits
resultado=$(claude -p \
    "Analiza este mensaje de commit: '$mensaje_original'.
     Verifica si sigue el formato Conventional Commits (feat:, fix:, docs:, etc).
     Si es correcto, responde SOLO 'OK'.
     Si no es correcto, sugiere una versión mejorada en una sola línea." \
    --max-turns 1 \
    --max-budget-usd 0.02 \
    --output-format text)

if [ "$resultado" != "OK" ]; then
    echo ""
    echo "== SUGERENCIA DE CLAUDE PARA EL MENSAJE DE COMMIT =="
    echo "Original:  $mensaje_original"
    echo "Sugerido:  $resultado"
    echo ""
    # Opcional: reemplazar automáticamente el mensaje
    # echo "$resultado" > "$1"
fi

exit 0
```

### Pre-push: Verificación final

```bash
#!/bin/bash
# .git/hooks/pre-push
# Verificación final antes de hacer push

echo "Ejecutando verificación pre-push con Claude..."

# Obtener los commits que se van a pushear
commits=$(git log @{u}..HEAD --oneline 2>/dev/null)

if [ -z "$commits" ]; then
    exit 0
fi

# Obtener el diff completo
diff=$(git diff @{u}..HEAD)

echo "$diff" | claude -p \
    "Estos son los cambios que se van a pushear. Haz una verificación rápida:
     1. ¿Hay archivos sensibles (passwords, API keys, .env)?
     2. ¿Hay archivos de debug o console.log que deberían eliminarse?
     3. ¿Hay conflictos de merge sin resolver?
     Responde brevemente." \
    --max-turns 1 \
    --max-budget-usd 0.05

exit 0
```

### Instalar hooks fácilmente

```bash
#!/bin/bash
# install-hooks.sh
# Script para instalar los hooks en cualquier repositorio

HOOKS_DIR=".git/hooks"

# Pre-commit
cp hooks/pre-commit "$HOOKS_DIR/pre-commit"
chmod +x "$HOOKS_DIR/pre-commit"

# Commit-msg
cp hooks/commit-msg "$HOOKS_DIR/commit-msg"
chmod +x "$HOOKS_DIR/commit-msg"

# Pre-push
cp hooks/pre-push "$HOOKS_DIR/pre-push"
chmod +x "$HOOKS_DIR/pre-push"

echo "Hooks instalados correctamente."
```

---

## Batch Processing

Procesar múltiples archivos automáticamente es uno de los usos más potentes de Claude Code en modo no interactivo.

### Añadir documentación a múltiples archivos

```bash
#!/bin/bash
# add-docs.sh
# Añade documentación JSDoc/docstrings a todos los archivos de un directorio

directorio="${1:-src}"
extension="${2:-ts}"

echo "Procesando archivos .$extension en $directorio..."

for archivo in $(find "$directorio" -name "*.$extension" -not -path "*/node_modules/*"); do
    echo "Documentando: $archivo"

    claude -p "Añade documentación JSDoc a todas las funciones y clases exportadas de este archivo. Mantén el código existente intacto y solo añade los comentarios de documentación. El archivo es: $archivo" \
        --max-turns 3 \
        --max-budget-usd 0.10

    echo "Completado: $archivo"
    echo "---"
done

echo "Proceso de documentación completado."
```

### Migrar archivos de un formato a otro

```bash
#!/bin/bash
# migrate-to-typescript.sh
# Convierte archivos JavaScript a TypeScript

for archivo in $(find src -name "*.js" -not -name "*.config.js"); do
    nuevo_archivo="${archivo%.js}.ts"
    echo "Migrando: $archivo -> $nuevo_archivo"

    claude -p "Convierte este archivo JavaScript a TypeScript. Añade tipos explícitos donde sea posible. El archivo es: $archivo. Guarda el resultado como $nuevo_archivo" \
        --max-turns 5 \
        --max-budget-usd 0.15

    echo "Migrado: $nuevo_archivo"
done
```

### Revisión en lote de archivos

```bash
#!/bin/bash
# batch-review.sh
# Revisa todos los archivos modificados desde el último release

TAG_ANTERIOR=$(git describe --tags --abbrev=0 2>/dev/null || echo "HEAD~20")
ARCHIVOS_MODIFICADOS=$(git diff --name-only "$TAG_ANTERIOR"..HEAD -- '*.py' '*.ts' '*.go' '*.java')

informe="/tmp/revision-$(date +%Y%m%d).md"
echo "# Informe de Revisión de Código" > "$informe"
echo "Fecha: $(date)" >> "$informe"
echo "Rango: $TAG_ANTERIOR..HEAD" >> "$informe"
echo "" >> "$informe"

for archivo in $ARCHIVOS_MODIFICADOS; do
    if [ ! -f "$archivo" ]; then
        continue
    fi

    echo "Revisando: $archivo"

    resultado=$(claude -p "Revisa este archivo brevemente. Lista los 3 problemas más importantes (si los hay). Sé conciso." \
        --max-turns 1 \
        --max-budget-usd 0.05 \
        --output-format text \
        < "$archivo")

    echo "## $archivo" >> "$informe"
    echo "" >> "$informe"
    echo "$resultado" >> "$informe"
    echo "" >> "$informe"
done

echo "Informe generado en: $informe"
```

---

## Tareas Programadas (Cron Jobs)

### Auditoría de seguridad semanal

```bash
#!/bin/bash
# security-audit.sh
# Ejecutar semanalmente: 0 9 * * 1 /path/to/security-audit.sh

PROYECTO="/ruta/a/tu/proyecto"
INFORME="/var/reports/security-$(date +%Y%m%d).md"

cd "$PROYECTO" || exit 1

# Auditar dependencias
claude -p "Analiza el archivo de dependencias de este proyecto y lista las que podrían tener vulnerabilidades conocidas. Revisa package.json, requirements.txt, go.mod o cualquier archivo de dependencias que encuentres." \
    --max-turns 5 \
    --max-budget-usd 0.30 \
    --output-format text \
    > "$INFORME"

# Enviar notificación (ejemplo con webhook de Slack)
if [ -n "$SLACK_WEBHOOK_URL" ]; then
    curl -X POST "$SLACK_WEBHOOK_URL" \
        -H 'Content-type: application/json' \
        -d "{\"text\": \"Auditoría de seguridad semanal completada. Informe en: $INFORME\"}"
fi
```

### Limpieza de código mensual

```bash
#!/bin/bash
# monthly-cleanup.sh
# Detectar código muerto, imports sin usar, etc.

PROYECTO="/ruta/a/tu/proyecto"
cd "$PROYECTO" || exit 1

claude -p "Analiza este proyecto y encuentra:
1. Imports no utilizados
2. Variables declaradas pero no usadas
3. Funciones que no se llaman desde ningún lugar
4. Archivos que parecen no estar en uso
Lista todo organizado por archivo." \
    --max-turns 10 \
    --max-budget-usd 0.50 \
    > "/var/reports/cleanup-$(date +%Y%m%d).md"
```

---

## `claude ultrareview`: Revisión Profunda en CI/Scripts

A partir de la versión 2.1.120, Claude Code incluye el subcomando `ultrareview` que permite ejecutar el comando `/ultrareview` de forma completamente no-interactiva desde pipelines de CI o scripts. Es la forma recomendada de incorporar revisiones exhaustivas de código en flujos automatizados.

> **Nota:** Si no conoces `/ultrareview` como herramienta interactiva, consúltalo en el [Módulo 6 — Plan Mode y Workflows](../../modulo-06-planificacion-opus/teoria/). Este apartado se centra exclusivamente en su uso automatizado.

### Sintaxis

```bash
claude ultrareview [target] [flags]
```

El parámetro `target` acepta tres formas:

| Forma | Ejemplo | Cuándo usarlo |
|-------|---------|---------------|
| Número de PR | `42` | En GitHub Actions, cuando tienes el número de PR |
| Nombre de rama | `feature/login` | Para revisar todos los cambios de una rama respecto a `main` |
| Rango de commits | `abc123..HEAD` | Para revisar un conjunto exacto de commits |

El flag `--json` produce una salida estructurada (JSON) que los scripts pueden parsear directamente.

### Ejemplo básico en línea de comandos

```bash
# Revisar los cambios de la rama actual respecto a main
claude ultrareview main..HEAD

# Revisar una rama concreta
claude ultrareview feature/nueva-api

# Revisar y obtener salida JSON
claude ultrareview main..HEAD --json > revision.json
```

### Integración en GitHub Actions

El caso de uso más habitual es revisar un PR automáticamente al abrirse. El número del PR está disponible en el contexto del evento de GitHub:

```yaml
# .github/workflows/ultra-review.yml
name: Ultra Review en PR

on:
  pull_request:
    types: [opened, synchronize]

jobs:
  ultrareview:
    runs-on: ubuntu-latest
    permissions:
      contents: read
      pull-requests: write
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Instalar Claude Code
        run: npm install -g @anthropic-ai/claude-code

      - name: Ultra Review
        run: claude ultrareview ${{ github.event.pull_request.number }} --json > review.json
        env:
          ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}

      - name: Publicar resultado como comentario
        uses: actions/github-script@v7
        with:
          script: |
            const fs = require('fs');
            const review = JSON.parse(fs.readFileSync('review.json', 'utf8'));
            github.rest.issues.createComment({
              issue_number: context.issue.number,
              owner: context.repo.owner,
              repo: context.repo.repo,
              body: review.summary
            });
```

### Integración en un pre-merge hook

Puedes bloquear merges si la revisión detecta problemas críticos:

```bash
#!/bin/bash
# scripts/pre-merge-ultrareview.sh
# Ejecutar antes de hacer merge a main

RAMA_ORIGEN="${1:?Uso: $0 <rama-origen>}"

echo "Ejecutando Ultra Review de $RAMA_ORIGEN..."

resultado=$(claude ultrareview "main..$RAMA_ORIGEN" --json)
estado=$(echo "$resultado" | python3 -c "import sys,json; print(json.load(sys.stdin).get('status','ok'))")

if [ "$estado" = "critical" ]; then
    echo ""
    echo "== MERGE BLOQUEADO: problemas críticos detectados =="
    echo "$resultado" | python3 -m json.tool
    exit 1
fi

echo "Ultra Review completado. Puedes hacer el merge."
exit 0
```

### Consumir la salida JSON en un script Python

El flag `--json` produce un objeto con los campos `status`, `summary`, `issues` y `metrics`:

```python
import subprocess
import json

def ultrareview_rama(rama: str) -> dict:
    """Ejecuta claude ultrareview y devuelve el resultado parseado."""
    resultado = subprocess.run(
        ["claude", "ultrareview", rama, "--json"],
        capture_output=True,
        text=True,
        check=True,
        env={"ANTHROPIC_API_KEY": os.environ["ANTHROPIC_API_KEY"]}
    )
    return json.loads(resultado.stdout)

# Ejemplo de uso
revision = ultrareview_rama("feature/nueva-api")
print(f"Estado: {revision['status']}")
print(f"Problemas encontrados: {len(revision['issues'])}")

for issue in revision["issues"]:
    print(f"  [{issue['severity']}] {issue['file']}:{issue['line']} — {issue['message']}")
```

### Diferencias con `claude -p` para revisiones

| Aspecto | `claude -p "revisa..."` | `claude ultrareview` |
|---------|------------------------|----------------------|
| Profundidad | Configurable | Siempre máxima (equivalente a `/ultrareview`) |
| Formato de salida | Texto libre | Estructurado con `--json` |
| Target | Manual en el prompt | Nativo: PR, rama, rango |
| Integración CI | General | Optimizado para revisiones de PR |
| Disponible desde | Siempre | v2.1.120+ |

### Control de costes

`ultrareview` realiza un análisis más profundo que una revisión ordinaria, lo que implica un mayor consumo de tokens. Combínalo con `--max-budget-usd` para acotar el gasto:

```bash
claude ultrareview $PR_NUMBER --json --max-budget-usd 0.50
```

Guía de referencia por tipo de PR:

| Tamaño del PR | `--max-budget-usd` recomendado |
|---------------|-------------------------------|
| Pequeño (<200 líneas) | `0.20` |
| Mediano (200-800 líneas) | `0.50` |
| Grande (>800 líneas) | `1.00` |

---

## Integración con Otros Sistemas CI/CD

### Jenkins

```groovy
// Jenkinsfile
pipeline {
    agent any

    environment {
        ANTHROPIC_API_KEY = credentials('anthropic-api-key')
    }

    stages {
        stage('Code Review') {
            steps {
                script {
                    def diff = sh(
                        script: 'git diff HEAD~1',
                        returnStdout: true
                    )

                    def review = sh(
                        script: """
                            echo '${diff}' | claude -p \
                                "Revisa estos cambios de código. Sé constructivo y específico." \
                                --max-turns 3 \
                                --max-budget-usd 0.10 \
                                --output-format text
                        """,
                        returnStdout: true
                    )

                    echo "Revisión de Claude:\n${review}"
                }
            }
        }
    }
}
```

### GitLab CI

```yaml
# .gitlab-ci.yml
claude-review:
  stage: review
  image: ubuntu:latest
  before_script:
    - apt-get update && apt-get install -y curl git
    - curl -fsSL https://claude.ai/install.sh | bash
  script:
    - |
      git diff $CI_MERGE_REQUEST_DIFF_BASE_SHA..HEAD | claude -p \
        "Revisa estos cambios de código del merge request. Sé constructivo." \
        --max-turns 3 \
        --max-budget-usd 0.10 \
        --output-format text
  rules:
    - if: $CI_PIPELINE_SOURCE == "merge_request_event"
  variables:
    ANTHROPIC_API_KEY: $ANTHROPIC_API_KEY
```

### CircleCI

```yaml
# .circleci/config.yml
version: 2.1

jobs:
  claude-review:
    docker:
      - image: cimg/base:stable
    steps:
      - checkout
      - run:
          name: Instalar Claude Code
          command: curl -fsSL https://claude.ai/install.sh | bash
      - run:
          name: Revisión de código
          command: |
            git diff HEAD~1 | claude -p \
              "Revisa estos cambios. Enfócate en seguridad y rendimiento." \
              --max-turns 3 \
              --max-budget-usd 0.10

workflows:
  review:
    jobs:
      - claude-review:
          context: anthropic-credentials
```

### Azure DevOps

```yaml
# azure-pipelines.yml
trigger:
  branches:
    include:
      - main
      - develop

pr:
  branches:
    include:
      - main

pool:
  vmImage: 'ubuntu-latest'

steps:
  - script: curl -fsSL https://claude.ai/install.sh | bash
    displayName: 'Instalar Claude Code'

  - script: |
      git diff origin/main...HEAD | claude -p \
        "Revisa estos cambios de código. Prioriza seguridad." \
        --max-turns 3 \
        --max-budget-usd 0.10 \
        --output-format text
    displayName: 'Revisión con Claude'
    env:
      ANTHROPIC_API_KEY: $(ANTHROPIC_API_KEY)
```

---

## El Flag `--dangerously-skip-permissions`

En entornos de CI/CD donde no hay un usuario interactivo, Claude Code puede necesitar ejecutar comandos sin pedir confirmación:

```bash
claude -p "Corrige los errores de linting en src/" \
    --dangerously-skip-permissions \
    --max-turns 10 \
    --max-budget-usd 0.50
```

**ADVERTENCIA IMPORTANTE**: Este flag permite que Claude ejecute cualquier comando sin confirmación. Solo usarlo en:
- Entornos de CI/CD aislados (contenedores desechables)
- Entornos sandbox
- Nunca en máquinas de desarrollo local con datos sensibles

Alternativa más segura: configurar permisos en `settings.json`:

```json
{
  "permissions": {
    "allow": [
      "Read",
      "Grep",
      "Glob",
      "WebFetch"
    ],
    "deny": [
      "Bash(rm *)",
      "Bash(git push --force)"
    ]
  }
}
```

---

## Scripts de Automatización Especializados

### Generador de notas de versión

```bash
#!/bin/bash
# generate-release-notes.sh

VERSION="${1:?Uso: $0 <version>}"
TAG_ANTERIOR=$(git describe --tags --abbrev=0 HEAD^ 2>/dev/null || echo "")

if [ -z "$TAG_ANTERIOR" ]; then
    RANGO="HEAD"
else
    RANGO="$TAG_ANTERIOR..HEAD"
fi

# Obtener commits
commits=$(git log "$RANGO" --pretty=format:"%h %s" --no-merges)

# Generar notas con Claude
claude -p "Genera notas de versión profesionales para la versión $VERSION.
Estos son los commits:

$commits

Formato de salida:
# Release $VERSION

## Nuevas Funcionalidades
- ...

## Correcciones de Bugs
- ...

## Mejoras
- ...

## Cambios Importantes (Breaking Changes)
- ...

Agrupa los commits por categoría. Ignora commits de merge. Redacta en español." \
    --max-turns 1 \
    --max-budget-usd 0.05
```

### Revisor de actualizaciones de dependencias

```bash
#!/bin/bash
# review-deps-update.sh

# Obtener dependencias desactualizadas (ejemplo con npm)
outdated=$(npm outdated --json 2>/dev/null)

if [ -z "$outdated" ] || [ "$outdated" = "{}" ]; then
    echo "Todas las dependencias están actualizadas."
    exit 0
fi

claude -p "Analiza estas dependencias desactualizadas de npm y recomienda cuáles actualizar:

$outdated

Para cada una, indica:
1. Riesgo de actualizar (bajo/medio/alto)
2. Si es un parche, minor o major update
3. Si tiene breaking changes conocidos
4. Tu recomendación: actualizar ahora / esperar / investigar

Responde en español." \
    --max-turns 1 \
    --max-budget-usd 0.05
```

### Generador de migraciones de base de datos

```bash
#!/bin/bash
# generate-migration.sh

DESCRIPCION="${1:?Uso: $0 <descripcion-del-cambio>}"
DIRECTORIO_MIGRACIONES="${2:-migrations}"

# Listar migraciones existentes para contexto
migraciones_existentes=$(ls -1 "$DIRECTORIO_MIGRACIONES"/*.sql 2>/dev/null | tail -5)

claude -p "Genera una migración SQL para: $DESCRIPCION

Migraciones recientes existentes para contexto:
$migraciones_existentes

Genera:
1. Un archivo de migración UP (aplicar cambio)
2. Un archivo de migración DOWN (revertir cambio)
3. Nombre del archivo con timestamp: YYYYMMDDHHMMSS_descripcion.sql

Usa SQL estándar compatible con PostgreSQL." \
    --max-turns 3 \
    --max-budget-usd 0.10
```

---

## Sesiones Remotas y Ejecución en Background

### Sesiones remotas con `--remote`

Para entornos sin terminal interactiva (servidores headless, contenedores):

```bash
# Iniciar una sesión remota
claude --remote

# Esto genera una URL que puedes abrir en tu navegador local
# para interactuar con Claude Code que se ejecuta en el servidor remoto
```

### Ejecución en background

Para tareas de larga duración:

```bash
# Ejecutar en background y guardar la salida
nohup claude -p "Realiza una auditoría completa del proyecto" \
    --max-turns 20 \
    --max-budget-usd 1.00 \
    --output-format json \
    > /tmp/auditoria-resultado.json 2>&1 &

echo "Tarea iniciada en background. PID: $!"
echo "Resultado se guardará en /tmp/auditoria-resultado.json"
```

### Automatización multi-proyecto con `--add-dir`

```bash
# Analizar múltiples directorios en una sola sesión
claude -p "Compara la estructura y patrones de estos dos proyectos. Identifica inconsistencias." \
    --add-dir /ruta/proyecto-frontend \
    --add-dir /ruta/proyecto-backend \
    --max-turns 5 \
    --max-budget-usd 0.20
```

---

## Resumen de Patrones

| Patrón | Herramienta | Flag Clave |
|--------|-------------|-----------|
| Git hooks | Scripts Bash + Claude `-p` | `--max-turns 1`, `--max-budget-usd 0.05` |
| Batch processing | Bucles Bash + Claude `-p` | `--max-turns 3`, `--output-format json` |
| Cron jobs | Cron + scripts Bash | `--max-budget-usd`, `--output-format text` |
| Revisión exhaustiva en CI | `claude ultrareview [target]` | `--json`, `--max-budget-usd` |
| Jenkins / GitLab / CircleCI | Pipeline config + Claude | `--dangerously-skip-permissions` |
| Sesiones remotas | `claude --remote` | N/A |
| Background | `nohup claude -p ... &` | `--output-format json` |
| Multi-proyecto | Claude `-p` + `--add-dir` | `--add-dir /ruta` |

La clave de la automatización exitosa con Claude Code es combinar el modo no interactivo (`-p`) con límites adecuados (`--max-turns`, `--max-budget-usd`) y el formato de salida correcto para cada caso de uso.

---

> **Profundiza**: Para dominar la orquestación multi-agente, prompts robustos para CI/CD desatendido, procesamiento en lote a escala y testing de prompts — consulta el [Módulo D2: Orquestación Multi-Agente y Automatización a Escala](https://github.com/josefcohernandez/curso-ia-agentica/blob/master/modulo-D2-orquestacion-automatizacion/README.md) del curso "Desarrollo Profesional con IA Agéntica".
