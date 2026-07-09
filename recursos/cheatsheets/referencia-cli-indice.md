# Referencia CLI de Claude Code — Índice

> Referencia exhaustiva del CLI de Claude Code, estilo "man page". Cubre todos los modos de ejecución, flags, comandos, atajos, variables de entorno y formatos de salida.
>
> Si buscas un resumen rápido para el día a día, consulta [cheatsheet-general.md](./cheatsheet-general.md).

---

## Qué es esta referencia

Este anexo documenta de forma exhaustiva la interfaz de línea de comandos (CLI) de Claude Code. Está orientado a:

- **Consulta puntual**: encontrar el flag exacto o la variable de entorno que necesitas
- **Aprendizaje profundo**: entender el comportamiento detallado de cada opción
- **Automatización**: construir scripts y pipelines que usen Claude Code de forma no interactiva
- **Depuración**: diagnosticar comportamientos inesperados con información completa

A diferencia del [cheatsheet-general.md](./cheatsheet-general.md), que es una referencia rápida con los comandos más usados, esta referencia incluye todas las opciones documentadas, incluidas las avanzadas y las menos frecuentes.

---

## Ficheros de la referencia

| Fichero | Contenido |
|---------|-----------|
| [referencia-cli-modos-ejecucion.md](./referencia-cli-modos-ejecucion.md) | Modos de ejecución: interactivo, one-shot, headless/pipe, stdin, remoto y teleport |
| [referencia-cli-flags-arranque.md](./referencia-cli-flags-arranque.md) | Todos los flags disponibles al arrancar `claude` (tabla exhaustiva) |
| [referencia-cli-slash-commands.md](./referencia-cli-slash-commands.md) | Todos los slash commands del modo interactivo |
| [referencia-cli-atajos-teclado.md](./referencia-cli-atajos-teclado.md) | Todos los atajos de teclado, con variantes por plataforma |
| [referencia-cli-variables-entorno.md](./referencia-cli-variables-entorno.md) | Todas las variables de entorno que afectan a Claude Code |
| [referencia-cli-formatos-salida.md](./referencia-cli-formatos-salida.md) | Formatos de salida (`--output-format`), JSON Schema y parseo con jq |

---

## Otros recursos de configuración

| Fichero | Contenido |
|---------|-----------|
| [cheatsheet-general.md](./cheatsheet-general.md) | Resumen rápido para el día a día |
| [estructura-carpeta-claude.md](./estructura-carpeta-claude.md) | Estructura completa de `.claude/` y ficheros de configuración |
| [github-actions-claude-code.md](./github-actions-claude-code.md) | Integración con GitHub Actions |

---

## Guía de uso rápido

Para encontrar lo que buscas:

- **"Quiero ejecutar Claude sin interacción"** → [Modo headless](./referencia-cli-modos-ejecucion.md#modo-headless--p)
- **"Qué hace el flag `--permission-mode`"** → [Flags de arranque](./referencia-cli-flags-arranque.md)
- **"Cómo hacer rewind a un punto anterior"** → [Slash commands: /rewind](./referencia-cli-slash-commands.md)
- **"Atajo para cambiar de modelo"** → [Atajos de teclado](./referencia-cli-atajos-teclado.md)
- **"Limitar tokens de pensamiento"** → [Variables de entorno](./referencia-cli-variables-entorno.md)
- **"Parsear la salida JSON con jq"** → [Formatos de salida](./referencia-cli-formatos-salida.md)
- **"Ver todas mis sesiones en background"** → [Modos de ejecución: subcomandos de gestión](./referencia-cli-modos-ejecucion.md#subcomandos-de-gestion) (`claude agents`)
- **"Diagnosticar un problema de configuración aislando CLAUDE.md, plugins y hooks"** → [Modos de ejecución: modo seguro](./referencia-cli-modos-ejecucion.md#modo-seguro---safe-mode) (`--safe-mode`)

---

## Fuentes

- [Documentación oficial CLI](https://code.claude.com/docs/en/cli-reference)
- [Documentación modo interactivo](https://code.claude.com/docs/en/interactive-mode)
- [Documentación de comandos](https://code.claude.com/docs/en/commands)
- [Variables de entorno](https://code.claude.com/docs/en/env-vars)
- [Configuración y settings](https://code.claude.com/docs/en/settings)
