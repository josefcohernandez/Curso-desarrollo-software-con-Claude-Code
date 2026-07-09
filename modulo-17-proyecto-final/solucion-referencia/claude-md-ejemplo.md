# CLAUDE.md de Referencia para TaskFlow API

> Copia este archivo como `CLAUDE.md` en la raíz del proyecto TaskFlow.

---

```markdown
# TaskFlow API

API REST para gestión de tareas con autenticación JWT.

## Stack
- Python 3.12 + FastAPI
- PostgreSQL 16 + SQLAlchemy 2.0 (async)
- Alembic para migraciones
- pytest + pytest-asyncio para tests
- Ruff para linting
- Docker + docker-compose

## Comandos
- `make dev` - Servidor desarrollo (uvicorn --reload, puerto 8000)
- `make test` - Ejecutar tests con pytest
- `make test-cov` - Tests con reporte de cobertura
- `make lint` - Ruff check + format
- `make migrate` - Aplicar migraciones pendientes
- `make migrate-create MSG="desc"` - Crear nueva migración
- `make seed` - Cargar datos de prueba
- `docker-compose up -d` - Levantar todo con Docker

## Estructura
src/
  main.py         - App FastAPI, routers
  config.py       - Settings con Pydantic
  models/         - SQLAlchemy models
  schemas/        - Pydantic request/response
  api/            - Endpoints (routers FastAPI)
  services/       - Lógica de negocio
  middleware/     - Auth middleware
tests/            - pytest tests

## Convenciones
- snake_case para funciones y variables
- PascalCase para clases y modelos
- Endpoints: /api/v1/resources (plural, kebab-case)
- Un router por recurso (auth, users, tasks)
- Un servicio por dominio
- Async siempre (async def)
- Validación con Pydantic, no manual
- Error handling con HTTPException

## Endpoints
- POST /api/v1/auth/register - Registro
- POST /api/v1/auth/login - Login (devuelve JWT)
- POST /api/v1/auth/refresh - Refresh token
- GET /api/v1/users/me - Perfil actual
- GET /api/v1/tasks - Listar tareas (paginación, filtros)
- POST /api/v1/tasks - Crear tarea
- GET /api/v1/tasks/:id - Detalle tarea
- PUT /api/v1/tasks/:id - Actualizar tarea
- DELETE /api/v1/tasks/:id - Eliminar tarea

## Restricciones
- No modificar alembic/env.py
- No usar print(), usar logger
- No queries raw SQL (usar ORM)
- No hardcodear secrets
- Ejecutar tests antes de dar tarea por completa
- Mínimo 60% cobertura de tests

## Respuestas
- Concisas, sin explicaciones innecesarias
- Solo mostrar código que cambia
- No generar comentarios obvios
```

---

## Settings de Referencia

### .claude/settings.json (equipo)

```json
{
  "permissions": {
    "allow": [
      "Read", "Glob", "Grep",
      "Bash(make test*)", "Bash(make lint*)",
      "Bash(pytest*)", "Bash(ruff*)",
      "Bash(git status)", "Bash(git diff*)", "Bash(git log*)",
      "Bash(docker-compose*)",
      "Bash(alembic *)"
    ],
    "deny": [
      "Bash(rm -rf *)", "Bash(sudo *)",
      "Bash(pip install*)",
      "Write(.env*)", "Write(*secret*)",
      "Edit(alembic/env.py)"
    ]
  }
}
```

### .claude/rules/testing.md

```markdown
---
globs: ["tests/**", "**/*test*"]
---
# Testing Rules
- pytest con fixtures en conftest.py
- Async tests con pytest-asyncio
- Un assert por test idealmente
- Nombres: test_should_[accion]_when_[condicion]
- Factory pattern para crear datos de prueba
- Mock de BD con testcontainers o sqlite in-memory
```
