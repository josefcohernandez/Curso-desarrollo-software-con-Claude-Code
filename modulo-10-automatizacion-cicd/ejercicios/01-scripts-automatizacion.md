# Ejercicio 01: Crear Scripts de Automatización

## Objetivo

Crear dos scripts funcionales que utilicen Claude Code en modo no interactivo para automatizar tareas comunes de desarrollo: revisión de código y generación de notas de versión.

**Duración estimada:** 15 minutos

---

## Parte 1: Script de Revisión Automática de Código

### Contexto

Tu equipo quiere automatizar la revisión de código antes de cada commit. El script debe analizar los cambios staged en Git y proporcionar feedback constructivo.

### Instrucciones

1. **Guarda la ruta del modulo** para poder invocar los scripts de ejemplo
   desde el repositorio de prueba:

```bash
MODULO_AUTOMATIZACION="/ruta/al/Curso-desarrollo-software-con-Claude-Code/modulo-10-automatizacion-cicd"
```

> Los scripts se ejecutan sobre el repositorio Git del directorio actual, asi
> que puedes lanzarlos desde `/tmp/proyecto-prueba` usando una ruta absoluta.

2. **Crea un repositorio de prueba** (o usa uno existente):

```bash
mkdir /tmp/proyecto-prueba && cd /tmp/proyecto-prueba
git init
```

3. **Crea un archivo con código que tenga problemas intencionales:**

```bash
cat > app.py << 'EOF'
import os
import sys
import json
import requests  # import no utilizado en este ejemplo

DB_PASSWORD = "admin123"  # password hardcodeado

def get_user(id):
    query = "SELECT * FROM users WHERE id = " + str(id)  # SQL injection
    result = eval(input("Enter expression: "))  # eval peligroso
    return result

def process_data(data):
    for i in range(len(data)):  # podria ser un for-each
        item = data[i]
        print(item)
    return None  # return innecesario
EOF

git add app.py
```

4. **Examina el script de revision de ejemplo** ubicado en:
   `"$MODULO_AUTOMATIZACION/workflows/script-review-codigo.sh"`

5. **Ejecuta el script de revision:**

```bash
chmod +x "$MODULO_AUTOMATIZACION/workflows/script-review-codigo.sh"
"$MODULO_AUTOMATIZACION/workflows/script-review-codigo.sh"
```

6. **Verifica la salida.** El script deberia detectar:
   - El password hardcodeado (`DB_PASSWORD`)
   - La vulnerabilidad de SQL injection
   - El uso peligroso de `eval()`
   - El import no utilizado
   - Oportunidades de mejora de estilo

### Tarea: Personaliza el script

Modifica el script `script-review-codigo.sh` para que:

- [ ] Use `--json-schema` para obtener salida estructurada con campos: `severidad`, `problemas[]`, `aprobado`
- [ ] Bloquee el commit si la severidad es "crítica"
- [ ] Genere un archivo de informe en `/tmp/review-YYYYMMDD-HHMMSS.json`

**Pista:**

```bash
# Esquema JSON sugerido
SCHEMA='{
  "type": "object",
  "properties": {
    "aprobado": { "type": "boolean" },
    "severidad": { "type": "string", "enum": ["baja", "media", "alta", "crítica"] },
    "problemas": {
      "type": "array",
      "items": {
        "type": "object",
        "properties": {
          "archivo": { "type": "string" },
          "linea": { "type": "integer" },
          "tipo": { "type": "string" },
          "descripcion": { "type": "string" }
        },
        "required": ["tipo", "descripcion"]
      }
    }
  },
  "required": ["aprobado", "severidad", "problemas"]
}'

resultado=$(git diff --staged | claude -p "Revisa este código..." \
    --output-format json \
    --json-schema "$SCHEMA" \
    --max-turns 1)
```

---

## Parte 2: Script de Generación de Notas de Versión

### Contexto

Cada vez que tu equipo lanza una nueva versión, necesita generar notas de versión a partir del historial de commits. Este proceso manual consume tiempo y es propenso a errores.

### Instrucciones

1. **Prepara el repositorio con historial de commits:**

```bash
cd /tmp/proyecto-prueba

# Simular un historial de commits
git commit --allow-empty -m "feat: add user authentication with JWT"
git commit --allow-empty -m "fix: resolve memory leak in connection pool"
git commit --allow-empty -m "docs: update API documentation for v2 endpoints"
git commit --allow-empty -m "feat: implement real-time notifications via WebSocket"
git commit --allow-empty -m "fix: correct timezone handling in date parser"
git commit --allow-empty -m "refactor: extract validation logic into shared module"
git commit --allow-empty -m "feat: add export to CSV functionality"
git commit --allow-empty -m "fix: prevent XSS in user profile page"
git commit --allow-empty -m "chore: upgrade dependencies to latest versions"
git commit --allow-empty -m "perf: optimize database queries for dashboard"

# Crear un tag como punto de referencia
git tag v1.0.0 HEAD~10 2>/dev/null || git tag v1.0.0 $(git rev-list --max-parents=0 HEAD)
```

2. **Examina el script de notas de version** ubicado en:
   `"$MODULO_AUTOMATIZACION/workflows/script-release-notes.sh"`

3. **Ejecuta el script:**

```bash
chmod +x "$MODULO_AUTOMATIZACION/workflows/script-release-notes.sh"
"$MODULO_AUTOMATIZACION/workflows/script-release-notes.sh" v1.1.0
```

4. **Revisa la salida.** Las notas deberían incluir:
   - Nuevas funcionalidades (feat)
   - Correcciones de bugs (fix)
   - Mejoras de rendimiento (perf)
   - Otros cambios relevantes

### Tarea: Mejora el script

Añade las siguientes funcionalidades al script:

- [ ] Genera la salida en formato Markdown y guárdala en un archivo `RELEASE_NOTES.md`
- [ ] Añade una sección de "Contribuidores" extrayendo los autores de los commits
- [ ] Incluye estadisticas: número total de commits, archivos modificados, líneas añadidas/eliminadas
- [ ] Acepta un segundo parámetro opcional para especificar el tag anterior

**Pista:**

```bash
# Obtener autores
autores=$(git log "$RANGO" --pretty=format:"%an" | sort -u)

# Obtener estadisticas
stats=$(git diff --stat "$RANGO")
num_commits=$(git log "$RANGO" --oneline | wc -l)
```

---

## Verificación

Al completar este ejercicio, deberías tener:

1. Un script de revisión de código que:
   - Analiza cambios staged con Claude Code
   - Detecta problemas de seguridad, bugs y mejoras de estilo
   - Genera salida estructurada en JSON
   - Puede usarse como git hook pre-commit

2. Un script de notas de versión que:
   - Lee el historial de commits desde el último tag
   - Genera notas organizadas por categoría
   - Incluye autores y estadísticas
   - Produce un archivo Markdown listo para publicar

---

## Criterios de Evaluación

| Criterio | Puntos |
|----------|--------|
| El script de revisión detecta los problemas del código de ejemplo | 3 |
| La salida JSON cumple con el esquema definido | 2 |
| El script de notas genera categorías correctas | 3 |
| Las personalizaciones adicionales funcionan correctamente | 2 |
| **Total** | **10** |

---

## Bonus

Si terminas antes, intenta:

1. **Crear un git hook pre-commit completo** que use tu script de revisión y bloquee commits con problemas críticos
2. **Añadir soporte para múltiples idiomas** en las notas de versión (español e inglés)
3. **Integrar notificaciones** enviando el resultado a Slack o email usando `curl`
