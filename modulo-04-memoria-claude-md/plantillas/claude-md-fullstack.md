# Plantilla CLAUDE.md - Proyecto Fullstack

> Copia como `CLAUDE.md` en la raiz del monorepo. Complementar con
> reglas modulares en `.claude/rules/` para cada parte del stack.

---

```markdown
# [Nombre del Proyecto]

Aplicacion fullstack para [descripcion breve].

## Stack
- Frontend: React 19 + TypeScript + Vite
- Backend: Node.js + Express/Fastify (o Python + FastAPI)
- BD: PostgreSQL 16
- Cache: Redis 7
- Tests: Vitest (front) + Jest/pytest (back)
- CI: GitHub Actions
- Deploy: Docker + docker-compose

## Comandos
- `npm run dev` - Levantar todo (front + back + BD)
- `npm run dev:front` - Solo frontend
- `npm run dev:back` - Solo backend
- `npm test` - Todos los tests
- `npm run test:front` - Tests frontend
- `npm run test:back` - Tests backend
- `npm run lint` - Lint completo
- `npm run build` - Build produccion
- `npm run db:migrate` - Migraciones BD
- `npm run db:seed` - Datos de prueba

## Estructura
frontend/
  src/
    components/  - Componentes React
    pages/       - Paginas/rutas
    hooks/       - Custom hooks
    api/         - Cliente API (fetch wrappers)
backend/
  src/
    routes/      - Endpoints API
    services/    - Logica de negocio
    models/      - Modelos BD
    middleware/  - Auth, logging, etc
shared/
  types/         - Types compartidos front/back
  constants/     - Constantes compartidas
infra/
  docker/        - Dockerfiles
  .github/       - GitHub Actions

## Convenciones
- TypeScript estricto en front y back
- camelCase funciones, PascalCase clases/componentes
- API REST: /api/v1/resources (plural)
- Commits: conventional commits (feat:, fix:, chore:)
- PRs: titulo corto + descripcion con contexto

## Reglas
- Frontend y backend son independientes (comunicacion solo via API)
- Shared types para contratos API (no duplicar tipos)
- Variables de entorno en .env (nunca hardcoded)
- Docker para desarrollo local (docker-compose up)
- Tests obligatorios para features nuevas

## Restricciones
- No mezclar logica frontend/backend
- No modificar docker-compose.prod.yml
- No instalar deps sin confirmar
- Ejecutar tests antes de dar tarea por completa

## Respuestas
- Concisas, sin explicaciones innecesarias
- Especificar en que parte del stack se trabaja (front/back)
- No generar comentarios obvios
```

---

## Reglas Modulares Complementarias

Crear en `.claude/rules/`:

### frontend.md
```yaml
---
paths: ["frontend/**", "*.tsx", "*.jsx"]
---
```
Reglas especificas de React, hooks, estilos.

### backend.md
```yaml
---
paths: ["backend/**"]
---
```
Reglas de API, BD, servicios.

### testing.md
```yaml
---
paths: ["**/*.test.*", "**/*.spec.*", "tests/**"]
---
```
Reglas de testing por framework.

### infra.md
```yaml
---
paths: ["infra/**", "docker/**", "Dockerfile*", ".github/**"]
---
```
Reglas de Docker, CI/CD, infraestructura.
