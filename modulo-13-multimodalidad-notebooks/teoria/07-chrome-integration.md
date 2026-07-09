# Chrome Integration: Debugging y Extracción de Datos desde el Navegador

> **Estado: Disponibilidad General (GA) desde v2.1.198.** Chrome Integration ya no requiere activación experimental ni consideraciones de disponibilidad limitada: es una capacidad estable del producto, lista para flujos de trabajo diarios.

Claude Code puede trabajar con tu navegador Chrome o Edge en tiempo real: leer errores de consola, inspeccionar el DOM, rellenar formularios y extraer datos de páginas web. Este capítulo explica cómo activar la integración con Chrome y cómo aprovecharla en flujos de desarrollo y testing.

---

## Objetivos de aprendizaje

Al terminar este capítulo serás capaz de:

1. Instalar la extensión "Claude in Chrome" y activar la integración desde Claude Code
2. Usar la integración para debuggear errores de consola y DOM en tiempo real
3. Pedir a Claude que rellene formularios y simule interacciones de usuario
4. Extraer datos estructurados de páginas web con comprensión semántica
5. Grabar GIFs de flujos de usuario para documentación o reportes de bugs
6. Trabajar con apps autenticadas (Google Docs, Notion, etc.) sin exportar datos
7. Conocer las limitaciones de seguridad de la integración

---

## Parte 1: Qué permite Chrome Integration

### Acceso al estado vivo del navegador

La integración con Chrome da a Claude Code acceso en tiempo real a:

| Capacidad | Qué puede ver o hacer Claude |
|-----------|------------------------------|
| Consola del navegador | Errores JavaScript, warnings, logs de la aplicación |
| DOM actual | Estructura HTML, atributos, estado visible de los elementos |
| Estado de la red | Peticiones HTTP, respuestas, errores de CORS, tiempos de carga |
| Formularios | Rellenar campos, seleccionar opciones, enviar formularios |
| Interacciones | Hacer click en elementos, desplazarse, activar estados hover |
| Screenshots | Capturar el estado actual de la página para análisis visual |
| Grabación GIF | Registrar una secuencia de interacciones como animación |

Esta combinación permite a Claude diagnosticar problemas que solo se manifiestan en el navegador, no en el código fuente ni en los logs del servidor.

### Acceso a apps autenticadas

Dado que Claude opera dentro de tu sesión activa de Chrome, tiene acceso a las aplicaciones donde ya estás autenticado:

- Google Docs, Sheets, Slides
- Gmail y Google Calendar
- Notion, Confluence, Linear
- Cualquier aplicación web donde hayas iniciado sesión

Esto elimina la necesidad de exportar datos para analizarlos: Claude puede leer el contenido directamente desde la página sin pasar por APIs ni archivos intermedios.

---

## Parte 2: Requisitos y Activación

### Requisitos

| Requisito | Detalle |
|-----------|---------|
| Extensión | "Claude in Chrome" versión 1.0.36 o superior |
| Navegador | Chrome o Microsoft Edge (basado en Chromium) |
| Autenticación | La extensión debe estar conectada a la misma cuenta claude.ai que Claude Code |

La extensión está disponible en la Chrome Web Store. Tras instalarla, conéctala con tu cuenta claude.ai desde el popup de la extensión.

### Activar la integración

**Al iniciar Claude Code:**

```bash
# Iniciar con Chrome integration activa desde el principio
claude --chrome
```

**Durante una sesión en curso:**

```bash
# Activar la integración en la sesión actual
/chrome

# Desactivar la integración en la sesión actual
/no-chrome
```

**Activar por defecto para todas las sesiones:**

Abre `/config` dentro de Claude Code y activa la opción "Enable Chrome integration by default". Esta preferencia persiste entre sesiones y elimina la necesidad de usar el flag `--chrome` cada vez.

También puedes establecerlo directamente en los settings de usuario:

```json
{
  "chromeIntegrationEnabled": true
}
```

### Qué ocurre al activar la integración

Cuando Claude Code establece la conexión con Chrome, la extensión muestra un indicador visual en el icono de la barra de herramientas del navegador. Claude solo puede interactuar con las pestañas donde el usuario ha dado permiso explícito; el resto de pestañas permanecen inaccesibles.

---

## Parte 3: Casos de Uso Prácticos

### Debuggear errores de consola

El caso de uso más directo: un componente falla en el navegador pero no hay indicación en el código de por qué.

```text
Desarrollador: "¿Por qué falla este formulario de registro? Mira la consola"

Claude accede a la consola del navegador y ve:
  TypeError: Cannot read properties of undefined (reading 'trim')
    at validateEmail (validation.js:23)
    at handleSubmit (RegisterForm.jsx:47)

Claude: "El error está en validation.js línea 23. El campo email llega como
undefined cuando el usuario envía el formulario sin haber tocado ese campo,
porque el estado inicial no inicializa email a string vacío. Aquí tienes la
corrección..."
```

Claude no necesita que describas el error: lo ve directamente y puede correlacionarlo con el código fuente del proyecto.

### Inspeccionar el DOM para debugging visual

Cuando hay diferencias entre el diseño esperado y lo que aparece en pantalla:

```text
"El botón de submit debería estar alineado a la derecha pero aparece centrado.
Revisa el DOM y los estilos computados"

Claude inspecciona el elemento, comprueba los estilos computados y detecta
que un ancestor tiene `text-align: center` heredado de un componente compartido.
```

### Test de formularios

Claude puede rellenar y enviar formularios para validar flujos de la aplicación:

```text
"Prueba el flujo de login con estas credenciales de prueba:
usuario test@ejemplo.com, contraseña Test1234!"

Claude rellena los campos, hace click en el botón de login,
verifica la redirección y reporta si el flujo funcionó correctamente
o si apareció algún error.
```

Esto es útil para smoke tests rápidos sin necesidad de configurar un framework de testing end-to-end completo.

### Extraer datos estructurados (scraping inteligente)

La comprensión semántica de Claude permite extraer datos de tablas, listas o layouts complejos sin necesidad de escribir selectores CSS frágiles:

```text
"Extrae todos los precios de la tabla de planes de precios y guárdalos
en un CSV con columnas: plan, precio_mensual, precio_anual, usuarios_max"
```

Claude entiende el contenido de la página y genera el CSV correctamente aunque la estructura HTML no sea semánticamente perfecta.

### Grabación GIF de flujos de usuario

Para documentar un flujo de usuario o adjuntar evidencia de un bug en un ticket:

```text
"Graba un GIF del proceso de checkout completo, desde el carrito hasta la
confirmación del pedido"
```

Claude ejecuta las interacciones paso a paso y genera un GIF que puedes añadir directamente a la documentación o al reporte del bug.

### Trabajar con contenido de apps autenticadas

```text
"En la hoja de cálculo que tengo abierta en Google Sheets, extrae los datos
de ventas de enero y febrero y genera un resumen comparativo"
```

Claude lee el contenido directamente desde la página sin necesidad de exportar a CSV ni pasar por la API de Google Sheets. Solo tiene acceso a las pestañas para las que el usuario ha dado permiso.

---

## Comparativa con otras formas de interacción con el navegador

| Enfoque | Cuándo usarlo |
|---------|---------------|
| Chrome Integration | Debugging interactivo, apps autenticadas, flujos que requieren ver el estado actual |
| MCP Puppeteer/Playwright | Automatización headless repetible, tests en CI/CD, flujos sin necesidad de sesión activa |
| Computer Use (Claude Cowork) | Control completo del escritorio, aplicaciones nativas, flujos que no son solo web |
| Screenshot + `/image` | Análisis visual estático cuando no necesitas interactuar |

La Chrome Integration es más ágil que configurar Puppeteer para tareas interactivas puntuales, pero no reemplaza los tests automatizados en pipelines de CI/CD.

---

## Limitaciones de seguridad

### Permiso explícito por pestaña

Claude solo puede interactuar con las pestañas donde el usuario ha concedido permiso de forma explícita a través de la extensión. Las demás pestañas son completamente inaccesibles. Esto incluye pestañas con información bancaria, correos personales u otras páginas sensibles donde no has activado el acceso.

### Qué no puede hacer Claude a través de Chrome Integration

- Acceder a ficheros del sistema de ficheros local a través del navegador
- Guardar credenciales o cookies para uso posterior
- Hacer capturas de pestañas sin permiso activo
- Ejecutar extensiones del navegador

### Consideraciones en entornos corporativos

En algunos entornos corporativos, las políticas de gestión de extensiones del navegador (MDM) pueden impedir la instalación de la extensión "Claude in Chrome". Si la extensión está bloqueada por política, el flag `--chrome` no tendrá efecto y Claude Code informará de que no puede establecer la conexión.

---

## Errores comunes

**Error: `Chrome integration not available: extension not found`**

La extensión "Claude in Chrome" no está instalada o no está activa. Instálala desde la Chrome Web Store y verifica que esté habilitada en `chrome://extensions/`.

**Error: la extensión está instalada pero Claude dice que no puede conectar**

Verifica que la extensión está conectada a la misma cuenta claude.ai con la que está autenticado Claude Code. Abre el popup de la extensión y comprueba el estado de la conexión.

**Error: Claude puede ver la consola pero no puede interactuar con la página**

El permiso de interacción se gestiona por pestaña. Haz click en el icono de la extensión en la pestaña donde quieres que Claude interactúe y activa los permisos de esa pestaña.

**Error: el GIF generado está vacío o muestra solo el estado inicial**

Algunas páginas bloquean la captura de pantalla por CSP (Content Security Policy). En ese caso, la grabación GIF no está disponible para esa página. Puedes usar `/screenshot` para capturas individuales si el grabado continuo no funciona.

---

## Puntos clave

- Chrome Integration alcanzó **Disponibilidad General (GA)** en v2.1.198: es una capacidad estable, no experimental
- La extensión "Claude in Chrome" (v1.0.36+) es el requisito previo; sin ella el flag `--chrome` no tiene efecto
- Se activa con `--chrome` al iniciar, `/chrome` durante la sesión, o estableciendo `chromeIntegrationEnabled: true` en los settings
- Claude puede leer errores de consola, inspeccionar el DOM, rellenar formularios, extraer datos y grabar GIFs
- El acceso a apps autenticadas (Google Docs, Notion, etc.) no requiere exportar datos ni configurar APIs
- Por seguridad, Claude solo tiene acceso a las pestañas donde el usuario ha dado permiso explícito; el resto son inaccesibles

---

Este capítulo cierra el bloque de integraciones del módulo M13. Para flujos de automatización más complejos que combinen Chrome Integration con agentes, consulta el módulo [M14 - Claude Agent SDK](../../modulo-14-agent-sdk/README.md).
