# Modulo 03: Contexto y Tokens - La Clave de la Eficiencia

> **Este es el modulo mas importante del curso.** Todo lo que aprendas aqui determinara
> cuanto valor extraes de Claude Code cada dia. Un desarrollador que gestiona bien su
> contexto es 3-5x mas productivo que uno que no lo hace.

## Por que este modulo es critico

Claude Code es extraordinariamente capaz, pero tiene un recurso finito: la **ventana de contexto**.
Cada mensaje, cada archivo leido, cada salida de comando consume parte de ese recurso. Cuando
se llena, el rendimiento se degrada: Claude "olvida" instrucciones, comete errores, y necesita
que le repitas cosas.

La diferencia entre un usuario novato y un experto no esta en conocer mas comandos. Esta en
**gestionar el contexto de forma inteligente**. Este modulo te ensena exactamente como hacerlo.

## Objetivos de aprendizaje

Al completar este modulo seras capaz de:

1. **Entender** que es la ventana de contexto y que la consume
2. **Monitorizar** tu uso de contexto y tokens en tiempo real
3. **Aplicar** las 11 tecnicas fundamentales de ahorro de tokens
4. **Disenar** estrategias de sesion eficientes para distintos tipos de trabajo
5. **Estimar** costes y optimizar el gasto de tu equipo
6. **Elegir** el modelo correcto para cada tipo de tarea
7. **Delegar** trabajo a subagentes para proteger tu contexto principal

## Contenido del modulo

### Teoria

| Archivo | Tema | Tiempo estimado |
|---------|------|-----------------|
| [01-la-ventana-de-contexto.md](teoria/01-la-ventana-de-contexto.md) | Que es el contexto, que lo consume, como funciona la compactacion | 30 min |
| [02-tecnicas-ahorro-tokens.md](teoria/02-tecnicas-ahorro-tokens.md) | 11 tecnicas practicas para reducir consumo de tokens | 40 min |
| [03-estrategias-sesion.md](teoria/03-estrategias-sesion.md) | Cuando usar /clear, /compact, /rewind, subagentes y sesiones paralelas | 20 min |
| [04-prompt-caching-y-optimizacion-de-costes.md](teoria/04-prompt-caching-y-optimizacion-de-costes.md) | Prompt caching automatico, costes por modelo y estrategias de optimizacion | 20 min |
| [05-compaction-api.md](teoria/05-compaction-api.md) | Compaction API (beta): compactacion automatica server-side, hook PostCompact y configuracion | 20 min |

### Ejercicios practicos

| Archivo | Ejercicio | Tiempo estimado |
|---------|-----------|-----------------|
| [01-monitorizar-contexto.md](ejercicios/01-monitorizar-contexto.md) | Aprender a monitorizar y gestionar el contexto | 15 min |
| [02-optimizar-sesion.md](ejercicios/02-optimizar-sesion.md) | Optimizar una sesion larga de programacion | 20 min |

### Ejemplos y referencias

| Archivo | Contenido |
|---------|-----------|
| [comparativa-costes.md](ejemplos/comparativa-costes.md) | Tablas de costes por modelo, estimaciones mensuales, limites de ratio |

## Tiempo total estimado

**2 horas 15 minutos** (100 min teoria + 35 min ejercicios)

## Prerequisitos

- Haber completado el Modulo 01 (Introduccion)
- Haber completado el Modulo 02 (CLI y primeros pasos)
- Tener Claude Code instalado y configurado
- Acceso a un proyecto de codigo real para los ejercicios

## Consejo antes de empezar

Lee este modulo con Claude Code abierto. Prueba cada comando que se menciona
mientras lo lees. La gestion de contexto no se aprende leyendo; se aprende
**practicando y observando** como cambian los numeros.

---

**Siguiente modulo:** [Modulo 04 - Memoria: CLAUDE.md](../modulo-04-memoria-claude-md/README.md)
