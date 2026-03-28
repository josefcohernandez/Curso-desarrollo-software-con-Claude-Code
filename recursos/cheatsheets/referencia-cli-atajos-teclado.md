# Referencia CLI — Atajos de teclado

> Documentacion exhaustiva de todos los atajos de teclado disponibles en Claude Code, con variantes por plataforma y contexto de uso.

Indice: [referencia-cli-indice.md](./referencia-cli-indice.md)

---

## Nota sobre plataformas y terminales

Los atajos pueden variar segun el sistema operativo y el terminal. Para ver los atajos disponibles en tu entorno concreto, pulsa `?` en el prompt interactivo.

**Configuracion requerida en macOS para atajos con Option/Alt:**

Los atajos `Option+P`, `Option+T`, `Alt+B`, `Alt+F`, `Alt+Y`, `Alt+M` requieren configurar la tecla Option como Meta en el terminal:

| Terminal | Como configurar |
|----------|----------------|
| **iTerm2** | Settings → Profiles → Keys → Left/Right Option key: "Esc+" |
| **Terminal.app** | Settings → Profiles → Keyboard → "Use Option as Meta Key" |
| **VS Code** | Settings → Profiles → Keys → Left/Right Option key: "Esc+" |

Ejecuta `/terminal-setup` en Claude Code para configurar automaticamente los keybindings en terminales que lo requieren (VS Code, Alacritty, Warp, Zed).

---

## Controles generales

| Atajo | Plataforma | Accion | Contexto |
|-------|-----------|--------|---------|
| `Ctrl+C` | Todas | Cancela el input actual o la generacion en curso | Siempre |
| `Ctrl+D` | Todas | Sale de Claude Code (senial EOF) | Siempre |
| `Ctrl+X Ctrl+K` | Todas | Termina todos los agentes en segundo plano | Modo interactivo |
| `Ctrl+G` | Todas | Abre el prompt o una respuesta personalizada en el editor de texto por defecto | Modo interactivo |
| `Ctrl+X Ctrl+E` | Todas | Abre el editor externo configurado en `$EDITOR` para redactar el prompt actual. Al guardar y cerrar, el contenido se inserta en el prompt | Prompt |
| `Ctrl+L` | Todas | Limpia la pantalla del terminal (conserva el historial de conversacion) | Modo interactivo |
| `Ctrl+O` | Todas | Alterna el output verbose (muestra el uso detallado de herramientas y ejecucion) | Modo interactivo |
| `Ctrl+R` | Todas | Busqueda inversa en el historial de comandos (busqueda interactiva) | Prompt |
| `Ctrl+B` | Todas | Mueve comandos o agentes en ejecucion al segundo plano. **Usuarios de tmux: pulsar dos veces** | Modo interactivo |
| `Ctrl+T` | Todas | Muestra u oculta la lista de tareas en el area de estado del terminal | Modo interactivo |

---

## Modos de permisos y comportamiento

| Atajo | Plataforma | Accion | Contexto |
|-------|-----------|--------|---------|
| `Shift+Tab` | Todas | Cicla entre modos de permisos: Normal → Auto-Accept → Plan → Normal | Modo interactivo |
| `Alt+M` | Linux/Windows | Cicla entre modos de permisos (configuraciones alternativas) | Modo interactivo |
| `Alt+O` / `Option+O` | Todas | Activa o desactiva el modo rapido (fast mode) | Modo interactivo |
| `Esc` | Todas | Detiene a Claude a mitad de una accion | Mientras Claude trabaja |
| `Esc` + `Esc` | Todas | Abre el menu de rewind: retrocede codigo y/o conversacion a un punto anterior, o resume desde un mensaje | Modo interactivo |

### Modos de permisos al ciclar con Shift+Tab

| Ciclo | Modo | Comportamiento |
|-------|------|----------------|
| Estado inicial | **Normal** (`default`) | Pregunta antes de ejecutar acciones que modifican el sistema |
| Shift+Tab x1 | **Auto-Accept** (`acceptEdits`) | Acepta ediciones de ficheros automaticamente, pregunta para Bash |
| Shift+Tab x2 | **Plan** (`plan`) | Solo propone planes, no ejecuta nada |
| Shift+Tab x3 | **Normal** (vuelta al inicio) | — |

> **Nota:** Si tienes modos adicionales habilitados (como `auto` con `--enable-auto-mode` o `bypassPermissions`), estos se añaden al ciclo.

---

## Modelos y razonamiento

| Atajo | macOS | Linux/Windows | Accion | Contexto |
|-------|-------|--------------|--------|---------|
| `Option+P` | Si | `Alt+P` | Cambia de modelo sin borrar el prompt actual | Prompt |
| `Option+T` | Si | `Alt+T` | Activa/desactiva el modo de extended thinking | Modo interactivo |

**Nota:** `Option+T` / `Alt+T` requiere ejecutar `/terminal-setup` previamente para habilitar el atajo.

---

## Navegacion por historial

| Atajo | Plataforma | Accion | Contexto |
|-------|-----------|--------|---------|
| `Flecha arriba` | Todas | Navega hacia atras en el historial de comandos | Prompt |
| `Flecha abajo` | Todas | Navega hacia adelante en el historial de comandos | Prompt |
| `Ctrl+R` | Todas | Busqueda inversa interactiva en el historial. Escribe texto, pulsa `Ctrl+R` para mas resultados | Prompt |

### Como usar la busqueda inversa con Ctrl+R

1. Pulsa `Ctrl+R` para activar la busqueda
2. Escribe texto para buscar entre comandos previos (el termino se resalta en los resultados)
3. Pulsa `Ctrl+R` de nuevo para ciclar hacia resultados mas antiguos
4. `Tab` o `Esc` para aceptar el resultado y seguir editando
5. `Enter` para aceptar y ejecutar el comando inmediatamente
6. `Ctrl+C` para cancelar y restaurar el input original

---

## Entrada de texto multilinea

| Metodo | Atajo | Plataforma | Notas |
|--------|-------|-----------|-------|
| Escape rapido | `\` + `Enter` | Todas | Funciona en todos los terminales |
| macOS por defecto | `Option+Enter` | macOS | Defecto en macOS |
| Shift+Enter | `Shift+Enter` | iTerm2, WezTerm, Ghostty, Kitty | Funciona sin configuracion en estos terminales |
| Line feed | `Ctrl+J` | Todas | Caracter de nueva linea para entrada multilinea |
| Pegar directamente | Pegar | Todas | Para bloques de codigo o logs largos |

Para que `Shift+Enter` funcione en VS Code, Alacritty, Zed o Warp, ejecuta `/terminal-setup`.

---

## Edicion de texto en el prompt

| Atajo | macOS | Linux/Windows | Accion | Contexto |
|-------|-------|--------------|--------|---------|
| `Ctrl+K` | Si | Si | Borra desde el cursor hasta el final de la linea (guarda para pegar) | Prompt |
| `Ctrl+U` | Si | Si | Borra desde el cursor hasta el inicio de la linea (guarda para pegar) | Prompt |
| `Ctrl+Y` | Si | Si | Pega el texto borrado con Ctrl+K o Ctrl+U | Prompt |
| `Alt+Y` (tras Ctrl+Y) | Option+Y | `Alt+Y` | Cicla por el historial de textos pegados | Prompt |
| `Alt+B` | Option+B | `Alt+B` | Mueve el cursor una palabra hacia atras | Prompt |
| `Alt+F` | Option+F | `Alt+F` | Mueve el cursor una palabra hacia adelante | Prompt |

---

## Navegacion por pestanas y dialogos

| Atajo | Plataforma | Accion | Contexto |
|-------|-----------|--------|---------|
| `Flecha izquierda` / `Flecha derecha` | Todas | Cicla por pestanas en dialogos de permisos y menus | Dialogos y menus |

---

## Pegado de imagenes

| Atajo | macOS | Linux/Windows | Accion | Contexto |
|-------|-------|--------------|--------|---------|
| `Ctrl+V` | Si (iTerm2: `Cmd+V`) | `Ctrl+V` (Windows: `Alt+V`) | Pega una imagen desde el portapapeles (o la ruta a un fichero de imagen) | Prompt |

---

## Envio de mensajes

| Atajo | Plataforma | Accion | Contexto |
|-------|-----------|--------|---------|
| `Enter` | Todas | Envia el mensaje al presionar en una linea simple | Prompt |
| `Tab` | Todas | Acepta la sugerencia de prompt mostrada en gris | Prompt con sugerencia activa |
| `Enter` (sobre sugerencia) | Todas | Acepta la sugerencia y la envia inmediatamente | Prompt con sugerencia activa |

---

## Atajos de comandos rapidos en el prompt

| Prefijo | Accion | Ejemplo |
|---------|--------|---------|
| `/` al inicio | Abre el menu de comandos y skills | `/clear` |
| `!` al inicio | Modo bash: ejecuta el comando directamente y anade la salida al contexto | `! npm test` |
| `@` | Dispara el autocompletado de rutas de ficheros | `@src/auth` |
| `Space` (mantener) | Push-to-talk: dictado por voz | Requiere `/voice` activado |

---

## Busqueda en la transcripcion

| Atajo | Plataforma | Accion | Contexto |
|-------|-----------|--------|---------|
| `/` | Todas | Activa la busqueda interactiva en la transcripcion de la sesion. Escribe texto para filtrar mensajes | Modo transcript (historial visible) |
| `n` | Todas | Salta al siguiente resultado de busqueda | Busqueda activa en transcript |
| `N` | Todas | Salta al resultado de busqueda anterior | Busqueda activa en transcript |

---

## Modo Vim

Activa el modo de edicion Vim con `/vim` o configuralo permanentemente en `/config`.

### Cambio de modo

| Comando | Accion | Desde modo |
|---------|--------|-----------|
| `Esc` | Entra en modo NORMAL | INSERT |
| `i` | Inserta antes del cursor | NORMAL |
| `I` | Inserta al inicio de la linea | NORMAL |
| `a` | Inserta despues del cursor | NORMAL |
| `A` | Inserta al final de la linea | NORMAL |
| `o` | Abre linea debajo | NORMAL |
| `O` | Abre linea encima | NORMAL |

### Navegacion en modo NORMAL

| Comando | Accion |
|---------|--------|
| `h` / `j` / `k` / `l` | Mover izquierda / abajo / arriba / derecha |
| `w` | Siguiente palabra |
| `e` | Final de palabra |
| `b` | Palabra anterior |
| `0` | Inicio de linea |
| `$` | Final de linea |
| `^` | Primer caracter no-blanco |
| `gg` | Inicio del input |
| `G` | Final del input |
| `f{char}` | Salta al siguiente `char` en la linea |
| `F{char}` | Salta al `char` anterior en la linea |
| `t{char}` | Salta justo antes del siguiente `char` |
| `T{char}` | Salta justo despues del `char` anterior |
| `;` | Repite el ultimo movimiento f/F/t/T |
| `,` | Repite el ultimo movimiento en sentido inverso |

### Edicion en modo NORMAL

| Comando | Accion |
|---------|--------|
| `x` | Borra el caracter bajo el cursor |
| `dd` | Borra la linea |
| `D` | Borra hasta el final de linea |
| `dw` / `de` / `db` | Borra palabra / hasta final / hacia atras |
| `cc` | Cambia la linea |
| `C` | Cambia hasta el final de linea |
| `cw` / `ce` / `cb` | Cambia palabra / hasta final / hacia atras |
| `yy` / `Y` | Copia (yank) la linea |
| `yw` / `ye` / `yb` | Copia palabra / hasta final / hacia atras |
| `p` | Pega despues del cursor |
| `P` | Pega antes del cursor |
| `>>` | Aumenta la indentacion |
| `<<` | Reduce la indentacion |
| `J` | Une lineas |
| `.` | Repite el ultimo cambio |

### Objetos de texto en modo NORMAL

Funcionan con operadores `d`, `c`, `y`:

| Comando | Accion |
|---------|--------|
| `iw` / `aw` | Interior / alrededor de la palabra |
| `iW` / `aW` | Interior / alrededor de la PALABRA (delimitada por espacios) |
| `i"` / `a"` | Interior / alrededor de comillas dobles |
| `i'` / `a'` | Interior / alrededor de comillas simples |
| `i(` / `a(` | Interior / alrededor de parentesis |
| `i[` / `a[` | Interior / alrededor de corchetes |
| `i{` / `a{` | Interior / alrededor de llaves |

---

## Voz (push-to-talk)

| Atajo | Plataforma | Accion | Contexto |
|-------|-----------|--------|---------|
| Mantener `Space` | Todas | Dictado por voz (push-to-talk). La transcripcion se inserta en el cursor | Requiere `/voice` activado y cuenta Claude.ai |

El atajo de push-to-talk es reconfgurable. Ver [voice dictation](https://code.claude.com/docs/en/voice-dictation) para detalles.

---

## Personalizacion de keybindings

Puedes personalizar los atajos de teclado con el fichero de configuracion:

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
- El fichero se crea automaticamente si no existe al ejecutar `/keybindings`

---

## Ver tambien

- [Slash commands](./referencia-cli-slash-commands.md) — Comandos invocables desde el prompt
- [Flags de arranque](./referencia-cli-flags-arranque.md) — `--permission-mode` para iniciar en un modo especifico
- [Modos de ejecucion](./referencia-cli-modos-ejecucion.md) — Los atajos solo aplican en modo interactivo
