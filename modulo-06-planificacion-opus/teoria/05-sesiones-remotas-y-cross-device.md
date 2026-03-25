# 05 - Sesiones Remotas y Workflows Cross-Device

Claude Code no requiere que estés físicamente delante de tu máquina de desarrollo. Puedes iniciar una sesión en la interfaz web (claude.ai) y continuarla en tu terminal local, o al revés: abrir una sesión desde el terminal y acceder a ella desde un navegador.

## Conceptos clave

### Sesiones remotas: trabajar desde cualquier sitio

Esto es útil cuando:
- Cambias de máquina durante el día (oficina, casa, laptop de viaje)
- Quieres compartir una sesión activa con un compañero para hacer pair programming
- Necesitas iniciar trabajo rápido desde un dispositivo sin Claude Code instalado (tablet, PC de préstamo)
- Lanzas una tarea larga y quieres desconectarte mientras sigue ejecutando en la nube

### El flag `--remote`

`--remote` crea una sesión en la infraestructura de Anthropic — una VM aislada con acceso al repositorio — y te devuelve un enlace para acceder a ella desde cualquier navegador.

```bash
claude --remote
```

Al ejecutar este comando Claude Code muestra una URL. Abrirla en el navegador abre la sesión con el estado completo: historial, contexto y herramientas.

**Casos de uso típicos:**

- Trabajar desde una tablet o un dispositivo sin Claude Code instalado
- Iniciar una tarea larga (refactoring de módulo entero, migración de base de datos) y dejar que corra en la nube mientras tu máquina está apagada
- Compartir la sesión con un compañero para revisar el trabajo en tiempo real

### El flag `--teleport`

`--teleport` va en la dirección contraria: reanuda en tu terminal local una sesión que está corriendo en la infraestructura web. Trae el contexto completo de vuelta a tu máquina, con acceso a tu filesystem, herramientas locales y variables de entorno.

```bash
claude --teleport
```

Claude Code lista las sesiones remotas activas y te permite seleccionar cuál continuar.

**Caso de uso típico:**

Empezaste la planificación desde claude.ai en el móvil durante el desplazamiento. Al llegar a la oficina, ejecutas `--teleport` y continúas exactamente donde lo dejaste, pero ahora con acceso a tu repositorio local y a todas tus herramientas.

### El flag `--fallback-model`

Cuando el modelo principal no está disponible o su latencia es demasiado alta (por saturación o mantenimiento), Claude Code puede cambiar automáticamente a un modelo de respaldo.

```bash
claude --model claude-opus-4-6 --fallback-model claude-sonnet-4-6
```

Si Opus no responde dentro del umbral de latencia configurado, la sesión continúa con Sonnet sin interrupciones. Esto es especialmente útil en momentos de alta demanda global o en pipelines de CI/CD donde la interrupción del agente tiene coste alto.

También puedes configurarlo de forma permanente en el fichero de settings del proyecto:

```json
{
  "model": "claude-opus-4-6",
  "fallbackModel": "claude-sonnet-4-6"
}
```

## Ejemplos prácticos

### Patrón "Inicio en web, termino en local"

Útil para empezar rápido desde un dispositivo móvil y luego continuar con todas las herramientas disponibles.

```bash
# Paso 1: En el móvil o tablet, abrir claude.ai y comenzar la planificación
# (no requiere instalar nada)

# Paso 2: Al llegar a la máquina de desarrollo, reanudar la sesión en local
claude --teleport

# Paso 3: Continuar con acceso completo al filesystem y herramientas
> "Ahora implementa el plan que diseñamos antes en el fichero src/auth/service.ts"
```

### Patrón "Sesión compartida para pair programming"

Útil para revisiones de código o debugging en pareja sin necesidad de compartir pantalla.

```bash
# Developer A: crea la sesión remota
claude --remote
# Output: Sesión disponible en https://claude.ai/code/session/abc123

# Developer A comparte el enlace con Developer B
# Developer B abre la URL en su navegador y ve la sesión en tiempo real
# Ambos pueden leer el estado, Developer A mantiene el control de entrada
```

### Patrón "Trabajo nocturno"

Útil para tareas largas que no requieren supervisión continua.

```bash
# Al final de la jornada: iniciar tarea larga en sesión remota
claude --remote --model claude-opus-4-6
> "Refactoriza el módulo de pagos en src/payments/ para separar
>  la lógica de negocio de la capa de infraestructura.
>  Sigue el patrón repositorio. Ejecuta los tests al finalizar cada fichero."

# Desconectarse. La sesión sigue ejecutando en la VM de Anthropic.

# Al día siguiente: revisar resultado en el navegador o retomar en local
claude --teleport
> "Resume el estado: qué ficheros modificaste y cuáles tests pasaron?"
```

### Configurar fallback para pipelines críticos

En un entorno de CI/CD donde Claude Code actúa como agente de revisión:

```bash
# En el script de CI
export CLAUDE_CODE_EFFORT_LEVEL=medium
claude \
  --model claude-opus-4-6 \
  --fallback-model claude-sonnet-4-6 \
  -p "Revisa el diff de este PR y reporta problemas de seguridad o regresiones"
```

Si Opus está saturado en ese momento, Sonnet toma el relevo y el pipeline no falla.

## Errores comunes

**Intentar usar `--teleport` con una sesión ya cerrada**: `--teleport` requiere que la sesión remota siga activa. Si la sesión expiró o fue cerrada manualmente, el contexto no está disponible. Guarda siempre un resumen del estado antes de desconectarte de sesiones largas.

**Esperar acceso completo al filesystem local desde una sesión remota**: Las sesiones creadas con `--remote` corren en una VM aislada. Solo tienen acceso al repositorio que se subió al iniciar la sesión. Cambios en tu filesystem local no son visibles hasta que hagas `--teleport`.

**No configurar `--fallback-model` en tareas críticas**: Si Opus no está disponible y no hay fallback configurado, el agente falla. En pipelines de CI/CD o tareas largas, configura siempre un fallback.

**Confundir sesiones remotas con sincronización automática**: Las sesiones remotas no sincronizan cambios de vuelta a tu repositorio local automáticamente. Necesitas hacer `git pull` o usar `--teleport` para integrar los cambios.

## Remote Control: control desde cualquier dispositivo

> **Novedad v3.0 (research preview, macOS only)**

Remote Control es una evolución de las sesiones remotas que permite **conectar la app de claude.ai/code, la app iOS o la app Android** directamente a tu sesión local de Claude Code. A diferencia de `--remote`, aquí la sesión se ejecuta en tu máquina local — Remote Control simplemente la expone para control externo.

### Cómo funciona

```bash
# En tu terminal local
/remote-control
# Claude Code muestra un código QR o enlace para conectar
```

Al conectar desde claude.ai/code o la app móvil, la sesión mantiene acceso completo a tu entorno local:
- Filesystem, herramientas, MCP servers y configuración locales
- Variables de entorno del proyecto
- La conversación se sincroniza en tiempo real entre dispositivos

### Diferencias con `--remote`

| | `--remote` | Remote Control |
|-|-----------|----------------|
| Ejecución | VM en la nube | Tu máquina local |
| Acceso a filesystem | Solo repo subido | Completo (es local) |
| Caso de uso | Trabajo sin máquina | Control desde móvil/web |
| Disponibilidad | General | Research preview, macOS |

### Computer Use + Remote Control

Computer Use es la capacidad de Claude para controlar el teclado, ratón y navegador de tu máquina. Combinado con Remote Control, puedes:

1. Enviar instrucciones desde el móvil
2. Claude ejecuta acciones en tu desktop (abrir apps, interactuar con la UI, navegar)
3. Observar el resultado en tiempo real desde el móvil

```
Ejemplo: Desde tu teléfono le dices a Claude "Abre VS Code, navega a src/auth/
y ejecuta los tests de ese módulo". Claude controla tu máquina local y lo hace.
```

> Computer Use se cubre en detalle en el [Módulo 13](../../modulo-13-multimodalidad-notebooks/teoria/05-voice-y-computer-use.md).

---

## Resumen

- `--remote` crea una sesión en la nube de Anthropic accesible desde cualquier navegador
- `--teleport` reanuda una sesión remota activa en tu terminal local con acceso al filesystem
- **Remote Control** conecta apps externas (web/iOS/Android) a tu sesión local, manteniendo acceso completo al entorno
- **Computer Use** permite a Claude controlar teclado, ratón y navegador de tu máquina, combinable con Remote Control
- Las sesiones remotas permiten compartir trabajo, continuar desde otros dispositivos y ejecutar tareas largas sin supervisión
- `--fallback-model` garantiza continuidad cuando el modelo principal no está disponible
- Las sesiones remotas tienen acceso limitado al filesystem local: solo el repositorio subido al inicio
