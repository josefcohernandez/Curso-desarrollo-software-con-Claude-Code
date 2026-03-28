# 04 - Prompt Caching y Optimización de Costes

> Tiempo estimado: 20 minutos | Nivel: Intermedio

## Conceptos clave

### Prompt Caching: qué es y por qué importa

Cada mensaje que envías a Claude incluye una carga fija: el system prompt interno,
el contenido de tu CLAUDE.md, las reglas de permisos y las definiciones de herramientas
MCP. En una sesión normal esta carga puede superar los 10.000 tokens por mensaje.

El **prompt caching** es el mecanismo por el que Claude reutiliza automáticamente los
prefijos de contexto que no han cambiado entre turnos consecutivos. Si tu CLAUDE.md,
las reglas y las definiciones de herramientas son idénticas al mensaje anterior, esa
parte del contexto se sirve desde caché en lugar de procesarse de nuevo.

Los tokens cacheados cuestan un 90% menos que los tokens de entrada normales.

```
Sin caché:   1.000 tokens fijos × N mensajes = N × 1.000 tokens facturados
Con caché:   1.000 tokens fijos × N mensajes = 1.000 tokens + (N-1) × 100 tokens facturados
```

Esto ocurre de forma completamente transparente: no requiere configuración manual
ni ningún cambio en tu flujo de trabajo. El beneficio es automático siempre que la
parte inicial del contexto no cambie entre turnos.

**Impacto práctico**: en una sesión larga de 30 mensajes, el coste real puede ser
un 60-80% inferior al coste nominal calculado sin caché.

---

## Coste por modelo

La siguiente tabla muestra los precios aproximados de los modelos más usados en
Claude Code. Los precios están expresados por millón de tokens (MTok).

| Modelo | Input (por 1M tokens) | Output (por 1M tokens) | Cached input |
|--------|-----------------------|------------------------|--------------|
| Claude Opus 4.6 | $5.00 | $25.00 | $0.50 (90% ahorro) |
| Claude Sonnet 4.6 | $3.00 | $15.00 | $0.30 (90% ahorro) |
| Claude Haiku 4.5 | $1.00 | $5.00 | $0.10 (90% ahorro) |

> Los precios son aproximados y pueden variar. Consulta siempre los precios
> actualizados en https://www.anthropic.com/pricing antes de planificar un
> presupuesto de producción.

Dos aspectos adicionales a tener en cuenta:

- Los tokens de **Extended Thinking** (razonamiento extendido) se facturan al
  precio de output, no de input. Activar Extended Thinking en tareas simples
  puede triplicar el coste de una sesión.
- El modelo por defecto en Claude Code es Sonnet, que ofrece el mejor equilibrio
  entre capacidad y coste para la mayoría de tareas de desarrollo.

---

## Estrategias de optimización de costes

### 1. Elegir el modelo correcto

El error más común es usar Opus para tareas que Sonnet o Haiku resuelven igual
de bien. La diferencia de coste entre Opus y Haiku es de 18x en input y casi
19x en output.

```bash
# Cambiar modelo en sesión interactiva
/model claude-haiku-4-5

# Especificar modelo en modo headless
claude -p "Resume este fichero" --model claude-haiku-4-5
```

Usa Opus cuando la tarea requiera razonamiento complejo, arquitectura de sistemas
o revisión crítica de seguridad. Usa Haiku para exploración, búsqueda de ficheros
y tareas repetitivas.

### 2. Aprovechar el caché: mantener sesiones estables

El caché se invalida cuando cambia cualquier parte del prefijo del contexto.
Cambiar el CLAUDE.md, añadir o quitar herramientas MCP, o modificar las reglas
de permisos entre mensajes destruye el caché y obliga a reprocesar todo.

Práctica recomendada: cierra y configura tus herramientas antes de empezar a
trabajar. Evita modificar CLAUDE.md a mitad de una sesión de trabajo intensivo.

### 3. Limitar el gasto máximo con `--max-budget-usd`

En modo headless (`-p`) puedes establecer un techo de gasto para evitar
sorpresas en tareas agénticas de larga duración:

```bash
claude -p "Refactoriza el módulo de autenticación completo" --max-budget-usd 2.00
```

Claude detendrá la ejecución si el coste acumulado supera el límite indicado.
Especialmente útil en pipelines de CI/CD o cuando delegas tareas largas sin
supervisión directa.

### 4. Limitar el número de turnos con `--max-turns`

Las tareas agénticas pueden encadenarse indefinidamente si no se acotan. Usa
`--max-turns` para limitar cuántas iteraciones puede hacer Claude antes de
detenerse y pedir supervisión:

```bash
claude -p "Analiza todos los ficheros en src/ y detecta code smells" --max-turns 5
```

### 5. Mantener CLAUDE.md conciso

Cada línea de tu CLAUDE.md se carga en cada mensaje de la sesión. Diez reglas
innecesarias en tu CLAUDE.md son cientos de tokens multiplicados por cada turno
de conversación.

Principio: si una regla no cambia el comportamiento de Claude en tu proyecto,
elimínala. Un CLAUDE.md de 50 líneas bien elegidas es más eficiente que uno
de 200 líneas con duplicados y reglas obsoletas.

### 6. Code execution gratuita con web search/fetch

Cuando una llamada a la API combina **code execution** con web search o web fetch, la ejecución de código es **gratuita**. Esto significa que puedes usar code execution para filtrar y procesar dinámicamente los resultados de búsquedas web sin coste adicional por la ejecución.

```bash
# El code execution que filtra los resultados de la búsqueda no se factura
claude -p "Busca las últimas versiones de React y filtra solo las stable releases"
```

Este patrón es especialmente útil en pipelines de monitorización donde necesitas buscar información en la web y procesarla programáticamente.

### 7. Reducir herramientas cargadas (Deferred Tools)

Cada herramienta MCP que Claude tiene disponible ocupa tokens en el prefijo del
sistema. Si tienes 10 herramientas configuradas pero solo usas 3 regularmente,
las otras 7 consumen tokens en cada mensaje sin aportar valor.

La configuración de Deferred Tools (detallada en el Capítulo 7) permite cargar
herramientas solo cuando se necesitan, reduciendo el overhead de tokens en
sesiones donde no se usan.

### 8. Subagentes con modelo económico

En tareas que combinan investigación y ejecución, puedes asignar el trabajo de
exploración al modelo más barato y reservar el modelo potente para la
implementación final:

```bash
# Investigación con Haiku (barato)
claude -p "Lista todos los endpoints de la API en src/" --model claude-haiku-4-5 > endpoints.txt

# Implementación con Sonnet (capacidad media, precio razonable)
cat endpoints.txt | claude -p "Genera tests de integración para estos endpoints"
```

### 9. `/clear` vs `/compact`: impacto en caché

- **`/clear`**: elimina todo el historial de la sesión. El siguiente mensaje se
  procesa sin ninguna parte cacheada del contexto anterior. Útil cuando la tarea
  cambia completamente, pero costoso si el prefijo es grande.
- **`/compact`**: resume el historial en un texto comprimido y continúa la sesión.
  Mantiene parte del caché de prefijo intacto. Es la opción más eficiente cuando
  quieres liberar contexto sin perder el arranque en caliente del caché.

### 10. Controlar el nivel de esfuerzo

La variable de entorno `CLAUDE_CODE_EFFORT_LEVEL` controla cuántos tokens de
razonamiento interno usa Claude antes de responder:

```bash
# Nivel bajo: menos tokens de thinking, respuestas más directas
CLAUDE_CODE_EFFORT_LEVEL=low claude -p "¿Qué hace esta función?"

# Nivel alto (por defecto en tareas complejas): más razonamiento, más coste
CLAUDE_CODE_EFFORT_LEVEL=high claude -p "Diseña la arquitectura del sistema de pagos"
```

---

## Monitorizar el consumo

### Comando `/cost`

Dentro de cualquier sesión interactiva, `/cost` muestra el coste acumulado y el
desglose de tokens consumidos en la sesión actual:

```
/cost
```

Ejemplo de salida:

```
Tokens de entrada:   45.230 (23.100 cacheados)
Tokens de salida:     8.920
Coste estimado:      $0.18
```

### Status line en tiempo real

La línea de estado inferior de Claude Code muestra los tokens consumidos en tiempo
real mientras Claude trabaja. Observa ese número para detectar tareas que consumen
contexto de forma inesperada.

### Salida JSON en modo headless

Cuando usas `-p` con `--output-format json`, la respuesta incluye métricas de uso
de tokens que puedes procesar o registrar:

```bash
claude -p "Resume src/auth.ts" --output-format json | jq '.usage'
```

Salida esperada:

```json
{
  "input_tokens": 1240,
  "output_tokens": 312,
  "cache_read_input_tokens": 8900,
  "cache_creation_input_tokens": 0
}
```

El campo `cache_read_input_tokens` muestra cuántos tokens se sirvieron desde caché.
Si ese número es alto respecto a `input_tokens`, el caching está funcionando bien.

---

## Presupuesto por tipo de tarea

La siguiente tabla ofrece orientación práctica para estimar el coste de las tareas
más comunes. Los rangos son aproximados y dependen del tamaño del proyecto, la
complejidad del código y la longitud de las respuestas.

| Tipo de tarea | Modelo recomendado | Coste típico | Budget sugerido |
|---------------|-------------------|--------------|-----------------|
| Explorar codebase desconocido | Haiku / Sonnet | $0.05 - $0.20 | $0.50 |
| Implementar feature simple | Sonnet | $0.20 - $0.80 | $1.00 |
| Refactorizar un módulo | Sonnet / Opus | $0.50 - $2.00 | $3.00 |
| Revisión de seguridad | Opus | $0.30 - $1.50 | $2.00 |
| Planificación de arquitectura | Opus | $0.50 - $3.00 | $5.00 |
| Sesión completa de trabajo (2h) | Mix según tarea | $2.00 - $8.00 | $10.00 |

> Registrar el coste de cada fase del proyecto te permitirá calibrar estos rangos
> con los datos reales de tu equipo. Este registro es especialmente útil durante
> el proyecto final (Capítulo 16).

---

## Errores comunes

**Usar Opus para todo**: es el error más frecuente en equipos que empiezan con
Claude Code. La tentación de usar el modelo más potente es comprensible, pero en
la mayoría de tareas cotidianas (lectura de ficheros, generación de tests, commits)
Sonnet o Haiku ofrecen el mismo resultado a una fracción del coste.

**Modificar CLAUDE.md durante sesiones activas**: cualquier cambio invalida el
caché y dispara el reprocesado del prefijo en el siguiente mensaje. Edita tu
CLAUDE.md fuera de las sesiones de trabajo intensivo.

**Ignorar Extended Thinking en tareas simples**: si tienes Extended Thinking
activado globalmente, cada pregunta sencilla incurre en un coste de razonamiento
desproporcionado. Activa Extended Thinking solo cuando la tarea lo justifique.

**No usar `--max-budget-usd` en pipelines automatizados**: una tarea agéntica sin
techo de gasto puede consumir presupuesto de forma inesperada si el agente entra
en un bucle o la tarea es más grande de lo estimado.

---

## Resumen

- El prompt caching reduce automáticamente el coste de los tokens fijos en un 90%.
  No requiere configuración, pero se beneficia de sesiones estables donde el
  CLAUDE.md y las herramientas no cambian entre turnos.
- Elegir el modelo correcto es la decisión de mayor impacto económico. Haiku para
  exploración, Sonnet para implementación, Opus para arquitectura y seguridad crítica.
- `--max-budget-usd` y `--max-turns` son los controles de gasto más directos en
  modo headless.
- `/cost` y el campo `usage` del output JSON permiten monitorizar el consumo en
  tiempo real y ajustar el presupuesto a datos reales.
- Un CLAUDE.md conciso y unas herramientas MCP bien seleccionadas reducen el
  overhead de tokens en cada mensaje de la sesión.
