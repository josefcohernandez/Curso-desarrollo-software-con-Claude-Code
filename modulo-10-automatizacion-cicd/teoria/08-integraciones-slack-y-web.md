# 08 - Integraciones: Claude Code en Slack y en la Web

## Objetivos de aprendizaje

Al completar esta sección, serás capaz de:

1. **Instalar y configurar** la integración de Claude Code en Slack para tu equipo.
2. **Invocar Claude desde Slack** con `@Claude` y entender cómo decide entre responder en el hilo o abrir una sesión de código.
3. **Usar los botones de acción** (View Session, Create PR, Change Repo) de la respuesta de Claude en Slack.
4. **Acceder a Claude Code en la web** desde claude.ai sin instalar nada en la máquina local.
5. **Conectar repositorios de GitHub** a la sesión web para que Claude tenga contexto del código.
6. **Elegir entre la integración de Slack, la sesión web y el CLI local** según el escenario.

---

## Claude Code en Slack

### ¿Qué es?

La integración de Claude Code en Slack permite mencionar `@Claude` directamente en cualquier canal donde la app esté instalada. Claude analiza el mensaje y decide automáticamente si la tarea requiere código o no:

- Si es una **pregunta de chat** (dudas conceptuales, explicaciones, decisiones de arquitectura), responde directamente en el hilo de Slack.
- Si es una **tarea de código** (revisar un fichero, refactorizar una función, detectar vulnerabilidades), abre una sesión web de Claude Code y responde con un enlace a esa sesión.

Esta detección automática permite que el equipo use un único punto de entrada sin tener que pensar en qué herramienta abrir.

### Requisitos

| Requisito | Descripción |
|-----------|-------------|
| Plan | Team o Enterprise |
| Claude Code on the web | Debe estar configurado en la cuenta de Anthropic |
| GitHub conectado | La cuenta de Anthropic debe tener GitHub conectado |
| Canal, no DM | Solo funciona en canales; no en mensajes directos (DMs) |

### Instalación

1. Desde claude.ai, ve a **Settings > Integrations > Slack**.
2. Haz clic en **Add to Slack** y autoriza el workspace.
3. Invita la app `@Claude` al canal donde quieras usarla: `/invite @Claude`.
4. Verifica que GitHub esté conectado en **Settings > Connections > GitHub**.

---

## Usar `@Claude` en un canal

### Sintaxis básica

```text
@Claude <tu pregunta o tarea>
```

No hay comandos especiales que aprender. El lenguaje natural es suficiente.

### Ejemplo 1: Pregunta de chat

```text
@Claude ¿Cuál es la diferencia entre una clave de API y un token JWT?
```

Claude responde directamente en el hilo de Slack con una explicación. No abre una sesión de código.

### Ejemplo 2: Tarea de código

```text
@Claude revisa la función de autenticación en auth.py y dime si hay vulnerabilidades
```

Claude detecta que necesita acceder a código, abre una sesión web de Claude Code con el repositorio más relevante del contexto del canal, y responde en el hilo con un enlace a la sesión y un resumen inicial del análisis.

### Ejemplo 3: Tarea con repositorio explícito

```text
@Claude en el repo mi-org/backend, busca todas las consultas SQL que no usan parámetros preparados
```

Cuando hay ambigüedad sobre qué repositorio usar, puedes indicarlo explícitamente. Claude usa ese contexto para seleccionar el repositorio correcto al abrir la sesión.

---

## Botones de acción en la respuesta

Cuando Claude abre una sesión de código, la respuesta en Slack incluye botones de acción interactivos:

| Botón | Qué hace |
|-------|---------|
| **View Session** | Abre la sesión de Claude Code en el navegador para ver el trabajo en detalle o continuar la conversación |
| **Create PR** | Solicita a Claude que cree una PR con los cambios realizados durante la sesión |
| **Change Repo** | Cambia el repositorio asociado a la sesión si Claude eligió el incorrecto automáticamente |

Estos botones aparecen en el mensaje de respuesta de Claude en el canal. Cualquier miembro del canal puede hacer clic en ellos.

---

## Selección automática de repositorio

Claude usa el contexto del canal y del hilo para seleccionar el repositorio más relevante. Los factores que considera:

- Menciones previas de repositorios en el hilo.
- Nombre del canal (un canal llamado `#backend-api` sugiere un repositorio de backend).
- Último repositorio mencionado en el canal.
- Repositorios conectados a la cuenta del miembro que hizo la mención.

Si la selección automática no es la correcta, usa el botón **Change Repo** o menciona el repositorio explícitamente en el mensaje.

---

## Claude Code en la web

Además de la integración con Slack, Claude Code está disponible directamente en [claude.ai](https://claude.ai) como una sesión web. Esto es útil cuando:

- Trabajas en una máquina sin acceso de instalación (máquina de cliente, ordenador prestado).
- Quieres revisar código sin configurar nada localmente.
- Tu equipo prefiere una interfaz web sobre la terminal.

### Cómo acceder

1. Ve a [claude.ai](https://claude.ai) e inicia sesión.
2. En el menú lateral, selecciona **Claude Code**.
3. Conecta tu cuenta de GitHub si aún no lo has hecho.
4. Selecciona el repositorio sobre el que quieres trabajar.

### Diferencias con el CLI local

| Característica | CLI local | Sesión web |
|----------------|-----------|-----------|
| Instalación | Necesaria | Ninguna |
| Acceso al sistema de ficheros local | Sí | Solo repos de GitHub |
| Velocidad de respuesta | Alta (sin latencia web) | Depende de la conexión |
| Herramientas disponibles | Todas | Subconjunto orientado a GitHub |
| Uso en máquinas sin permisos de instalación | No | Sí |

---

## Ejemplo práctico: revisión de seguridad desde Slack

Este ejemplo muestra el flujo completo de una revisión iniciada desde Slack.

### Contexto

El canal `#seguridad` recibe una alerta de que se acaba de mergear una PR que modifica el sistema de autenticación. Un miembro del equipo quiere una revisión rápida sin abrir el portátil de desarrollo.

### Interacción en Slack

```text
# Miembro del equipo escribe en #seguridad:
@Claude revisa los cambios del último merge en la rama main del repo mi-org/backend.
Comprueba si hay problemas de seguridad en el código de autenticación.

# Claude responde en el hilo:
He abierto una sesión de Claude Code con el repositorio mi-org/backend.
Estoy analizando los cambios del último commit en main...

Hallazgos iniciales:
- El token JWT ahora tiene una expiración de 30 días (era 24 horas). Revisa si esto
  es intencional o un error de configuración.
- Se eliminó la validación del campo `email` en el endpoint /auth/register.

[View Session] [Create PR] [Change Repo]
```

El miembro hace clic en **View Session** para ver el análisis completo en el navegador y solicitar correcciones si es necesario.

---

## Casos de uso por canal

La integración de Slack es más útil cuando el canal tiene un propósito claro que Claude puede aprovechar:

| Canal | Uso típico de `@Claude` |
|-------|------------------------|
| `#code-review` | Pedir revisiones de PRs específicas antes de asignar revisores humanos |
| `#bugs` | Pedir a Claude que analice el stacktrace adjunto y sugiera dónde está el bug |
| `#deploys` | Pedir a Claude que genere el changelog del último deploy |
| `#arquitectura` | Preguntas conceptuales sobre decisiones de diseño (respuesta en el hilo, sin sesión) |
| `#seguridad` | Solicitar análisis de vulnerabilidades en código recién mergeado |

---

## Errores comunes

| Error | Causa probable | Solución |
|-------|---------------|---------|
| `@Claude` no responde en el canal | La app no está invitada al canal | Ejecuta `/invite @Claude` en el canal |
| Claude abre sesión web pero no encuentra el repositorio | GitHub no está conectado a la cuenta | Conecta GitHub en Settings > Connections |
| Los botones de acción no aparecen | Versión antigua de la integración de Slack | Reinstala la app desde Settings > Integrations > Slack |
| Claude selecciona el repositorio equivocado | Ambigüedad en el contexto del canal | Menciona el repositorio explícitamente: `en el repo mi-org/nombre` |
| La integración no funciona en DMs | Limitación de diseño: solo funciona en canales | Pasa la conversación a un canal o usa claude.ai directamente |

---

## Resumen

- La integración de **Claude Code en Slack** permite invocar Claude con `@Claude` en cualquier canal; Claude decide automáticamente si responder en el hilo (chat) o abrir una sesión de código (GitHub).
- Los **botones de acción** (View Session, Create PR, Change Repo) aparecen en la respuesta y permiten continuar el trabajo sin salir de Slack.
- Solo funciona en **canales**, no en DMs, y requiere plan **Team o Enterprise** con GitHub conectado.
- **Claude Code en la web** (claude.ai) ofrece una sesión de Claude Code sin instalación local, útil para revisar código desde máquinas sin acceso de instalación.
- La selección automática de repositorio usa el contexto del canal y del hilo; se puede corregir con el botón **Change Repo** o mencionando el repositorio explícitamente en el mensaje.

## Siguiente paso

Continúa con [09-goal-y-self-hosted-runners.md](09-goal-y-self-hosted-runners.md) para aprender a fijar condiciones de finalización en tareas largas con `/goal` y a configurar hooks de ciclo de vida en self-hosted runners.
