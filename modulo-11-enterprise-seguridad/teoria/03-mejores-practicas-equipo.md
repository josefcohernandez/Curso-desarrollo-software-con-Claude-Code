# Mejores Prácticas para Equipos

## Onboarding de nuevos miembros del equipo

La incorporación de nuevos miembros a un equipo que usa Claude Code debe ser gradual y estructurada. Un onboarding mal hecho genera dependencia, errores de seguridad y frustración.

### Proceso de onboarding recomendado

#### Fase 1: Instalación y configuración (Día 1)

```bash
# 1. Instalar Claude Code (instalador nativo, no requiere Node.js)
curl -fsSL https://claude.ai/install.sh | bash

# 2. Clonar el repositorio del proyecto
git clone git@github.com:empresa/mi-proyecto.git
cd mi-proyecto

# 4. Los archivos de configuración ya estarán en el repo:
#    - CLAUDE.md (instrucciones del proyecto)
#    - .claude/settings.json (permisos del proyecto)
#    - .claude/commands/ (skills del proyecto)

# 5. Configurar el entorno local
cp .env.example .env
# Rellenar variables con valores del gestor de secretos
```

#### Fase 2: Modo observación con Plan mode (Semana 1)

El nuevo miembro debe empezar usando exclusivamente **Plan mode**:

```bash
# Iniciar Claude Code en modo Plan
claude --plan

# O dentro de una sesión:
/plan
```

En esta fase, el desarrollador:

1. **Pide a Claude que analice** partes del codebase para entenderlas
2. **Revisa los planes** que Claude propone antes de ejecutar nada
3. **Aprende las convenciones** del proyecto viendo cómo Claude las sigue
4. **Entiende el flujo** de trabajo del equipo

```
Ejemplo de sesión de aprendizaje:
> "Explícame la arquitectura de este proyecto. Qué patrones usa y cómo
   están organizados los módulos."

> "Quiero añadir un nuevo endpoint GET /api/users/:id. Muéstrame el plan
   de lo que harías sin ejecutar nada."

> "Qué tests necesitaría escribir para esta funcionalidad? Muéstrame
   el plan."
```

> **Beneficio clave**: El nuevo miembro aprende el codebase y las convenciones del equipo al mismo tiempo, guiado por el CLAUDE.md que el equipo ya ha configurado.

#### Fase 3: Ejecución con aprobación (Semanas 2-3)

El desarrollador empieza a ejecutar las sugerencias de Claude, pero aprobando cada acción:

```bash
# Modo normal (requiere aprobación para cada acción)
claude
```

En esta fase:
- Aprueba comandos uno por uno
- Revisa cada cambio con `git diff` antes de hacer commit
- Consulta a compañeros si algo le parece extraño
- Reporta comportamientos inesperados

#### Fase 4: Auto-accept para operaciones seguras (Mes 2+)

Una vez el desarrollador tiene confianza, puede usar auto-accept para operaciones seguras:

```bash
# Auto-accept solo para operaciones de lectura y tests
claude --allowedTools "Read,Glob,Grep,Bash(npm test),Bash(npm run lint)"
```

> **Nunca se debe usar auto-accept completo** sin entender las implicaciones y sin tener un sistema de permisos bien configurado.

---

## Flujo de trabajo de code review con Claude

### El principio fundamental: Claude propone, el humano revisa

```
Desarrollador                Claude Code              Repositorio
     |                           |                        |
     |-- "Implementa feature" -->|                        |
     |                           |-- genera código ------->|
     |                           |                        |
     |<-- "He hecho estos       |                        |
     |     cambios" -------------|                        |
     |                           |                        |
     |-- git diff (REVISIÓN) --->|                        |
     |                           |                        |
     |-- (aprueba o corrige) --->|                        |
     |                           |                        |
     |-- git commit ------------>|                        |
     |                           |                        |
     |-- Pull Request ---------->|                        |
     |                           |                        |
     |   (Otro humano revisa el PR)                       |
```

### Nunca aceptar ciegamente la salida de Delegate mode

Aunque Agent Teams y Delegate mode (Capítulo 9) son potentes, todo su output requiere revisión:

```bash
# DESPUÉS de que Claude termine cualquier tarea:
git diff                    # Ver exactamente qué cambió
git diff --stat            # Ver resumen de archivos afectados
npm test                    # Ejecutar tests
npm run lint               # Verificar estilo de código

# Si algo no está bien:
git checkout -- <archivo>   # Descartar cambios en un archivo específico
# O pedir a Claude que corrija:
> "El cambio en auth.ts tiene un problema: no maneja el caso de token
    expirado. Corrígelo."
```

### Checklist de revisión post-Claude

Antes de hacer commit del código generado por Claude, verifica:

- [ ] Los cambios hacen lo que se pidió y nada más
- [ ] No se han introducido credenciales o datos sensibles
- [ ] Los tests pasan
- [ ] El linting pasa
- [ ] No hay archivos modificados inesperadamente
- [ ] Las dependencias nuevas son necesarias y están justificadas
- [ ] El código sigue las convenciones del proyecto
- [ ] No hay código comentado innecesario
- [ ] Los mensajes de error son informativos
- [ ] Las validaciones de entrada son adecuadas

---

## Convenciones compartidas del equipo

### CLAUDE.md del equipo

Mantener un CLAUDE.md coherente es crítico para equipos. Debe ser un documento vivo que evoluciona con el proyecto:

```markdown
# CLAUDE.md del Proyecto

## Arquitectura
- Backend: FastAPI (Python 3.12) en /api
- Frontend: React 18 + TypeScript en /web
- Base de datos: PostgreSQL 16 con Alembic para migraciones
- Caché: Redis 7 para sesiones y caché de consultas
- Infra: Docker Compose para desarrollo, Kubernetes en producción

## Convenciones de código
- Python: Black + Ruff, type hints obligatorios
- TypeScript: ESLint + Prettier, strict mode
- Tests: pytest (backend), Vitest (frontend)
- Cobertura mínima: 80%

## Estructura de archivos
- /api/routes/       -> Endpoints REST
- /api/services/     -> Lógica de negocio
- /api/models/       -> Modelos SQLAlchemy
- /api/schemas/      -> Schemas Pydantic
- /web/src/pages/    -> Páginas (React Router)
- /web/src/components/ -> Componentes reutilizables
- /web/src/hooks/    -> Custom hooks

## Comandos esenciales
- `make dev`         -> Levantar entorno de desarrollo
- `make test`        -> Ejecutar todos los tests
- `make lint`        -> Linting completo
- `make migrate`     -> Aplicar migraciones pendientes
- `make seed`        -> Cargar datos de prueba

## Reglas de negocio
- Los usuarios tienen roles: admin, editor, viewer
- Toda acción de escritura requiere autenticación
- Los endpoints públicos se cachean 5 minutos
- Las respuestas de API siguen el formato {data, meta, errors}

## NO hacer
- No modificar archivos en /api/core/ sin aprobación del lead
- No agregar dependencias sin justificación en el PR
- No usar `any` en TypeScript
- No hacer queries directas a la BD fuera de /api/services/
```

### Settings.json compartido del proyecto

```json
{
  "permissions": {
    "allow": [
      "Read",
      "Glob",
      "Grep",
      "Bash(make *)",
      "Bash(npm *)",
      "Bash(pytest *)",
      "Bash(python -m *)",
      "Bash(git status)",
      "Bash(git diff *)",
      "Bash(git log *)",
      "Bash(docker compose *)"
    ],
    "deny": [
      "Bash(rm -rf *)",
      "Bash(sudo *)",
      "Bash(env)",
      "Bash(curl * | bash)",
      "Bash(docker system prune *)"
    ]
  }
}
```

### Librería de skills compartida

Mantener una carpeta `.claude/commands/` con skills reutilizables por todo el equipo:

```
.claude/commands/
  review-pr.md          # Revisar un Pull Request
  create-endpoint.md    # Crear un nuevo endpoint REST
  add-migration.md      # Crear una nueva migración de BD
  write-tests.md        # Escribir tests para un módulo
  debug-issue.md        # Diagnosticar un bug
  refactor-module.md    # Refactorizar un módulo
```

### Configuración de hooks estándar

```json
{
  "hooks": {
    "postToolUse": [
      {
        "matcher": "Write|Edit",
        "command": "npm run lint:fix -- $FILE_PATH 2>/dev/null || true"
      }
    ],
    "preCommit": [
      {
        "command": "npm test -- --bail"
      }
    ]
  }
}
```

---

## Patrones de comunicación

### Documentar qué hizo Claude en las descripciones de PR

```markdown
## Pull Request: Implementar caché de consultas frecuentes

### Descripción
Implementa un sistema de caché con Redis para las 10 consultas más
frecuentes del dashboard, reduciendo la carga en la base de datos.

### Cambios realizados
- Nuevo servicio `CacheService` en `/api/services/cache.py`
- Decorador `@cached(ttl=300)` para endpoints
- Tests unitarios y de integración
- Configuración de Redis en docker-compose.yml

### Generado con ayuda de IA
Los siguientes archivos fueron generados/modificados con asistencia de
Claude Code y revisados manualmente:
- `api/services/cache.py` (generado, revisado y ajustado)
- `api/decorators/cache.py` (generado, revisado)
- `tests/test_cache.py` (generado, ampliado manualmente)

### Tests
- [x] Tests unitarios pasan
- [x] Tests de integración pasan
- [x] Probado manualmente con datos reales del staging
```

### Etiquetar commits generados con IA

```bash
# Usar Co-Authored-By para indicar participación de Claude
git commit -m "feat: implementar caché de consultas con Redis

Agrega sistema de caché usando Redis para las consultas más frecuentes
del dashboard. Incluye decorador @cached y tests.

Co-Authored-By: Claude <noreply@anthropic.com>"
```

> **Convención del equipo**: Siempre usar `Co-Authored-By` cuando Claude haya generado parte significativa del código. Esto ayuda en auditorías y da transparencia.

### Revisar código IA con el mismo rigor que código humano

No hay excepción: el código generado por IA debe pasar los mismos estándares que el código humano:

- Code review por al menos un compañero
- Todos los tests pasan
- Linting sin errores
- Documentación actualizada
- Sin violaciones de seguridad
- Rendimiento aceptable

---

## Optimización de costes para equipos

### 1. Sonnet como modelo por defecto, Opus bajo demanda

```bash
# Configurar en .claude/settings.json del proyecto
{
  "model": "claude-sonnet-4-20250514"
}

# Los desarrolladores cambian a Opus solo cuando es necesario:
# - Tareas de planificación complejas
# - Refactoring de gran escala
# - Debugging difícil
/model claude-opus-4-20250514

# Y vuelven a Sonnet después:
/model claude-sonnet-4-20250514
```

### 2. Hábito de limpiar contexto

```bash
# Limpiar contexto cuando:
# - Cambias de tarea
# - El contexto supera las 50K tokens
# - La conversación lleva muchos intercambios
/clear

# Verificar el gasto actual
/cost
```

### 3. Presupuestos por desarrollador

Establecer límites claros:

| Rol | Presupuesto mensual | Modelo por defecto |
|-----|--------------------|--------------------|
| Junior | $50-100 | Sonnet |
| Mid | $100-200 | Sonnet |
| Senior | $200-400 | Sonnet (Opus disponible) |
| Lead/Architect | $300-500 | Sonnet (Opus disponible) |
| CI/CD | $100-300 | Haiku/Sonnet |

### 4. Monitorizar con /cost

```bash
# Al final de cada sesión, verificar el gasto
/cost

# Ejemplo de salida:
# Session cost: $0.42
# Total tokens: 45,230 (input: 38,100, output: 7,130)
# Model: claude-sonnet-4-20250514
```

### 5. Limitar presupuesto en scripts automatizados

```bash
# En CI/CD, SIEMPRE limitar el presupuesto
claude -p "Run tests and fix any failures" --max-budget-usd 2

# Para tareas más complejas
claude -p "Review PR #123 and suggest improvements" --max-budget-usd 5
```

---

## Errores comunes y cómo evitarlos

### 1. Sobre-dependencia de Claude sin comprensión

**El problema**:
```
Desarrollador: "Claude, implementa todo el módulo de autenticación"
Claude: [implementa un sistema completo]
Desarrollador: [hace commit sin entender cómo funciona]
```

**La solución**:
```
Desarrollador: "Explica cómo debería funcionar el flujo de autenticación
                en este proyecto"
Claude: [explica el flujo]
Desarrollador: "Ahora implementa el paso 1: el endpoint de login"
Claude: [implementa]
Desarrollador: [revisa, entiende, pregunta dudas]
Desarrollador: "Ahora implementa el paso 2..."
```

> **Regla**: Si no puedes explicar cómo funciona el código que Claude generó, no está listo para hacer commit.

### 2. No revisar los cambios de IA

**El problema**:
```bash
# NUNCA hagas esto:
claude "Fix the bug"
git add -A && git commit -m "fix: bug fix" && git push
```

**La solución**:
```bash
claude "Fix the bug"
git diff                  # Revisar CADA línea de cambio
npm test                  # Ejecutar tests
git add -p                # Agregar cambios selectivamente
git commit -m "fix: descripción precisa del fix"
```

### 3. Compartir credenciales vía CLAUDE.md

**El problema**:
```markdown
<!-- CLAUDE.md -->
# Para conectar al servidor de staging:
# SSH: ssh admin@staging.empresa.com
# Password: SuperSecr3t!
# API Key: sk-prod-1234567890
```

**La solución**:
```markdown
<!-- CLAUDE.md -->
# Entorno
Las credenciales de staging están en el gestor de secretos (1Password).
Copia `.env.example` a `.env` y rellena los valores desde 1Password.
```

### 4. Ignorar los límites de contexto

**El problema**:
```
[Sesión de 4 horas sin limpiar contexto]
Claude empieza a "olvidar" instrucciones del inicio
Las respuestas se vuelven menos coherentes
El coste se dispara
```

**La solución**:
```bash
# Monitorizar el uso de tokens
/cost

# Limpiar cuando cambias de tarea o el contexto crece
/clear

# Usar sesiones cortas y enfocadas:
# Sesión 1: "Implementa el modelo de datos"
# /clear
# Sesión 2: "Implementa los endpoints"
# /clear
# Sesión 3: "Escribe los tests"
```

### 5. No limpiar después de Agent Teams

**El problema**:
```bash
# Después de usar Agent Teams / Delegate mode
# Quedan archivos temporales, ramas sin merge, cambios sin commit
```

**La solución**:
```bash
# Después de cualquier tarea con agentes:
git status                # Ver estado del repositorio
git diff                  # Ver cambios pendientes
git stash list           # Ver stashes olvidados
git branch               # Ver ramas creadas
# Limpiar lo que no sea necesario
```

---

## Resumen de mejores prácticas

| Práctica | Prioridad | Impacto |
|----------|-----------|---------|
| Plan mode para onboarding | Alta | Aprendizaje seguro |
| Revisar TODOS los cambios de IA | Crítica | Calidad y seguridad |
| CLAUDE.md compartido y actualizado | Alta | Coherencia del equipo |
| Co-Authored-By en commits | Media | Transparencia |
| Sonnet por defecto, Opus puntual | Alta | Control de costes |
| /clear entre tareas | Media | Costes y calidad |
| Presupuestos por desarrollador | Alta | Control financiero |
| Nunca credenciales en CLAUDE.md | Crítica | Seguridad |
| Settings.json restrictivo | Alta | Seguridad |
| Skills compartidas en el repo | Media | Productividad |
