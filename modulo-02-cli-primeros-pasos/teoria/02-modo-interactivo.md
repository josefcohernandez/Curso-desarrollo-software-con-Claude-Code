# 02 - Modo Interactivo y Slash Commands

## Introducción

El modo interactivo es el modo principal de Claude Code. Abres una sesión conversacional
donde puedes dar instrucciones, Claude ejecuta acciones y tú revisas los resultados.

---

## Iniciar una Sesión Interactiva

```bash
cd /ruta/a/tu/proyecto
claude                    # Sesión nueva
claude --resume           # Continuar última sesión
claude --resume <id>      # Continuar sesión específica
```

Al iniciar, Claude Code:
1. Lee archivos CLAUDE.md del proyecto (si existen)
2. Carga configuración de `.claude/settings.json`
3. Conecta servidores MCP configurados
4. Muestra el prompt interactivo `>`

---

## Atajos de Teclado

| Atajo | Acción |
|-------|--------|
| `Enter` | Enviar mensaje |
| `Shift+Enter` / `\` | Nueva línea (no enviar) |
| `Shift+Tab` | Alternar modo Plan / Normal |
| `Tab` | Seleccionar sugerencia / autocompletar archivos |
| `Esc` | Cancelar operación en curso |
| `Esc (doble)` | Salir de la sesión |
| `Ctrl+C` | Cancelar / Interrumpir |
| `Alt+T` | Toggle Extended Thinking |
| `Ctrl+L` | Limpiar pantalla (no contexto) |

---

## Slash Commands

Los slash commands son acciones integradas que no consumen tokens de la API.

> **Tip:** El comando `/powerup` (v2.1.90) ofrece **lecciones interactivas con demos animadas** de las funcionalidades de Claude Code. Es una forma rápida de descubrir features que quizás no conocías. Ejecuta `/powerup` desde el prompt interactivo para explorar las lecciones disponibles.

### Comandos de Sesión

| Comando | Descripción |
|---------|------------|
| `/clear` | Limpiar contexto completo. Esencial entre tareas. |
| `/compact [instrucción]` | Resumir conversación. Opcionalmente con foco. |
| `/exit` | Salir de la sesión |
| `/resume` | Continuar sesión anterior |
| `/logout` | Cerrar sesión de Claude Code (desautentica el cliente) |

### Comandos de Información

| Comando | Descripción |
|---------|------------|
| `/help` | Mostrar ayuda |
| `/cost` | Ver el coste acumulado de la sesión: tokens consumidos y coste estimado en USD |
| `/model` | Ver o cambiar modelo actual |
| `/doctor` | Diagnosticar problemas de configuración, conexión y permisos. Útil cuando algo no funciona como se espera |
| `/status` | Estado de la sesión |

### Comandos de Configuración

| Comando | Descripción |
|---------|------------|
| `/init` | Crear archivo CLAUDE.md del proyecto |
| `/permissions` | Ver/modificar permisos |
| `/mcp` | Ver servidores MCP activos |
| `/config` | Ver configuración actual |
| `/memory` | Gestionar memoria automática |

### Comandos de Modo

| Comando | Descripción |
|---------|------------|
| `/plan` | Activar modo planificación |
| `Shift+Tab` | Alternar Plan/Normal (atajo) |

---

## Modos de Operación

### Modo Normal (por defecto)
Claude puede leer archivos, ejecutar comandos y editar código.
Pide confirmación para acciones de escritura según permisos.

### Modo Plan (Shift+Tab o /plan)
Claude **solo propone** cambios sin ejecutarlos.
Ideal para revisar antes de implementar.

### Auto-accept Edits
Acepta automáticamente ediciones de archivos.
Útil cuando confías en las sugerencias y quieres velocidad.

---

## Referenciando Archivos

Puedes referenciar archivos directamente en tus mensajes:

```
> Revisa el archivo src/auth/login.ts
> Compara src/old.js con src/new.js
> Lee el package.json y dime las dependencias
```

Claude Code resuelve rutas relativas al directorio del proyecto.
También puedes arrastrar archivos al terminal en la extensión de VS Code.

---

## Flujo Típico de Trabajo

```
1. claude                           # Iniciar sesión
2. "Implementa endpoint POST /users"  # Dar instrucción
3. [Claude propone y ejecuta]       # Observar
4. "¿Los tests pasan?"              # Verificar
5. /cost                           # Ver consumo
6. /clear                          # Limpiar para nueva tarea
7. "Ahora crea el endpoint GET..."  # Nueva tarea limpia
8. /exit                           # Terminar
```

---

## Consumo de Tokens en Modo Interactivo

| Evento | Tokens consumidos |
|--------|------------------|
| Inicio de sesión | ~1,000-3,000 (CLAUDE.md, system prompt) |
| Cada mensaje tuyo | ~50-500 (tu texto + overhead) |
| Claude lee un archivo | ~500-5,000 (según tamaño) |
| Claude ejecuta un comando | ~200-2,000 (comando + output) |
| Claude edita un archivo | ~500-2,000 (old + new + contexto) |

> **Tip**: Usa `/cost` frecuentemente para monitorizar el consumo.
