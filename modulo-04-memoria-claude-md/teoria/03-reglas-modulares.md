# 03 - Reglas Modulares (.claude/rules/)

## El Problema de un CLAUDE.md Grande

Cuando un CLAUDE.md crece demasiado, hay problemas:
- Consume muchos tokens en cada mensaje
- Mezcla instrucciones de diferentes contextos
- Difícil de mantener por el equipo

**Solución**: Reglas modulares en `.claude/rules/`.

---

## Cómo Funcionan

Los archivos en `.claude/rules/*.md` se cargan **condicionalmente** según el archivo
que Claude está editando, usando paths en el YAML frontmatter.

### Estructura

```
.claude/
├── CLAUDE.md           ← Reglas globales (siempre cargado)
└── rules/
    ├── frontend.md     ← Solo para archivos frontend
    ├── backend.md      ← Solo para archivos backend
    ├── testing.md      ← Solo para archivos de test
    └── database.md     ← Solo para migraciones/modelos
```

### Formato de un Archivo de Reglas

```markdown
---
paths: ["src/frontend/**", "src/components/**", "*.tsx", "*.jsx"]
---

# Reglas Frontend

- Usar componentes funcionales con hooks
- TypeScript estricto, no usar `any`
- Estilos con CSS Modules (*.module.css)
- Tests con React Testing Library
- No usar enzyme
- Imports absolutos con @/components/...
```

---

## Paths: Patrones de Coincidencia

| Patrón | Coincide con |
|--------|-------------|
| `"*.ts"` | Archivos TypeScript en raíz |
| `"**/*.ts"` | Archivos TypeScript en cualquier nivel |
| `"src/api/**"` | Todo dentro de src/api/ |
| `"*.test.*"` | Archivos de test |
| `"*.{ts,tsx}"` | TypeScript y TSX |
| `"migrations/**"` | Archivos de migración |
| `"Dockerfile*"` | Dockerfiles |

### Múltiples Paths

```yaml
---
paths: ["src/api/**/*.py", "src/services/**/*.py", "tests/api/**"]
---
```

---

## Ejemplos Prácticos

### frontend.md

```markdown
---
paths: ["src/components/**", "src/pages/**", "*.tsx", "*.jsx"]
---

# Reglas Frontend

## Componentes
- Funcionales con hooks (no class components)
- Props tipadas con interface, no type
- Exportar componente como default
- Colocar test junto al componente: Component.test.tsx

## Imports
- Absolutos: @/components/, @/hooks/, @/utils/
- React imports: solo lo necesario (no import React)

## Estilos
- CSS Modules: Component.module.css
- Variables en :root de globals.css
- Mobile first, breakpoints en variables
```

### backend.md

```markdown
---
paths: ["src/api/**", "src/services/**", "src/models/**", "*.py"]
---

# Reglas Backend

## API
- REST con FastAPI
- Validación con Pydantic v2
- Responses tipadas con Response models
- Error handling con HTTPException

## Base de Datos
- SQLAlchemy 2.0 con async
- Migraciones con Alembic
- Modelos en src/models/

## Testing
- pytest con fixtures
- Async tests con pytest-asyncio
- Mocks con unittest.mock
```

### testing.md

```markdown
---
paths: ["**/*.test.*", "**/*.spec.*", "tests/**", "**/__tests__/**"]
---

# Reglas de Testing

## Principios
- Un assert por test (idealmente)
- Nombres descriptivos: test_should_return_404_when_user_not_found
- Arrange-Act-Assert pattern
- No testear implementación, testear comportamiento

## Fixtures
- Fixtures compartidas en conftest.py (Python) o setup files (JS)
- Factory pattern para crear objetos de prueba
- No usar datos hardcoded, usar factories

## Mocks
- Mockear dependencias externas (BD, APIs, filesystem)
- No mockear la unidad bajo test
- Verificar que los mocks se llaman correctamente
```

### database.md

```markdown
---
paths: ["migrations/**", "src/models/**", "alembic/**", "prisma/**"]
---

# Reglas Base de Datos

## Migraciones
- Una migración por cambio lógico
- Siempre reversibles (upgrade + downgrade)
- Nombres descriptivos: add_user_email_index
- NO modificar migraciones ya aplicadas

## Modelos
- Un modelo por archivo
- Relaciones explícitas con foreign keys
- Índices para campos de búsqueda frecuente
- Soft delete (deleted_at) en lugar de hard delete
```

---

## Reglas sin Paths

Si un archivo en `rules/` no tiene frontmatter con paths,
se carga **siempre** (como si estuviera en CLAUDE.md):

```markdown
# Reglas Generales de Seguridad

- No hardcodear secrets, usar variables de entorno
- Validar input del usuario siempre
- Sanitizar output para prevenir XSS
- Usar prepared statements para SQL
```

---

## Beneficios de Reglas Modulares

| Aspecto | CLAUDE.md único | Reglas modulares |
|---------|----------------|-----------------|
| Tokens por mensaje | Todos siempre | Solo los relevantes |
| Mantenimiento | Un archivo grande | Archivos enfocados |
| Equipo | Conflictos de merge | Cada rol edita su archivo |
| Contexto | Todo mezclado | Específico al archivo actual |

---

## Mejores Prácticas

1. **CLAUDE.md global**: Solo reglas universales (<50 líneas)
2. **Rules por dominio**: frontend, backend, testing, infra
3. **Paths precisos**: No usar `**/*` (cargaría siempre)
4. **Revisar periódicamente**: Eliminar reglas obsoletas
5. **Versionado**: Commitear rules/ al repo (excepto local)
