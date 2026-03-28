# 01 - La Ventana de Contexto: El Concepto Más Importante

> De todo lo que cubre este capítulo, la ventana de contexto es el concepto con mayor impacto práctico:
> es un recurso finito. Cada token cuenta.
> Cuanto mejor la gestiones, mejor trabaja Claude para ti.

## Qué es la ventana de contexto

La ventana de contexto es la **memoria de trabajo** de Claude durante una conversación.
Piensa en ella como la RAM de un ordenador: tiene un tamaño fijo y todo lo que Claude
necesita para ayudarte tiene que caber ahí.

Pero a diferencia de la RAM, la ventana de contexto no solo almacena datos. **Es el
espacio donde Claude "piensa"**. Cuanto más llena está, menos espacio tiene para
razonar, y la calidad de sus respuestas se degrada.

### Qué contiene la ventana de contexto

Todo. Literalmente todo lo que Claude necesita para funcionar:

```
+------------------------------------------------------------------+
|                    VENTANA DE CONTEXTO                            |
|                                                                  |
|  +---------------------------+  +-----------------------------+  |
|  | Instrucciones del sistema |  | Contenido de CLAUDE.md      |  |
|  | (invisibles para ti)      |  | (proyecto + usuario + local)|  |
|  +---------------------------+  +-----------------------------+  |
|                                                                  |
|  +---------------------------+  +-----------------------------+  |
|  | Definiciones de tools     |  | Skills cargados             |  |
|  | (MCP servers, built-in)   |  | (bajo demanda)              |  |
|  +---------------------------+  +-----------------------------+  |
|                                                                  |
|  +------------------------------------------------------------+  |
|  |           HISTORIAL DE LA CONVERSACIÓN                      |  |
|  |                                                              |  |
|  |  Tu mensaje 1                                                |  |
|  |  Respuesta de Claude 1 (incluye archivos leídos, outputs)   |  |
|  |  Tu mensaje 2                                                |  |
|  |  Respuesta de Claude 2                                       |  |
|  |  ...                                                         |  |
|  |  Tu mensaje actual                                           |  |
|  +------------------------------------------------------------+  |
|                                                                  |
|  +------------------------------------------------------------+  |
|  |           ESPACIO PARA RAZONAR Y RESPONDER                  |  |
|  |           (cuanto más grande, mejor calidad)                 |  |
|  +------------------------------------------------------------+  |
+------------------------------------------------------------------+
```

### Tamaños de ventana de contexto

| Modelo | Ventana de contexto | Tokens de salida máx |
|--------|--------------------|-----------------------|
| Claude Opus 4.6 | 1M tokens (Max/Team/Enterprise) | 128,000 tokens |
| Claude Sonnet 4.6 | 1M tokens (beta) | 64,000 tokens |
| Claude Haiku 4.5 | 200K tokens | 64,000 tokens |

> **Nota v3.0:** Opus 4.6 duplicó su límite de salida de 64K a **128K tokens** en marzo 2026.
> Sonnet 4.6 alcanza 1M de contexto en beta. Estos incrementos permiten sesiones más largas
> y respuestas más completas, pero el contexto sigue siendo un recurso finito: cada token cuenta.

## Qué consume contexto (y cuánto)

No todo consume la misma cantidad de tokens. Aquí tienes una referencia aproximada:

### Contenido que siempre está presente

| Elemento | Tokens aproximados | Notas |
|----------|-------------------|-------|
| Instrucciones del sistema | ~2,000-4,000 | Invisibles, siempre presentes |
| CLAUDE.md (proyecto) | Variable | Cada línea cuenta. 500 líneas ~ 3,000-5,000 tokens |
| CLAUDE.md (usuario) | Variable | Se suma al del proyecto |
| CLAUDE.md (local) | Variable | Se suma a los anteriores |
| Definiciones de tools built-in | ~1,500-3,000 | Bash, Read, Write, etc. |
| Definiciones de MCP servers | Variable | **Cada servidor añade herramientas aunque no se usen** |

### Contenido que crece con la sesión

| Elemento | Tokens aproximados | Notas |
|----------|-------------------|-------|
| Mensaje de usuario típico | 50-200 | Depende de la longitud |
| Lectura de un archivo (500 líneas) | ~2,000-4,000 | Cada archivo leído se añade al contexto |
| Salida de `npm test` | 500-5,000 | Tests verbosos consumen mucho |
| Salida de `git diff` | Variable | Diffs grandes son costosos |
| Respuesta de Claude | 200-2,000 | Incluye razonamiento |
| Búsqueda grep (resultados) | 500-3,000 | Depende del número de matches |
| Thinking tokens (Opus) | Hasta 31,999 | Se cobran como tokens de salida |

### Un ejemplo concreto

Imagina una sesión típica de 30 minutos:

```
Inicio de sesión:
  Sistema + CLAUDE.md + tools          ~  8,000 tokens

Tarea 1: Fix de un bug
  Tu: "hay un bug en el login"         ~    100 tokens
  Claude lee auth.ts (200 líneas)      ~  1,200 tokens
  Claude lee auth.test.ts (150 líneas) ~    900 tokens
  Claude responde con análisis         ~    800 tokens
  Tu: "sí, arréglalo"                  ~     30 tokens
  Claude lee, edita, ejecuta tests     ~  3,500 tokens
  Salida de tests                      ~  1,500 tokens
  Claude confirma fix                  ~    400 tokens
                                       ----------
  Subtotal tarea 1:                    ~ 16,430 tokens (8.2% de 200K)

Tarea 2: Nuevo endpoint API
  (Sin /clear, todo lo anterior sigue en contexto)
  Tu: "crea un endpoint GET /users"    ~    100 tokens
  Claude lee routes.ts                 ~  2,000 tokens
  Claude lee models/user.ts            ~  1,500 tokens
  Claude lee middleware/auth.ts        ~  1,200 tokens
  Claude implementa                    ~  2,500 tokens
  Tests                                ~  3,000 tokens
                                       ----------
  Subtotal tarea 2:                    ~ 10,300 tokens

  TOTAL ACUMULADO:                     ~ 26,730 tokens (13.4% de 200K)
```

Parece que tenemos espacio de sobra, pero observa: los 8,430 tokens de la Tarea 1
**siguen ahí** y ya no son útiles para la Tarea 2. Si hubiéramos hecho `/clear`
entre tareas, la Tarea 2 habría empezado con solo ~8,000 tokens de base.

Después de 10-15 tareas sin limpiar, fácilmente llegas al 60-80% de capacidad.

## Por qué importa: la degradación del rendimiento

Este es el punto clave que la mayoría de usuarios no entiende:

> **Claude no funciona igual al 20% de contexto que al 80%.**

A medida que la ventana de contexto se llena:

1. **Instrucciones tempranas se "diluyen"**: Si diste una instrucción importante al
   principio de la sesión, Claude puede "olvidarla" cuando hay 100K tokens de
   conversación por medio.

2. **Aumentan los errores**: Claude tiene más probabilidad de contradecirse,
   repetir trabajo ya hecho, o ignorar restricciones que mencionaste antes.

3. **Las respuestas se vuelven genéricas**: Con menos espacio para razonar,
   Claude tiende a dar respuestas más superficiales.

4. **Se pierden detalles**: En una sesión larga, Claude puede olvidar que ya
   modificó un archivo y volver a leerlo (desperdiciando más tokens).

### La analogía del escritorio

Imagina un escritorio físico:
- **Contexto limpio (20%):** Tienes espacio para trabajar. Ves todos tus
  documentos relevantes. Puedes pensar con claridad.
- **Contexto medio (50%):** El escritorio está lleno de papeles. Encuentras
  lo que necesitas pero tardas más. A veces no ves un documento importante
  tapado por otros.
- **Contexto lleno (80%+):** Papeles por todas partes, cayéndose al suelo.
  No encuentras nada. Cometes errores porque no ves información importante.

## Auto-compactación

Cuando la ventana de contexto alcanza aproximadamente el **95% de capacidad**,
Claude Code activa automáticamente la **auto-compactación**.

### Qué hace la compactación

La compactación es un proceso que:

1. **Resume** la conversación anterior en un formato condensado
2. **Preserva** el código fuente y las decisiones clave
3. **Descarta** detalles que se consideran menos importantes
4. **Libera** espacio para continuar trabajando

### Qué se preserva vs qué se pierde

| Se preserva | Puede perderse |
|-------------|----------------|
| Cambios de código realizados | Instrucciones detalladas del inicio |
| Decisiones arquitectónicas | Contexto de por qué se descartaron alternativas |
| Estado actual del trabajo | Matices de conversaciones largas |
| Archivos críticos mencionados | Detalles de errores intermedios |

### El problema de la auto-compactación

La auto-compactación es una **red de seguridad**, no una estrategia. Cuando se activa:

- **Tú no controlas qué se descarta.** Claude decide qué es "menos importante", y
  a veces se equivoca.
- **Hay una pausa perceptible** mientras se procesa la compactación.
- **Se pierde granularidad.** "Recuerda que el cliente pidió que usemos snake_case
  en la API" puede desaparecer si se dijo hace 50 mensajes.

Es mucho mejor **gestionar tu contexto proactivamente** con `/clear` y `/compact`
que esperar a que la auto-compactación te rescate.

## Monitorizar el uso de contexto

Para saber cuánto contexto estás consumiendo, usa el comando `/cost` o la barra de estado que muestra el porcentaje de uso de la ventana de contexto.

### Qué vigilar

1. **MCP tool definitions alto:** Si tienes 8-10 servidores MCP configurados,
   pueden consumir el 10-15% de tu contexto solo con sus definiciones de
   herramientas. Incluso si no los usas.

2. **CLAUDE.md demasiado grande:** Si tu CLAUDE.md tiene 1,000 líneas, eso son
   potencialmente 6,000-10,000 tokens que se cargan en CADA sesión.

3. **Conversation history desproporcionado:** Si llevas muchos mensajes sin
   hacer `/clear`, el historial crece sin parar.

## Costes y tokens

### Cuánto cuesta usar Claude Code

Los tokens no son solo un tema de rendimiento; también son dinero.

| Modelo | Precio Input (1M tokens) | Precio Output (1M tokens) |
|--------|-------------------------|--------------------------|
| Claude Sonnet 4.6 | $3.00 | $15.00 |
| Claude Opus 4.6 | $5.00 | $25.00 |
| Claude Haiku 4.5 | $1.00 | $5.00 |

### Costes típicos por día

Según datos de Anthropic:

| Percentil | Coste diario (Sonnet) |
|-----------|----------------------|
| Media | ~$6/dev/día |
| 90% de usuarios | < $12/dev/día |
| Usuarios intensivos | $15-25/dev/día |

> **Nota:** Los costes de Opus son aproximadamente 1.7x los de Sonnet. Un día
> intensivo con Opus puede costar $15-30. Por eso es importante elegir el
> modelo correcto para cada tarea.

### Prompt caching: ahorro automático

Claude Code utiliza **prompt caching** para reducir costes en contenido repetido:

- **El system prompt** se cachea entre turnos de conversación
- **Los archivos de CLAUDE.md** se cachean
- **Las definiciones de tools** se cachean

El caching reduce el coste de los tokens de input cacheados a un 10% del precio
normal. Esto significa que tu CLAUDE.md de 5,000 tokens no cuesta 5,000 tokens
en cada turno, sino mucho menos después del primer turno.

### Costes de background

Claude Code también consume tokens "en segundo plano":

| Operación | Coste aproximado |
|-----------|-----------------|
| Resumen de conversación (compactación) | ~$0.02-0.04 |
| Procesamiento de título de sesión | ~$0.01 |
| Resolución de herramientas (Tool Search) | ~$0.01 |

Estos costes son mínimos (~$0.04/sesión) pero es bueno saberlo.

### El comando /cost

Para ver cuánto llevas gastado en la sesión actual:

```
/cost
```

Muestra:
```
Session cost: $0.47
  Input tokens:  45,231 ($0.14)
  Output tokens: 12,456 ($0.19)
  Cache hits:    38,200 (saved $0.10)

  Total API calls: 23
  Session duration: 45 min
```

Usa `/cost` regularmente para desarrollar intuición sobre qué operaciones
son caras y cuáles son baratas.

## Resumen: reglas de oro del contexto

1. **El contexto es finito.** Todo lo que entra ocupa espacio y degrada el
   rendimiento gradualmente.

2. **Limpia proactivamente.** No esperes a la auto-compactación. Usa `/clear`
   entre tareas no relacionadas.

3. **Monitoriza constantemente.** Usa `/cost` y la barra de estado para saber dónde
   estás.

4. **Cada línea de CLAUDE.md tiene un coste.** Se carga en cada sesión,
   en cada turno.

5. **Los MCP servers tienen un coste oculto.** Sus definiciones de tools
   consumen contexto aunque no los uses.

6. **El modelo importa.** Sonnet es más barato que Opus (~1.7x diferencia). Usa cada uno
   donde corresponde.

7. **La degradación es gradual e invisible.** No recibes un aviso cuando
   Claude empieza a olvidar cosas. Tú debes prevenirlo.
