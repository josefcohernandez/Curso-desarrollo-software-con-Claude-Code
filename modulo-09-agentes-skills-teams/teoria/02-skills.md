# 02 - Sistema de Skills

## Qué son los Skills

Los **Skills** son archivos `SKILL.md` que definen **capacidades reutilizables** para Claude Code. A diferencia de `CLAUDE.md` (que se carga siempre al inicio de cada sesión), los skills se cargan **bajo demanda**, solo cuando se necesitan.

### Analogía

Si `CLAUDE.md` es el "manual del empleado" que todo el mundo lee el primer día, los Skills son los **procedimientos operativos estándar (SOP)** que consultas solo cuando necesitas realizar una tarea específica: "Procedimiento para despliegue a producción", "Procedimiento para crear una migración de base de datos", etc.

```
CLAUDE.md                          Skills
+--------------------------+       +---------------------------+
| Se carga SIEMPRE         |       | Se cargan BAJO DEMANDA    |
| - Reglas del proyecto    |       | - deploy-staging/SKILL.md |
| - Convenciones de código |       | - generar-migracion/      |
| - Stack tecnológico      |       |   SKILL.md                |
| - Estructura general     |       | - crear-componente/       |
|                          |       |   SKILL.md                |
| Consumo: CADA sesión     |       | Consumo: SOLO cuando se   |
|                          |       |           invoca           |
+--------------------------+       +---------------------------+
```

---

## Ubicación de los Skills

Los skills pueden estar en dos ubicaciones:

### Skills de Proyecto (compartidos con el equipo)

Cada skill es un **directorio** con un archivo `SKILL.md` como entrypoint:

```
tu-proyecto/
  .claude/
    skills/
      deploy-staging/
        SKILL.md              # Instrucciones principales (requerido)
        template.md           # Plantilla opcional
        scripts/              # Scripts opcionales
      generar-migracion/
        SKILL.md
      crear-componente/
        SKILL.md
        examples/             # Ejemplos opcionales
```

Estos skills se comparten vía control de versiones (git) y están disponibles para todos los miembros del equipo.

### Skills de Usuario (personales)

```
~/.claude/
  skills/
    mi-workflow-personal/
      SKILL.md
    atajos-favoritos/
      SKILL.md
```

Estos skills son personales y no se comparten con el equipo.

### Skills de Enterprise (organizacionales)

Los administradores pueden definir skills a nivel de organización que se distribuyen a todos los proyectos.

### Prioridad de Carga

Si existe un skill con el mismo nombre en varias ubicaciones, la prioridad es:

1. **Enterprise** (mayor prioridad)
2. **Personal** (usuario)
3. **Proyecto** (menor prioridad)

> **Nota:** Los skills personales tienen **más prioridad** que los de proyecto. Esto permite que un desarrollador personalice un skill de proyecto sin afectar al equipo.

---

## Formato del Archivo SKILL.md

Un archivo SKILL.md tiene dos partes: un **frontmatter YAML** (opcional) y el **contenido Markdown**.

### Estructura Completa

```markdown
---
name: "Deploy to Staging"
description: "Ejecuta el flujo completo de despliegue a staging"
context: fork
disable-model-invocation: false
---

# Deploy to Staging

## Prerrequisitos
- Asegúrate de estar en la rama correcta
- Verifica que los tests pasen localmente

## Pasos

1. Ejecutar tests:
   ```bash
   npm test
   ```

2. Construir el proyecto:
   ```bash
   npm run build
   ```

3. Desplegar a staging:
   ```bash
   ./scripts/deploy.sh staging $ARGUMENTS
   ```

4. Verificar el despliegue:
   ```bash
   curl -s https://staging.miapp.com/health | jq .
   ```

## Si algo falla
- Revisar los logs: `kubectl logs -f deployment/miapp -n staging`
- Hacer rollback si es necesario: `./scripts/rollback.sh staging`
```

---

## Propiedades del Frontmatter

### name (obligatorio)

El nombre legible del skill. Aparece en la lista cuando usas `/skills`.

```yaml
name: "Deploy to Production"
```

### description (obligatorio)

Descripción breve de lo que hace el skill. Ayuda a Claude a decidir cuándo sugerirlo y al usuario a saber qué hace.

```yaml
description: "Ejecuta el pipeline completo de despliegue a producción"
```

> **Nota:** El menú `/skills` trunca las descripciones a **1.536 caracteres** y ordena los skills alfabéticamente. Escribe descripciones concisas y con la información más relevante al principio (*frontloaded*): si la descripción es larga, los últimos caracteres pueden no mostrarse. *(Novedad v2.1.86)*
>
> Desde v2.1.105, el límite de la descripción en el menú `/skills` se amplió de 250 a 1.536 caracteres. Descripciones que excedan este límite generan un warning al iniciar la sesión.

### context (opcional)

Controla dónde se ejecuta el skill:

| Valor | Comportamiento |
|-------|---------------|
| (no especificado) | Se ejecuta en el contexto principal |
| `fork` | Se ejecuta en un **subagente** con su propia ventana de contexto |

```yaml
context: fork  # Ejecutar en subagente
```

**Cuándo usar `context: fork`:**
- El skill genera mucho output (logs, tests)
- El skill lee muchos archivos
- No necesitas que el resultado detallado esté en tu contexto principal
- Quieres mantener limpia tu ventana de contexto

**Cuándo NO usar `context: fork`:**
- Necesitas interactuar con el resultado directamente
- El skill es corto y su output es pequeño
- Necesitas que la información esté disponible para tareas posteriores en la misma sesión

### paths (opcional)

> **Novedad v3.1 (v2.1.84)**

Limita la activación del skill a ficheros que coincidan con una lista de patrones glob. El skill solo se sugerirá o activará cuando el usuario trabaje con ficheros que coincidan:

```yaml
paths:
  - "src/api/**/*.ts"
  - "src/routes/**/*.ts"
  - "tests/api/**/*.test.ts"
```

Esto permite que un skill de "deploy" solo aparezca cuando trabajas en ficheros de infraestructura, o que un skill de "test" solo se active en directorios de tests. Acepta listas YAML de globs estándar.

### effort (opcional)

> **Novedad v2.1.80**

Controla el nivel de esfuerzo de razonamiento que Claude aplica al ejecutar el skill:

| Valor | Comportamiento |
|-------|---------------|
| `"low"` | Respuestas rápidas con razonamiento mínimo |
| `"medium"` | Balance entre velocidad y profundidad |
| `"high"` (default) | Razonamiento profundo y detallado |

```yaml
effort: "low"  # Para skills de consulta rápida
```

Este campo también se aplica a los **commands** personalizados definidos con frontmatter. Es útil para skills de consulta o referencia donde no se necesita razonamiento extenso.

### disableSkillShellExecution (v2.1.91)

El setting `disableSkillShellExecution` (configurado en `settings.json`, no en el frontmatter) desactiva la ejecución inline de bloques de código shell dentro de skills y commands personalizados. Cuando está activo, los bloques `bash` del skill se muestran como referencia pero no se ejecutan directamente. Ver [Módulo 15](../../modulo-15-plugins-marketplaces/teoria/04-marketplaces-y-gestion-enterprise.md) para detalles sobre su uso en entornos enterprise.

### disable-model-invocation (opcional)

Controla si Claude procesa las instrucciones o simplemente las devuelve como texto:

| Valor | Comportamiento |
|-------|---------------|
| `false` (default) | Claude ejecuta las instrucciones del skill |
| `true` | Claude devuelve el contenido del skill como texto sin ejecutarlo |

```yaml
disable-model-invocation: true  # Solo devuelve el texto
```

**Caso de uso para `true`:** Cuando el skill es una referencia o checklist que el usuario quiere leer, no ejecutar. Por ejemplo, un checklist de revisión de código que el desarrollador sigue manualmente.

---

## Variables disponibles en Skills

Los skills soportan variables especiales que se sustituyen en tiempo de ejecución.

### $ARGUMENTS

Variable sustituida con los argumentos que el usuario pasa al invocar el skill.

### Ejemplo

**Definición del skill (generar-migracion/SKILL.md):**
```markdown
---
name: "Generar Migración"
description: "Genera una migración de base de datos"
---

# Generar Migración

Genera una nueva migración de base de datos con el nombre: $ARGUMENTS

## Pasos
1. Crear archivo de migración con timestamp
2. Nombrar la migración: $ARGUMENTS
3. Añadir los métodos up() y down()
```

**Invocación:**
```
/generar-migracion add_email_to_users
```

**Resultado (tras sustitución):**
```
Genera una nueva migración de base de datos con el nombre: add_email_to_users
```

### Múltiples Argumentos

`$ARGUMENTS` recibe todo el texto después del nombre del skill como un único string:

```
/deploy-staging --env=staging --version=2.1.0 --skip-tests
```

En el skill, `$ARGUMENTS` se sustituye por: `--env=staging --version=2.1.0 --skip-tests`

### ${CLAUDE_EFFORT}

> **Novedad v2.1.120**

La variable `${CLAUDE_EFFORT}` contiene el nivel de esfuerzo de razonamiento activo en la sesión en el momento de ejecutar el skill. Los valores posibles son: `low`, `medium`, `high`, `xhigh` y `max`.

Esto permite que el skill adapte su comportamiento según el nivel configurado por el usuario:

```markdown
---
name: "Code Review"
description: "Revisa el código de la rama actual con profundidad variable según el effort configurado."
---

# Code Review

Nivel de esfuerzo actual: ${CLAUDE_EFFORT}

## Instrucciones según el nivel de esfuerzo

{% if ${CLAUDE_EFFORT} == "low" or ${CLAUDE_EFFORT} == "medium" %}
Haz una revisión rápida: busca solo bugs críticos y problemas de seguridad evidentes.
{% else %}
Haz una revisión exhaustiva: analiza bugs, rendimiento, seguridad, legibilidad y cobertura de tests.
{% endif %}

## Ámbito
Revisa los cambios en: $ARGUMENTS (o toda la rama si no se especifica ruta)
```

**Casos de uso habituales de `${CLAUDE_EFFORT}`:**

| Situación | Comportamiento esperado |
|-----------|------------------------|
| `low` / `medium` | Respuestas rápidas, análisis superficial, menos iteraciones |
| `high` | Análisis estándar con buena cobertura |
| `xhigh` / `max` | Análisis exhaustivo, razonamiento profundo, más iteraciones |

> **Relación con el campo `effort:` del frontmatter:** El campo `effort:` del frontmatter define el nivel de esfuerzo que el skill pide a Claude al ejecutarse (lo fija). La variable `${CLAUDE_EFFORT}` en cambio refleja el nivel que el usuario tiene configurado en ese momento, sin modificarlo. Úsalos de forma complementaria: `effort:` para fijar el nivel del skill, `${CLAUDE_EFFORT}` para adaptar las instrucciones al nivel ya activo.

---

## Cómo Invocar Skills

### Desde la Interfaz Interactiva

```bash
# Listar skills disponibles
/skills

# Invocar un skill por nombre
/deploy-staging

# Invocar con argumentos
/generar-migracion add_column_role_to_users

# Usando el comando skill
/skill deploy-staging
```

### Desde el Código (Skill Tool)

Claude también puede invocar skills programáticamente cuando detecta que uno es relevante para la tarea:

```
Skill tool call:
  skill: "deploy-staging"
  args: "--env=staging --version=2.1.0"
```

#### Invocación de slash commands built-in via Skill tool

> **Novedad v2.1.108**

El modelo puede descubrir e invocar comandos built-in de Claude Code a través del mismo mecanismo de Skill tool. Esto incluye comandos como `/init`, `/review` y `/security-review`.

En la práctica, esto significa que Claude puede decidir autónomamente ejecutar, por ejemplo, una revisión de seguridad (`/security-review`) o una revisión general de código (`/review`) sobre el trabajo que acaba de realizar, sin que el usuario lo pida explícitamente, cuando el contexto lo justifica.

**Ejemplo de situación donde esto ocurre:**

```
Usuario: "Implementa la autenticación JWT en src/auth/"

Claude:
  1. Implementa los cambios en los ficheros de auth
  2. Detecta que ha modificado código de seguridad sensible
  3. Invoca /security-review automáticamente via Skill tool
     para verificar que la implementación no introduce vulnerabilidades
  4. Presenta los resultados de la revisión junto con el código
```

Los comandos built-in disponibles para invocación automática incluyen:
- `/init` — inicializa la configuración del proyecto
- `/review` — revisa el código reciente
- `/security-review` — revisión orientada a seguridad

> **Nota:** Esta capacidad complementa los skills personalizados: el modelo tiene acceso tanto a los skills que defines en `.claude/skills/` como a los comandos built-in del sistema.

### Invocación Automática

Si Claude detecta que tu petición coincide con la descripción de un skill existente, puede sugerirte usarlo o invocarlo automáticamente (dependiendo de la configuración de permisos).

---

## Skills Invocables por el Usuario vs Skills Internos

### Skills Invocables por el Usuario

Son skills que aparecen en la lista de `/skills` y que el usuario puede invocar directamente. Normalmente tienen nombres descriptivos y documentación clara.

```markdown
---
name: "Crear Componente React"
description: "Genera la estructura completa de un componente React con tests"
---

# Crear Componente React: $ARGUMENTS

## Estructura a generar
- src/components/$ARGUMENTS/$ARGUMENTS.tsx
- src/components/$ARGUMENTS/$ARGUMENTS.test.tsx
- src/components/$ARGUMENTS/$ARGUMENTS.module.css
- src/components/$ARGUMENTS/index.ts
...
```

### Skills Internos

Son skills diseñados para ser invocados por Claude de forma automática, no directamente por el usuario. Útiles para estandarizar cómo Claude realiza ciertas operaciones internas.

```markdown
---
name: "Formato de Commit"
description: "Reglas internas para formatear mensajes de commit"
disable-model-invocation: true
---

## Reglas de Commit
- Prefijos: feat:, fix:, refactor:, docs:, test:, chore:
- Máximo 72 caracteres en la primera línea
- Cuerpo del mensaje después de línea en blanco
- Referencia al ticket: Closes #123
```

---

## Skills vs CLAUDE.md: Cuándo Usar Cada Uno

Esta es una de las decisiones más importantes para optimizar el consumo de tokens.

### Usa CLAUDE.md para:

- Información que Claude necesita en **CADA** sesión
- Reglas del proyecto que siempre aplican
- Stack tecnológico y convenciones de código
- Estructura del repositorio
- Configuración del entorno de desarrollo

### Usa Skills para:

- Workflows que solo se ejecutan **ocasionalmente**
- Procedimientos específicos de tareas concretas
- Instrucciones de despliegue
- Procesos de generación de código
- Checklists de revisión

### Regla Práctica para Migrar de CLAUDE.md a Skills

Si una sección de tu `CLAUDE.md` cumple estos criterios, muévela a un skill:

1. Solo se usa en un tipo específico de tarea (no siempre)
2. Tiene más de 10-15 líneas
3. Es un procedimiento paso a paso
4. Incluye comandos específicos para ejecutar

**Antes (CLAUDE.md inflado):**
```markdown
# CLAUDE.md

## Stack
- Node.js 20, TypeScript, Express, PostgreSQL

## Convenciones
- Usar camelCase para variables
- Archivos en kebab-case

## Proceso de Despliegue a Staging    <-- Esto debería ser un Skill
1. Ejecutar npm test                   |
2. Ejecutar npm run build              |
3. Ejecutar ./scripts/deploy.sh        |
4. Verificar health check              |
5. Notificar en Slack                  |

## Proceso de Migraciones              <-- Esto también
1. Crear archivo en migrations/        |
2. Usar el formato YYYYMMDD_nombre     |
3. Implementar up() y down()           |
4. Ejecutar npm run migrate            |
```

**Después (CLAUDE.md limpio + Skills):**
```markdown
# CLAUDE.md

## Stack
- Node.js 20, TypeScript, Express, PostgreSQL

## Convenciones
- Usar camelCase para variables
- Archivos en kebab-case

## Skills Disponibles
- /deploy-staging: Despliegue a staging
- /generar-migracion: Crear migración de BD
```

Los procedimientos detallados ahora están en sus respectivos archivos SKILL.md, y solo se cargan cuando se necesitan. Esto **ahorra tokens en cada sesión**.

---

## Ejemplo Completo: Skill con context: fork

```markdown
---
name: "Analizar Rendimiento"
description: "Ejecuta benchmarks y analiza el rendimiento de la aplicación"
context: fork
---

# Analizar Rendimiento

## Objetivo
Ejecutar los benchmarks del proyecto y generar un informe de rendimiento.

## Pasos

1. Ejecutar benchmarks:
   ```bash
   npm run benchmark -- $ARGUMENTS
   ```

2. Analizar los resultados:
   - Identificar las funciones más lentas
   - Comparar con la línea base (si existe en benchmarks/baseline.json)
   - Detectar regresiones de rendimiento

3. Generar informe:
   - Crear un resumen con las top 10 funciones más lentas
   - Incluir gráficos ASCII si es posible
   - Sugerir optimizaciones para cada cuello de botella

4. Guardar resultados:
   ```bash
   cp benchmark-results.json benchmarks/latest.json
   ```
```

Este skill se ejecuta en un subagente (`context: fork`) porque:
- Los benchmarks generan mucho output
- El análisis requiere leer archivos de resultados
- Solo el informe final necesita llegar al contexto principal

---

## Buenas Prácticas para Skills

1. **Nombres descriptivos**: Usa nombres que dejen claro qué hace el skill
   - Bien: `deploy-staging`, `generar-migracion`, `crear-componente`
   - Mal: `d1`, `proceso`, `hacer-cosa`

2. **Descripciones útiles y concisas**: La descripción ayuda a Claude a sugerir el skill correcto. El menú `/skills` muestra un máximo de 1.536 caracteres (ampliado de 250 en v2.1.105), así que coloca la información clave al principio.
   ```yaml
   description: "Genera una migración de base de datos con métodos up/down"
   ```

3. **Instrucciones completas**: Incluye todo lo necesario para que Claude ejecute el workflow sin ambigüedad

4. **Manejo de errores**: Incluye secciones de "Si algo falla" con pasos de recuperación

5. **$ARGUMENTS documentado**: Explica qué argumentos espera el skill
   ```markdown
   ## Uso
   /generar-migracion <nombre_de_la_migracion>

   Ejemplo: /generar-migracion add_email_to_users
   ```

6. **Usa `context: fork` para skills pesados**: Si el skill genera mucho output o lee muchos archivos

7. **Versionado**: Mantiene los skills en git para que todo el equipo los use

---

## Resumen

| Concepto | Descripción |
|----------|-------------|
| Skill | Directorio con SKILL.md como entrypoint |
| Ubicación proyecto | `.claude/skills/nombre-skill/SKILL.md` |
| Ubicación usuario | `~/.claude/skills/nombre-skill/SKILL.md` |
| Prioridad | Enterprise > Personal > Proyecto |
| Carga | Bajo demanda (no al inicio de cada sesión) |
| `$ARGUMENTS` | Variable sustituida con los argumentos del usuario |
| `${CLAUDE_EFFORT}` | Variable con el nivel de effort activo: `low`, `medium`, `high`, `xhigh`, `max` (v2.1.120) |
| `context: fork` | Ejecuta en subagente (contexto aislado) |
| `effort` | Nivel de esfuerzo de razonamiento fijo del skill: `"low"`, `"medium"`, `"high"` |
| `disable-model-invocation` | Si es `true`, devuelve el texto sin ejecutar |
| Invocación | `/nombre-del-skill` o Skill tool |
| Comandos built-in via Skill tool | `/init`, `/review`, `/security-review` invocables automáticamente por el modelo (v2.1.108) |
| vs CLAUDE.md | CLAUDE.md = siempre; Skills = bajo demanda |
