# Módulo 03: Contexto y Tokens

> **Este es el módulo más importante del curso.** Todo lo que aprendas aquí determinará cuánto valor extraes de Claude Code cada día. Un desarrollador que gestiona bien su contexto es entre 3 y 5 veces más productivo que uno que no lo hace.

## Por qué este módulo es crítico

Claude Code es extraordinariamente capaz, pero tiene un recurso finito: la **ventana de contexto**. Cada mensaje, cada archivo leído y cada salida de comando consumen parte de ese recurso. Cuando se llena, el rendimiento se degrada: Claude "olvida" instrucciones, comete errores y necesita que le repitas cosas.

La diferencia entre un usuario novato y un experto no está en conocer más comandos. Está en **gestionar el contexto de forma inteligente**. Este módulo te enseña exactamente cómo hacerlo.

## Objetivos de aprendizaje

Al completar este módulo serás capaz de:

1. **Entender** qué es la ventana de contexto y qué la consume.
2. **Monitorizar** tu uso de contexto y tokens en tiempo real.
3. **Aplicar** las 11 técnicas fundamentales de ahorro de tokens.
4. **Diseñar** estrategias de sesión eficientes para distintos tipos de trabajo.
5. **Estimar** costes y optimizar el gasto de tu equipo.
6. **Elegir** el modelo correcto para cada tipo de tarea.
7. **Delegar** trabajo a subagentes para proteger tu contexto principal.

## Contenido del módulo

### Teoría

| Archivo | Tema | Tiempo estimado |
|---------|------|-----------------|
| [01-la-ventana-de-contexto.md](teoria/01-la-ventana-de-contexto.md) | Qué es el contexto, qué lo consume y cómo funciona la compactación | 30 min |
| [02-tecnicas-ahorro-tokens.md](teoria/02-tecnicas-ahorro-tokens.md) | 11 técnicas prácticas para reducir el consumo de tokens | 40 min |
| [03-estrategias-sesion.md](teoria/03-estrategias-sesion.md) | Cuándo usar `/clear`, `/compact`, `/rewind`, subagentes y sesiones paralelas | 20 min |
| [04-prompt-caching-y-optimizacion-de-costes.md](teoria/04-prompt-caching-y-optimizacion-de-costes.md) | Prompt caching automático, costes por modelo y estrategias de optimización | 20 min |
| [05-compaction-api.md](teoria/05-compaction-api.md) | Compaction API (beta): compactación automática server-side, hook `PostCompact` y configuración | 20 min |

### Ejercicios prácticos

| Archivo | Ejercicio | Tiempo estimado |
|---------|-----------|-----------------|
| [01-monitorizar-contexto.md](ejercicios/01-monitorizar-contexto.md) | Aprender a monitorizar y gestionar el contexto | 15 min |
| [02-optimizar-sesion.md](ejercicios/02-optimizar-sesion.md) | Optimizar una sesión larga de programación | 20 min |

### Ejemplos y referencias

| Archivo | Contenido |
|---------|-----------|
| [comparativa-costes.md](ejemplos/comparativa-costes.md) | Tablas de costes por modelo, estimaciones mensuales y límites de ratio |

## Tiempo total estimado

**2 horas y 15 minutos** (100 min de teoría + 35 min de ejercicios)

## Prerrequisitos

- Haber completado el Módulo 01 (Introducción)
- Haber completado el Módulo 02 (CLI y primeros pasos)
- Tener Claude Code instalado y configurado
- Acceso a un proyecto de código real para los ejercicios

## Consejo antes de empezar

Lee este módulo con Claude Code abierto. Prueba cada comando que se menciona mientras lo lees. La gestión de contexto no se aprende leyendo; se aprende **practicando y observando** cómo cambian los números.

---

**Siguiente módulo:** [Módulo 04 - Memoria: CLAUDE.md](../modulo-04-memoria-claude-md/README.md)

---

## Navegación

| Anterior | Siguiente |
|----------|-----------|
| [Módulo 02: CLI y Primeros Pasos](../modulo-02-cli-primeros-pasos/README.md) | [Módulo 04: Memoria y CLAUDE.md](../modulo-04-memoria-claude-md/README.md) |
