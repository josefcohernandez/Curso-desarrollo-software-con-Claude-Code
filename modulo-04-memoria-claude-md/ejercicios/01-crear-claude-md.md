# Ejercicio 01: Crear tu CLAUDE.md

## Objetivo

Crear un CLAUDE.md efectivo para un proyecto real, aplicando las mejores practicas.

---

## Parte 1: Analizar un Proyecto (10 min)

Elige un proyecto existente (tuyo o clonado):

```bash
cd ~/tu-proyecto
claude
```

Pide a Claude que analice el proyecto:

```
Analiza este proyecto y dame:
1. Stack tecnologico detectado
2. Comandos de build/test/lint disponibles
3. Convenciones de codigo que observas
4. Estructura de directorios principal
Formato: lista breve por cada punto.
```

Anota las respuestas.

---

## Parte 2: Crear CLAUDE.md (15 min)

Crea el archivo usando la plantilla:

```
/init
```

Luego editalo para incluir:

1. **Descripcion** (1-2 frases)
2. **Stack tecnologico** (lista)
3. **Comandos** (build, test, lint, dev)
4. **Convenciones de codigo** (naming, imports, estructura)
5. **Restricciones** (que NO debe hacer Claude)
6. **Estilo de respuesta** (conciso, sin explicaciones innecesarias)

### Criterios de Calidad

- [ ] Menos de 100 lineas
- [ ] Cada linea es accionable
- [ ] Comandos verificados (que funcionen)
- [ ] Sin documentacion general (solo instrucciones)

---

## Parte 3: Verificar Efectividad (10 min)

Prueba tu CLAUDE.md:

```bash
/clear
```

```
"Crea una funcion nueva siguiendo las convenciones del proyecto"
```

Verifica:
- Usa el lenguaje correcto?
- Sigue el naming convention?
- Usa los imports del proyecto?

```
"Ejecuta los tests"
```

Verifica:
- Usa el comando correcto de tu CLAUDE.md?

---

## Parte 4: Configurar preferencias locales (5 min)

Para preferencias personales que no se comparten con el equipo, usa `.claude/settings.local.json`
o crea un fichero personal importado desde CLAUDE.md.

**Opcion A**: Crear un fichero de preferencias personales:

```bash
# Crear el fichero personal en tu home:
mkdir -p ~/.claude
cat > ~/.claude/mis-preferencias.md << 'EOF'
# Mis preferencias personales
- Trabajo principalmente en el modulo de [tu modulo]
- Prefiero respuestas en espanol
- Siempre ejecutar lint despues de editar
EOF
```

Luego, en el `CLAUDE.md` del proyecto, anade la linea de import:

```markdown
@~/.claude/mis-preferencias.md
```

**Opcion B**: Usar `.claude/settings.local.json` para configuraciones simples (este fichero
no se commitea al repositorio).

---

## Entregable

Tu CLAUDE.md final deberia verse similar a:

```markdown
# [Nombre del Proyecto]

API REST para gestion de [dominio].

## Stack
- Backend: Python 3.12 / FastAPI
- BD: PostgreSQL 16 + SQLAlchemy 2.0
- Tests: pytest + pytest-asyncio
- CI: GitHub Actions

## Comandos
- `make test` - Tests unitarios
- `make lint` - Ruff + mypy
- `make dev` - Servidor desarrollo (uvicorn --reload)
- `make migrate` - Aplicar migraciones

## Convenciones
- Funciones: snake_case
- Clases: PascalCase
- Archivos: snake_case.py
- Endpoints: /api/v1/resource (plural)
- Commits: conventional commits

## Restricciones
- No modificar alembic/env.py
- No usar print(), usar logging
- No instalar deps sin confirmar
- Ejecutar tests antes de dar tarea por completa

## Respuestas
- Concisas, sin explicaciones innecesarias
- No repetir codigo sin cambios
- Preferir editar sobre crear archivos nuevos
```

---

## Criterios de Completitud

- [ ] CLAUDE.md creado con las 6 secciones
- [ ] Menos de 100 lineas
- [ ] Verificado con una tarea real
- [ ] Preferencias locales configuradas (settings.local.json o fichero personal importado)
- [ ] Commiteado al repositorio (excepto ficheros locales)
