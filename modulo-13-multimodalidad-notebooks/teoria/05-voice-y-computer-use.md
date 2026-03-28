# /voice y Computer Use: Entrada por Voz y Control Remoto del Escritorio

Claude Code no solo recibe instrucciones tecleadas: desde la versión 2.1.69 permite dictar prompts con la voz, y desde versiones recientes ofrece Remote Control para continuar una sesión local desde cualquier dispositivo. Este capítulo explica ambas capacidades, cómo activarlas y cuándo usarlas.

---

## Objetivos de aprendizaje

Al terminar este capítulo serás capaz de:

1. Activar el modo `/voice` y dictar prompts con push-to-talk
2. Configurar el idioma de dictado y personalizar el keybinding
3. Entender qué es Remote Control y cómo difiere del control de interfaz a nivel de sistema operativo
4. Iniciar una sesión Remote Control y continuarla desde el móvil o el navegador
5. Conocer las limitaciones y consideraciones de seguridad de ambas funciones

---

## Parte 1: /voice — Entrada por voz

### Qué es /voice

`/voice` es un slash command que activa el modo push-to-talk en el CLI de Claude Code. En lugar de teclear el prompt, mantienes pulsada una tecla mientras hablas; al soltarla, tu voz se transcribe y se envía como mensaje. El resultado aparece en el mismo campo de texto que usarías para escribir, por lo que puedes mezclar voz y teclado en el mismo mensaje.

La transcripción ocurre en tiempo real: el texto aparece en el input conforme hablas, algo atenuado hasta que se finaliza. Una vez que sueltas la tecla, el texto se fija en la posición del cursor.

```
> /voice
Voice mode enabled. Hold Space to record. Dictation language: es (/config to change).
```

El modo voice persiste entre sesiones. Para desactivarlo, ejecuta `/voice` de nuevo.

### Requisitos previos

Antes de activar `/voice` verifica que tu entorno cumple estas condiciones:

| Requisito | Detalle |
|-----------|---------|
| Versión mínima | Claude Code v2.1.69 o superior (`claude --version`) |
| Autenticación | Cuenta claude.ai (OAuth). No funciona con API key directa, Amazon Bedrock, Google Vertex AI ni Microsoft Foundry |
| Micrófono local | No disponible en entornos remotos (SSH, Claude Code on the web) |
| Linux (WSL) | Requiere WSLg para acceso a audio. Incluido en WSL2 en Windows 11; en Windows 10 o WSL1, usar Claude Code nativo en Windows |
| Linux (nativo) | Usa módulo nativo; si no carga, hace fallback a `arecord` (ALSA utils) o `rec` (SoX) |

### Cómo funciona el push-to-talk

El mecanismo de detección de tecla mantenida se basa en los eventos de key-repeat del terminal:

1. Mantienes pulsado `Space`
2. El terminal envía eventos de repetición rápida de esa tecla
3. Claude Code detecta el patrón de repetición y activa la grabación
4. El footer muestra `keep holding…` durante el breve calentamiento, luego cambia a una forma de onda en vivo
5. Al soltar, la grabación se detiene y el texto se inserta en el cursor

El calentamiento existe porque el sistema espera confirmar que la tecla se mantiene y no es una pulsación simple. Los primeros caracteres que el terminal emite durante el calentamiento se insertan y se eliminan automáticamente cuando la grabación se activa.

```
> refactor el middleware de auth para ▮
  [mantén Space, habla: "usar el nuevo helper de validación de tokens"]
> refactor el middleware de auth para usar el nuevo helper de validación de tokens▮
```

La transcripción está ajustada para vocabulario de desarrollo: términos como `regex`, `OAuth`, `JSON`, `localhost` o el nombre de tu proyecto y rama git se reconocen correctamente, ya que se añaden como pistas de reconocimiento automáticamente.

### Idiomas soportados

El dictado usa el mismo ajuste `language` que controla el idioma de las respuestas de Claude. Si ese ajuste está vacío, el dictado usa inglés por defecto.

Actualmente están soportados 20 idiomas:

| Idioma | Código |
|--------|--------|
| Checo | `cs` |
| Danés | `da` |
| Neerlandés | `nl` |
| Inglés | `en` |
| Francés | `fr` |
| Alemán | `de` |
| Griego | `el` |
| Hindi | `hi` |
| Indonesio | `id` |
| Italiano | `it` |
| Japonés | `ja` |
| Coreano | `ko` |
| Noruego | `no` |
| Polaco | `pl` |
| Portugués | `pt` |
| Ruso | `ru` |
| Español | `es` |
| Sueco | `sv` |
| Turco | `tr` |
| Ucraniano | `uk` |

Para establecer el idioma, usa `/config` dentro de Claude Code o edita directamente el fichero de ajustes de usuario:

```json
{
  "language": "spanish"
}
```

Puedes usar el código BCP 47 (`es`) o el nombre del idioma en inglés (`spanish`). Si el valor configurado no está en la lista de soportados, `/voice` lo advierte al activarse y recurre al inglés para el dictado; las respuestas de Claude no se ven afectadas.

### Personalizar el keybinding

El keybinding por defecto es `Space`. El problema de usar `Space` es que el calentamiento es necesario para distinguir pulsación simple (espacio en el prompt) de pulsación mantenida (grabar). Para eliminar el calentamiento y activar la grabación en el primer keypress, usa una combinación con modificador.

Edita `~/.claude/keybindings.json`:

```json
{
  "bindings": [
    {
      "context": "Chat",
      "bindings": {
        "meta+k": "voice:pushToTalk",
        "space": null
      }
    }
  ]
}
```

`"space": null` elimina el binding por defecto. Si quieres mantener ambas teclas activas, omite esa línea. Evita asignar letras sueltas como `v`: durante el calentamiento, esas letras se escribirían en el prompt.

### Casos de uso

**Dictado rápido de prompts largos.** Describir verbalmente una tarea compleja es más rápido que teclearla. Útil para instrucciones largas como "explica el flujo de autenticación, identifica los puntos de fallo y propone un refactor manteniendo la interfaz pública".

**Accesibilidad.** Desarrolladores con dificultades para teclear (lesiones de muñeca, síndrome del túnel carpiano) pueden mantener la productividad usando el dictado.

**Manos ocupadas.** Si estás consultando documentación en papel, revisando notas en una pizarra o examinando hardware, puedes hablar con Claude sin necesidad de interactuar con el teclado.

**Iteraciones rápidas en sesiones largas.** Tras una respuesta, el comando de seguimiento suele ser corto ("aplica los cambios", "añade los tests", "muestra el diff"). El push-to-talk reduce la fricción de esas iteraciones.

---

## Parte 2: Remote Control y Computer Use

### Qué es Remote Control

Remote Control es una función que conecta claude.ai/code o la app móvil de Claude (iOS y Android) con una sesión de Claude Code que se ejecuta en tu máquina local. Claude sigue corriendo localmente; el cliente web o móvil es simplemente una ventana hacia esa sesión.

Esto significa que tu sistema de ficheros, servidores MCP, herramientas y configuración de proyecto permanecen disponibles aunque estés enviando instrucciones desde el móvil. La conversación se sincroniza en tiempo real entre todos los dispositivos conectados.

```
tu laptop (terminal con claude) ←→ API Anthropic (HTTPS) ←→ móvil o navegador
```

Remote Control requiere Claude Code v2.1.51 o superior y autenticación con cuenta claude.ai (planes Pro, Max, Team o Enterprise). No está disponible con API key directa.

### Computer Use: control del entorno a nivel de sistema operativo

> **Nota**: Computer Use es una capacidad de **Claude Cowork** (no de Claude Code directamente). Está disponible como research preview, actualmente solo en **macOS**. Claude Cowork permite a Claude interactuar con el escritorio (ratón, teclado, navegador), mientras que Claude Code está enfocado en el terminal y editor de código. Ambos productos comparten la base de Claude pero tienen interfaces y capacidades distintas.

Computer Use es la capacidad de Claude para interactuar con el entorno gráfico del sistema operativo: mover el ratón, hacer clicks, escribir en campos de texto, abrir aplicaciones y usar el navegador. Mientras que Claude Code opera dentro del terminal (ejecuta comandos, edita ficheros, llama a APIs), Computer Use opera a nivel de pantalla, igual que lo haría un usuario humano frente al escritorio.

| Ámbito | Claude Code (herramientas normales) | Computer Use |
|--------|-------------------------------------|--------------|
| Nivel | Terminal, sistema de ficheros, API | Escritorio, UI gráfica, navegador |
| Interacción | Comandos bash, lectura/escritura de ficheros | Clicks, teclado, screenshots de pantalla |
| Visibilidad | Lo que el terminal puede ver | Cualquier elemento visible en pantalla |
| Casos de uso | Desarrollo, automatización de procesos | Testing visual, configuración de entornos con UI |

### Combinar Remote Control con Computer Use

> **Importante**: Remote Control es una funcionalidad de Claude Code, mientras que Computer Use es una funcionalidad de Claude Cowork (solo macOS). Son productos distintos que pueden complementarse pero no están integrados directamente en un mismo flujo. Remote Control permite controlar tu sesión de Claude Code en el terminal desde otro dispositivo; Computer Use permite a Claude Cowork interactuar con la interfaz gráfica del escritorio.

La combinación conceptual más potente sería enviar instrucciones desde el móvil mientras Claude ejecuta tareas en el escritorio de tu laptop. En la práctica, Remote Control te permite continuar usando Claude Code desde otro dispositivo para tareas de terminal, y Computer Use (vía Claude Cowork, solo macOS) permite interactuar con la UI del escritorio de forma independiente.

### Cómo iniciar una sesión Remote Control

Hay tres formas de activar Remote Control:

**Modo servidor (para múltiples conexiones concurrentes):**

```bash
cd /ruta/a/tu/proyecto
claude remote-control --name "Mi Proyecto"
```

El proceso queda a la escucha en el terminal. Muestra una URL de sesión y puedes pulsar `Space` para mostrar un código QR. Flags disponibles:

| Flag | Descripción |
|------|-------------|
| `--name "Título"` | Nombre visible en la lista de sesiones de claude.ai/code |
| `--spawn same-dir` | Todas las sesiones comparten el directorio actual (por defecto) |
| `--spawn worktree` | Cada sesión nueva obtiene su propio git worktree (requiere repo git) |
| `--capacity N` | Número máximo de sesiones concurrentes (por defecto: 32) |
| `--sandbox` | Activa aislamiento de sistema de ficheros y red |

**Sesión interactiva con Remote Control habilitado:**

```bash
claude --remote-control "Mi Proyecto"
# o la forma corta:
claude --rc "Mi Proyecto"
```

Esto abre una sesión interactiva normal en el terminal que también es accesible remotamente. Puedes escribir mensajes localmente mientras otros dispositivos también están conectados.

**Desde una sesión ya en curso:**

```
/remote-control Mi Proyecto
# o la forma corta:
/rc Mi Proyecto
```

Esto transforma la sesión actual en una sesión Remote Control, manteniendo el historial de conversación.

**Habilitar Remote Control para todas las sesiones** (persistente):

Abre `/config` dentro de Claude Code y activa "Enable Remote Control for all sessions", o edita el fichero de ajustes de usuario:

```json
{
  "remoteControlEnabled": true
}
```

### Conectar desde otro dispositivo

Una vez activa la sesión, para conectar desde un dispositivo remoto:

1. **Abre la URL de sesión** en cualquier navegador — va directamente a claude.ai/code con esa sesión activa
2. **Escanea el código QR** (con `claude remote-control`, pulsa `Space` para mostrarlo) para abrir en la app de Claude
3. **Abre claude.ai/code** o la app de Claude y busca la sesión por nombre en la lista (icono de ordenador con punto verde)

### Casos de uso de Remote Control

**Continuar trabajo al alejarte del escritorio.** Iniciaste una refactorización grande, tienes que ir a una reunión. Con `/rc`, puedes seguir enviando instrucciones y revisando el progreso desde el móvil.

**Testing visual con Computer Use.** Pides a Claude que abra el navegador, navegue a la versión de staging de la app, compruebe que los elementos visuales coinciden con el mockup y reporte las diferencias. Claude puede hacer screenshots de la pantalla, analizarlos y actuar sobre ellos.

**Automatización de flujos de UI.** Hay herramientas sin API que solo se pueden usar a través de su interfaz gráfica. Claude puede operar esas interfaces directamente: rellenar formularios, navegar menús, exportar datos.

**Configuración de entornos.** Instalar y configurar software que requiere pasos en la UI del sistema operativo (asistentes de instalación, configuración de preferencias del sistema, activación de licencias).

**Delegación asíncrona.** Usando la app móvil con Dispatch, puedes enviar una tarea desde el teléfono y que Claude la ejecute en tu desktop mientras haces otra cosa. Ver la comparativa en la sección de limitaciones.

### Seguridad y consideraciones

**Arquitectura de seguridad.** Tu sesión local solo hace peticiones HTTPS salientes; nunca abre puertos entrantes. Todo el tráfico pasa por la API de Anthropic sobre TLS, igual que cualquier sesión normal de Claude Code. El código, los ficheros y los servidores MCP nunca salen de tu máquina; solo los mensajes de chat se transmiten por el canal cifrado.

**Credenciales de corta duración.** La conexión usa múltiples credenciales de corta vida, cada una limitada a un único propósito y con expiración independiente.

**Exposición de la URL de sesión.** Si la URL de sesión queda expuesta, cualquiera con esa URL puede enviar comandos a tu sesión local. El radio de acción está limitado a lo que Claude Code puede hacer (acceso al sistema de ficheros, comandos de shell, servidores MCP configurados), que es considerable. No compartas las URLs de sesión.

**Fatiga de aprobación.** Claude Code pide confirmación antes de operaciones sensibles, pero si estás aceptando rápidamente desde el móvil, es fácil aprobar algo sin revisarlo. Revisa las herramientas que Claude va a ejecutar antes de aprobarlas, especialmente en sesiones Remote Control.

**Política organizativa.** En planes Team y Enterprise, Remote Control está desactivado por defecto. Un administrador debe habilitarlo en la configuración de Claude Code del panel de administración. Si tu organización tiene configuraciones de retención de datos o compliance incompatibles, Remote Control puede no estar disponible.

Para entornos donde quieres limitar el acceso al sistema de ficheros y la red durante una sesión Remote Control, usa el flag `--sandbox`:

```bash
claude remote-control --sandbox --name "Sesión Aislada"
```

### Limitaciones actuales

| Limitación | Detalle |
|------------|---------|
| Una sesión remota por proceso interactivo | Fuera del modo servidor, cada instancia de Claude Code soporta una sesión remota a la vez. Usa `--spawn` en modo servidor para múltiples sesiones concurrentes |
| El terminal debe permanecer abierto | Remote Control corre como proceso local. Si cierras el terminal, la sesión termina |
| Corte de red prolongado | Si la máquina está encendida pero sin red durante más de ~10 minutos, la sesión expira |
| Autenticación requerida | No disponible con API key, Amazon Bedrock, Google Vertex AI ni Microsoft Foundry |

---

## Comparativa: enfoques para trabajar fuera del terminal

Remote Control es uno de varios enfoques disponibles para continuar trabajo cuando no estás en el terminal:

| Enfoque | Quién dispara la tarea | Dónde corre Claude | Mejor para |
|---------|------------------------|-------------------|------------|
| Remote Control | Tú, desde otro dispositivo | Tu máquina (CLI o VS Code) | Continuar trabajo en curso desde otro dispositivo |
| Dispatch (app móvil + Desktop) | Tú, mensaje desde el móvil | Tu máquina (Desktop) | Delegar trabajo mientras estás fuera, setup mínimo |
| Channels (Telegram, Discord...) | Eventos externos | Tu máquina (CLI) | Reaccionar a eventos de CI, mensajes de equipo |
| Claude Code on the web | Tú, desde el navegador | Infraestructura Anthropic | Tareas sin necesidad de configuración local |
| Scheduled tasks | Un horario | CLI, Desktop o nube | Automatización recurrente |

---

## Errores comunes

**Error: `/voice` no responde al mantener Space**

Comprueba si `voice` está activado. Si siguen apareciendo espacios en el prompt sin que se active la grabación, ejecuta `/voice` para activarlo. Si aparecen 1-2 espacios y luego nada, `voice` está activo pero el terminal no envía eventos de key-repeat. Verifica que key-repeat no esté desactivado a nivel del sistema operativo.

**Error: el dictado transcribe en inglés aunque el idioma configurado es otro**

El ajuste `language` en los settings de usuario puede estar vacío o con un valor no soportado. Ejecuta `/config` y verifica el valor. Si el idioma no está en la lista de 20 soportados, Claude Code hace fallback automático al inglés con un aviso.

**Error: `Voice mode requires a Claude.ai account`**

Estás autenticado con una API key directa o un proveedor de terceros. Ejecuta `/login` para autenticarte con una cuenta claude.ai.

**Error: Remote Control no se activa (`Remote Control is not yet enabled for your account`)**

Comprueba si tienes `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC`, `DISABLE_TELEMETRY`, `CLAUDE_CODE_USE_BEDROCK` u otras variables de entorno de proveedor de terceros. Elimínalas y vuelve a intentarlo. Si persiste, ejecuta `/logout` y luego `/login`.

**Error: sesión Remote Control termina inesperadamente**

El proceso local se cerró o hubo un corte de red de más de ~10 minutos. Vuelve al terminal de la laptop y ejecuta `claude remote-control` de nuevo.

---

## Puntos clave

- `/voice` activa el modo push-to-talk: mantén `Space` para grabar, suelta para enviar. Requiere Claude Code v2.1.69+, cuenta claude.ai y acceso local al micrófono
- El dictado soporta 20 idiomas; usa el ajuste `language` en los settings de usuario o en `/config`
- Para eliminar el calentamiento de `Space`, reasigna el keybinding a una combinación con modificador como `meta+k` en `~/.claude/keybindings.json`
- Remote Control conecta una sesión local con claude.ai/code o la app móvil de Claude sin mover el código a la nube
- Computer Use es una capacidad de **Claude Cowork** (no de Claude Code), disponible como research preview solo en **macOS**. Opera a nivel de escritorio (ratón, teclado, navegador, UI gráfica), mientras que las herramientas normales de Claude Code operan dentro del terminal
- Remote Control (Claude Code) y Computer Use (Claude Cowork) son productos distintos que pueden complementarse pero no están integrados directamente
- Remote Control solo hace peticiones HTTPS salientes; nunca abre puertos entrantes
- Limitaciones clave: el terminal debe permanecer abierto, un corte de red de ~10 min expira la sesión, requiere cuenta claude.ai

---

Este capítulo cierra el bloque de capacidades multimodales de M13. Los patrones de Remote Control con Computer Use se retoman en el M14 (Agent SDK), donde se orquesta Claude como agente con acceso a herramientas de nivel de sistema.
