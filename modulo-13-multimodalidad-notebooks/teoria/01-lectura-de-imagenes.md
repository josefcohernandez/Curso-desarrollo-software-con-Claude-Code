# Claude Code como LLM Multimodal: Lectura de Imágenes

Claude Code no es un asistente de texto puro: es un LLM multimodal capaz de procesar imágenes y razonar sobre su contenido de la misma forma que razona sobre código o texto. Este capítulo explica cómo aprovechar esa capacidad en el trabajo diario de desarrollo.

---

## Conceptos clave

### Claude Code "ve" imágenes

La herramienta `Read` de Claude Code soporta ficheros de imagen y los presenta visualmente al modelo cuando los lee. Esto tiene una consecuencia práctica importante: **no necesitas describir lo que ves**. Si tienes un mockup, un screenshot o un diagrama, puedes dárselo directamente a Claude y pedirle que actúe sobre él.

### Formatos soportados

Claude Code acepta los siguientes formatos de imagen a través de la herramienta `Read`:

| Formato | Extensión | Notas |
|---------|-----------|-------|
| PNG | `.png` | Recomendado para screenshots y diagramas |
| JPEG | `.jpg`, `.jpeg` | Recomendado para fotografías y mockups exportados |
| GIF | `.gif` | Solo el primer fotograma si es animado |
| WebP | `.webp` | Formato moderno, bien soportado |

No se soportan SVG, BMP, TIFF ni formatos de imagen vectorial de forma nativa. Si necesitas analizar un SVG, expórtalo a PNG primero.

---

## Cómo proporcionar imágenes a Claude Code

Hay tres formas de incluir imágenes en una sesión:

### Opción 1: Arrastrar al CLI

En la mayoría de terminales y en el editor de VS Code con la extensión de Claude Code, puedes arrastrar un fichero de imagen directamente a la ventana del CLI. La imagen se adjunta al mensaje y Claude la ve al procesarlo.

```
[Arrastra screenshot.png a la ventana del CLI]
> Genera el CSS necesario para que esta pantalla quede idéntica al mockup.
```

### Opción 2: Pegar desde el portapapeles

Si hiciste un screenshot (por ejemplo con `Cmd+Shift+4` en macOS o `PrtSc` en Windows/Linux), puedes pegarlo directamente en el CLI con `Ctrl+V` o `Cmd+V`. Claude recibirá la imagen pegada.

> **Novedad v3.0:** Las imágenes pegadas ahora insertan chips `[Image #N]` en el texto del prompt. Esto permite referenciar imágenes por posición cuando pegas varias: "En la [Image #1] veo un botón rojo, pero en la [Image #2] es azul — ¿cuál prefieres?"

```
[Cmd+Shift+4 para capturar un área de la pantalla]
[Cmd+V para pegar en el CLI de Claude Code]
> ¿Qué componentes de React necesito para recrear esta interfaz?
```

### Opción 3: Referenciar un fichero con @

Esta es la forma más explícita y reproducible. Usa `@ruta/al/fichero.png` en tu mensaje para que Claude lea y analice el fichero:

```
> Analiza el diagrama en @docs/arquitectura.png y explica el flujo de datos entre servicios.
```

```
> Compara el mockup en @diseno/checkout-v2.png con la implementación actual en @src/pages/Checkout.tsx
```

La referencia con `@` es especialmente útil en scripts o cuando quieres que la acción quede documentada en el historial de la sesión.

---

## Ejemplos prácticos

### Ejemplo 1: Generar CSS desde un mockup

Tienes un mockup en `diseno/tarjeta-producto.png` y quieres que coincida con el componente actual:

```
> Lee @diseno/tarjeta-producto.png y genera el CSS necesario en src/components/ProductCard.css
> para que el componente coincida exactamente con el mockup. Presta atención a:
> - Espaciados y padding
> - Tipografía (familia, peso, tamaño)
> - Colores (extrae los valores hex si los ves claramente)
> - Bordes y sombras
```

Claude examinará la imagen y escribirá el CSS directamente en el fichero.

### Ejemplo 2: Documentar un diagrama de arquitectura

Tienes un diagrama de arquitectura exportado de Lucidchart o draw.io:

```
> Analiza @docs/arquitectura-microservicios.png. Describe:
> 1. Los servicios presentes y su responsabilidad aparente
> 2. Las conexiones entre servicios (síncronas vs asíncronas si se distinguen)
> 3. Los puntos potenciales de fallo único (SPOF)
> 4. Genera docs/ARQUITECTURA.md con esta información
```

### Ejemplo 3: Comparar mockup con implementación

Tienes un screenshot del estado actual de la app y el mockup original:

```
> Compara @diseno/mockup-dashboard.png con @screenshots/dashboard-actual.png.
> Lista las diferencias visuales: elementos faltantes, espaciados incorrectos,
> colores distintos. Ordena por impacto visual (mayor a menor).
```

### Ejemplo 4: Analizar un error de interfaz

Un usuario reportó un bug visual. Tienen un screenshot:

```
> El usuario reporta este problema: @bugs/reporte-ui-123.png
> Identifica qué elemento visual está mal y busca la causa en src/components/.
> Propone un fix.
```

---

## Errores comunes

**Error: Proporcionar imágenes de baja resolución para código**

Si el mockup tiene menos de 800px de ancho, Claude puede no distinguir tipografía, colores exactos ni espaciados pequeños. Usa siempre imágenes a resolución de pantalla o superior.

**Error: Esperar precisión perfecta en colores**

Claude puede identificar colores aproximados ("un azul oscuro, probablemente #1A3A5C"), pero no tiene acceso a cuentagotas. Si necesitas colores exactos, obtenlos del fichero de diseño original (Figma, Sketch) o usa una herramienta de captura de color.

**Error: Imágenes muy complejas sin punto de enfoque**

Si proporcionas un screenshot de toda la aplicación y pides "genera el código", Claude generará algo, pero el resultado será menos preciso que si acortas la imagen al componente específico que te interesa. Recorta o usa capturas parciales.

**Error: Usar imágenes para información que ya está en texto**

Si tienes un log de error, una traza de stack o un mensaje de consola, cópialo como texto en lugar de hacer un screenshot. El texto es más fácil de procesar con precisión que leer caracteres en una imagen.

---

## Resumen

- Claude Code es multimodal: puede ver y razonar sobre imágenes PNG, JPG, GIF y WebP
- Hay tres formas de proporcionar imágenes: arrastrar, pegar desde portapapeles o referenciar con `@`
- Los casos de uso más útiles son: generar código desde mockups, documentar diagramas, comparar diseño con implementación y analizar bugs visuales
- Las limitaciones principales son: resolución baja, precisión de colores y complejidad excesiva
- Cuando la información es texto (logs, traces), es mejor copiarla que hacer screenshot
