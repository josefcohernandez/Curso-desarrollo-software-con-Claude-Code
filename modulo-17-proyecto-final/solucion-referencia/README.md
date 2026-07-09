# Solución de Referencia: TaskFlow API

## Sobre Esta Solución

Esta es una **guía de referencia**, no la única solución correcta.
El objetivo es mostrar cómo se aplican todas las técnicas del libro
en un proyecto real.

---

## Estructura del Proyecto Final

```
taskflow-api/
├── CLAUDE.md                    ← Configuración del proyecto
├── SPEC.md                      ← Especificación técnica (SDD - C12)
├── .claude/
│   ├── settings.json            ← Permisos del equipo
│   ├── settings.local.json      ← Preferencias personales
│   └── rules/
│       ├── backend.md           ← Reglas para código Python
│       └── testing.md           ← Reglas para tests
├── features/                    ← Historias de usuario Gherkin (C12)
│   ├── auth.feature             ← Escenarios de autenticación
│   ├── tareas.feature           ← Escenarios CRUD de tareas
│   └── filtros.feature          ← Escenarios de filtrado/paginación
├── src/
│   ├── main.py                  ← Punto de entrada FastAPI
│   ├── config.py                ← Configuración
│   ├── models/
│   │   ├── user.py              ← Modelo User
│   │   └── task.py              ← Modelo Task
│   ├── schemas/
│   │   ├── user.py              ← Schemas Pydantic
│   │   └── task.py              ← Schemas Pydantic
│   ├── api/
│   │   ├── auth.py              ← Endpoints autenticación
│   │   ├── users.py             ← Endpoints usuarios
│   │   └── tasks.py             ← Endpoints tareas
│   ├── services/
│   │   ├── auth.py              ← Lógica JWT
│   │   ├── user.py              ← Lógica usuarios
│   │   └── task.py              ← Lógica tareas
│   └── middleware/
│       └── auth.py              ← Middleware JWT
├── tests/
│   ├── conftest.py              ← Fixtures
│   ├── test_auth.py
│   ├── test_users.py
│   └── test_tasks.py
├── alembic/                     ← Migraciones
├── requirements.txt
├── Dockerfile
└── docker-compose.yml
```

---

## Técnicas del Libro Aplicadas

| Capítulo | Técnica | Dónde se aplica |
|----------|---------|----------------|
| C01 | Agentic loop | Todo el desarrollo |
| C02 | CLI modes | One-shot para commits, interactivo para features |
| C03 | Ahorro tokens | /clear entre fases, prompts específicos |
| C04 | CLAUDE.md | Configuración del proyecto |
| C05 | Permisos | settings.json con allow/deny |
| C06 | Plan Mode | Diseñar antes de implementar |
| C07 | MCP | PostgreSQL para queries directas |
| C08 | Hooks | Auto-formateo, tests automáticos |
| C09 | Subagentes | Code reviewer, test runner |
| C10 | CI/CD | GitHub Action para review |
| C11 | Seguridad | Permisos restrictivos, hooks de protección |
| C12 | SDD + Gherkin + TDD | SPEC.md, features/, tests derivados de Gherkin |

---

## Archivos de Referencia

- `claude-md-ejemplo.md` — Configuración óptima del CLAUDE.md
- `sesion-paso-a-paso.md` — Transcripción de sesiones de trabajo
