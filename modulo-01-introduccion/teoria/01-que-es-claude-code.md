# 01 - Qué es Claude Code

## Claude Code: un agente, no un chatbot

Claude Code **no es un chatbot** con el que mantienes una conversación sobre código. Es una **herramienta agéntica de desarrollo** que opera directamente en tu entorno de trabajo. La diferencia es fundamental:

| Chatbot | Agente (Claude Code) |
|---------|---------------------|
| Tú le pegas fragmentos de código y te devuelve sugerencias | Él lee tu proyecto completo por sí mismo |
| Opera en una ventana separada de tu editor | Opera dentro de tu terminal, en el directorio de tu proyecto |
| No puede ejecutar nada | Ejecuta comandos de terminal, tests, builds |
| Te muestra código que tú debes copiar y pegar | Edita los archivos directamente en tu sistema de archivos |
| Cada interacción es independiente | Mantiene contexto durante toda la sesión |
| Trabaja con fragmentos aislados | Coordina cambios en múltiples archivos simultáneamente |

Cuando inicias Claude Code en un directorio de proyecto, este puede:

- **Leer** cualquier archivo de tu codebase
- **Buscar** patrones en miles de archivos con grep y glob
- **Ejecutar** comandos de terminal: tests, builds, linters, migraciones de base de datos, comandos git
- **Editar** archivos existentes con precisión quirúrgica (reemplazos exactos de texto)
- **Crear** archivos nuevos cuando es necesario
- **Navegar** por la web para consultar documentación
- **Razonar** sobre la arquitectura completa de tu proyecto

Es, en esencia, un **colega de desarrollo autónomo** que vive en tu terminal.

### Ejemplo concreto

Imagina que le dices a Claude Code:

```
Hay un bug en el endpoint /api/users: cuando se envía un email duplicado, el servidor
devuelve un 500 en vez de un 409. Corrígelo y añade un test.
```

Claude Code, por sí solo, hará lo siguiente:

1. Buscará el archivo que define la ruta `/api/users` (usando Grep/Glob)
2. Leerá el controlador y el servicio asociado
3. Identificará dónde falta la validación de email duplicado
4. Editará el código para capturar el error de duplicado y devolver un 409
5. Buscará el directorio de tests
6. Leerá los tests existentes para seguir el mismo patrón
7. Creará un nuevo test que envíe un email duplicado y verifique el 409
8. Ejecutará los tests para confirmar que pasan
9. Te mostrará un resumen de todo lo que hizo

Tú no le dictaste paso a paso qué hacer. Le **delegaste** una tarea y él la resolvió de forma autónoma.

---

## El cambio de paradigma: delegar, no dictar

La mayoría de desarrolladores empiezan a usar herramientas de IA como si fueran compiladores sofisticados: les dictan instrucciones paso a paso. Con Claude Code, este enfoque es ineficiente.

### El modelo mental correcto

Piensa en Claude Code como si fuera un **colega senior nuevo en el equipo**:

- **Sabe programar muy bien** en prácticamente cualquier lenguaje
- **No conoce tu proyecto** (todavía), pero puede explorarlo rápidamente
- **Necesita contexto** sobre las decisiones de negocio y las convenciones del equipo
- **Puede trabajar de forma autónoma** si le das una tarea clara
- **Necesita verificación**: como cualquier colega, su trabajo debe revisarse

### Dictado vs Delegación

**Dictado (ineficiente):**
```
Abre el archivo src/controllers/userController.ts.
En la línea 45, después del try, añade un catch que
verifique si el error es de tipo UniqueConstraintError.
Si lo es, devuelve res.status(409).json({error: 'Email ya existe'}).
Después ve al archivo tests/user.test.ts y...
```

**Delegación (efectivo):**
```
El endpoint POST /api/users devuelve 500 cuando se intenta registrar
un email que ya existe en la base de datos. Debería devolver 409 con
un mensaje descriptivo. Corrige el bug y añade un test que lo cubra.
Sigue los patrones existentes en el proyecto.
```

En el segundo caso, Claude Code usa su autonomía para:
- Encontrar los archivos relevantes
- Entender los patrones del proyecto
- Aplicar la solución de forma coherente con el resto del código
- Verificar su propio trabajo

---

## Diferencias con otras herramientas de IA

### Claude Code vs GitHub Copilot

| Aspecto | GitHub Copilot | Claude Code |
|---------|---------------|-------------|
| Dónde opera | Dentro del editor (inline) | En la terminal + editor |
| Unidad de trabajo | Línea o función individual | Tarea completa (multi-archivo) |
| Contexto | El archivo actual + archivos abiertos | Todo el proyecto + terminal + git |
| Puede ejecutar comandos | No (Copilot Chat tiene limitaciones) | Sí, cualquier comando de terminal |
| Puede editar archivos | No, solo sugiere | Sí, edita directamente |
| Ideal para | Autocompletado rápido mientras escribes | Tareas complejas, refactoring, debugging |

**No son excluyentes.** Muchos equipos usan Copilot para autocompletado rápido y Claude Code para tareas más complejas.

### Claude Code vs ChatGPT / Claude Web

| Aspecto | ChatGPT/Claude Web | Claude Code |
|---------|-------------------|-------------|
| Contexto | Solo lo que pegas en el chat | Tu proyecto completo |
| Archivos | Copiar y pegar manual | Lectura/escritura directa |
| Ejecución | No puede ejecutar en tu máquina | Ejecuta tests, builds, etc. |
| Multi-archivo | Un fragmento a la vez | Cambios coordinados en muchos archivos |
| Verificación | Tú debes verificar manualmente | Puede ejecutar tests para verificar |
| Git | No tiene acceso | Lee estado de git, puede hacer commits |

### Claude Code vs Cursor / Windsurf / Otros IDEs con IA

| Aspecto | Cursor/Windsurf | Claude Code |
|---------|----------------|-------------|
| Interfaz | IDE gráfico propio | Terminal (+ extensiones para VS Code/JetBrains) |
| Ejecución de comandos | Limitada | Completa (acceso total a terminal) |
| Flexibilidad de entorno | Requiere usar su IDE | Funciona en cualquier terminal |
| Integración CI/CD | Limitada | Nativa (se ejecuta en pipelines) |
| Automatización headless | No disponible | Sí (modo no interactivo con `-p`) |
| Personalizable con hooks | No | Sí (hooks pre/post ejecución) |

La ventaja principal de Claude Code es que opera como un **proceso en tu terminal**, lo que significa que puede integrarse en scripts, pipelines CI/CD, git hooks y cualquier flujo de trabajo automatizado.

---

## Plataformas disponibles

Claude Code está disponible en múltiples plataformas para adaptarse a cualquier flujo de trabajo:

### 1. Terminal CLI (la experiencia principal)

La forma canónica de usar Claude Code. Se ejecuta directamente en tu terminal (bash, zsh, PowerShell):

```bash
cd mi-proyecto
claude
```

Funciona en **macOS, Linux y Windows** (nativo o vía WSL).

La CLI es la interfaz más completa: tiene acceso irrestricto al terminal, se integra en scripts y pipelines CI/CD, y es la opción más adecuada cuando se necesita automatización o ejecución en entornos sin interfaz gráfica. Los plugins para VS Code y JetBrains son cómodos para el trabajo diario dentro del editor, pero la CLI sigue siendo la referencia para tareas complejas y para quienes trabajan habitualmente desde la terminal.

### 2. Extensión para VS Code

Integra Claude Code directamente en Visual Studio Code como un panel lateral. Permite:
- Interactuar con Claude sin salir del editor
- Referenciar archivos abiertos
- Ver los cambios que Claude hace en tiempo real

### 3. Plugin para JetBrains

Disponible para todos los IDEs de JetBrains (IntelliJ, PyCharm, WebStorm, GoLand, etc.):
- Misma funcionalidad que la extensión de VS Code
- Integrado en el ecosistema JetBrains

### 4. Aplicación de escritorio

Aplicación nativa para **macOS** y **Windows** que proporciona:
- Interfaz gráfica dedicada
- Gestión de múltiples sesiones
- Fácil acceso sin necesidad de terminal

### 5. Web: claude.ai/code

Acceso a Claude Code desde el navegador en **claude.ai/code**. Útil cuando:
- No puedes instalar software en la máquina
- Necesitas acceso rápido desde cualquier lugar
- Quieres colaborar compartiendo sesiones

### 6. Chrome

Extensión para Chrome que permite interactuar con Claude Code desde el navegador.

### 7. Slack

Integración con Slack para equipos que quieren invocar Claude Code desde canales de comunicación del equipo.

### 8. iOS

Aplicación móvil para consultas rápidas y revisión de resultados sobre la marcha.

---

## Modelos disponibles

Claude Code puede utilizar diferentes modelos de la familia Claude, cada uno optimizado para distintos escenarios:

### Opus 4.6 (Razonamiento más potente)

- **Identificador:** `claude-opus-4-6`
- **Fortalezas:** Razonamiento profundo, planificación de arquitectura, problemas complejos, pensamiento adaptativo (extended thinking)
- **Ideal para:** Diseño de sistemas, debugging de problemas difíciles, refactoring a gran escala, revisiones de código exhaustivas
- **Velocidad:** Más lento que los otros modelos
- **Coste:** El más caro
- **Pensamiento adaptativo:** Opus 4.6 incluye "adaptive thinking" -- puede dedicar más o menos tiempo a razonar según la complejidad del problema

### Sonnet 4.6 (Desarrollo diario)

- **Identificador:** `claude-sonnet-4-6` (la versión puede variar)
- **Fortalezas:** Excelente equilibrio entre calidad y velocidad
- **Ideal para:** Trabajo de desarrollo diario, implementación de features, corrección de bugs, tests
- **Velocidad:** Rápido
- **Coste:** Moderado
- **Recomendación:** Este es el modelo que usarás el 80% del tiempo

### Haiku 4.5 (Rápido y económico)

- **Identificador:** `claude-haiku-4-5-20251001` (la versión puede variar)
- **Fortalezas:** Muy rápido, coste bajo
- **Ideal para:** Tareas simples, autocompletado, preguntas rápidas, operaciones en lote
- **Velocidad:** El más rápido
- **Coste:** El más barato
- **Limitaciones:** Menor capacidad de razonamiento complejo

### Cómo cambiar de modelo

En la CLI puedes cambiar el modelo de varias formas:

```bash
# Especificar modelo al iniciar
claude --model claude-opus-4-6

# Dentro de una sesión, usar el comando /model
/model opus

# Modo rápido (fast mode) dentro de una sesión
/fast
```

### Cuándo usar cada modelo

| Tarea | Modelo recomendado |
|-------|-------------------|
| Diseñar arquitectura de un sistema | Opus 4.6 |
| Debugging de un problema difícil | Opus 4.6 |
| Implementar una feature | Sonnet 4.6 |
| Corregir un bug sencillo | Sonnet 4.6 |
| Escribir tests | Sonnet 4.6 |
| Preguntas rápidas sobre sintaxis | Haiku 4.5 |
| Generar boilerplate | Haiku 4.5 |
| Procesar muchos archivos en lote | Haiku 4.5 |

---

## El bucle agéntico

El corazón de Claude Code es su **bucle agéntico** (agentic loop). A diferencia de un chatbot que responde una vez y espera, Claude Code opera en un bucle continuo hasta completar la tarea:

```
   +---------------------+
   |   Recoger contexto  |  <--- Lee archivos, busca patrones,
   |   (Gather context)  |       analiza estado del proyecto
   +----------+----------+
              |
              v
   +----------+----------+
   |   Tomar acción      |  <--- Edita archivos, ejecuta comandos,
   |   (Take action)     |       crea archivos, busca en la web
   +----------+----------+
              |
              v
   +----------+----------+
   |   Verificar          |  <--- Ejecuta tests, revisa output,
   |   resultados         |       comprueba que no hay errores
   |   (Verify results)   |
   +----------+----------+
              |
              v
       Tarea completa? ----NO----> Volver a "Recoger contexto"
              |
             SÍ
              |
              v
   +----------+----------+
   |   Presentar          |
   |   resultado final    |
   +---------------------+
```

### Fase 1: Recoger contexto

Claude Code comienza cada tarea explorando tu proyecto. Utiliza sus herramientas internas para:

- Buscar archivos relevantes (`Glob`, `Grep`)
- Leer el contenido de archivos (`Read`)
- Examinar el estado de git
- Leer el archivo `CLAUDE.md` para entender las convenciones del proyecto
- Consultar documentación web si es necesario (`WebFetch`, `WebSearch`)

### Fase 2: Tomar acción

Una vez que entiende el contexto, Claude Code actúa:

- Edita archivos existentes (`Edit`)
- Crea archivos nuevos (`Write`)
- Ejecuta comandos de terminal (`Bash`): tests, builds, linters, migraciones, etc.

### Fase 3: Verificar resultados

Después de cada acción, Claude Code verifica que las cosas funcionan:

- Ejecuta tests para confirmar que pasan
- Revisa el output de los comandos buscando errores
- Comprueba que los cambios son coherentes

### Fase 4: Iterar o finalizar

Si la verificación detecta problemas, Claude Code vuelve a la fase 1 para recoger más contexto y corregir. Si todo está correcto, presenta el resultado final.

### Ejemplo del bucle en acción

Tarea: "Añade un campo `phone` al modelo de usuario y actualiza toda la API"

1. **Contexto:** Claude busca el modelo de usuario, los controladores, los DTOs, las migraciones, los tests
2. **Acción:** Añade el campo al modelo, actualiza el DTO, modifica el controlador, crea una migración
3. **Verificación:** Ejecuta `npm run test` -- 2 tests fallan por validaciones faltantes
4. **Contexto:** Lee los tests que fallan para entender qué esperan
5. **Acción:** Añade validación de formato de teléfono en el DTO
6. **Verificación:** Ejecuta `npm run test` -- todos los tests pasan
7. **Resultado:** Presenta un resumen de todos los archivos modificados

Este bucle es lo que convierte a Claude Code en un **agente** y no en un simple generador de texto.

---

## Herramientas internas (built-in tools)

Claude Code viene equipado con un conjunto de herramientas que utiliza automáticamente según la tarea:

### Bash

Ejecuta cualquier comando de terminal en tu sistema operativo.

```
Ejemplos de uso:
- npm run test
- python manage.py migrate
- docker compose up -d
- git diff HEAD~3
- cargo build --release
- kubectl get pods
```

**Importante:** Claude Code pide permiso antes de ejecutar comandos potencialmente destructivos. Tú controlas qué nivel de autonomía le das (más sobre esto en el **Capítulo 5**).

### Read

Lee el contenido de cualquier archivo del proyecto. También puede leer imágenes (es multimodal), PDFs y notebooks Jupyter.

### Edit

Realiza reemplazos exactos de texto en archivos existentes. Es la herramienta principal de edición: busca una cadena de texto exacta y la reemplaza por otra.

### Write

Crea archivos nuevos o sobrescribe archivos existentes cuando es necesario.

### Glob

Busca archivos por patrón de nombre (similar a `find` pero más rápido):

```
Ejemplos:
- **/*.ts        -> todos los archivos TypeScript
- src/**/*.test.js -> todos los tests en src/
- **/Dockerfile  -> todos los Dockerfiles del proyecto
```

### Grep

Busca contenido dentro de archivos usando expresiones regulares (construido sobre `ripgrep`):

```
Ejemplos:
- Buscar todas las llamadas a una función
- Encontrar todos los TODO/FIXME
- Localizar imports de un módulo específico
```

### WebFetch

Obtiene contenido de una URL y lo procesa. Útil para consultar documentación, APIs públicas o ejemplos.

### WebSearch

Realiza búsquedas web para obtener información actualizada.

### Task

Crea sub-tareas que Claude Code puede ejecutar en paralelo o de forma secuencial. Útil para tareas complejas que requieren múltiples flujos de trabajo.

### AskUserQuestion

Cuando Claude Code necesita información que no puede obtener por sí mismo, te hace una pregunta directamente.

---

## A qué tiene acceso Claude Code

Es importante entender exactamente qué puede ver y usar Claude Code en cada sesión:

### Archivos del proyecto

Claude Code puede leer **cualquier archivo** dentro del directorio donde lo ejecutaste y sus subdirectorios. Esto incluye:

- Código fuente en cualquier lenguaje
- Archivos de configuración (package.json, Dockerfile, .env.example, etc.)
- Documentación (README, docs/)
- Archivos de tests
- Scripts de CI/CD
- Imágenes (puede "ver" screenshots y diagramas)

### Terminal y comandos

Puede ejecutar cualquier comando disponible en tu terminal:

- Comandos del lenguaje (node, python, java, go, cargo, etc.)
- Gestores de paquetes (npm, pip, maven, etc.)
- Docker y docker compose
- Kubernetes (kubectl)
- Terraform, Ansible
- Cualquier CLI instalada en tu sistema

### Estado de Git

Claude Code puede ver y usar todo el estado de git:

- `git status` -- archivos modificados, staged, etc.
- `git log` -- historial de commits
- `git diff` -- cambios actuales
- `git branch` -- ramas disponibles
- Puede hacer commits, crear ramas, cherry-pick, etc.

### CLAUDE.md

Un archivo especial que Claude Code lee automáticamente al iniciar una sesión. Contiene:

- Convenciones del proyecto
- Comandos importantes (cómo correr tests, cómo hacer build)
- Patrones preferidos
- Información del equipo

Lo veremos en detalle en el **Capítulo 4**.

### Extensiones MCP (Model Context Protocol)

Claude Code puede extender sus capacidades mediante servidores MCP que le dan acceso a:

- Bases de datos
- APIs internas
- Sistemas de tickets (Jira, Linear)
- Herramientas de monitorización
- Cualquier servicio que exponga un servidor MCP

Lo veremos en detalle en el **Capítulo 7**.

### Lo que NO tiene acceso (por defecto)

- Archivos fuera del directorio del proyecto (a menos que des permiso explícito)
- Secretos y credenciales (no los incluyas en CLAUDE.md)
- Servicios autenticados sin configuración MCP
- Tu historial de navegación o datos personales
