# 04 - Memoria estructurada con tipos

> **Nota importante**: El sistema de tipos de memoria con frontmatter (`user`, `feedback`, `project`, `reference`) descrito en este capitulo es un **patron recomendado por este curso** para organizar la auto memory de forma estructurada. NO es una funcionalidad impuesta por Claude Code. Auto memory es un sistema libre donde Claude escribe ficheros markdown organizados como considere conveniente. Este patron ha demostrado ser efectivo para mantener la memoria organizada y util entre sesiones, y Claude Code lo adopta cuando se configura en el system prompt del proyecto.

## 1. El sistema de auto-memoria evolucionado

Al inicio de este capítulo vimos que Claude Code puede guardar notas automáticamente entre
sesiones. El sistema ha evolucionado hacia una estructura más organizada: cada trozo de
memoria vive en su propio fichero con un tipo declarado.

### Ubicación de los ficheros de memoria

```
~/.claude/projects/<hash-del-proyecto>/memory/
├── MEMORY.md              ← Índice central (solo punteros)
├── usuario-data-scientist.md
├── feedback-no-mockear-bd.md
├── proyecto-freeze-marzo.md
└── ref-bugs-linear.md
```

El directorio `~/.claude/projects/` contiene una carpeta por proyecto, identificada por un hash
de la ruta del proyecto. Dentro de `memory/` encontrarás los ficheros individuales más el
índice `MEMORY.md`.

### El índice MEMORY.md

`MEMORY.md` es el único fichero que se carga **siempre** al inicio de cada sesión
(se leen las primeras ~200 líneas). Su función es exclusivamente de índice: lista los
ficheros de memoria existentes con una descripción breve de cada uno.

Claude carga el resto de ficheros bajo demanda, cuando el índice indica que son relevantes
para la tarea en curso.

```markdown
# Índice de memoria del proyecto

## Memorias activas

- [usuario-data-scientist.md](usuario-data-scientist.md) — Rol y preferencias del usuario
- [feedback-no-mockear-bd.md](feedback-no-mockear-bd.md) — Corrección: no mockear BD en tests de integración
- [proyecto-freeze-marzo.md](proyecto-freeze-marzo.md) — Merge freeze hasta el 10 de marzo
- [ref-bugs-linear.md](ref-bugs-linear.md) — Bugs del pipeline se trackean en Linear (proyecto INGEST)
```

**Regla crítica**: No escribas contenido directamente en `MEMORY.md`. Si el índice crece
hasta superar 200 líneas, las memorias al final dejan de cargarse en el contexto inicial.

---

## 2. Los 4 tipos de memoria recomendados

Este curso propone estructurar la memoria en 4 tipos, declarando el tipo en el frontmatter
YAML de cada fichero. El tipo no es un campo decorativo: le indica a Claude el propósito
de la información y cómo debe usarla.

---

### Tipo `user`

Información sobre el rol, objetivos, experiencia y preferencias del usuario. Permite que
Claude calibre sus explicaciones y sugiera soluciones alineadas con el nivel del usuario.

**Cuándo usarlo**: Información sobre quién eres y cómo trabajas que no cambia con el
proyecto.

**Ejemplo:**

```markdown
---
name: perfil-usuario
description: Rol, tecnologías dominadas y áreas de aprendizaje del usuario
type: user
---

El usuario es data scientist con 5 años de experiencia en Python (pandas, scikit-learn,
PyTorch). Conoce SQL avanzado y bash básico. Está migrando un pipeline de ML a producción
y es nuevo en infraestructura (Docker, Kubernetes, CI/CD).

Prefiere explicaciones con analogías de ML cuando hay conceptos nuevos. No necesita
que se le explique Python; sí necesita ayuda con conceptos de sistemas.
```

---

### Tipo `feedback`

Correcciones y confirmaciones del usuario sobre cómo Claude debe trabajar. Captura
aprendizajes de la interacción: "hice esto, el usuario dijo que estaba mal, aquí está
la regla".

**Estructura recomendada**: regla principal + **Why:** + **How to apply:**

**Cuándo usarlo**: Cuando el usuario corrige un comportamiento de Claude o confirma
explícitamente una forma de trabajar no obvia.

**Ejemplo:**

```markdown
---
name: no-mockear-bd-integracion
description: No usar mocks de base de datos en tests de integración
type: feedback
---

No mockear la base de datos en tests de integración.

**Why:** El usuario necesita que los tests de integración validen el comportamiento
real con PostgreSQL, incluyendo transacciones, constraints e índices. Los mocks
ocultan bugs que solo aparecen con la BD real.

**How to apply:** En tests marcados con @pytest.mark.integration, usar una BD de
test real (fixture db_session con rollback). Usar mocks solo en tests unitarios
puros de lógica de negocio.
```

---

### Tipo `project`

Información sobre el trabajo en curso: decisiones tomadas, restricciones temporales,
contexto del proyecto que no está en el código.

**Estructura recomendada**: hecho o decisión + **Why:** + **How to apply:**

**Cuándo usarlo**: Decisiones de diseño que no están documentadas en el código,
restricciones externas (releases, deadlines), o acuerdos del equipo recientes.

**Ejemplo:**

```markdown
---
name: merge-freeze-marzo
description: Restricción de merges a main hasta el 10 de marzo por release de mobile
type: project
---

No mergear a main hasta el 10 de marzo de 2026.

**Why:** El equipo de mobile tiene una release crítica el 9 de marzo. Cualquier
cambio en la API puede romper la app antes de que pasen por QA. El freeze lo
decidió el CTO el 20 de febrero.

**How to apply:** Si el usuario pide hacer merge a main o crear un PR hacia main,
recordar la restricción y sugerir usar ramas de integración intermedias o esperar
a que pase el freeze.
```

Otro ejemplo de tipo `project`:

```markdown
---
name: decision-arquitectura-cache
description: Decisión de usar Redis para caché de sesiones en lugar de memcached
type: project
---

El proyecto usa Redis para caché de sesiones de usuario.

**Why:** Migramos de memcached a Redis en enero porque necesitamos persistencia
opcional y estructuras de datos más ricas (sets para permisos). La decisión
la tomó el equipo en la retro del sprint 14.

**How to apply:** Al implementar cualquier lógica de sesión o caché de usuario,
usar el cliente Redis configurado en src/cache/redis_client.py. No introducir
dependencias de memcached.
```

---

### Tipo `reference`

Punteros a información que vive en sistemas externos: herramientas de tracking, wikis,
documentación, repositorios. No replica el contenido, solo indica dónde encontrarlo.

**Cuándo usarlo**: Cuando la fuente de verdad está fuera del repositorio y Claude necesita
saber dónde mirar o derivar a alguien.

**Ejemplo:**

```markdown
---
name: tracking-bugs-pipeline
description: Dónde se trackean los bugs del pipeline de ingestion
type: reference
---

Los bugs del pipeline de ingestion de datos se trackean en Linear, proyecto INGEST.

- URL: https://linear.app/miempresa/team/INGEST
- Etiqueta para bugs críticos: P0
- Responsable de triaje: equipo de data engineering (canal #data-eng en Slack)
- SLA para P0: 4 horas de respuesta

Al encontrar un bug en el pipeline, no abrir un issue en GitHub. Indicar al usuario
que lo reporte en Linear con la etiqueta correcta.
```

---

## 3. Formato de cada fichero de memoria

Todos los ficheros de memoria siguen el mismo formato: frontmatter YAML seguido del
contenido en markdown.

```markdown
---
name: nombre-de-la-memoria
description: descripción de una línea para el índice MEMORY.md
type: user|feedback|project|reference
---

Contenido de la memoria en markdown libre.
```

### Reglas del frontmatter

- `name`: identificador único, en minúsculas con guiones. Debe coincidir aproximadamente
  con el nombre del fichero.
- `description`: frase corta que aparecerá en el índice. Debe ser suficientemente
  descriptiva para que Claude decida si cargar el fichero completo.
- `type`: uno de los 4 valores exactos: `user`, `feedback`, `project`, `reference`.

### Ejemplo completo con los 4 tipos

Supongamos un proyecto de backend Python para una fintech:

```markdown
---
name: perfil-dev-backend
description: Experiencia y preferencias del desarrollador backend
type: user
---

El usuario lleva 3 años en Python backend (FastAPI, SQLAlchemy). Es senior en tests
unitarios pero quiere mejorar en tests de contrato y e2e. Prefiere respuestas directas
sin preámbulos. Le gusta que Claude explique el "por qué" de las decisiones de diseño.
```

```markdown
---
name: feedback-commits-convencionales
description: Usar Conventional Commits siempre, con scope obligatorio
type: feedback
---

Usar siempre el formato Conventional Commits con scope obligatorio.

**Why:** El equipo genera changelogs automáticos con semantic-release. Sin scope,
el changelog agrupa todo bajo "otros cambios" y pierde valor.

**How to apply:** feat(auth): ..., fix(payments): ..., docs(api): ...
El scope es el módulo afectado. Para cambios transversales usar chore(deps): o
refactor(core):.
```

```markdown
---
name: decision-paginacion-cursor
description: La API usa paginación por cursor, no por offset
type: project
---

Todos los endpoints de listado usan paginación por cursor (keyset pagination),
no paginación por offset.

**Why:** La tabla de transacciones tiene 50M+ de filas. Offset pagination degrada
a O(n) en páginas tardías. La decisión se tomó en la ADR-007 (docs/adr/007-pagination.md).

**How to apply:** Al implementar nuevos endpoints de listado, usar el patrón definido
en src/pagination.py. El cursor es opaco para el cliente (base64 de campos de ordenación).
```

```markdown
---
name: ref-documentacion-api-pagos
description: Dónde está la documentación de la API del proveedor de pagos
type: reference
---

La API del proveedor de pagos (Stripe) se documenta en:
- Guía general: https://stripe.com/docs/api
- Webhooks del proyecto: docs/stripe-webhooks.md (en este repo)
- Claves de test: en 1Password, bóveda "Desarrollo", entrada "Stripe Test Keys"
- Canal de soporte interno: #payments-integration en Slack
```

---

## 4. Qué NO guardar en memoria

Saber qué no guardar es tan importante como saber qué guardar. La memoria mal usada
introduce ruido y puede hacer que Claude trabaje con información incorrecta.

### Información derivable del código

El código es la fuente de verdad. Claude puede leerlo directamente.

| No guardar | Por qué |
|-----------|---------|
| "El proyecto usa TypeScript estricto" | Visible en `tsconfig.json` |
| "La función de autenticación está en auth/jwt.py" | Claude puede buscarla con grep |
| "Usamos ESLint con Airbnb config" | Visible en `.eslintrc.js` |
| "La BD tiene una tabla users con campos name, email" | Claude puede leer el schema |

### Historial git

```bash
# Claude puede ejecutar esto directamente
git log --oneline -20
git blame src/auth/jwt.py
```

El historial de commits y las razones de cada cambio están en git. No los repliques en memoria.

### Soluciones de debugging temporales

Si debuggeaste un problema y lo resolviste con un fix en el código, el fix ya está en el
código. No necesitas recordar "el problema era que el timeout era de 5s". Si el fix
fue un workaround que podría revertirse, considera documentarlo en un comentario en el
código o en una ADR.

### Lo que ya está en CLAUDE.md

Si una convención del proyecto está en `CLAUDE.md`, no la dupliques en memoria.
`CLAUDE.md` se carga siempre en el contexto; la memoria es para lo que `CLAUDE.md`
no puede cubrir porque es específico de una sesión o de un usuario concreto.

### Detalles efímeros de la tarea actual

"El usuario está trabajando en el ticket INGEST-412" no es algo que valga la pena
recordar para la próxima sesión. La memoria es para información con valor a largo plazo.

---

## 5. Cuándo guardar vs. cuándo no guardar

### Guardar en memoria

- **Correcciones del usuario**: Claude hizo algo, el usuario dijo "no, hazlo así".
  Ese aprendizaje no está en ningún otro sitio.
- **Confirmaciones no obvias**: El usuario explícitamente confirmó una forma de trabajar
  que Claude no podría inferir del código.
- **Contexto externo relevante**: Restricciones de negocio, decisiones del equipo,
  herramientas externas que Claude necesita conocer.
- **Preferencias del usuario**: Cómo quiere que Claude se comunique, qué nivel de detalle,
  qué tecnologías domina.

### No guardar

- Información que Claude puede obtener leyendo ficheros del proyecto.
- Estado temporal ("estoy a mitad de implementar X") — para eso usa tasks o plan.
- Duplicados de lo que ya está en `CLAUDE.md` o en documentación del repo.
- Información que caduca rápidamente (la memoria persiste entre sesiones).

---

## 6. Memoria vs. otros mecanismos de persistencia

Claude Code tiene varios mecanismos para manejar información. Cada uno tiene su ámbito:

| Mecanismo | Ámbito | Caso de uso |
|-----------|--------|-------------|
| **Memoria** | Entre sesiones, futuras conversaciones | Preferencias, correcciones, contexto externo |
| **Plan** | Sesión actual, alineación con el usuario | Acordar antes de ejecutar pasos complejos |
| **Tasks** | Sesión actual, seguimiento de progreso | Lista de pasos de una tarea en curso |
| **CLAUDE.md** | Permanente, todas las sesiones del equipo | Instrucciones del proyecto, convenciones |

### Ejemplo de decisión: dónde guardar cada cosa

Situación: estás implementando un sistema de notificaciones y el usuario ha dado varias
indicaciones durante la sesión.

| Indicación del usuario | Dónde guardar |
|------------------------|---------------|
| "Prefiero que uses nombres descriptivos en las variables, aunque sean largos" | Memoria tipo `feedback` |
| "Para este sprint, prioriza la notificación por email sobre la de push" | Memoria tipo `project` |
| "Los siguientes pasos son: 1) modelo, 2) servicio, 3) API, 4) tests" | Tasks (sesión actual) |
| "Siempre usar snake_case en Python" | `CLAUDE.md` (convención permanente del equipo) |
| "Antes de escribir código, muestra el plan" | Plan (alineación en la sesión actual) |

---

## Errores comunes

### Escribir contenido directamente en MEMORY.md

```markdown
# Incorrecto: MEMORY.md con contenido mezclado

# Memoria del proyecto

El usuario prefiere nombres descriptivos.
No mockear la base de datos.

- [feedback-commits.md](feedback-commits.md) — Conventional Commits
```

```markdown
# Correcto: MEMORY.md solo como índice

# Índice de memoria

- [feedback-nombres-descriptivos.md](feedback-nombres-descriptivos.md) — Preferencia por nombres largos y descriptivos
- [feedback-no-mockear-bd.md](feedback-no-mockear-bd.md) — No mockear BD en tests de integración
- [feedback-commits.md](feedback-commits.md) — Conventional Commits con scope obligatorio
```

### Usar el tipo incorrecto

Usar `project` para información que es en realidad una preferencia del usuario, o
`feedback` para información de referencia externa, hace que Claude no pueda priorizar
correctamente qué memorias cargar según el contexto.

### Guardar información que caduca sin fecha

Si guardas "merge freeze hasta el 10 de marzo", incluye la fecha para que en sesiones
futuras Claude sepa si la restricción sigue vigente.

---

## Resumen

- Los ficheros de memoria viven en `~/.claude/projects/<hash>/memory/` con frontmatter YAML.
- `MEMORY.md` es solo un índice de punteros; el contenido va en ficheros separados.
- Recomendamos organizar la auto memory en 4 tipos: `user` (quién eres), `feedback` (correcciones), `project` (contexto del trabajo), `reference` (dónde buscar).
- No guardes lo que el código ya dice, ni duplicados de `CLAUDE.md`, ni estado temporal.
- La memoria es para futuras sesiones; usa plan y tasks para la sesión actual.

---

Con esto completas el sistema de memoria de Claude Code. El Capítulo 5 (Configuración y
Permisos) cubre cómo configurar permisos y ajustar el comportamiento de Claude a nivel de
proyecto y de usuario.
