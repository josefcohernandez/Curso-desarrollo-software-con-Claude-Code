# 02 - Sistema de Skills

## Qué son los Skills

Los **Skills** son archivos `SKILL.md` que definen **capacidades reutilizables** para Claude Code. A diferencia de `CLAUDE.md` (que se carga siempre al inicio de cada sesión), los skills se cargan **bajo demanda**, solo cuando se necesitan.

### Analogía

Si `CLAUDE.md` es el "manual del empleado" que todo el mundo lee el primer día, los Skills son los **procedimientos operativos estándar (SOP)** que consultas solo cuando necesitas realizar una tarea específica: "Procedimiento para despliegue a producción", "Procedimiento para crear una migración de base de datos", etc.

```
CLAUDE.md                          Skills
+--------------------------+       +---------------------------+
| Se carga SIEMPRE         |       | Se cargan BAJO DEMANDA    |
| - Reglas del proyecto    |       | - deploy-staging.md       |
| - Convenciones de código |       | - generar-migracion.md    |
| - Stack tecnológico      |       | - crear-componente.md     |
| - Estructura general     |       | - release-process.md      |
|                          |       |                           |
| Consumo: CADA sesión     |       | Consumo: SOLO cuando se   |
|                          |       |           invoca           |
+--------------------------+       +---------------------------+
```

---

## Ubicación de los Skills

Los skills pueden estar en dos ubicaciones:

### Skills de Proyecto (compartidos con el equipo)

```
tu-proyecto/
  .claude/
    skills/
      deploy-staging.md
      generar-migracion.md
      crear-componente.md
```

Estos skills se comparten vía control de versiones (git) y están disponibles para todos los miembros del equipo.

### Skills de Usuario (personales)

```
~/.claude/
  skills/
    mi-workflow-personal.md
    atajos-favoritos.md
```

Estos skills son personales y no se comparten con el equipo.

### Prioridad de Carga

Si existe un skill con el mismo nombre en ambas ubicaciones, el skill de **proyecto** tiene prioridad sobre el de **usuario**.

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

Limita la activacion del skill a ficheros que coincidan con una lista de patrones glob. El skill solo se sugerira o activara cuando el usuario trabaje con ficheros que coincidan:

```yaml
paths:
  - "src/api/**/*.ts"
  - "src/routes/**/*.ts"
  - "tests/api/**/*.test.ts"
```

Esto permite que un skill de "deploy" solo aparezca cuando trabajas en ficheros de infraestructura, o que un skill de "test" solo se active en directorios de tests. Acepta listas YAML de globs estandar.

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

## La Variable $ARGUMENTS

Los skills soportan una variable especial `$ARGUMENTS` que se sustituye con los argumentos que el usuario pasa al invocar el skill.

### Ejemplo

**Definición del skill (generar-migracion.md):**
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

2. **Descripciones útiles**: La descripción ayuda a Claude a sugerir el skill correcto
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
| Skill | Archivo SKILL.md con capacidades reutilizables |
| Ubicación proyecto | `.claude/skills/nombre.md` |
| Ubicación usuario | `~/.claude/skills/nombre.md` |
| Carga | Bajo demanda (no al inicio de cada sesión) |
| `$ARGUMENTS` | Variable sustituida con los argumentos del usuario |
| `context: fork` | Ejecuta en subagente (contexto aislado) |
| `disable-model-invocation` | Si es `true`, devuelve el texto sin ejecutar |
| Invocación | `/nombre-del-skill` o Skill tool |
| vs CLAUDE.md | CLAUDE.md = siempre; Skills = bajo demanda |
