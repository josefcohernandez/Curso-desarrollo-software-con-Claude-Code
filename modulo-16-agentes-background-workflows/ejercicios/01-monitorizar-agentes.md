# Ejercicio 01: Monitorizar Agentes en Segundo Plano con Agent View

## Contexto

Trabajas en el equipo de plataforma de una startup y acabas de recibir tres peticiones simultáneas antes de irte a una reunión: auditar las dependencias del proyecto, revisar qué archivos carecen de tests y generar documentación de los endpoints de la API. En vez de hacerlas una a una de forma secuencial, vas a lanzarlas como sesiones background y usar `claude agents` para supervisarlas sin bloquear tu propio trabajo.

---

## Objetivo

Lanzar 2-3 sesiones background simultáneas, monitorizarlas con el dashboard `claude agents` y con su salida `--json`, configurar una notificación cuando terminen, y practicar el flujo de adjuntarte a una sesión para intervenir cuando lo necesite.

---

## Requisitos previos

| Módulo / Fichero | Razón |
|-------------------|-------|
| [M02 - CLI y Primeros Pasos](../../modulo-02-cli-primeros-pasos/README.md) | Comandos básicos y `/resume` |
| [M08 - Hooks](../../modulo-08-hooks/README.md) | Sintaxis de hooks para configurar la notificación |
| [M09 - Subagentes, Skills y Agent Teams](../../modulo-09-agentes-skills-teams/README.md) | Concepto de background agents y `run_in_background` |
| [01-agent-view.md](../teoria/01-agent-view.md) | Teoría de este ejercicio |

Un proyecto de código con el que trabajar (puede ser cualquier repositorio propio, o el propio repositorio de este curso).

---

## Instrucciones paso a paso

1. Abre una sesión interactiva de Claude Code en tu proyecto de prueba:

    ```bash
    cd /ruta/a/tu/proyecto
    claude
    ```

2. Lanza tres agentes en background desde esa sesión, cada uno con un nombre identificable:

    ```text
    > Lanza tres agentes en background:
      - "audit-deps": revisa package.json (o el gestor de dependencias
        de este proyecto) y reporta dependencias desactualizadas
      - "audit-tests": recorre el código fuente y lista los archivos
        o módulos principales que no tienen tests asociados
      - "audit-api": si el proyecto expone una API, lista los endpoints
        que no tienen documentación o comentarios explicativos

      Cada uno debe trabajar de forma independiente y notificarme
      con un resumen cuando termine.
    ```

3. Sin cerrar esa sesión, abre una **segunda terminal** en el mismo directorio y arranca el dashboard:

    ```bash
    cd /ruta/a/tu/proyecto
    claude agents
    ```

4. Observa el listado: deberías ver las tres sesiones (`audit-deps`, `audit-tests`, `audit-api`) junto con tu sesión interactiva original, cada una con su estado.

5. Consulta el mismo listado en formato JSON desde una tercera terminal (o saliendo temporalmente del dashboard):

    ```bash
    claude agents --json
    ```

    Identifica en la salida los campos `status` y `waitingFor` de cada sesión.

6. Filtra el listado por el directorio de tu proyecto:

    ```bash
    claude agents --cwd /ruta/a/tu/proyecto
    ```

7. Escribe un pequeño script que detecte sesiones bloqueadas esperando tu input:

    ```bash
    cat > /tmp/vigilar-agentes.sh << 'EOF'
    #!/bin/bash
    claude agents --json | jq -r '
      .[] | select(.waitingFor != null) |
      "BLOQUEADA: \(.name) — esperando: \(.waitingFor)"
    '
    EOF
    chmod +x /tmp/vigilar-agentes.sh
    /tmp/vigilar-agentes.sh
    ```

    Si alguna de tus tres auditorías necesita permiso para leer un fichero o ejecutar un comando, debería aparecer en la salida de este script.

8. Configura una notificación local para cuando un agente termine o necesite input. Crea (o edita) `.claude/settings.json` en tu proyecto:

    ```json
    {
      "hooks": {
        "Notification": [
          {
            "hooks": [
              {
                "type": "command",
                "command": "bash -c 'cat >> /tmp/notificaciones-agentes.log; echo \"---\" >> /tmp/notificaciones-agentes.log'"
              }
            ]
          }
        ]
      }
    }
    ```

9. Deja que las tres auditorías avancen. Si alguna se bloquea (por ejemplo, pidiendo permiso para ejecutar un comando), adjúntate desde el dashboard `claude agents` para resolverla:

    - Navega hasta la sesión bloqueada en el dashboard
    - Adjúntate (attach)
    - Concede o deniega el permiso solicitado
    - Vuelve al dashboard sin cerrar la sesión background

10. Cuando las tres terminen, revisa el fichero de notificaciones y comprueba que se registraron los eventos:

    ```bash
    cat /tmp/notificaciones-agentes.log
    ```

11. Vuelve a tu sesión interactiva original y pide un resumen consolidado:

    ```text
    > Resume los hallazgos de los tres agentes en background
      (audit-deps, audit-tests, audit-api) en una lista priorizada.
    ```

---

## Criterios de éxito

- Las tres sesiones background aparecen simultáneamente en `claude agents`
- `claude agents --json` devuelve JSON válido y parseable con los campos `status`, `name` y `waitingFor` de cada sesión
- El script `/tmp/vigilar-agentes.sh` detecta correctamente al menos una sesión bloqueada (o confirmas que ninguna se bloqueó, si las auditorías no requerían permisos adicionales)
- El hook `Notification` registra al menos un evento en `/tmp/notificaciones-agentes.log`
- Consigues adjuntarte a una sesión background, resolver un bloqueo si lo hubo, y volver al dashboard sin perder el progreso de la sesión
- Obtienes un resumen final consolidado de los tres agentes desde tu sesión interactiva original

---

## Pistas

1. Si `claude agents` no muestra tus sesiones background, verifica que las estás ejecutando en el mismo directorio de proyecto (o usa `--cwd` sin filtro para ver todas).
2. Si `jq` no está instalado, instálalo con el gestor de paquetes de tu sistema (`apt install jq`, `brew install jq`, etc.) antes del paso 7.
3. Si ninguna de las tres auditorías se bloquea esperando permiso, puedes forzarlo pidiendo a uno de los agentes que ejecute un comando que normalmente requiere confirmación (por ejemplo, instalar una dependencia nueva).
4. El campo exacto del JSON puede variar ligeramente según tu versión de Claude Code; ejecuta `claude agents --json | jq '.[0]'` primero para ver la estructura real antes de escribir el script del paso 7.
5. Si quieres practicar sesiones "pinned" (v2.1.147), consulta la opción correspondiente en el dashboard tras seleccionar una sesión de larga duración.

---

## Solución de referencia

Este ejercicio depende del proyecto y el sistema operativo de cada estudiante, por lo que no existe una única solución de código. El criterio de éxito es funcional: si completas los 11 pasos y cumples los criterios de éxito, el ejercicio está resuelto correctamente.

Si te atascas en el script de vigilancia del paso 7, aquí tienes una versión ampliada que también cuenta sesiones activas por estado:

```bash
#!/bin/bash
# vigilar-agentes-completo.sh
echo "=== Estado de sesiones ($(date)) ==="
claude agents --json | jq -r '
  group_by(.status) |
  map({status: .[0].status, count: length}) |
  .[] | "\(.status): \(.count)"
'
echo ""
echo "=== Sesiones bloqueadas ==="
claude agents --json | jq -r '
  .[] | select(.waitingFor != null) |
  "\(.name) (\(.id)): \(.waitingFor)"
'
```
