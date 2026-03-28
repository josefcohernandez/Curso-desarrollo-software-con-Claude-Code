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
| **TodoWrite** | Gestionar lista de tareas | Bajo |

---

## Modos de Operación

Claude Code tiene 6 modos de permisos oficiales. Se pueden activar con `--permission-mode <modo>` desde CLI, con `Shift+Tab` durante una sesion interactiva, o persistir en `settings.json` con `"permissions": { "defaultMode": "<modo>" }`.

### 1. default (por defecto)

Comportamiento estandar: pide confirmacion para herramientas que modifican (Write, Edit, Bash) segun la configuracion de permisos.

```bash
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

Auto-deniega herramientas a menos que esten pre-aprobadas via reglas `allow`. Si una herramienta no tiene una regla `allow` explicita, se deniega automaticamente sin preguntar al usuario.

```bash
claude --permission-mode dontAsk
```

Este modo es util cuando se quiere un comportamiento estrictamente controlado: solo se ejecutan las acciones explicitamente permitidas.

### 5. bypassPermissions

**Peligroso**: Salta todos los prompts de permisos, con excepcion de operaciones sobre directorios protegidos (`.git`, `.claude`, `.vscode`, `.idea`). Solo usar en entornos CI/CD controlados.

```bash
claude -p "ejecuta tests" --dangerously-skip-permissions
```

### 6. auto (research preview)

Un clasificador de seguridad basado en IA decide automaticamente si permitir cada accion. Requiere modelos **Claude Sonnet 4.6** o **Claude Opus 4.6**. Ver [05-auto-mode.md](05-auto-mode.md) para detalles completos.

```bash
claude --permission-mode auto
```

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

## Ver y Modificar Permisos

```bash
# En sesión interactiva
/permissions              # Ver permisos actuales

# Desde CLI
claude config list        # Ver toda la config
claude config set permissions.allow '["Read","Glob"]'
```
