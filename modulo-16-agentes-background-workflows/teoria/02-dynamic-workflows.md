# 02 - Dynamic Workflows: Orquestación a Gran Escala

> **Disponible desde v2.1.154**

Hasta ahora, escalar el trabajo con agentes significaba lanzar tú mismo unos pocos subagentes o teammates con nombre (M09) y coordinarlos manualmente. Los **Dynamic Workflows** cambian esa escala: le pides a Claude, en una sola instrucción, que **descomponga una tarea grande y orqueste el trabajo entre decenas o cientos de agentes en background** sin que tengas que definir cada uno.

---

## Objetivos de aprendizaje

Al terminar esta sección serás capaz de:

- Explicar qué es un Dynamic Workflow y en qué se diferencia de lanzar subagentes o Agent Teams manualmente
- Activar la creación de un workflow dinámico con la palabra clave `ultracode`
- Monitorizar el progreso de un workflow con `/workflows`, incluido el filtrado por estado
- Configurar el tamaño de los workflows dinámicos (`small`/`medium`/`large`) desde `/config`
- Decidir cuándo un Dynamic Workflow aporta valor real y cuándo es sobre-ingeniería para la tarea

---

## Conceptos clave

### Qué es un Dynamic Workflow

Un Dynamic Workflow es una **orquestación automática**: le describes a Claude una tarea grande y descomponible, y Claude:

1. **Analiza** la tarea y la descompone en sub-tareas independientes
2. **Lanza** un número variable de agentes en background — potencialmente decenas o cientos, según el tamaño de la tarea
3. **Coordina** las dependencias entre sub-tareas (algunas pueden requerir que otras terminen primero)
4. **Agrega** los resultados y te presenta un resumen cuando el workflow completa

La diferencia clave frente a lanzar subagentes manualmente (M09) es que **tú no decides cuántos agentes ni cómo se reparte el trabajo**. Describes el objetivo; Claude decide la estrategia de descomposición y paralelización.

### La palabra clave `ultracode`

> **Renombrada de "workflow" a "ultracode" en v2.1.160**

Para que Claude interprete tu instrucción como una petición de Dynamic Workflow (y no como una tarea normal de una sesión), se usa la palabra clave `ultracode` en el prompt:

```text
ultracode: Migra todos los componentes de la carpeta src/components
de PropTypes a TypeScript. Hay aproximadamente 140 componentes.
Para cada uno: convierte las props a una interfaz TypeScript,
actualiza las importaciones y verifica que el build sigue pasando.
```

> **Nota de nomenclatura:** en versiones anteriores a v2.1.160, la misma funcionalidad se activaba con la palabra "workflow". Si consultas documentación o material de versiones anteriores a mayo de 2026, ten en cuenta que el trigger ha cambiado a `ultracode`.

Al recibir esta instrucción, Claude Code no ejecuta la tarea directamente: primero **propone un plan de descomposición** (cuántos agentes, cómo se reparte el trabajo, qué dependencias hay entre sub-tareas) para que lo apruebes antes de lanzar la ejecución masiva.

### `/workflows`: ver y monitorizar los runs

```bash
/workflows
```

Muestra la lista de ejecuciones de Dynamic Workflows (runs), pasadas y en curso, con su estado general y progreso. Desde la vista de un run puedes entrar al **detalle de agente**, donde ves cada uno de los agentes lanzados por el workflow individualmente.

### Filtrado por estado en la vista de detalle

> **Disponible desde v2.1.186**

Dentro de la vista de detalle de un run, la tecla `f` abre un filtro por estado de agente (por ejemplo: en ejecución, completados, con error, esperando input). Esto es imprescindible cuando el workflow lanza cientos de agentes: sin filtrado, localizar los 3 agentes que fallaron entre 200 completados sería inviable.

```text
# Dentro de /workflows → detalle de un run:
f
# Selecciona el estado a filtrar (ej. "failed") para ver solo esos agentes
```

### Dynamic workflow size: controlar la escala

> **Setting disponible desde v2.1.202**

Por defecto, Claude decide cuántos agentes lanzar según su propio análisis de la tarea. El setting "Dynamic workflow size" en `/config` permite acotar ese comportamiento:

```bash
/config
# Navega a "Dynamic workflow size" y selecciona: small / medium / large
```

| Tamaño | Cuándo usarlo |
|--------|---------------|
| `small` | Tareas descomponibles pero acotadas (decenas de sub-tareas); minimiza consumo de tokens |
| `medium` | Tamaño por defecto recomendado para la mayoría de migraciones y refactors medianos |
| `large` | Tareas masivas (cientos de ficheros o módulos) donde priorizas velocidad de completado sobre coste |

> Ajustar el tamaño es especialmente relevante para controlar costes: cada agente lanzado por el workflow consume tokens de forma independiente, así que un workflow `large` en una tarea que en realidad es `small` puede ser significativamente más caro sin aportar más valor.

### Telemetría: `workflow.run_id` y `workflow.name`

> **Disponible desde v2.1.202**

Si tu organización usa OpenTelemetry (ver [M11](../../modulo-11-enterprise-seguridad/README.md)), los eventos de los agentes lanzados por un Dynamic Workflow incluyen los atributos `workflow.run_id` y `workflow.name`. Esto permite agregar coste y uso de tokens **por workflow completo**, no solo por sesión individual, en tus dashboards de observabilidad.

### Diferencias con otros mecanismos de paralelismo

Es fácil confundir los Dynamic Workflows con otros conceptos ya vistos en el curso que también usan la palabra "workflow" o implican varios agentes. Esta tabla aclara las diferencias:

| Mecanismo | Módulo | Quién decide la descomposición | Escala típica |
|-----------|--------|----------------------------------|----------------|
| "Workflows eficientes" (Writer→Reviewer, Spec First, etc.) | [M06](../../modulo-06-planificacion-opus/teoria/03-workflows-eficientes.md) | Tú, manualmente, en sesiones secuenciales | 1 sesión, pasos manuales |
| Subagentes nombrados | [M09](../../modulo-09-agentes-skills-teams/teoria/01-subagentes.md) | Tú decides cuántos y para qué | Unos pocos (2-5 típico) |
| Agent Teams | [M09](../../modulo-09-agentes-skills-teams/teoria/03-agent-teams.md) | Tú defines los teammates; colaboran en tareas compartidas | Un equipo pequeño (2-6 teammates) |
| Dynamic Workflow (`ultracode`) | Este módulo | **Claude** decide la descomposición y el número de agentes | Decenas a cientos de agentes |

---

## Casos de uso: cuándo SÍ y cuándo NO

### Cuándo un Dynamic Workflow tiene sentido

- **Migraciones masivas y homogéneas**: convertir 150 componentes de un patrón a otro, donde cada componente se procesa de forma prácticamente independiente
- **Auditorías a gran escala**: revisar seguridad, cobertura de tests o calidad de código en cientos de ficheros de un monorepo
- **Actualizaciones de dependencias en cascada**: actualizar una librería y adaptar cada uno de los módulos que la usan, cuando los cambios necesarios son similares pero no idénticos
- **Generación de documentación en volumen**: documentar cientos de endpoints o funciones públicas siguiendo una plantilla común

El patrón común: **la tarea se descompone en muchas unidades similares y mayormente independientes**, y el cuello de botella es la cantidad de trabajo, no la complejidad de coordinación entre partes.

### Cuándo un Dynamic Workflow es sobre-ingeniería

- **Tareas pequeñas** (menos de 10-15 unidades de trabajo): el overhead de planificación y coordinación del workflow supera el tiempo que ahorra frente a hacerlo con 2-3 subagentes manuales
- **Tareas con fuerte interdependencia secuencial**: si cada paso depende críticamente del resultado exacto del anterior (por ejemplo, diseñar un esquema de base de datos y luego implementarlo), la paralelización masiva no aplica bien; usa un workflow manual de M06 (Spec First, Writer→Reviewer)
- **Tareas que requieren juicio humano en cada unidad**: decisiones de diseño de UX, naming de APIs públicas o cualquier cosa donde cada resultado necesita revisión individual antes de continuar — el volumen de PRs draft resultante sería inmanejable
- **Presupuesto de tokens ajustado**: un workflow `large` mal dimensionado puede consumir significativamente más tokens que la suma de hacer el trabajo con unos pocos subagentes bien dirigidos

> **Regla práctica:** si puedes describir la tarea completa como "haz lo mismo en N sitios distintos, de forma casi independiente", es candidata a Dynamic Workflow. Si la tarea es "diseña algo y luego constrúyelo paso a paso", usa los workflows manuales de M06 o un subagente único con Plan Mode.

---

## Ejemplos prácticos

### Migración masiva con `ultracode`

```text
ultracode: Actualiza los 80 archivos de test en tests/integration/
que usan la librería de mocking antigua "nock" al nuevo estándar
del equipo con "msw". Para cada archivo:
1. Identifica los mocks de nock existentes
2. Convierte cada uno a un handler de msw equivalente
3. Ejecuta el archivo de test y verifica que sigue pasando
4. Si un test falla tras la conversión, repórtalo sin intentar arreglarlo

Usa Dynamic workflow size: medium.
```

### Monitorizar el progreso con filtrado

```bash
/workflows
# Selecciona el run en curso de la migración de tests
# Dentro del detalle:
f
# Filtra por "failed" para revisar primero los agentes que fallaron
```

### Auditoría de seguridad a escala de monorepo

```text
ultracode: Audita los 45 microservicios en services/ buscando:
- Dependencias con vulnerabilidades conocidas (CVE)
- Secretos hardcodeados en el código
- Endpoints sin autenticación

Genera un informe consolidado con hallazgos por severidad al terminar.
```

---

## Errores comunes

| Error | Causa | Solución |
|-------|-------|---------|
| Usar `ultracode` para tareas de 5-10 unidades | Confundir "varios agentes" con "muchísimos agentes" | Para tareas pequeñas, lanza subagentes manuales (M09); reserva `ultracode` para volúmenes de decenas o cientos |
| No revisar el plan de descomposición antes de aprobar | Aprobar el workflow a ciegas por prisa | Revisa siempre el plan propuesto: cuántos agentes, cómo se reparte el trabajo, antes de confirmar la ejecución |
| Confundir la palabra clave antigua "workflow" con `ultracode` | Usar documentación o hábitos de antes de v2.1.160 | Desde v2.1.160 el trigger es `ultracode`; "workflow" ya no activa la creación del Dynamic Workflow |
| Dejar el tamaño en `large` por defecto sin necesidad | No ajustar "Dynamic workflow size" en `/config` | Empieza en `small` o `medium` y sube a `large` solo si el volumen de trabajo lo justifica |
| Usar `ultracode` para tareas con fuerte dependencia secuencial | La tarea no es paralelizable de forma natural | Si cada paso depende del resultado exacto del anterior, usa un workflow manual (M06) o Plan Mode con un único agente |
| No monitorizar los agentes fallidos de un workflow grande | Asumir que "workflow completado" significa "todo salió bien" | Usa el filtro por estado (`f`) en `/workflows` para revisar explícitamente los agentes con error antes de dar el workflow por bueno |

---

## Resumen

- Un Dynamic Workflow (v2.1.154) orquesta automáticamente decenas o cientos de agentes background a partir de una única instrucción; Claude decide la descomposición, no tú
- La palabra clave que activa la creación de un workflow es `ultracode` (renombrada desde "workflow" en v2.1.160)
- `/workflows` muestra los runs y su progreso; el filtrado por estado (`f`, v2.1.186) es esencial para revisar fallos en workflows grandes
- El setting "Dynamic workflow size" (`/config`, v2.1.202) controla la escala: `small`, `medium` o `large`
- Los atributos OTEL `workflow.run_id` y `workflow.name` (v2.1.202) permiten agregar telemetría por workflow completo
- Un Dynamic Workflow tiene sentido cuando la tarea se descompone en muchas unidades similares y mayormente independientes
- Es sobre-ingeniería para tareas pequeñas, con fuerte dependencia secuencial, o que requieren juicio humano en cada unidad

---

## Siguiente paso

Aplica lo aprendido en los ejercicios de este módulo: [01 - Monitorizar Agentes](../ejercicios/01-monitorizar-agentes.md) y [02 - Dynamic Workflow](../ejercicios/02-dynamic-workflow.md).
