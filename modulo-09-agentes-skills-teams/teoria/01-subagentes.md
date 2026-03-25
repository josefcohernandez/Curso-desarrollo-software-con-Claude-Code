# 01 - Subagentes en Profundidad

## Qué son los Subagentes

Un **subagente** es un asistente de IA especializado que Claude Code lanza en su **propia ventana de contexto**, separada de la conversación principal. Piensa en ellos como "trabajadores" a los que el agente principal delega tareas específicas.

### Analogía

Imagina que eres un arquitecto de software (el agente principal). En lugar de leer personalmente cada archivo de un repositorio de 500 archivos, envías a un asistente junior (subagente) a que investigue y te traiga un resumen. Tu escritorio (ventana de contexto) permanece limpio y organizado.

```
+------------------------------------------+
|        Agente Principal (Tu sesión)       |
|                                           |
|  "Necesito saber cómo funciona el auth"   |
|                                           |
|  +------------------------------------+  |
|  | Subagente Explore                   |  |
|  | - Lee auth/login.ts                 |  |
|  | - Lee auth/middleware.ts             |  |
|  | - Lee auth/tokens.ts                |  |
|  | - Lee auth/types.ts                 |  |
|  | - Lee tests/auth.test.ts            |  |
|  |                                     |  |
|  | Devuelve: RESUMEN de 200 palabras   |  |
|  +------------------------------------+  |
|                                           |
|  Contexto principal: solo el resumen      |
|  (no los 5 archivos completos)            |
+------------------------------------------+
```

---

## Por qué Usar Subagentes

### 1. Aislamiento de Contexto

Cada subagente tiene su propia ventana de contexto. Cuando lee archivos, ejecuta comandos o procesa datos, todo eso se queda **en su contexto**. Al agente principal solo le llega un resumen.

**Sin subagentes:**
```
Contexto principal: [instrucciones] + [archivo1: 500 líneas] + [archivo2: 300 líneas] +
                    [archivo3: 400 líneas] + [output tests: 200 líneas] = CONTEXTO LLENO
```

**Con subagentes:**
```
Contexto principal: [instrucciones] + [resumen: 50 líneas] = CONTEXTO LIMPIO
```

### 2. Paralelización del Trabajo

Claude Code puede lanzar múltiples subagentes simultáneamente para tareas independientes:

```
Agente Principal
    |
    +---> Subagente 1: "Investiga el módulo de pagos"
    |
    +---> Subagente 2: "Ejecuta los tests de integración"
    |
    +---> Subagente 3: "Revisa la documentación de la API"
    |
    <--- Recibe 3 resúmenes en paralelo
```

### 3. Especialización

Cada tipo de subagente está optimizado para una tarea concreta, con acceso solo a las herramientas que necesita.

---

## Tipos de Subagentes Incorporados

### Explore (Explorador)

El subagente **Explore** es un investigador rápido y de solo lectura. Tiene acceso únicamente a herramientas de búsqueda y lectura:

| Herramienta | Función |
|-------------|---------|
| `Glob` | Buscar archivos por patrón (ej: `**/*.ts`) |
| `Grep` | Buscar contenido dentro de archivos |
| `Read` | Leer el contenido de archivos |

**Características:**
- No puede modificar archivos ni ejecutar comandos
- Muy rápido porque tiene un conjunto reducido de herramientas
- Ideal para investigación y exploración del codebase
- Devuelve un resumen estructurado de lo que encontró

**Casos de uso ideales:**
- "Encuentra todas las funciones que usan la base de datos"
- "¿Cómo está estructurado el módulo de autenticación?"
- "¿Qué dependencias usa este proyecto?"
- "¿Dónde se define la interfaz User?"

**Ejemplo de uso interno (cómo Claude lo invoca):**
```
Task tool call:
  description: "Investigar la estructura del módulo de autenticación"
  subagent_type: "explore"
  prompt: "Encuentra todos los archivos relacionados con autenticación.
           Identifica el flujo de login, los middlewares de auth,
           y cómo se manejan los tokens JWT. Resume la arquitectura."
```

### Plan (Planificador)

El subagente **Plan** actúa como un **arquitecto de software**. Tiene acceso a herramientas de lectura y puede diseñar planes de implementación detallados.

**Características:**
- Acceso de solo lectura al codebase (lee archivos, busca patrones)
- No ejecuta comandos ni modifica archivos
- Devuelve planes paso a paso estructurados
- Excelente para diseñar antes de implementar

**Casos de uso ideales:**
- "Diseña un plan para migrar de REST a GraphQL"
- "¿Cómo debería refactorizar este módulo monolítico?"
- "¿Qué pasos necesito para añadir soporte multi-idioma?"
- "Planifica la implementación de un sistema de caché"

**Ejemplo de uso interno:**
```
Task tool call:
  description: "Diseñar plan de migración de base de datos"
  subagent_type: "plan"
  prompt: "Analiza el esquema actual en src/database/schema.ts y
           las migraciones existentes en migrations/. Diseña un plan
           paso a paso para migrar de PostgreSQL a MySQL, incluyendo
           cambios necesarios en los queries, modelos y configuración."
```

**Ejemplo de salida de un subagente Plan:**
```markdown
## Plan de Migración PostgreSQL -> MySQL

### Fase 1: Preparación (estimado: 2h)
1. Instalar dependencia mysql2 y eliminar pg
2. Crear archivo de configuración para MySQL
3. Adaptar el connection pool en src/database/connection.ts

### Fase 2: Migración de Esquemas (estimado: 4h)
4. Convertir tipos PostgreSQL-específicos:
   - JSONB -> JSON
   - SERIAL -> AUTO_INCREMENT
   - TEXT[] -> tabla de relación
5. Reescribir migraciones en formato MySQL
...
```

### General-Purpose (Propósito General)

El subagente de **propósito general** tiene acceso a **todas las herramientas** disponibles, incluyendo:

- Lectura y escritura de archivos
- Ejecución de comandos bash
- Búsqueda en el codebase
- Todas las demás herramientas del agente principal

**Características:**
- Capacidades completas (puede hacer todo lo que el agente principal)
- Ideal para tareas complejas que requieren múltiples pasos
- Puede modificar código, ejecutar tests, instalar dependencias
- Mayor consumo de tokens por su amplitud de capacidades

**Casos de uso ideales:**
- "Ejecuta los tests y arregla los que fallen"
- "Refactoriza este componente siguiendo el nuevo patrón"
- "Implementa esta feature en un módulo aislado"
- "Genera fixtures de datos para los tests"

**Ejemplo de uso interno:**
```
Task tool call:
  description: "Ejecutar suite de tests y analizar resultados"
  subagent_type: "general-purpose"
  prompt: "Ejecuta 'npm test' y analiza los resultados.
           Si hay tests fallando, identifica la causa raíz
           de cada fallo y sugiere correcciones específicas."
```

---

## Cómo Claude Usa Subagentes Automáticamente

Claude Code utiliza internamente la herramienta **Task** para lanzar subagentes. No necesitas invocarlos manualmente en la mayoría de casos — Claude decide cuándo delegarle trabajo a un subagente basándose en:

1. **Volumen de datos**: si necesita leer muchos archivos, usa un subagente Explore
2. **Complejidad de la tarea**: si la tarea es grande, la delega a un subagente general
3. **Paralelismo**: si hay tareas independientes, lanza múltiples subagentes
4. **Preservación de contexto**: si la salida sería muy grande, la aísla en un subagente

### Parámetro model en Subagentes

Los subagentes aceptan un parámetro `model` que define qué modelo de IA usan:

| Modelo | Uso recomendado | Costo relativo |
|--------|----------------|----------------|
| `haiku` | Tareas simples: búsquedas, lecturas básicas | Bajo |
| `sonnet` | Tareas moderadas: análisis, resúmenes | Medio |
| `opus` | Tareas complejas: planificación, refactoring | Alto |

**Recomendación de optimización de costos:**

```
# Tarea simple -> Haiku (barato y rápido)
Task(subagent_type="explore", model="haiku",
     prompt="Busca dónde se define la función calculateTotal")

# Tarea moderada -> Sonnet (buen balance)
Task(subagent_type="plan", model="sonnet",
     prompt="Diseña un plan para añadir paginación a la API")

# Tarea compleja -> Opus (máxima calidad)
Task(subagent_type="general-purpose", model="opus",
     prompt="Refactoriza el módulo de pagos para soportar múltiples proveedores")
```

---

## El Flujo de Información: Subagente -> Agente Principal

Es crucial entender cómo fluye la información:

```
1. Agente principal ENVÍA instrucciones al subagente
2. Subagente TRABAJA en su propio contexto:
   - Lee archivos (se quedan en SU contexto)
   - Ejecuta comandos (output en SU contexto)
   - Procesa datos (en SU contexto)
3. Subagente DEVUELVE un resumen al agente principal
4. Agente principal RECIBE solo el resumen
```

**Implicación clave:** Si un subagente lee 10 archivos de 500 líneas cada uno (5000 líneas), el agente principal puede recibir un resumen de 50-100 líneas. Esto es una **compresión 50-100x** de la información.

### Qué pasa con el contexto del subagente

Una vez que el subagente termina su tarea:
- Su contexto se **descarta**
- Solo el resumen persiste en el contexto principal
- No hay forma de "volver a consultar" al mismo subagente después
- Si necesitas más información, se lanza un **nuevo** subagente

---

## Agentes Personalizados

Además de los tipos incorporados, puedes crear tus propios agentes personalizados mediante archivos `.md` en el directorio `.claude/agents/`.

### Estructura del Directorio

```
tu-proyecto/
  .claude/
    agents/
      code-reviewer.md      # Agente revisor de código
      test-runner.md         # Agente ejecutor de tests
      security-auditor.md    # Agente auditor de seguridad
      docs-writer.md         # Agente escritor de documentación
```

### `initialPrompt` en frontmatter

> **Novedad v3.0**

Los agentes personalizados pueden declarar un `initialPrompt` en su frontmatter YAML. Cuando el agente se lanza, este prompt se envía automáticamente sin necesidad de que el usuario escriba nada:

```markdown
---
name: daily-standup
description: Recopila el estado del trabajo pendiente
initialPrompt: "Revisa las tareas pendientes en TaskList, el git log de las últimas 24h y genera un resumen para la daily standup"
---
```

Esto es útil para agentes que siempre ejecutan la misma tarea inicial, como auditorías periódicas o reportes de estado.

### Formato del Archivo de Agente

```markdown
# Code Reviewer

Eres un agente especializado en revisión de código. Tu trabajo es:

1. Analizar los cambios en el código (git diff)
2. Identificar problemas potenciales:
   - Bugs lógicos
   - Problemas de rendimiento
   - Vulnerabilidades de seguridad
   - Violaciones de estilo
3. Sugerir mejoras concretas con ejemplos de código
4. Priorizar los hallazgos por severidad (crítico, alto, medio, bajo)

## Reglas
- Sé constructivo, no destructivo
- Proporciona ejemplos de código corregido
- Explica el "por qué" detrás de cada sugerencia
- Considera el contexto del proyecto (no apliques reglas genéricas ciegamente)
```

### Lanzar Agentes Personalizados

Hay varias formas de lanzar un agente personalizado:

```bash
# Desde la línea de comandos con --agent
claude --agent code-reviewer

# Interactivamente con /agent
> /agent code-reviewer "Revisa los últimos cambios en src/auth/"

# Claude también puede lanzarlos automáticamente si detecta que
# un agente personalizado es apropiado para la tarea
```

### Agentes con Memoria Persistente

Los agentes personalizados pueden tener su propia memoria persistente, separada de la memoria del agente principal. Esto les permite:

- Recordar decisiones anteriores entre sesiones
- Mantener un registro de patrones encontrados
- Acumular conocimiento específico de su dominio

---

## Cuándo Usar Subagentes: Guía de Decisión

### USA un subagente cuando:

| Escenario | Tipo recomendado | Razón |
|-----------|-----------------|-------|
| Investigar estructura de un módulo grande | Explore | Evita llenar el contexto con lecturas de archivos |
| Ejecutar tests con output verbose | General-Purpose | El output de tests puede ser enorme |
| Buscar documentación en el codebase | Explore | Búsqueda eficiente sin contaminar contexto |
| Procesar logs extensos | General-Purpose | Los logs pueden tener miles de líneas |
| Tareas paralelas independientes | Múltiples General-Purpose | Acelera el trabajo total |
| Diseñar arquitectura de una feature | Plan | Obtienes un plan estructurado |
| Analizar dependencias del proyecto | Explore | Lectura de muchos package.json, go.mod, etc. |
| Refactorizar un módulo aislado | General-Purpose | Trabajo autocontenido |

### NO uses un subagente cuando:

- La tarea requiere interacción continua contigo
- Necesitas ver el proceso paso a paso
- La tarea es tan simple que el overhead del subagente no se justifica
- Necesitas que el resultado esté en el contexto principal para tareas posteriores

---

## Ejemplo Completo: Investigación con Subagentes

Supongamos que le pides a Claude Code:

> "Quiero añadir autenticación con OAuth2 a mi aplicación Express. Primero investiga cómo está configurado actualmente el auth, y luego diseña un plan de migración."

Claude Code podría hacer internamente:

```
Paso 1: Lanzar subagente Explore
  -> "Investiga todo el sistema de autenticación actual:
      archivos, middlewares, modelos de usuario, rutas protegidas"
  -> Resultado: resumen de la arquitectura auth actual

Paso 2: Lanzar subagente Plan (usando el resumen del paso 1)
  -> "Dado el sistema auth actual [resumen], diseña un plan
      para migrar a OAuth2 con Google y GitHub como proveedores"
  -> Resultado: plan paso a paso de migración

Paso 3: Presentar el plan al usuario en el contexto principal
  (el contexto principal solo contiene los dos resúmenes,
   no los 15+ archivos que se leyeron)
```

---

## Comparativa de Consumo de Contexto

| Acción | Sin subagente | Con subagente |
|--------|--------------|---------------|
| Leer 10 archivos de 200 líneas | +2000 líneas en contexto | +50 líneas (resumen) |
| Ejecutar `npm test` (output largo) | +500 líneas en contexto | +30 líneas (resumen) |
| Buscar patrón en 100 archivos | +3000 líneas en contexto | +40 líneas (resumen) |
| Analizar `git log --oneline -100` | +100 líneas en contexto | +20 líneas (resumen) |

**Total estimado:** ~5600 líneas vs ~140 líneas. Diferencia de **40x**.

---

## Resumen

| Concepto | Descripción |
|----------|-------------|
| Subagente | Asistente con su propia ventana de contexto |
| Explore | Solo lectura: Glob, Grep, Read |
| Plan | Arquitecto: lee codebase, devuelve planes |
| General-Purpose | Capacidades completas |
| Aislamiento | Solo el resumen vuelve al contexto principal |
| Modelo | haiku (barato), sonnet (equilibrado), opus (potente) |
| Agentes custom | `.claude/agents/nombre.md` con frontmatter YAML |
| `initialPrompt` | Prompt automático al lanzar un agente (v3.0) |
| Paralelismo | Múltiples subagentes simultáneos para tareas independientes |

> **Deprecaciones v3.0:**
> - La herramienta `TaskOutput` está deprecada. Usa `Read` sobre el fichero de output de la tarea en su lugar.
> - El parámetro `task.resume` ha sido eliminado. Usa `SendMessage()` para continuar un agente existente (ver [fichero 04](04-aislamiento-worktree-y-comunicacion.md)).
