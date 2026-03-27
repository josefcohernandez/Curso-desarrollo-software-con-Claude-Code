# 05 - Cron y Tareas Programadas

Claude Code ofrece tres enfoques complementarios para programar tareas recurrentes: las herramientas nativas `CronCreate`/`CronList`/`CronDelete`, el skill `/loop` para monitorización durante una sesión activa, y la integración con sistemas de scheduling externos como crontab o GitHub Actions. Este capítulo describe cada uno y cuándo elegirlos.

---

## Tareas programadas nativas en Claude Code

Claude Code incluye herramientas nativas para programar tareas recurrentes directamente desde la sesión interactiva, sin necesidad de configurar cron del sistema ni GitHub Actions.

### Las herramientas de scheduling

| Herramienta | Descripción |
|-------------|-------------|
| `CronCreate` | Registra una tarea recurrente con expresión cron y un prompt |
| `CronList` | Lista todas las tareas programadas activas |
| `CronDelete` | Elimina una tarea programada por su ID |

### Crear una tarea programada

```text
Crea una tarea programada con CronCreate que ejecute
un análisis de seguridad del repositorio cada lunes a las 9:00.
El prompt debe revisar los ficheros modificados la semana pasada
buscando patrones de inyección SQL y credenciales hardcodeadas.
```

El formato de la expresión cron sigue la sintaxis estándar:

```text
┌───────────── minuto (0-59)
│ ┌───────────── hora (0-23)
│ │ ┌───────────── día del mes (1-31)
│ │ │ ┌───────────── mes (1-12)
│ │ │ │ ┌───────────── día de la semana (0=domingo, 6=sábado)
│ │ │ │ │
* * * * *
```

Ejemplos de expresiones útiles:

```text
0 9 * * 1      Cada lunes a las 9:00
0 9 * * 1-5    Cada día laborable a las 9:00
0 */4 * * *    Cada 4 horas
0 18 * * 5     Los viernes a las 18:00
```

### Ver y eliminar tareas programadas

```text
# Listar todas las tareas activas
Usa CronList para mostrarme las tareas programadas que tengo configuradas.

# Eliminar una tarea
Usa CronDelete para eliminar la tarea de ID <id-de-la-tarea>.
```

### Casos de uso típicos

- Análisis de seguridad semanal del repositorio
- Generación de reportes de PRs abiertas cada mañana
- Verificación diaria de dependencias con vulnerabilidades conocidas
- Revisión periódica del estado de los tests en la rama principal

---

## El skill /loop

El skill `/loop` permite ejecutar un prompt o un slash command de forma recurrente durante una sesión activa. Es ideal para **monitorizar procesos en curso** o **vigilar el estado de algo** a intervalos regulares.

### Sintaxis

```text
/loop <intervalo> <comando-o-prompt>
```

El intervalo se especifica con sufijos de tiempo:

```text
/loop 5m /babysit-prs          Ejecuta el skill cada 5 minutos
/loop 1h /security-audit       Ejecuta el skill cada hora
/loop 30s "¿Hay errores nuevos en los logs?"  Pregunta cada 30 segundos
```

Si no se especifica intervalo, el valor por defecto es **10 minutos**.

### Casos de uso del skill /loop

**Monitorizar el estado de un deploy:**

```text
/loop 5m "Ejecuta 'kubectl get pods -n production' y reporta si algún pod tiene estado diferente a Running. Si hay problemas, descríbelos con detalle."
```

**Revisar PRs nuevas periódicamente:**

```text
/loop 15m /babysit-prs
```

**Vigilar logs en busca de errores:**

```text
/loop 2m "Lee las últimas 50 líneas de /var/log/app/error.log y alerta si hay errores nuevos desde la última revisión."
```

**Seguimiento de un proceso largo:**

```text
/loop 10m "Comprueba el estado del job de migración de base de datos ejecutando 'python manage.py migration_status'. Reporta el porcentaje completado y el tiempo estimado restante."
```

### Cuándo NO usar /loop

- Para tareas puntuales que solo necesitan ejecutarse una vez: usa un prompt directo
- Para tareas que deben ejecutarse aunque no haya una sesión activa: usa `CronCreate` o crontab del sistema
- Para intervalos menores a 30 segundos: genera demasiado ruido y puede agotar el contexto rápidamente

### Timestamps en tareas programadas

> **Novedad v3.2 (v2.1.85)**

Cuando una tarea programada (`/loop` o `CronCreate`) se dispara, Claude Code añade automáticamente un **marcador de timestamp** en el transcript. Esto facilita la revisión posterior: puedes ver exactamente a qué hora se ejecutó cada iteración sin depender de los logs del sistema.

### Detener un /loop activo

Para detener un loop en ejecución, interrumpe la sesión con `Ctrl+C` o escribe `stop` cuando Claude te pregunte si continuar.

---

## Integración con sistemas de scheduling externos

Para tareas que deben ejecutarse independientemente de si hay una sesión de Claude Code activa, la integración con scheduling externo es la solución correcta.

### crontab del sistema + claude -p

El modo no interactivo (`-p`) de Claude Code permite lanzarlo desde cron como cualquier otro script:

```bash
# Ver el crontab actual
crontab -l

# Editar el crontab
crontab -e
```

Ejemplo de entrada en crontab para un reporte diario:

```bash
# Reporte diario de PRs a las 9:00 de lunes a viernes
0 9 * * 1-5 /home/usuario/scripts/daily-pr-report.sh
```

El script correspondiente:

```bash
#!/bin/bash
# daily-pr-report.sh

export ANTHROPIC_API_KEY="<tu-api-key>"
PROJECT_DIR="/home/usuario/mi-proyecto"

cd "$PROJECT_DIR" || exit 1

claude -p "Lista todas las PRs abiertas en este repositorio. \
  Para cada una, indica: título, autor, fecha de apertura, \
  número de comentarios y si tiene conflictos. \
  Al final, genera un resumen ejecutivo de 3 líneas con \
  las PRs que más necesitan atención." \
  --output-format text > /tmp/daily-pr-report.txt

# Enviar el reporte por email (requiere mailutils instalado)
mail -s "Reporte diario de PRs - $(date +%Y-%m-%d)" \
  equipo@empresa.com < /tmp/daily-pr-report.txt
```

### GitHub Actions con schedule trigger

Para proyectos en GitHub, el trigger `schedule` de GitHub Actions es la opción más portable:

```yaml
# .github/workflows/weekly-security-audit.yml
name: Auditoría de Seguridad Semanal

on:
  schedule:
    - cron: "0 9 * * 1"  # Cada lunes a las 9:00 UTC
  workflow_dispatch:       # Permite lanzarlo manualmente también

permissions:
  contents: read
  issues: write

jobs:
  security-audit:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 7  # Última semana de commits

      - uses: anthropics/claude-code-action@v1
        with:
          anthropic_api_key: ${{ secrets.ANTHROPIC_API_KEY }}
          prompt: |
            Realiza una auditoría de seguridad de los cambios de la última semana.
            Revisa los commits de los últimos 7 días con 'git log --since=7.days --name-only'.
            Para cada fichero modificado, verifica:
            1. Si hay credenciales o tokens hardcodeados
            2. Si hay patrones de inyección SQL o XSS
            3. Si se han desactivado validaciones de seguridad

            Crea un issue en GitHub con el título "Auditoría de Seguridad - <fecha>"
            listando todos los hallazgos. Si no hay hallazgos, crea el issue
            con el mensaje "Sin hallazgos de seguridad esta semana."
          claude_args: "--max-turns 10"
```

### Comparación de los tres enfoques

| Enfoque | Cuándo usar |
|---------|-------------|
| `CronCreate` nativo | Tareas ligadas a una instancia de Claude Code en ejecución |
| `/loop` | Monitorizar procesos durante una sesión activa |
| crontab del sistema | Tareas en servidores sin sesión interactiva |
| GitHub Actions schedule | Tareas en proyectos GitHub, sin infraestructura propia |

---

## Ejemplo práctico completo: pipeline de reporte diario

Este ejemplo combina las tres técnicas en un pipeline real para un equipo de desarrollo.

### Objetivo

Cada mañana a las 9:00, el equipo recibe un reporte con:

1. PRs abiertas que necesitan atención
2. Tests fallando en la rama principal
3. Dependencias con vulnerabilidades nuevas

### Implementación con crontab

```bash
#!/bin/bash
# /scripts/morning-report.sh
# Ejecutado por crontab: 0 9 * * 1-5 /scripts/morning-report.sh

set -euo pipefail

REPORT_FILE="/tmp/morning-report-$(date +%Y%m%d).txt"
PROJECT_DIR="/srv/mi-proyecto"
RECIPIENTS="dev-team@empresa.com"

cd "$PROJECT_DIR"

echo "=== REPORTE MATUTINO $(date '+%Y-%m-%d %H:%M') ===" > "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

# Sección 1: PRs abiertas
claude -p "Lista las PRs abiertas ordenadas por fecha de última actividad. \
  Para cada una indica si lleva más de 3 días sin actividad (marcarla como STALE). \
  Formato: una línea por PR." \
  --output-format text >> "$REPORT_FILE"

echo "" >> "$REPORT_FILE"

# Sección 2: Estado de tests
claude -p "Ejecuta 'npm test -- --passWithNoTests 2>&1 | tail -20' \
  y resume el estado: cuántos tests pasan, cuántos fallan y \
  el nombre de los tests fallidos si los hay." \
  --output-format text >> "$REPORT_FILE"

echo "" >> "$REPORT_FILE"

# Sección 3: Dependencias vulnerables
claude -p "Ejecuta 'npm audit --json 2>/dev/null | head -100' y lista \
  solo las vulnerabilidades de severidad HIGH o CRITICAL, \
  con el nombre del paquete afectado y la versión que corrige el problema." \
  --output-format text >> "$REPORT_FILE"

# Enviar el reporte
mail -s "Reporte Matutino - $(date +%Y-%m-%d)" "$RECIPIENTS" < "$REPORT_FILE"

echo "Reporte enviado a $RECIPIENTS"
```

### Implementación equivalente en GitHub Actions

```yaml
# .github/workflows/morning-report.yml
name: Reporte Matutino del Equipo

on:
  schedule:
    - cron: "0 9 * * 1-5"  # Lunes a viernes a las 9:00 UTC
  workflow_dispatch:

permissions:
  contents: read
  issues: write
  pull-requests: read

jobs:
  morning-report:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Instalar dependencias
        run: npm ci

      - uses: anthropics/claude-code-action@v1
        with:
          anthropic_api_key: ${{ secrets.ANTHROPIC_API_KEY }}
          prompt: |
            Genera el reporte matutino del equipo con tres secciones:

            1. PRs ABIERTAS: Lista las PRs ordenadas por última actividad.
               Marca como STALE las que llevan más de 3 días sin actividad.

            2. ESTADO DE TESTS: Ejecuta los tests con 'npm test -- --passWithNoTests'
               y resume cuántos pasan y cuántos fallan.

            3. VULNERABILIDADES: Ejecuta 'npm audit' y lista solo las
               vulnerabilidades HIGH y CRITICAL con el paquete afectado
               y la versión que las corrige.

            Crea un issue con el título "Reporte Matutino - <fecha>"
            con el contenido del reporte en formato Markdown.
          claude_args: "--max-turns 15 --max-budget-usd 2.00"
```

---

## Errores comunes

| Error | Causa | Solución |
|-------|-------|---------|
| `CronCreate` no persiste entre reinicios | Las tareas nativas son de la sesión actual | Usar crontab del sistema para persistencia |
| `/loop` con intervalo muy corto | Agota el contexto rápidamente | Usar intervalos de al menos 2-5 minutos |
| Script de cron sin ANTHROPIC_API_KEY | La variable de entorno no se hereda en cron | Exportarla explícitamente en el script o en `/etc/environment` |
| Cron ejecuta el script pero no encuentra claude | PATH reducido en entornos cron | Usar la ruta absoluta: `/usr/local/bin/claude` |
| Reporte sin fecha en el nombre del fichero | Los ficheros se sobreescriben | Incluir `$(date +%Y%m%d)` en el nombre del fichero |

---

## Resumen

- `CronCreate`, `CronList` y `CronDelete` son las herramientas nativas de Claude Code para programar tareas recurrentes sin salir de la sesión
- `/loop <intervalo> <comando>` ejecuta un skill o prompt periódicamente durante una sesión activa; el intervalo por defecto es 10 minutos
- Para tareas que deben ejecutarse sin sesión activa, usar crontab del sistema con `claude -p` en modo no interactivo
- GitHub Actions con trigger `schedule` es la opción más portable para proyectos en GitHub
- Combinar los tres enfoques permite cubrir todos los escenarios: monitoreo en sesión, tareas en servidor y pipelines en CI
