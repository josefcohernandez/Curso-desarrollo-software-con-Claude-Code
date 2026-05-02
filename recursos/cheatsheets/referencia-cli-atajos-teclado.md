# Referencia CLI — Atajos de teclado

> Documentación exhaustiva de todos los atajos de teclado disponibles en Claude Code, con variantes por plataforma y contexto de uso.

Índice: [referencia-cli-indice.md](./referencia-cli-indice.md)

---

## Nota sobre plataformás y terminales

Los atajos pueden variar según el sistema operativo y el terminal. Para ver los atajos disponibles en tu entorno concreto, pulsa `?` en el prompt interactivo.

**Configuración requerida en macOS para atajos con Option/Alt:**

Los atajos `Option+P`, `Option+T`, `Alt+B`, `Alt+F`, `Alt+Y`, `Alt+M` requieren configurar la tecla Option como Meta en el terminal:

| Terminal | Cómo configurar |
|----------|----------------|
| **iTerm2** | Settings → Profiles → Keys → Left/Right Option key: "Esc+" |
| **Terminal.app** | Settings → Profiles → Keyboard → "Use Option as Meta Key" |
| **VS Code** | Settings → Profiles → Keys → Left/Right Option key: "Esc+" |

Ejecuta `/terminal-setup` en Claude Code para configurar automáticamente los keybindings en terminales que lo requieren (VS Code, Alacritty, Warp, Zed).

---

## Controles generales

| Atajo | Plataforma | Acción | Contexto |
|-------|-----------|--------|---------|
| `Ctrl+C` | Todas | Cancela el input actual o la generación en curso | Siempre |
| `Ctrl+D` | Todas | Sale de Claude Code (señal EOF) | Siempre |
| `Ctrl+X Ctrl+K` | Todas | Termina todos los agentes en segundo plano | Modo interactivo |
| `Ctrl+G` | Todas | Abre el prompt o una respuesta personalizada en el editor de texto por defecto | Modo interactivo |
| `Ctrl+X Ctrl+E` | Todas | Abre el editor externo configurado en `$EDITOR` para redactar el prompt actual. Al guardar y cerrar, el contenido se inserta en el prompt | Prompt |
| `Ctrl+L` | Todas | Limpia la pantalla del terminal (conserva el historial de conversación) | Modo interactivo |
| `Ctrl+O` | Todas | Alterna entre vista normal y transcript detallado (verbose). Ya no activa la focus view; para eso usar el comando `/focus` | Modo interactivo |
| `Ctrl+R` | Todas | Búsqueda inversa en el historial de comandos (búsqueda interactiva) | Prompt |
| `Ctrl+B` | Todas | Mueve comandos o agentes en ejecución al segundo plano. **Usuarios de tmux: pulsar dos veces** | Modo interactivo |
| `Ctrl+T` | Todas | Muestra u oculta la lista de táreas en el área de estado del terminal | Modo interactivo |

---

## Modos de permisos y comportamiento

| Atajo | Plataforma | Acción | Contexto |
|-------|-----------|--------|---------|
| `Shift+Tab` | Todas | Cicla entre modos de permisos: Normal → Auto-Accept → Plan → Normal | Modo interactivo |
| `Alt+M` | Linux/Windows | Cicla entre modos de permisos (configuraciones alternativas) | Modo interactivo |
| `Alt+O` / `Option+O` | Todas | Activa o desactiva el modo rápido (fast mode) | Modo interactivo |
| `Esc` | Todas | Detiene a Claude a mitad de una acción | Mientras Claude trabaja |
| `Esc` + `Esc` | Todas | Abre el menú de rewind: retrocede código y/o conversación a un punto anterior, o resume desde un mensaje | Modo interactivo |

### Modos de permisos al ciclar con Shift+Tab

| Ciclo | Modo | Comportamiento |
|-------|------|----------------|
| Estado inicial | **Normal** (`default`) | Pregunta antes de ejecutar acciónes que modifican el sistema |
| Shift+Tab x1 | **Auto-Accept** (`acceptEdits`) | Acepta ediciónes de ficheros automáticamente, pregunta para Bash |
| Shift+Tab x2 | **Plan** (`plan`) | Solo propone planes, no ejecuta nada |
| Shift+Tab x3 | **Normal** (vuelta al inicio) | — |

> **Nota:** Si tienes modos adicionales habilitados (como `auto` o `bypassPermissions`), estos se añaden al ciclo. El flag `--enable-auto-mode` fue eliminado en v2.1.111; Auto Mode está disponible directamente según el plan.

---

## Modelos y razonamiento

| Atajo | macOS | Linux/Windows | Acción | Contexto |
|-------|-------|--------------|--------|---------|
| `Option+P` | Si | `Alt+P` | Cambia de modelo sin borrar el prompt actual | Prompt |
| `Option+T` | Si | `Alt+T` | Activa/desactiva el modo de extended thinking | Modo interactivo |

**Nota:** `Option+T` / `Alt+T` requiere ejecutar `/terminal-setup` previamente para habilitar el atajo.

---

## Navegación por historial

| Atajo | Plataforma | Acción | Contexto |
|-------|-----------|--------|---------|
| `Flecha arriba` | Todas | Navega hacia atrás en el historial de comandos | Prompt |
| `Flecha abajo` | Todas | Navega hacia adelante en el historial de comandos | Prompt |
| `Ctrl+R` | Todas | Búsqueda inversa interactiva en el historial. Escribe texto, pulsa `Ctrl+R` para más resultados | Prompt |

### Cómo usar la búsqueda inversa con Ctrl+R

1. Pulsa `Ctrl+R` para activar la búsqueda
2. Escribe texto para buscar entre comandos previos (el término se resalta en los resultados)
3. Pulsa `Ctrl+R` de nuevo para ciclar hacia resultados más antiguos
4. `Tab` o `Esc` para aceptar el resultado y seguir editando
5. `Enter` para aceptar y ejecutar el comando inmediatamente
6. `Ctrl+C` para cancelar y restaurar el input original

---

## Entrada de texto multilínea

| Método | Atajo | Plataforma | Notas |
|--------|-------|-----------|-------|
| Escape rápido | `\` + `Enter` | Todas | Funciona en todos los terminales |
| macOS por defecto | `Option+Enter` | macOS | Defecto en macOS |
| Shift+Enter | `Shift+Enter` | iTerm2, WezTerm, Ghostty, Kitty | Funciona sin configuración en estos terminales |
| Line feed | `Ctrl+J` | Todas | Carácter de nueva línea para entrada multilínea |
| Pegar directamente | Pegar | Todas | Para bloques de código o logs largos |

Para que `Shift+Enter` funcione en VS Code, Alacritty, Zed o Warp, ejecuta `/terminal-setup`.

---

## Edición de texto en el prompt

| Atajo | macOS | Linux/Windows | Acción | Contexto |
|-------|-------|--------------|--------|---------|
| `Ctrl+K` | Si | Si | Borra desde el cursor hasta el final de la línea (guarda para pegar) | Prompt |
| `Ctrl+U` | Si | Si | Limpia todo el buffer del prompt (antes solo borraba hasta el inicio de línea). `Ctrl+Y` restaura lo borrado | Prompt |
| `Ctrl+Y` | Si | Si | Restaura el texto borrado con `Ctrl+K` o `Ctrl+U` | Prompt |
| `Alt+Y` (tras Ctrl+Y) | Option+Y | `Alt+Y` | Cicla por el historial de textos pegados | Prompt |
| `Alt+B` | Option+B | `Alt+B` | Mueve el cursor una palabra hacia atrás | Prompt |
| `Alt+F` | Option+F | `Alt+F` | Mueve el cursor una palabra hacia adelante | Prompt |

---

## Navegación por pestañas y diálogos

| Atajo | Plataforma | Acción | Contexto |
|-------|-----------|--------|---------|
| `Flecha izquierda` / `Flecha derecha` | Todas | Cicla por pestañas en diálogos de permisos y menús | Dialogos y menús |

---

## Pegado de imágenes

| Atajo | macOS | Linux/Windows | Acción | Contexto |
|-------|-------|--------------|--------|---------|
| `Ctrl+V` | Si (iTerm2: `Cmd+V`) | `Ctrl+V` (Windows: `Alt+V`) | Pega una imagen desde el portapapeles (o la ruta a un fichero de imagen) | Prompt |

---

## Envío de mensajes

| Atajo | Plataforma | Acción | Contexto |
|-------|-----------|--------|---------|
| `Enter` | Todas | Envia el mensaje al presionar en una línea simple | Prompt |
| `Tab` | Todas | Acepta la sugerencia de prompt mostrada en gris | Prompt con sugerencia activa |
| `Enter` (sobre sugerencia) | Todas | Acepta la sugerencia y la envía inmediatamente | Prompt con sugerencia activa |

---

## Atajos de comandos rápidos en el prompt

| Prefijo | Acción | Ejemplo |
|---------|--------|---------|
| `/` al inicio | Abre el menú de comandos y skills | `/clear` |
| `!` al inicio | Modo bash: ejecuta el comando directamente y añade la salida al contexto | `! npm test` |
| `@` | Dispara el autocompletado de rutas de ficheros | `@src/auth` |
| `Space` (mantener) | Push-to-talk: dictado por voz | Requiere `/voice` activado |

---

## Búsqueda en la transcripción

| Atajo | Plataforma | Acción | Contexto |
|-------|-----------|--------|---------|
| `/` | Todas | Activa la búsqueda interactiva en la transcripción de la sesión. Escribe texto para filtrar mensajes | Modo transcript (historial visible) |
| `n` | Todas | Salta al siguiente resultado de búsqueda | Búsqueda activa en transcript |
| `N` | Todas | Salta al resultado de búsqueda anterior | Búsqueda activa en transcript |

---

## Modo Vim

Activa el modo de edición Vim con `/vim` o configuralo permanentemente en `/config`.

### Cambio de modo

| Comando | Acción | Desde modo |
|---------|--------|-----------|
| `Esc` | Entra en modo NORMAL | INSERT / VISUAL |
| `i` | Inserta antes del cursor | NORMAL |
| `I` | Inserta al inicio de la línea | NORMAL |
| `a` | Inserta después del cursor | NORMAL |
| `A` | Inserta al final de la línea | NORMAL |
| `o` | Abre línea debajo | NORMAL |
| `O` | Abre línea encima | NORMAL |
| `v` | Entra en modo VISUAL (selección carácter a carácter) | NORMAL |
| `V` | Entra en modo VISUAL-LINE (selección de línea completa) | NORMAL |

### Navegación en modo NORMAL

| Comando | Acción |
|---------|--------|
| `h` / `j` / `k` / `l` | Mover izquierda / abajo / arriba / derecha |
| `w` | Siguiente palabra |
| `e` | Final de palabra |
| `b` | Palabra anterior |
| `0` | Inicio de línea |
| `$` | Final de línea |
| `^` | Primer caracter no-blanco |
| `gg` | Inicio del input |
| `G` | Final del input |
| `f{char}` | Salta al siguiente `char` en la línea |
| `F{char}` | Salta al `char` anterior en la línea |
| `t{char}` | Salta justo antes del siguiente `char` |
| `T{char}` | Salta justo después del `char` anterior |
| `;` | Repite el último movimiento f/F/t/T |
| `,` | Repite el último movimiento en sentido inverso |

### Edición en modo NORMAL

| Comando | Acción |
|---------|--------|
| `x` | Borra el caracter bajo el cursor |
| `dd` | Borra la línea |
| `D` | Borra hasta el final de línea |
| `dw` / `de` / `db` | Borra palabra / hasta final / hacia atrás |
| `cc` | Cambia la línea |
| `C` | Cambia hasta el final de línea |
| `cw` / `ce` / `cb` | Cambia palabra / hasta final / hacia atrás |
| `yy` / `Y` | Copia (yank) la línea |
| `yw` / `ye` / `yb` | Copia palabra / hasta final / hacia atrás |
| `p` | Pega después del cursor |
| `P` | Pega antes del cursor |
| `>>` | Aumenta la indentacion |
| `<<` | Reduce la indentacion |
| `J` | Une líneas |
| `.` | Repite el último cambio |

### Operadores en modo VISUAL

En modo VISUAL y VISUAL-LINE, los operadores `d`, `c`, `y` actúan sobre la selección activa:

| Comando | Acción |
|---------|--------|
| `d` | Borra la selección |
| `c` | Cambia la selección (borra e inserta) |
| `y` | Copia (yank) la selección |
| `>` | Aumenta la indentación de la selección |
| `<` | Reduce la indentación de la selección |

### Objetos de texto en modo NORMAL

Funcionan con operadores `d`, `c`, `y`:

| Comando | Acción |
|---------|--------|
| `iw` / `aw` | Interior / alrededor de la palabra |
| `iW` / `aW` | Interior / alrededor de la PALABRA (delimitada por espacios) |
| `i"` / `a"` | Interior / alrededor de comillas dobles |
| `i'` / `a'` | Interior / alrededor de comillas simples |
| `i(` / `a(` | Interior / alrededor de paréntesis |
| `i[` / `a[` | Interior / alrededor de corchetes |
| `i{` / `a{` | Interior / alrededor de llaves |

---

## Voz (push-to-talk)

| Atajo | Plataforma | Acción | Contexto |
|-------|-----------|--------|---------|
| Mantener `Space` | Todas | Dictado por voz (push-to-talk). La transcripción se inserta en el cursor | Requiere `/voice` activado y cuenta Claude.ai |

El atajo de push-to-talk es reconfigurable. Ver [voice dictation](https://code.claude.com/docs/en/voice-dictation) para detalles.

---

## Personalización de keybindings

Puedes personalizar los atajos de teclado con el fichero de configuración:

```
~/.claude/keybindings.json
```

Accede a el directamente con el slash command `/keybindings`.

### Formato del fichero keybindings.json

```json
{
  "keybindings": [
    {
      "key": "ctrl+shift+r",
      "command": "rewind"
    },
    {
      "key": "alt+c",
      "command": "clear"
    }
  ]
}
```

### Notas sobre personalizacion

- Los keybindings personalizados se aplican globalmente a todas las sesiones
- Pueden sobreescribir los atajos por defecto
- El fichero se crea automáticamente si no existe al ejecutar `/keybindings`

---

## Ver también

- [Slash commands](./referencia-cli-slash-commands.md) — Comandos invocables desde el prompt
- [Flags de arranque](./referencia-cli-flags-arranque.md) — `--permission-mode` para iniciar en un modo específico
- [Modos de ejecución](./referencia-cli-modos-ejecucion.md) — Los atajos solo aplican en modo interactivo
