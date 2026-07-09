# Sesión Paso a Paso: Desarrollo de TaskFlow API

> Transcripción comentada de cómo desarrollar el proyecto final
> aplicando las técnicas del libro.

---

## Fase 1: Setup del Proyecto (20 min)

### Sesión 1: Inicialización

```bash
mkdir -p taskflow-api && cd taskflow-api
git init
claude
```

```
> /init

> "Inicializa un proyecto Python con FastAPI:
>  - Crear estructura de directorios (src/, tests/, alembic/)
>  - requirements.txt con FastAPI, SQLAlchemy, Alembic, pytest, uvicorn
>  - Makefile con comandos dev, test, lint, migrate
>  - docker-compose.yml con la app + PostgreSQL 16
>  - Dockerfile multi-stage
>  - .gitignore para Python"

> /cost   # ~5K-10K tokens

> "Verifica que docker-compose up funciona"

> /exit
```

**Técnicas**: /init (C04), prompt específico (C03), sesión corta (C03)

---

## Fase 2: Especificación, Gherkin y Diseño (30 min)

### Sesión 2a: SPEC.md y features Gherkin (C12)

```bash
claude
```

```
> "Vamos a usar Spec-Driven Development. Entrevístame para crear SPEC.md
>  de TaskFlow API: autenticación JWT, CRUD de tareas con filtros."

> [Responder las preguntas de Claude]

> "Genera SPEC.md con los requisitos que acordamos"

> "Ahora genera features Gherkin a partir de SPEC.md:
>  - features/auth.feature (registro, login, perfil)
>  - features/tareas.feature (CRUD + permisos)
>  - features/filtros.feature (filtrado y paginación)
>  Incluir happy path, errores, edge cases y Scenario Outline"

> /cost   # ~10K-15K tokens
> /exit
```

**Técnicas**: Spec-Driven Development (C12), Gherkin (C12)

### Sesión 2b: Diseñar con Plan Mode

```bash
claude --model opus
```

```
> Shift+Tab (Plan Mode)

> "Tenemos SPEC.md y features/ con Gherkin. Diseñar modelos de datos:
>  - User: id, email (unique), name, hashed_password, created_at
>  - Task: id, title, description, status (pending/in_progress/done),
>    priority (low/medium/high), owner_id (FK user), created_at, updated_at
>  Incluir: modelos SQLAlchemy, schemas Pydantic, migración inicial.
>  Estrategia TDD desde Gherkin para la implementación."

> [Revisar plan de Opus]
> "Apruebo. Usa Enum para status y priority."

> Shift+Tab (Normal)
> /model sonnet
> "Implementa los modelos según el plan"
> "Crea la migración inicial"
> "Ejecuta la migración con make migrate"

> /cost   # ~15K-20K tokens

> /exit
```

**Técnicas**: Plan Mode con Opus (C06), cambio a Sonnet para implementar (C06)

---

## Fase 3: Autenticación JWT con TDD (30 min)

### Sesión 3: Auth (TDD desde Gherkin - C12)

```bash
claude
```

```
> "Aplica TDD desde features/auth.feature:

>  Paso 1 (Red): Genera tests desde los escenarios Gherkin de auth.
>  Cada Scenario = 1 test. Ejecuta: deben FALLAR.

>  Paso 2 (Green): Implementa autenticación JWT:
>  1. POST /api/v1/auth/register - registro con email, name, password
>  2. POST /api/v1/auth/login - devuelve access_token + refresh_token
>  3. POST /api/v1/auth/refresh - renueva access_token
>  4. Middleware que verifica JWT en rutas protegidas
>  Usar python-jose para JWT, passlib+bcrypt para passwords.
>  El mínimo para que los tests pasen.

>  Paso 3 (Refactor): Mejora nombres, extrae constantes.
>  Ejecuta tests tras cada paso."

> /cost   # ~20K-30K tokens

> /exit
```

**Técnicas**: TDD desde Gherkin (C12), ciclo Red → Green → Refactor (C12)

---

## Fase 4: CRUD de Tareas con TDD (30 min)

### Sesión 4: Endpoints (TDD desde Gherkin - C12)

```bash
claude
```

```
> "Aplica TDD desde features/tareas.feature y features/filtros.feature:

>  Paso 1 (Red): Genera tests desde Gherkin. Ejecuta: deben FALLAR.

>  Paso 2 (Green): Implementa CRUD (autenticación requerida):
>  - GET /api/v1/tasks - listar con paginación y filtros
>  - POST /api/v1/tasks - crear (solo owner)
>  - GET /api/v1/tasks/:id - detalle (solo owner)
>  - PUT /api/v1/tasks/:id - actualizar (solo owner)
>  - DELETE /api/v1/tasks/:id - eliminar (solo owner)
>  El mínimo para que los tests pasen.

>  Paso 3 (Refactor): Mejora el código. Tests deben seguir pasando."

> "Ejecuta todos los tests (auth + tareas)"
> /cost
> /exit
```

### Sesión 5: Filtros avanzados (si tiempo)

```bash
claude
```

```
> /clear
> "Añade búsqueda por texto en título/descripción de tareas:
>  GET /api/v1/tasks?search=urgente
>  Usar ILIKE de PostgreSQL"

> "Añade ordenamiento: ?sort=created_at&order=desc"
> "Tests para búsqueda y ordenamiento"
> "Ejecuta tests"
> /exit
```

---

## Fase 5: Code Review (15 min)

### Sesión 6: Review con subagente

```bash
claude
```

```
> "Revisa TODO el código del proyecto buscando:
>  1. Vulnerabilidades de seguridad
>  2. SQL injection o problemas de validación
>  3. Edge cases no manejados
>  4. Mejoras de rendimiento
>  Solo reporta, no modifiques nada."

> [Claude reporta issues]

> /clear

> "Corrige los issues críticos: [lista]"
> "Ejecuta tests para verificar"
> /exit
```

**Técnicas**: Writer/Reviewer pattern (C06), /clear entre review y fix (C03)

---

## Fase 6: Cobertura y CI (15 min)

### Sesión 7

```bash
claude
```

```
> "Revisa la cobertura de tests actual con pytest --cov.
>  Si es menor al 60%, añade los tests necesarios."

> "Crea un GitHub Action en .github/workflows/ci.yml:
>  - Trigger: push a main, PRs a main
>  - Steps: checkout, setup Python 3.12, install deps,
>    lint con ruff, tests con pytest, reporte cobertura"

> "Ejecuta tests finales"
> /cost
> /exit
```

---

## Fase 7: Documentación (10 min)

### Sesión 8

```bash
claude
```

```
> "Genera un README.md con:
>  - Descripción del proyecto
>  - Stack tecnológico
>  - Cómo ejecutar (Docker y local)
>  - Endpoints documentados
>  - Cómo ejecutar tests"

> /exit
```

---

## Métricas Totales Estimadas

| Fase | Sesiones | Tokens | Coste (Sonnet) | Tiempo |
|------|---------|--------|---------------|--------|
| Setup | 1 | ~10K | $0.05 | 20 min |
| Spec + Gherkin | 1 | ~12K | $0.07 | 15 min |
| Modelos + Diseño | 1 | ~20K | $0.12 | 25 min |
| Auth (TDD) | 1 | ~25K | $0.15 | 30 min |
| CRUD (TDD) | 1-2 | ~30K | $0.18 | 30 min |
| Review | 1 | ~15K | $0.09 | 15 min |
| CI | 1 | ~10K | $0.05 | 15 min |
| Docs | 1 | ~5K | $0.03 | 10 min |
| **Total** | **8-9** | **~127K** | **~$0.74** | **~2.7h** |

> Con optimización de tokens y Sonnet, el proyecto completo cuesta menos de $1.
