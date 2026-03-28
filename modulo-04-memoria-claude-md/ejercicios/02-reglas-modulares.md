# Ejercicio 02: Configurar Reglas Modulares

## Objetivo

Crear un sistema de reglas modulares en `.claude/rules/` para un proyecto multi-rol.

---

## Escenario

Imagina un proyecto full-stack con:
- Frontend React/TypeScript en `src/frontend/`
- Backend Python/FastAPI en `src/api/`
- Tests en `tests/` y `**/*.test.*`
- Infraestructura en `infra/` y `docker/`

---

## Parte 1: Crear Estructura (5 min)

```bash
mkdir -p .claude/rules
```

---

## Parte 2: Crear Reglas por Dominio (20 min)

### Regla 1: Frontend

Crea `.claude/rules/frontend.md`:

```markdown
---
paths: ["src/frontend/**", "src/components/**", "*.tsx", "*.jsx"]
---

# Frontend Rules

- React functional components only (no class components)
- TypeScript strict mode, no `any` types
- CSS Modules for styling (*.module.css)
- Test files next to component: Component.test.tsx
- Use @/ prefix for absolute imports
- State management: Zustand (no Redux)
```

### Regla 2: Backend

Crea `.claude/rules/backend.md`:

```markdown
---
paths: ["src/api/**", "src/services/**", "src/models/**"]
---

# Backend Rules

- FastAPI with async handlers
- Pydantic v2 for validation
- SQLAlchemy 2.0 async with asyncpg
- Error responses use HTTPException
- All endpoints require authentication unless explicitly public
- Return Pydantic response models, never raw dicts
```

### Regla 3: Testing

Crea `.claude/rules/testing.md`:

```markdown
---
paths: ["tests/**", "**/*.test.*", "**/*.spec.*"]
---

# Testing Rules

- Use pytest (Python) or Vitest (TypeScript)
- One assert per test when possible
- Descriptive names: test_should_return_404_when_not_found
- AAA pattern: Arrange, Act, Assert
- Mock external dependencies, not the unit under test
- Use factories for test data, no hardcoded values
```

### Regla 4: Infraestructura

Crea `.claude/rules/infra.md`:

```markdown
---
paths: ["infra/**", "docker/**", "Dockerfile*", "docker-compose*", ".github/**"]
---

# Infrastructure Rules

- Multi-stage Dockerfiles
- docker-compose for local dev
- GitHub Actions for CI/CD
- Secrets in environment variables, never in files
- Healthchecks in all services
```

---

## Parte 3: Verificar (10 min)

Inicia Claude Code y verifica que las reglas se cargan condicionalmente:

```bash
claude
```

```
> "Quiero crear un nuevo componente React en src/frontend/UserProfile.tsx"
```

Deberia seguir las reglas de `frontend.md`.

```
> /clear
> "Crea un nuevo endpoint en src/api/users.py"
```

Deberia seguir las reglas de `backend.md`.

```
> /clear
> "Crea un test para el endpoint de users"
```

Deberia seguir las reglas de `testing.md`.

---

## Parte 4: Medir Impacto (5 min)

Compara tokens con y sin reglas modulares:

1. Sin reglas: pon todo en CLAUDE.md
2. Con reglas: usa los archivos modulares
3. Compara `/cost` para la misma tarea

---

## Criterios de Completitud

- [ ] 4 archivos de reglas creados en .claude/rules/
- [ ] Cada uno con paths correctos en frontmatter YAML
- [ ] Verificado que frontend.md se aplica a archivos .tsx
- [ ] Verificado que backend.md se aplica a archivos en src/api/
- [ ] Verificado que testing.md se aplica a archivos .test.*
- [ ] Commiteado al repositorio
