# 02 - Sistema de Permisos

## Los 3 Niveles de Permiso

| Nivel | Comportamiento |
|-------|---------------|
| **allow** | Se ejecuta sin preguntar |
| **ask** | Pide confirmación al usuario (por defecto) |
| **deny** | Bloqueado, no se puede ejecutar |

---

## Sintaxis de Permisos

### Por herramienta completa

```json
"allow": ["Read", "Glob", "Grep"]
```

### Por herramienta con patrón

```json
"allow": [
  "Bash(npm test:*)",        // Solo comandos npm test:xxx
  "Bash(git status)",        // Solo git status
  "Edit(src/**)",            // Editar solo en src/
  "Write(tests/**)"          // Escribir solo en tests/
]
```

### Patrones con wildcards

| Patrón | Significado |
|--------|-----------|
| `"Read"` | Todo Read |
| `"Bash(npm *)"` | Cualquier comando npm |
| `"Edit(src/**)"` | Editar archivos en src/ recursivo |
| `"Write(*.test.ts)"` | Escribir solo archivos test |
| `"Bash(git*)"` | Cualquier comando git |

### Sintaxis `Tool(param:value)`: matchear por parámetro de entrada (v2.1.178)

Además de matchear por patrón de argumento posicional (`Bash(npm test:*)`), las reglas de permisos admiten la sintaxis `Tool(param:value)` para matchear por un **parámetro concreto** del input de la tool call. Esto es especialmente útil para herramientas cuyo riesgo depende de un parámetro estructurado y no de un string de comando.

El caso más habitual es controlar qué modelo puede usar un subagente lanzado con la tool `Agent`:

```json
{
  "permissions": {
    "deny": [
      "Agent(model:opus)"
    ]
  }
}
```

Esta regla bloquea cualquier subagente que intente lanzarse usando el modelo `opus`, sin afectar a subagentes que usan `sonnet` o `haiku`. Es útil para limitar el coste cuando varios equipos comparten un proyecto y solo ciertos roles deben poder invocar subagentes con el modelo más caro.

```json
{
  "permissions": {
    "allow": [
      "Agent(model:haiku)",
      "Agent(model:sonnet)"
    ],
    "ask": [
      "Agent(model:opus)"
    ]
  }
}
```

### Patrón glob en la posición del nombre de herramienta (v2.1.166)

Las reglas `deny` admiten el comodín `"*"` en la posición donde normalmente iría el nombre de la herramienta, para bloquear **todas** las tools de golpe:

```json
{
  "permissions": {
    "deny": ["*"]
  }
}
```

Esto es útil en configuraciones `managed-settings.json` muy restrictivas (por ejemplo, una sesión de solo lectura donde ninguna herramienta debería ejecutarse sin revisión), combinado con excepciones explícitas en `allow` a nivel de proyecto o usuario si la jerarquía lo permite. Recuerda que `deny` siempre gana: un `deny: ["*"]` en `managed-settings.json` bloquea cualquier `allow` de niveles inferiores.

---

## Herramientas Disponibles

| Herramienta | Qué hace | Riesgo |
|-------------|---------|--------|
| **Read** | Leer archivos | Bajo |
| **Glob** | Buscar archivos por patrón | Bajo |
| **Grep** | Buscar contenido en archivos | Bajo |
| **Write** | Crear archivos nuevos | Medio |
| **Edit** | Modificar archivos existentes | Medio |
| **Bash** | Ejecutar comandos shell | Alto |
| **WebFetch** | Hacer peticiones HTTP | Medio |
| **WebSearch** | Buscar en internet | Bajo |
| **Task** | Lanzar subagentes | Bajo |
| **Agent** | Lanzar subagentes/teammates con parámetros estructurados (`model`, `name`) — ver [Módulo 09](../../modulo-09-agentes-skills-teams/README.md) | Bajo-Medio (depende del `model`) |
| **TodoWrite** | Gestionar lista de tareas | Bajo |

---

## Modos de Operación

Claude Code tiene 6 modos de permisos oficiales. Se pueden activar con `--permission-mode <modo>` desde CLI, con `Shift+Tab` durante una sesion interactiva, o persistir en `settings.json` con `"permissions": { "defaultMode": "<modo>" }`.

> **Renombrado v2.1.200:** El modo antes llamado **"default"** ahora se llama **"Manual"** en el CLI, en `--help`, y en las extensiones de VS Code y JetBrains. El flag `--permission-mode manual` es el nombre recomendado desde esta versión; `--permission-mode default` se sigue aceptando por retrocompatibilidad, pero la documentación y la interfaz ya usan "Manual" en todas partes. Si ves referencias a "default" en material más antiguo, es el mismo modo que "Manual".

### 1. Manual (antes "default")

Comportamiento estandar: pide confirmacion para herramientas que modifican (Write, Edit, Bash) segun la configuracion de permisos.

```bash
# Nombre actual (recomendado desde v2.1.200)
claude --permission-mode manual

# Nombre anterior, aceptado por retrocompatibilidad
claude --permission-mode default
```

### 2. acceptEdits

Auto-acepta ediciones de archivos (Read + Edit sin preguntar). Bash sigue pidiendo confirmacion.

```bash
claude --permission-mode acceptEdits
```

### 3. plan

Claude puede analizar codigo y ejecutar Bash para explorar el proyecto, pero **no modifica archivos** (no ejecuta Write ni Edit). Escribe un plan de accion que el usuario revisa antes de aplicar.

Activar con `Shift+Tab` durante una sesion interactiva o desde CLI:

```bash
claude --permission-mode plan
```

### 4. dontAsk

Auto-deniega herramientas a menos que estén preaprobadas vía reglas `allow`. Si una herramienta no tiene una regla `allow` explícita, se deniega automáticamente sin preguntar al usuario.

```bash
claude --permission-mode dontAsk
```

Este modo es útil cuando se quiere un comportamiento estrictamente controlado: solo se ejecutan las acciones explícitamente permitidas.

### 5. bypassPermissions

**Peligroso**: Salta todos los prompts de permisos, con excepcion de operaciones sobre directorios protegidos (`.git`, `.claude`, `.vscode`, `.idea`). Solo usar en entornos CI/CD controlados.

```bash
claude -p "ejecuta tests" --dangerously-skip-permissions
```

### 6. auto

Un clasificador de seguridad basado en IA decide automaticamente si permitir cada accion. Requiere modelos **Claude Sonnet 4.6**, **Claude Opus 4.6** o superior. Ver [05-auto-mode.md](05-auto-mode.md) para detalles completos.

```bash
claude --permission-mode auto
```

> **Cambio de comportamiento (v2.1.152):** Auto Mode ya **no requiere una pantalla de consentimiento opt-in** antes de activarse. En versiones anteriores, la primera vez que se activaba Auto Mode en una sesión, Claude Code mostraba un aviso que el usuario debía aceptar explícitamente. Desde v2.1.152, `--permission-mode auto` o `"defaultMode": "auto"` activan el modo directamente, igual que cualquier otro modo de permisos. Ver [05-auto-mode.md](05-auto-mode.md) para el detalle completo de esta y otras novedades recientes de Auto Mode.

---

## Configuración Recomendada por Rol

### Desarrollador Backend

```json
{
  "permissions": {
    "allow": [
      "Read", "Glob", "Grep",
      "Bash(pytest*)", "Bash(python -m pytest*)",
      "Bash(make test*)", "Bash(make lint*)",
      "Bash(git status)", "Bash(git diff*)", "Bash(git log*)",
      "Edit(src/**)", "Write(tests/**)"
    ],
    "deny": [
      "Bash(rm -rf *)", "Bash(sudo *)",
      "Bash(pip install*)",
      "Bash(alembic downgrade*)",
      "Write(config/production*)",
      "Edit(alembic/env.py)"
    ]
  }
}
```

### Desarrollador Frontend

```json
{
  "permissions": {
    "allow": [
      "Read", "Glob", "Grep",
      "Bash(npm test*)", "Bash(npm run lint*)",
      "Bash(npx vitest*)",
      "Bash(git status)", "Bash(git diff*)",
      "Edit(src/**)", "Write(src/components/**)"
    ],
    "deny": [
      "Bash(rm -rf *)", "Bash(sudo *)",
      "Bash(npm publish*)", "Bash(npm install*)",
      "Write(vite.config*)", "Write(.env*)"
    ]
  }
}
```

### DevOps

```json
{
  "permissions": {
    "allow": [
      "Read", "Glob", "Grep",
      "Bash(docker*)", "Bash(kubectl get*)",
      "Bash(terraform plan*)",
      "Edit(infra/**)", "Edit(.github/**)"
    ],
    "deny": [
      "Bash(terraform apply*)",
      "Bash(kubectl delete*)",
      "Bash(docker push*)",
      "Write(.env*)", "Write(*secret*)"
    ]
  }
}
```

### QA

```json
{
  "permissions": {
    "allow": [
      "Read", "Glob", "Grep",
      "Bash(npm test*)", "Bash(pytest*)",
      "Bash(npx playwright*)",
      "Write(tests/**)", "Edit(tests/**)"
    ],
    "deny": [
      "Bash(rm *)", "Bash(sudo *)",
      "Edit(src/**)",
      "Write(src/**)"
    ]
  }
}
```

---

## Regla de Oro: deny Siempre Gana

```
Si CUALQUIER nivel dice deny → BLOQUEADO
No importa si otro nivel dice allow.
deny es absoluto.
```

Ejemplo:

```json
// Project settings
{ "permissions": { "allow": ["Bash(npm install*)"] } }

// Managed settings (empresa)
{ "permissions": { "deny": ["Bash(npm install*)"] } }

// Resultado: npm install BLOQUEADO (deny gana)
```

---

## Comandos bash de solo lectura con globs (v2.1.111)

Los comandos bash que son de solo lectura y usan patrones glob —como `ls src/**/*.ts`, `find . -name "*.json"` o `cat config/*.yaml`— ya no generan prompt de confirmación al usuario aunque la herramienta `Bash` esté catalogada como `ask`. Claude Code los reconoce como operaciones de exploración sin efecto secundario y los ejecuta directamente.

Esto simplifica el workflow en tareas de análisis e inspección del proyecto sin necesidad de añadir reglas `allow` explícitas para cada variante de comando de lectura.

```bash
# Estos comandos ya no piden confirmación aunque Bash sea "ask":
ls src/**/*.ts
find . -name "*.json" -not -path "*/node_modules/*"
cat config/*.yaml
grep -r "TODO" src/**/*.ts
```

Las operaciones que escriben, modifican o ejecutan efectos secundarios siguen requiriendo confirmación o una regla `allow` explícita.

---

## Skill `/less-permission-prompts` (v2.1.111)

Claude Code incluye por defecto el skill `/less-permission-prompts`. Su función es analizar las transcripts de sesiones anteriores para detectar los patrones de herramientas que el usuario ha aprobado repetidamente y proponer una allowlist priorizada lista para añadir a `settings.json`.

```bash
# Dentro de una sesión interactiva
/less-permission-prompts
```

Claude Code examina el historial de confirmaciones y genera una lista ordenada por frecuencia. Las herramientas que has aprobado más veces aparecen primero:

```json
{
  "permissions": {
    "allow": [
      "Bash(npm test*)",
      "Bash(npm run lint*)",
      "Edit(src/**)",
      "Bash(git diff*)",
      "Bash(git status)"
    ]
  }
}
```

Puedes copiar esta lista directamente a tu `.claude/settings.json` o a `~/.claude/settings.json` según si el permiso aplica al proyecto o a tu uso global. Esto reduce la fricción de configurar permisos desde cero y garantiza que la allowlist refleja tu uso real, no una lista genérica.

---

## Ver y Modificar Permisos

```bash
# En sesión interactiva
/permissions              # Ver permisos actuales
/less-permission-prompts  # Analizar historial y proponer allowlist

# Desde CLI
claude config list        # Ver toda la config
claude config set permissions.allow '["Read","Glob"]'
```
