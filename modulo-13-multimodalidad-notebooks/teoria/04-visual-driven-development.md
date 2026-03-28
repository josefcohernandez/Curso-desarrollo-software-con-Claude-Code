# Visual-Driven Development: de Mockup a Código

Visual-Driven Development (VDD) es un patrón de trabajo en el que el punto de partida para escribir código de interfaz es una imagen: un wireframe, un mockup de alta fidelidad, un screenshot de una pantalla existente, o una captura de la competencia. Este capítulo explica el patrón y cómo ejecutarlo de forma estructurada con Claude Code.

---

## Conceptos clave

### Qué es Visual-Driven Development

En lugar de describir con palabras cómo debe quedar la interfaz ("el botón debe ser azul marino, con padding de 12px, bordes redondeados..."), el desarrollador proporciona directamente la imagen y Claude genera el código que la implementa.

VDD no reemplaza el diseño: asume que el diseño ya existe (en Figma, en papel, en un screenshot) y automatiza la traducción de ese diseño a código.

### Por qué funciona bien con Claude Code

La capacidad multimodal de Claude permite que razone simultáneamente sobre:
- La imagen del diseño (colores, espaciados, jerarquía visual, componentes)
- El código existente en el proyecto (framework, sistema de estilos, componentes ya creados)
- Las restricciones técnicas (accesibilidad, responsive design, soporte de navegadores)

Esto produce código que no solo "se parece" al mockup, sino que está integrado en el contexto real del proyecto.

---

## El flujo de Visual-Driven Development

### Paso 1: Capturar el mockup o screenshot

El punto de partida puede ser:

- Un screenshot de Figma (exportado como PNG o captura de pantalla)
- Una captura de pantalla del diseño que el cliente envió por email o Slack
- Un screenshot de la web de la competencia como referencia
- Una foto de un wireframe dibujado en papel
- Un screenshot del estado actual de la app que quieres replicar o modificar

Lo importante es que la imagen sea clara y a suficiente resolución. 800px de ancho mínimo para componentes; para pantallas completas, resolución de escritorio o móvil según corresponda.

### Paso 2: Proporcionar el mockup a Claude con contexto

No basta con dar la imagen. El prompt debe incluir:

- Qué tecnología usar (React, Vue, HTML/CSS vanilla, etc.)
- Si hay un sistema de estilos existente (Tailwind, CSS Modules, un design system propio)
- Qué parte del mockup implementar (el componente completo, solo el header, etc.)
- Dónde guardar el resultado

```
> Mira el mockup en @diseno/tarjeta-producto-v3.png.
> Implementa el componente en src/components/ProductCard.tsx.
> Usamos React con TypeScript y Tailwind CSS v3.
> El componente debe recibir estas props: name, price, imageUrl, rating, reviewCount.
> Sigue el patrón de los componentes existentes en src/components/.
```

### Paso 3: Revisar y comparar con el mockup

Después de que Claude genere el código, verifica visualmente el resultado. Hay dos formas:

**Forma manual:** Abre el componente en el navegador y compara visualmente con el mockup.

**Forma con Claude (patrón Writer/Reviewer):** Abre una sesión nueva de Claude Code y proporciona tanto el mockup original como un screenshot del resultado actual. Pide la comparación:

```bash
# Sesión nueva (contexto limpio para revisión objetiva)
claude
```

```
> Compara el diseño original en @diseno/tarjeta-producto-v3.png
> con el resultado actual en @screenshots/tarjeta-actual.png.
> Lista las diferencias visuales ordenadas por impacto.
> Para cada diferencia, indica el fichero y clase CSS o propiedad a cambiar.
```

### Paso 4: Iterar hasta convergencia

Con la lista de diferencias, pide a Claude (en la sesión original) que aplique los fixes:

```
> Aplica estas correcciones al componente ProductCard:
> 1. El espacio entre la imagen y el título es de 16px en el mockup, actualmente es 8px
> 2. El precio debe ser en negrita (font-weight: 600)
> 3. Las estrellas de rating deben ser amarillas (#F59E0B), no grises
```

Repite el ciclo de screenshot → comparación → fix hasta que el resultado sea aceptable.

---

## Integración con el patrón Writer/Reviewer

El patrón Writer/Reviewer del Capítulo 12 encaja perfectamente con VDD:

| Sesión | Rol | Input | Output |
|--------|-----|-------|--------|
| Sesión A (Writer) | Implementa | Mockup + contexto del proyecto | Código del componente |
| Sesión B (Reviewer) | Revisa | Mockup original + screenshot del resultado | Lista de diferencias |
| Sesión A (Writer) | Corrige | Lista de diferencias | Código corregido |

Las sesiones separadas garantizan que el Reviewer no esté influenciado por las decisiones de implementación del Writer. Con contexto limpio, el Reviewer evalúa objetivamente si el resultado coincide con el diseño.

---

## Herramientas complementarias

### MCP server de Figma

Si tu equipo usa Figma para el diseño, puedes conectar Claude Code a Figma via MCP. Esto permite que Claude lea el diseño directamente de Figma (sin exportar imágenes), accediendo a:

- Propiedades exactas de los elementos (colores, fuentes, espaciados en px)
- Tokens de diseño del design system
- Variantes y estados de los componentes

```bash
claude mcp add figma -- npx -y figma-developer-mcp --figma-api-key=$FIGMA_API_KEY
```

Con el MCP de Figma, el prompt cambia de referenciar una imagen a referenciar un componente directamente:

```
> @figma:component://TarjetaProducto genera el componente React en src/components/ProductCard.tsx.
> Extrae los valores exactos de colores, padding y tipografía del componente de Figma.
```

### Screenshots automáticos del navegador

Para el paso de verificación, puedes automatizar la captura del screenshot del resultado usando herramientas de línea de comandos:

```bash
# Con puppeteer (Node.js)
npx puppeteer screenshot http://localhost:3000/productos --output screenshots/resultado.png

# Con playwright
npx playwright screenshot http://localhost:3000/productos screenshots/resultado.png
```

Esto automatiza el ciclo de verificación visual sin necesidad de capturar screenshots manualmente.

---

## Ejemplo completo: de wireframe a página React

### Situación

El equipo de diseño entregó un wireframe de alta fidelidad de la página de checkout en `diseno/checkout-v2.png`. La página debe implementarse en React con Tailwind CSS.

### Paso 1: Análisis inicial del mockup

```
> Analiza el wireframe en @diseno/checkout-v2.png.
> Identifica los componentes que necesito implementar:
> - Lista los elementos de la página y su jerarquía
> - Qué datos necesita mostrar cada sección
> - ¿Hay elementos interactivos (formularios, botones, toggles)?
> No generes código todavía. Solo el análisis.
```

### Paso 2: Plan de implementación

```
> Basándote en el análisis, propone el plan de implementación:
> - Qué componentes crear (en orden de dependencia)
> - Props de cada componente
> - Estructura de carpetas en src/components/checkout/
```

### Paso 3: Implementación por componentes

```
> Implementa los componentes en este orden:
> 1. CheckoutSummary (el resumen del pedido de la derecha)
> 2. CheckoutForm (el formulario de la izquierda)
> 3. CheckoutPage (la página completa que los combina)
>
> Para cada componente, sigue el patrón de @src/components/ProductCard.tsx
> (props con TypeScript, Tailwind CSS, exportación nombrada).
```

### Paso 4: Verificación con sesión nueva

```bash
# Capturar el resultado
npx puppeteer screenshot http://localhost:3000/checkout --output screenshots/checkout-resultado.png

# Abrir sesión de revisión
claude
```

```
> Compara el mockup original @diseno/checkout-v2.png con el resultado @screenshots/checkout-resultado.png.
> Lista las diferencias visuales. Prioriza por impacto en UX (mayor a menor).
```

### Paso 5: Aplicar correcciones

De vuelta en la sesión de implementación:

```
> El Reviewer encontró estas diferencias. Aplícalas:
> [pegar la lista de diferencias]
```

---

## Cuándo NO usar Visual-Driven Development

VDD no es apropiado en todos los casos. Evítalo cuando:

**El diseño no existe todavía.** Si no hay mockup ni wireframe, primero diseña o usa un proceso como SDD (Capítulo 12) para definir requisitos. VDD parte de un diseño ya existente.

**La lógica de negocio es más importante que la presentación.** Si el componente tiene lógica compleja (validaciones, llamadas a API, manejo de estado), un approach dirigido por tests (TDD del Capítulo 12) es más apropiado. VDD es para la capa de presentación.

**La interfaz ya está implementada y solo necesitas ajustes menores.** Para cambios de 2-3 propiedades CSS, no vale la pena el overhead del flujo VDD. Edita directamente.

**El mockup es de muy baja fidelidad.** Un wireframe de caja gris sin información de colores, tipografía ni espaciados genera código genérico que requiere mucha iteración. VDD rinde mejor con mockups de alta fidelidad.

---

## Resumen

- VDD es el patrón de pasar de mockup/screenshot a código funcional usando la capacidad multimodal de Claude
- El flujo es: capturar → proporcionar con contexto → implementar → verificar → iterar
- La verificación se hace comparando el mockup original con un screenshot del resultado (ideal con sesión separada Writer/Reviewer)
- Herramientas complementarias: MCP de Figma para valores exactos, puppeteer/playwright para screenshots automáticos
- VDD es apropiado para implementación de UI; para lógica de negocio, usa TDD o SDD

---

Las técnicas de este capítulo se aplican en la sección de práctica al final del capítulo, que propone un ejercicio integrador de análisis visual completo.
