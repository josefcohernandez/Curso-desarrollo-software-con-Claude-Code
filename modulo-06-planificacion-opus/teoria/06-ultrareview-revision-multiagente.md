# 06 - Ultrareview: Revisión de Código Multi-Agente

## Objetivos de aprendizaje

Al terminar esta sección sabrás:
- Qué es `/ultrareview` y cómo se diferencia de una revisión de código ordinaria
- Cuándo usarlo en sesión interactiva y cuándo desde la CLI o un pipeline CI/CD
- Cómo interpretar el output estructurado con `--json`

---

## Qué es `/ultrareview`

`/ultrareview` es una feature de revisión de código **multi-agente en la nube**
introducida en v2.1.111 y ampliada en v2.1.120. A diferencia de pedir a Claude
"revisa este archivo", `/ultrareview` orquesta varios subagentes que analizan
el código en paralelo y consolidan sus hallazgos en un informe unificado.

**Qué examina cada subagente (por defecto):**
- Corrección lógica y posibles bugs
- Vulnerabilidades de seguridad
- Cobertura de casos límite
- Calidad de tests existentes
- Deuda técnica y oportunidades de refactoring
- Consistencia de estilo y convenciones del proyecto

El resultado es más exhaustivo que una revisión manual de Claude porque los
subagentes trabajan con perspectivas independientes y luego se contrastan,
reduciendo los falsos negativos.

---

## Usar `/ultrareview` en sesión interactiva

### Revisar el branch actual

Ejecuta `/ultrareview` sin argumentos para revisar todos los cambios del
branch activo respecto a la rama base:

```bash
# En una sesión interactiva de Claude Code
/ultrareview
```

Claude Code sube el diff al entorno cloud, lanza los subagentes y devuelve
el informe en la terminal. El proceso puede tardar entre 30 segundos y
varios minutos según el tamaño del cambio.

### Revisar un Pull Request de GitHub

Proporciona el número de PR como argumento:

```bash
/ultrareview 42
/ultrareview <número-de-PR>
```

Claude Code accede al PR directamente usando las credenciales de GitHub
configuradas (las mismas que usa para `/pr` y `gh`). No es necesario
tener el branch checkeado localmente.

---

## Usar `ultrareview` desde la CLI

Fuera de una sesión interactiva, el subcomando `ultrareview` de la CLI
permite integrarlo en scripts y pipelines:

```bash
# Revisar el branch actual
claude ultrareview

# Revisar un PR específico
claude ultrareview 42
claude ultrareview <número-de-PR>

# Output estructurado en JSON (útil para CI/CD)
claude ultrareview --json
claude ultrareview 42 --json
```

El flag `--json` devuelve un objeto con la estructura:

```json
{
  "summary": "Resumen ejecutivo de la revisión",
  "severity": "high",
  "issues": [
    {
      "file": "src/auth/service.ts",
      "line": 87,
      "category": "security",
      "severity": "high",
      "description": "El token JWT no valida la firma antes de decodificar",
      "suggestion": "Usa jwt.verify() en lugar de jwt.decode()"
    },
    {
      "file": "src/orders/controller.ts",
      "line": 234,
      "category": "logic",
      "severity": "medium",
      "description": "Condición de carrera al actualizar el estado del pedido",
      "suggestion": "Envuelve la operación en una transacción de base de datos"
    }
  ],
  "metrics": {
    "files_reviewed": 12,
    "issues_found": 7,
    "high": 1,
    "medium": 3,
    "low": 3
  }
}
```

---

## Integrar `/ultrareview` en CI/CD

El output JSON hace que `ultrareview` sea fácil de incorporar en pipelines
de GitHub Actions, GitLab CI o cualquier sistema de integración continua:

```yaml
# .github/workflows/code-review.yml
name: Revisión automática con ultrareview

on:
  pull_request:
    branches: [main, develop]

jobs:
  ultrareview:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Instalar Claude Code
        run: npm install -g @anthropic-ai/claude-code

      - name: Ejecutar ultrareview
        env:
          ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
        run: |
          claude ultrareview ${{ github.event.pull_request.number }} --json \
            > review-output.json

      - name: Comprobar severidad
        run: |
          SEVERITY=$(jq -r '.severity' review-output.json)
          if [ "$SEVERITY" = "high" ]; then
            echo "La revisión encontró problemas de severidad alta"
            jq '.issues[] | select(.severity == "high")' review-output.json
            exit 1
          fi
```

Este pipeline falla la revisión automáticamente si `/ultrareview` detecta
algún problema de severidad alta, evitando que el PR se merge sin revisión.

---

## Cuándo usar `/ultrareview` vs una revisión ordinaria

| Situación | Herramienta recomendada |
|-----------|------------------------|
| Revisión rápida de un cambio pequeño (<50 líneas) | Prompt directo: "Revisa este diff" |
| Feature nueva con lógica compleja o seguridad | `/ultrareview` |
| PR que toca múltiples módulos independientes | `/ultrareview` |
| Código crítico (pagos, autenticación, permisos) | `/ultrareview` |
| Revisión en pipeline CI/CD con criterio de paso/fallo | `claude ultrareview --json` |
| Code review colaborativo antes de merge a main | `/ultrareview <PR#>` |

---

## Errores comunes

**Usar `/ultrareview` para cambios triviales**: Para un cambio de 5 líneas,
el coste en tiempo y tokens no se justifica. Resérvalo para cambios significativos.

**No revisar el output antes de merge**: `/ultrareview` es una herramienta de
ayuda, no un validador definitivo. Revisa el informe y decide qué issues
son relevantes para tu contexto.

**Esperar velocidad equivalente a una revisión normal**: Los subagentes trabajan
en paralelo en la nube, pero el proceso completo puede tardar varios minutos
para PRs grandes. Planifica el tiempo de espera en tus pipelines de CI.

**Ignorar el campo `severity`**: El campo `severity` del objeto JSON raíz
refleja la severidad máxima encontrada. Úsalo como señal rápida de si
necesitas revisar el output con detenimiento.

---

## Resumen

- `/ultrareview` orquesta múltiples subagentes en la nube para revisiones exhaustivas
- En sesión interactiva: `/ultrareview` (branch actual) o `/ultrareview <PR#>` (GitHub)
- Desde la CLI: `claude ultrareview [target]` con soporte de `--json` para CI/CD
- El output JSON incluye issues con fichero, línea, categoría, severidad y sugerencia
- Ideal para código crítico, PRs multi-módulo y pipelines con criterio de paso/fallo

---

## Siguiente paso

[07 - Workflows avanzados con revisión integrada](../ejercicios/02-workflow-completo.md)
