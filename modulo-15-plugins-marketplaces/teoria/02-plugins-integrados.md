# Plugins y Extensiones del Ecosistema de Claude Code

El ecosistema de Claude Code incluye tres categorías de plugins y extensiones: **plugins de IDE**, **plugins de integración con servicios** y **plugins de productividad**. Algunos vienen preinstalados o se activan automáticamente según el entorno; otros requieren instalación explícita. Conocer estas categorías permite seleccionar las integraciones más adecuadas para cada stack tecnológico y combinarlas en un entorno de trabajo optimizado.

---

## Conceptos Clave

El ecosistema cubre desde la navegación semántica del código hasta la integración con herramientas de gestión de proyectos y bases de datos. Los plugins no son aditivos pasivos: cada uno amplía el conjunto de herramientas que Claude puede invocar y, en consecuencia, la calidad de las respuestas en ese dominio.

---

## Plugins de Code Intelligence

Los plugins de code intelligence mejoran la capacidad de Claude para navegar y comprender la estructura del código con precisión semántica. En lugar de buscar símbolos con grep sobre texto, Claude puede resolver referencias al nivel del compilador o el language server.

### Qué proporcionan

- **Go-to-definition**: Claude puede saltar a la definición exacta de una función o clase, incluso si está en un paquete externo
- **Find-references**: localiza todos los usos de un símbolo en el proyecto, no solo coincidencias textuales
- **Hover information**: obtiene tipos, documentación y firmas de funciones sin leer el archivo completo
- **Symbol search**: busca clases, funciones o variables por nombre en todo el workspace

### Cómo se activa

Claude Code lo activa automáticamente si detecta un language server compatible en el proyecto (por ejemplo, `pyright` para Python, `typescript-language-server` para TypeScript o `rust-analyzer` para Rust). También puedes instalarlo explícitamente:

```bash
claude plugin install code-intelligence@claude-plugins-official
```

### Ejemplo de uso práctico

Sin code intelligence, si pides "mueve la lógica de `procesar_pago` a un servicio separado", Claude busca con grep y puede perderse referencias indirectas. Con code intelligence, Claude resuelve el grafo de llamadas completo antes de hacer el refactor.

---

## Plugins de IDE

### Extensión de VS Code

La extensión oficial de Claude Code para VS Code es la forma más cómoda de trabajar con Claude en un editor gráfico. Se instala desde el marketplace de VS Code o desde la línea de comandos:

```bash
code --install-extension anthropic.claude-code
```

**Funcionalidades principales:**

- **Inline diffs**: los cambios de Claude aparecen directamente en el editor con las diferencias marcadas en verde/rojo, sin salir del archivo
- **@-mentions en el chat**: puedes referenciar archivos, símbolos o selecciones del editor escribiendo `@archivo.py` o `@NombreDeClase` directamente en el prompt
- **Plan review**: en Plan Mode, el plan aparece en un panel lateral donde puedes editarlo antes de aprobar la ejecución
- **Terminal integrado**: las sesiones de Claude Code se abren en el terminal del propio VS Code, sin cambiar de ventana
- **Ver pensamiento de Claude**: cuando Claude razona antes de responder, el proceso de pensamiento es visible en un panel colapsable

**Flujo de trabajo típico en VS Code:**

1. Seleccionas un bloque de código en el editor
2. Abres Claude con `Ctrl+Shift+C` (o el keybinding configurado)
3. Escribes "@seleccion refactoriza esto para eliminar la duplicación"
4. Claude muestra el diff en el propio archivo; tú aceptas o rechazas cada cambio

### Plugin de JetBrains

El plugin de JetBrains es compatible con IntelliJ IDEA, WebStorm, PyCharm, GoLand, Rider y el resto de la familia JetBrains.

```bash
# Desde la línea de comandos (alternativa al marketplace de JetBrains)
claude plugin install jetbrains-integration@claude-plugins-official
```

**Funcionalidades compartidas con la extensión de VS Code:**

- Ver el pensamiento de Claude en un panel lateral
- Aprobar o rechazar cambios individuales con diff visual
- @-mentions para referencias a archivos del proyecto
- Sesión integrada en el IDE sin cambiar de ventana

**Funcionalidades específicas de JetBrains:**

- Acceso al índice de símbolos de IntelliJ (más preciso que grep para proyectos Java/Kotlin grandes)
- Integración con el sistema de refactoring de JetBrains para renombrados seguros
- Compatible con el debugger integrado: Claude puede leer el estado de variables durante una sesión de depuración

---

## Plugins de Integración con Servicios

Estos plugins exponen herramientas de servicios externos como herramientas de Claude Code vía MCP o hooks. Una vez instalados, Claude puede interactuar con el servicio como si fuera una capacidad nativa.

### GitHub

Conecta Claude directamente con tu cuenta de GitHub para gestionar pull requests, issues y code reviews sin salir del terminal.

```bash
claude plugin install github@claude-plugins-official
# Requiere: GITHUB_TOKEN con permisos repo
```

**Qué hace:**

- Leer y crear pull requests, issues y comentarios
- Ejecutar code reviews automáticos cuando se menciona `@claude` en un PR
- Consultar el estado de los checks y workflows de CI/CD
- Crear branches y commits desde Claude

**Ejemplo de uso:**

```
> Crea un PR con los cambios actuales, titulado "feat: añadir validación de email"
  y asígnalo a @maria-garcia para revisión
```

Claude ejecuta `git push`, crea el PR vía API de GitHub y añade el asignado, todo en un solo paso.

### Notion

Permite a Claude leer y escribir en tu workspace de Notion: documentación, wikis, bases de datos de proyectos.

```bash
claude plugin install notion@claude-plugins-official
# Requiere: NOTION_API_KEY y compartir las páginas con la integración
```

**Qué hace:** acceder a páginas y bases de datos de Notion como contexto adicional para Claude. Útil para consultar especificaciones técnicas, ADRs o documentación de producto sin copiarlos manualmente al contexto.

**Ejemplo:** "Busca en la wiki de Notion la arquitectura del servicio de pagos y úsala como referencia para este refactor."

### Sentry

Integra el análisis de errores de producción directamente en el flujo de desarrollo.

```bash
claude plugin install sentry@claude-plugins-official
# Requiere: SENTRY_AUTH_TOKEN y SENTRY_ORG configurados
```

**Qué hace:** leer issues, stack traces y eventos de Sentry para que Claude pueda diagnosticar errores con el contexto real de producción (no solo el código fuente).

**Ejemplo:** "Busca el error `NullPointerException` en Sentry de las últimas 24 horas y localiza la línea exacta en el código que lo causa."

### Linear y Jira

Gestión de tickets e issues integrada en el flujo de Claude Code.

```bash
# Linear
claude plugin install linear@claude-plugins-official
# LINEAR_API_KEY requerida

# Jira
claude plugin install jira@claude-plugins-official
# JIRA_API_TOKEN, JIRA_BASE_URL y JIRA_EMAIL requeridos
```

**Qué hacen:** consultar tickets, actualizar estados, crear subtareas y vincular commits a issues directamente desde Claude. Útil para cerrar el ciclo entre el ticket y el código sin cambiar de herramienta.

**Ejemplo:** "Marca el ticket PLAT-482 como 'In Review' y añade un comentario con el enlace al PR que acabo de crear."

### Slack

Notificaciones y comunicación desde Claude Code hacia canales de Slack.

```bash
claude plugin install slack@claude-plugins-official
# SLACK_BOT_TOKEN y SLACK_CHANNEL configurados
```

**Qué hace:** enviar mensajes a canales de Slack como parte de un workflow automatizado. Típicamente se usa junto con hooks para notificar al equipo sobre deploys, tests fallidos o revisiones completadas.

**Ejemplo de uso en hook:** un hook `PostToolUse` que notifica a `#deploys` cuando Claude ejecuta un deploy a producción.

### PostgreSQL y MySQL

Acceso directo a bases de datos relacionales como herramienta de Claude.

```bash
# PostgreSQL vía MCP
claude plugin install postgresql@claude-plugins-official
# DATABASE_URL requerida (postgresql://usuario:password@host:5432/nombre_bd)

# MySQL vía MCP
claude plugin install mysql@claude-plugins-official
# MYSQL_URL requerida
```

**Qué hacen:** permiten a Claude ejecutar queries SQL, explorar el schema, diagnosticar problemas de rendimiento y proponer migraciones sin necesidad de un cliente de base de datos separado.

**Ejemplo:** "Analiza las queries más lentas de los últimos 7 días y propón índices que mejoren el rendimiento."

> Precaución: asegúrate de que las credenciales en `DATABASE_URL` solo tienen permisos de lectura si no quieres que Claude pueda modificar datos.

### Figma

Integración con diseños para Visual-Driven Development.

```bash
claude plugin install figma@claude-plugins-official
# FIGMA_ACCESS_TOKEN requerido
```

**Qué hace:** leer frames, componentes y tokens de diseño de Figma para que Claude pueda implementar UIs fieles al diseño sin que tengas que describir cada medida y color manualmente.

**Ejemplo:** "Implementa el componente `CardProducto` siguiendo exactamente el diseño del frame 'Card/Product' en el archivo Figma del Design System."

### Playwright y Puppeteer

Testing de UI y captura de screenshots integrado en el flujo de Claude.

```bash
claude plugin install playwright@claude-plugins-official
# Requiere: @playwright/test instalado en el proyecto
```

**Qué hace:** permite a Claude ejecutar tests de UI, capturar screenshots de la aplicación en distintos estados y usarlos como contexto visual para diagnosticar problemas de interfaz.

**Ejemplo:** "Ejecuta los tests de Playwright, captura un screenshot de la pantalla de login y muestra el resultado."

---

## Plugins de Productividad

### Prettier y ESLint

Formateo y linting automático activado mediante hooks.

```bash
claude plugin install prettier-eslint@claude-plugins-official
# Requiere: prettier y eslint configurados en el proyecto
```

**Qué hace:** instala hooks `PostToolUse` que ejecutan `prettier --write` y `eslint --fix` automáticamente cada vez que Claude edita un fichero JavaScript, TypeScript o CSS. El código siempre sale formateado, sin necesidad de un paso manual.

**Ejemplo de uso:** Claude edita `components/Button.tsx`. El hook se activa, ejecuta `prettier --write components/Button.tsx`, y el archivo queda formateado sin que hayas tenido que pedirlo.

### Docker

Gestión de contenedores integrada.

```bash
claude plugin install docker@claude-plugins-official
```

**Qué hace:** añade herramientas para gestionar imágenes, contenedores y redes de Docker. Claude puede arrancar, parar e inspeccionar contenedores como parte de un workflow de desarrollo o CI.

**Ejemplo:** "Construye la imagen Docker del proyecto, levanta el contenedor y ejecuta los tests de integración dentro de él."

### Kubernetes

Gestión de clusters para flujos de despliegue.

```bash
claude plugin install kubernetes@claude-plugins-official
# Requiere: kubectl configurado con acceso al cluster
```

**Qué hace:** expone operaciones de Kubernetes como herramientas de Claude: ver pods, aplicar manifests, escalar deployments y leer logs. Útil para ciclos de despliegue y diagnóstico en entornos Kubernetes.

**Ejemplo:** "Despliega la nueva versión de `api-service` en el cluster de staging y verifica que los pods arrancan correctamente."

---

## Errores Comunes

**Instalar plugins con credenciales de producción sin restricciones.** Si configuras el plugin de PostgreSQL con las credenciales de la base de datos de producción, cualquier proyecto en el que trabajas tiene acceso de escritura a producción. Usa credenciales de solo lectura o variables de entorno específicas por proyecto.

**No revisar los permisos que solicita un plugin antes de instalarlo.** Antes de instalar un plugin del marketplace público, usa la interfaz interactiva `/plugin` para navegar a la pestaña de detalles del plugin y ver qué herramientas usa, qué permisos solicita y quién es el autor. Un plugin que solicita `Bash` sin restricciones merece más escrutinio que uno que solo usa `Read`.

**Instalar demasiados plugins y aumentar el contexto innecesariamente.** Cada servidor MCP instalado vía plugin ocupa espacio en la ventana de contexto con su lista de herramientas. Si tienes 10 plugins activos, Claude ve cientos de herramientas disponibles, lo que puede degradar la calidad de sus decisiones. Activa solo los plugins que uses regularmente en cada proyecto.

---

## Resumen

- Los plugins de code intelligence mejoran la navegación semántica de símbolos y están disponibles para los lenguajes más comunes
- La extensión de VS Code y el plugin de JetBrains ofrecen inline diffs, @-mentions, plan review y streaming del pensamiento de Claude
- Los plugins de servicios (GitHub, Notion, Sentry, Linear, bases de datos) se configuran con tokens de API y amplían las herramientas disponibles para Claude
- Los plugins de productividad (Prettier, Docker, Kubernetes) automatizan tareas de infraestructura y formateo vía hooks
- Antes de instalar un plugin del marketplace, revisa siempre los permisos que solicita
