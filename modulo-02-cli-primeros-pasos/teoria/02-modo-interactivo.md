# 02 - Modo Interactivo y Slash Commands

## Introducción

El modo interactivo es el modo principal de Claude Code. Abres una sesión conversacional
donde puedes dar instrucciones, Claude ejecuta acciones y tú revisas los resultados.

---

## Iniciar una Sesión Interactiva

```bash
cd /ruta/a/tu/proyecto
claude                    # Sesión nueva
claude --resume           # Continuar última sesión
claude --resume <id>      # Continuar sesión específica
```

Al iniciar, Claude Code:
1. Lee archivos CLAUDE.md del proyecto (si existen)
2. Carga configuración de `.claude/settings.json`
3. Conecta servidores MCP configurados
4. Muestra el prompt interactivo `>`

---

## Atajos de Teclado

| Atajo | Acción |
|-------|--------|
| `Enter` | Enviar mensaje |
| `Shift+Enter` / `\` | Nueva línea (no enviar) |
| `Shift+Tab` | Alternar modo Plan / Normal |
| `Tab` | Seleccionar sugerencia / autocompletar archivos |
| `Esc` | Cancelar operación en curso |
| `Esc (doble)` | Salir de la sesión |
| `Ctrl+C` | Cancelar / Interrumpir |
| `Alt+T` | Toggle Extended Thinking |
| `Ctrl+L` | Limpiar pantalla (no contexto) |
| `Ctrl+O` | Alternar entre vista normal y transcript detallado (verbose) |

> **Nota (v2.1.110):** `Ctrl+O` ya no activa la "focus view". A partir de esta versión, `Ctrl+O` alterna únicamente entre la vista normal y el transcript detallado de la conversación. La focus view se activa ahora con el comando `/focus`.

---

## Slash Commands

Los slash commands son acciones integradas que no consumen tokens de la API.

> **Tip:** El comando `/powerup` (v2.1.90) ofrece **lecciones interactivas con demos animadas** de las funcionalidades de Claude Code. Es una forma rápida de descubrir features que quizás no conocías. Ejecuta `/powerup` desde el prompt interactivo para explorar las lecciones disponibles.

### Comandos de Sesión

| Comando | Descripción |
|---------|------------|
| `/clear` | Limpiar contexto completo. Esencial entre tareas. |
| `/compact [instrucción]` | Resumir conversación. Opcionalmente con foco. |
| `/exit` | Salir de la sesión |
| `/resume` | Continuar sesión anterior |
| `/rewind` | Deshacer el último turno de la conversación |
| `/undo` | Alias de `/rewind` (v2.1.108) |
| `/recap` | Generar un resumen del trabajo realizado en la sesión actual (v2.1.108) |
| `/logout` | Cerrar sesión de Claude Code (desautentica el cliente) |
| `/cd <ruta>` | Mueve la sesión activa a un nuevo directorio de trabajo sin perder el contexto ni romper el prompt cache (v2.1.169). Ver detalle más abajo |

### Comandos de Información

| Comando | Descripción |
|---------|------------|
| `/help` | Mostrar ayuda |
| `/usage` | Ver el coste y estadísticas de la sesión: tokens consumidos, coste estimado en USD y más métricas (v2.1.118). Fusiona los anteriores `/cost` y `/stats` |
| `/cost` | Atajo a la pestaña de coste dentro de `/usage` (sigue funcionando) |
| `/model` | Ver o cambiar modelo actual |
| `/doctor` | Chequeo completo de configuración, conexión, permisos, plugins, skills, hooks y servidores MCP. Diagnostica **y repara**. Desde v2.1.105, muestra iconos de estado y ofrece la opción `f` para que Claude repare automáticamente los problemas detectados. Desde v2.1.205 el chequeo es más exhaustivo (cubre más componentes de la instalación) |
| `/checkup` | Alias nuevo de `/doctor` (v2.1.205). Mismo comportamiento; ambos nombres son intercambiables |
| `/status` | Estado de la sesión |

### Comandos de Configuración

| Comando | Descripción |
|---------|------------|
| `/init` | Crear archivo CLAUDE.md del proyecto |
| `/permissions` | Ver/modificar permisos |
| `/mcp` | Ver servidores MCP activos |
| `/config` | Ver configuración actual |
| `/memory` | Gestionar memoria automática |

### Comandos de Modo y Visualización

| Comando | Descripción |
|---------|------------|
| `/plan` | Activar modo planificación |
| `/focus` | Activar focus view: oculta elementos secundarios y centra la pantalla en la respuesta de Claude (v2.1.110) |
| `/tui fullscreen` | Cambiar el modo de renderizado a pantalla completa sin parpadeo (flicker-free), en la misma sesión sin reiniciar (v2.1.110) |
| `Shift+Tab` | Alternar Plan/Normal (atajo) |

### Comandos de Apariencia

| Comando | Descripción |
|---------|------------|
| `/theme` | Cambiar o crear temas de color |
| `/recap` | Mostrar resumen del estado de la sesión actual |

---

## Autocompletado de Slash Commands: Rellenar vs. Ejecutar

> **Cambio de comportamiento (v2.1.162)**

Antes de la v2.1.162, hacer clic en un slash command del menú de autocompletado lo **ejecutaba directamente**. A partir de esta versión, el clic solo **rellena el comando en el prompt**; tienes que pulsar `Enter` para ejecutarlo.

```
> /rec        ← escribes parte del comando
  /recap      ← aparece en el menú de autocompletado
  /resume

[clic en /recap]  → el prompt queda como "> /recap" (sin ejecutar)
[Enter]           → ahora sí se ejecuta
```

Este cambio evita ejecuciones accidentales al navegar el menú con el ratón o al pulsar Tab varias veces, especialmente en comandos que no admiten deshacerse fácilmente. Si tenías memorizado el flujo anterior (clic = ejecución inmediata), acostúmbrate a confirmar siempre con `Enter`.

---

## Cambiar de Directorio con `/cd`

> **Novedad v2.1.169**

Hasta ahora, para trabajar en otro directorio dentro de la misma sesión había que salir y volver a lanzar `claude` desde la nueva ruta, lo que reiniciaba el prompt cache (el mecanismo que evita reprocesar el system prompt y el contexto estático en cada turno) y encarecía el siguiente mensaje. El comando `/cd` mueve la sesión activa a un nuevo directorio de trabajo **sin** ese coste:

```
> /cd ../otro-proyecto
```

**Cuándo usarlo:**

- Trabajas en un monorepo y necesitas moverte de `packages/api` a `packages/web` sin perder el hilo de la conversación.
- Quieres comparar código entre dos proyectos hermanos sin abrir dos sesiones distintas.
- Prefieres seguir con la misma sesión (y su historial) tras detectar que la tarea en realidad pertenece a otro repositorio.

```
> /cd ../shared-lib
> "Revisa si la función formatCurrency ya existe aquí antes de crearla en el proyecto principal"
```

> **Diferencia con `--add-dir`:** `--add-dir` (ver [01 - Comandos CLI](01-comandos-cli.md)) **añade** un directorio adicional al contexto sin cambiar el directorio principal de trabajo. `/cd` **cambia** el directorio de trabajo activo de la sesión. Usa `--add-dir` cuando necesitas leer de varios sitios a la vez, y `/cd` cuando el foco de trabajo se traslada a otro lugar.

---

## Rewind Avanzado

### Reanudar desde antes de un `/clear` (v2.1.191)

`/rewind` (o su alias `/undo`) tradicionalmente deshacía el último turno de la conversación activa. A partir de la v2.1.191, `/rewind` también puede **reanudar una conversación desde un punto anterior a un `/clear`**. Esto es útil cuando ejecutaste `/clear` por error, o cuando quieres recuperar el contexto de una tarea anterior sin tener que buscarla con `/resume`.

```
> /rewind
```

El selector de `/rewind` muestra los puntos de control disponibles, incluyendo los que quedaron "al otro lado" de un `/clear` previo dentro de la misma sesión.

### Opción "Summarize up to here" (v2.1.141)

El menú de `/rewind` incluye la opción **"Summarize up to here"**, que comprime todo el contexto anterior al punto seleccionado en un resumen, en lugar de descartarlo o mantenerlo íntegro. Es un punto intermedio entre `/compact` (resume toda la conversación) y `/clear` (la elimina por completo): conservas el punto de control exacto que elegiste, pero liberas espacio de contexto de todo lo anterior.

```
> /rewind
  [Selecciona un punto de control]
  → Summarize up to here
```

**Cuándo usar cada opción:**

| Necesitas... | Usa... |
|---|---|
| Deshacer solo el último turno | `/rewind` (sin más) |
| Volver a un punto de control concreto | `/rewind` → selecciona el punto |
| Recuperar contexto de antes de un `/clear` | `/rewind` → selecciona el punto anterior al `/clear` |
| Liberar contexto pero conservar un resumen desde un punto | `/rewind` → "Summarize up to here" |

---

## Modo Bash (`!`)

Escribir `!` al inicio del prompt activa el modo bash: el texto que sigue se ejecuta directamente como comando de shell en lugar de enviarse como mensaje a Claude.

```
> !ls -la src/
> !git status
```

### Autocompletado de rutas en vivo (v2.1.193)

En modo bash, Claude Code ahora ofrece **autocompletado de rutas de fichero en vivo** mientras escribes, igual que en una shell normal. Esto reduce errores de tipeo al referenciar archivos y acelera comandos que combinan varias rutas.

```
> !cat src/comp<TAB>
              → src/components/
```

### Respuesta automática al output (v2.1.186)

Desde la v2.1.186, tras ejecutar un comando `!bash`, Claude **responde automáticamente** al resultado (por ejemplo, interpretando el output de `!git status` y sugiriendo el siguiente paso), en lugar de quedarse a la espera de que tú describas lo que acaba de pasar.

```
> !npm test
  [output del comando]
  [Claude analiza el resultado y comenta si hay tests en fallo, sin que se lo pidas]
```

Si prefieres el comportamiento anterior (ejecutar el comando y esperar tu siguiente instrucción sin comentario automático), desactívalo en `.claude/settings.json`:

```json
{
  "respondToBashCommands": false
}
```

---

## Preguntas Interactivas: `AskUserQuestion`

> **Cambio de comportamiento (v2.1.200)**

Cuando Claude necesita una decisión tuya durante una tarea (por ejemplo, elegir entre dos enfoques de implementación), usa la herramienta interna `AskUserQuestion` para mostrarte opciones y esperar tu respuesta. Antes de la v2.1.200, si no respondías en un tiempo determinado, Claude Code **continuaba automáticamente** con una opción por defecto.

A partir de la v2.1.200, ese comportamiento ya **no** es el predeterminado: Claude espera tu respuesta indefinidamente. Si prefieres el comportamiento anterior (o uno similar, pero explícito), puedes activar un **timeout de inactividad opcional** desde `/config`:

```
> /config
  → Ajusta el timeout de inactividad para AskUserQuestion
```

**Cuándo activar el timeout:** en flujos semi-automatizados donde alguien lanza una tarea y no puede quedarse pendiente de responder preguntas, pero quiere que la sesión progrese igualmente en lugar de bloquearse esperando indefinidamente. En pair programming o revisión activa, lo habitual es dejarlo desactivado (comportamiento por defecto) para no perder ninguna decisión importante.

---

## Llamadas de Herramientas en Paralelo

> **Cambio de comportamiento (v2.1.161)**

Cuando Claude ejecuta varias herramientas en paralelo dentro del mismo turno (por ejemplo, varios comandos `Bash` independientes, o una combinación de `Read` y `Bash`), antes de la v2.1.161 un fallo en **cualquiera** de esas llamadas cancelaba el resto del lote, aunque no tuvieran relación entre sí.

A partir de la v2.1.161, un `Bash` que falla dentro de un lote de llamadas paralelas **ya no cancela** las demás llamadas del mismo lote. Cada herramienta se resuelve de forma independiente y Claude ve el resultado (éxito o error) de cada una por separado.

```
Lote paralelo:
  1. Bash: npm run lint         → falla (exit code 1)
  2. Bash: npm run typecheck    → se ejecuta igualmente
  3. Read: src/index.ts         → se ejecuta igualmente
```

**Por qué importa:** en tareas donde Claude lanza varias comprobaciones independientes a la vez (lint, typecheck, tests, lectura de ficheros), un solo fallo ya no te obliga a repetir todo el lote. Claude recibe el diagnóstico completo de una vez y puede decidir cómo proceder con la información de todas las llamadas, no solo de las que tuvieron éxito antes del fallo.

---

## Modo TUI Fullscreen

El renderizado por defecto de Claude Code puede mostrar pequeños parpadeos (flickering) al actualizar el área de respuesta en terminales rápidas. A partir de la v2.1.110, Claude Code incluye un modo de renderizado alternativo **fullscreen** que elimina este problema.

### Activación manual

```bash
/tui fullscreen
```

Ejecuta este comando en cualquier momento dentro de una sesión activa. El cambio es inmediato y no requiere reiniciar Claude Code ni abrir una sesión nueva.

### Activación por defecto

Para que todas las sesiones arranquen en fullscreen, añade la clave `tui` al fichero `.claude/settings.json` de tu proyecto o a `~/.claude/settings.json` para que aplique globalmente:

```json
{
  "tui": "fullscreen"
}
```

### Desactivar el auto-scroll en fullscreen

En modo fullscreen, el área de respuesta hace scroll automático para seguir la salida de Claude. Si prefieres controlar el scroll manualmente (útil cuando quieres leer una sección sin que el texto siga avanzando), puedes desactivarlo:

```json
{
  "tui": "fullscreen",
  "autoScrollEnabled": false
}
```

> **Cuándo usar fullscreen:** es especialmente útil en terminales con alta tasa de refresco (tmux, Kitty, Alacritty) donde el parpadeo del modo normal resulta molesto. En terminales estándar, ambos modos funcionan igual de bien.

---

## Modos de Operación

### Modo Normal (por defecto)
Claude puede leer archivos, ejecutar comandos y editar código.
Pide confirmación para acciones de escritura según permisos.

### Modo Plan (Shift+Tab o /plan)
Claude **solo propone** cambios sin ejecutarlos.
Ideal para revisar antes de implementar.

### Auto-accept Edits
Acepta automáticamente ediciones de archivos.
Útil cuando confías en las sugerencias y quieres velocidad.

---

## Referenciando Archivos

Puedes referenciar archivos directamente en tus mensajes:

```
> Revisa el archivo src/auth/login.ts
> Compara src/old.js con src/new.js
> Lee el package.json y dime las dependencias
```

Claude Code resuelve rutas relativas al directorio del proyecto.
También puedes arrastrar archivos al terminal en la extensión de VS Code.

---

## Flujo Típico de Trabajo

```
1. claude                           # Iniciar sesión
2. "Implementa endpoint POST /users"  # Dar instrucción
3. [Claude propone y ejecuta]       # Observar
4. "¿Los tests pasan?"              # Verificar
5. /usage                          # Ver consumo y estadísticas
6. /clear                          # Limpiar para nueva tarea
7. "Ahora crea el endpoint GET..."  # Nueva tarea limpia
8. /exit                           # Terminar
```

---

## Modo Fullscreen y Vista de Enfoque

> **Novedad v2.1.110**

### `/tui fullscreen`

El subcomando `/tui fullscreen` activa un modo de pantalla completa sin efecto de parpadeo al renderizar la interfaz. Es equivalente a la variable de entorno `CLAUDE_CODE_NO_FLICKER=1`, pero se puede activar directamente desde el prompt sin reiniciar la sesión.

```
> /tui fullscreen
```

En modo fullscreen también puedes desactivar el auto-scroll automático que sigue la salida de Claude en tiempo real. Esto es útil cuando quieres revisar respuestas anteriores mientras Claude sigue trabajando. La opción se controla con `autoScrollEnabled` en `/config`.

### `/focus`

A partir de v2.1.110, `/focus` es un **comando slash independiente** que alterna la vista de enfoque. Esta vista oculta los elementos secundarios de la interfaz para centrarte en el contenido principal.

```
> /focus
```

Antes de v2.1.110, la vista de enfoque se activaba con `Ctrl+O`. Ese atajo ahora tiene un comportamiento diferente (alternar entre transcripción normal y verbose). Si tenías ese flujo en la memoria muscular, actualiza el hábito: usa `/focus` desde ahora.

---

## Temas Personalizados

> **Novedad v2.1.118**

Claude Code permite crear y cambiar temas de color con nombre mediante el comando `/theme`. Los temas son ficheros JSON almacenados en `~/.claude/themes/` y son editables directamente con cualquier editor de texto.

### Cambiar de tema

```
> /theme
```

El comando abre un selector interactivo con los temas disponibles. También existe la opción **"Auto (match terminal)"** que sincroniza el tema de Claude Code con el modo oscuro o claro configurado en el terminal del sistema operativo.

### Estructura de un tema

Los ficheros de tema viven en `~/.claude/themes/` y siguen la convención `nombre-del-tema.json`:

```json
{
  "name": "mi-tema",
  "colors": {
    "primary": "#61AFEF",
    "secondary": "#98C379",
    "background": "#282C34",
    "text": "#ABB2BF",
    "accent": "#E06C75"
  }
}
```

### Distribución de temas via plugins

Los plugins pueden distribuir temas propios incluyendo una carpeta `themes/` en su paquete. Al instalar el plugin, sus temas quedan disponibles en el selector de `/theme`. Esto permite que los equipos compartan una apariencia consistente de la herramienta junto con las configuraciones del plugin.

---

## Consumo de Tokens en Modo Interactivo

| Evento | Tokens consumidos |
|--------|------------------|
| Inicio de sesión | ~1,000-3,000 (CLAUDE.md, system prompt) |
| Cada mensaje tuyo | ~50-500 (tu texto + overhead) |
| Claude lee un archivo | ~500-5,000 (según tamaño) |
| Claude ejecuta un comando | ~200-2,000 (comando + output) |
| Claude edita un archivo | ~500-2,000 (old + new + contexto) |

> **Tip**: Usa `/usage` frecuentemente para monitorizar el consumo de tokens y el coste estimado de la sesión.
