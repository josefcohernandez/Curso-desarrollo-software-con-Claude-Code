# 03 - Agent Teams (Equipos de Agentes)

> **NOTA:** Agent Teams es una funcionalidad **EXPERIMENTAL**. Su API, comportamiento
> y disponibilidad pueden cambiar sin previo aviso. Úsalo con precaución en entornos
> de producción.

## Qué son los Agent Teams

Los **Agent Teams** llevan el concepto de subagentes al siguiente nivel: en lugar de un agente principal que delega tareas puntuales a subagentes temporales, tienes un **equipo persistente** de agentes que colaboran simultáneamente.

### Diferencia con Subagentes

| Aspecto | Subagentes | Agent Teams |
|---------|-----------|-------------|
| Duración | Temporales (una tarea) | Persistentes (toda la sesión) |
| Comunicación | Unidireccional (principal -> sub) | Bidireccional (mailbox) |
| Coordinación | El principal orquesta todo | Lista de tareas compartida |
| Paralelismo | Posible pero ad-hoc | Diseñado para trabajo paralelo |
| Costo | Moderado | Alto (~7x más tokens) |
| Estado | Experimental | Experimental |

### Modelo Mental

```
+----------------------------------------------------+
|                 Agent Team                          |
|                                                     |
|  +----------------+    +----------------+           |
|  |  Team Lead     |    |  Teammate A    |           |
|  |  (tu interfaz) |    |  (Frontend)    |           |
|  |                |    |                |           |
|  | - Recibe tus   |    | - Trabaja en   |           |
|  |   peticiones   |    |   componentes  |           |
|  | - Coordina     |    |   React        |           |
|  | - Delega       |    | - Su propio    |           |
|  |                |    |   CLAUDE.md    |           |
|  +-------+--------+    +-------+--------+           |
|          |                      |                    |
|          |   +-----------+      |                    |
|          +-->| Shared    |<-----+                    |
|          |   | Task List |      |                    |
|          |   +-----------+      |                    |
|          |                      |                    |
|          |   +-----------+      |                    |
|          +-->| Mailbox   |<-----+                    |
|              +-----------+                           |
|                                                     |
|  +----------------+                                  |
|  |  Teammate B    |                                  |
|  |  (Backend)     |                                  |
|  |                |                                  |
|  | - Trabaja en   |                                  |
|  |   API endpoints|                                  |
|  | - Su propio    |                                  |
|  |   CLAUDE.md    |                                  |
|  +----------------+                                  |
+----------------------------------------------------+
```

---

## Habilitar Agent Teams

Agent Teams está detrás de un flag experimental. Para habilitarlo:

### Variable de Entorno

```bash
# En tu shell (temporal)
export CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1

# En tu .bashrc o .zshrc (permanente)
echo 'export CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1' >> ~/.bashrc
```

### Verificar que está Habilitado

Al iniciar Claude Code con la variable habilitada, deberías ver indicadores de que las funciones de equipo están disponibles. Puedes comprobarlo intentando usar el comando `/agents`.

---

## Componentes de un Agent Team

### 1. Team Lead (Líder del Equipo)

El Team Lead es el agente con el que tú interactúas directamente. Sus responsabilidades:

- Recibir tus peticiones y entenderlas
- Decidir cómo dividir el trabajo entre teammates
- Crear y asignar tareas en la lista compartida
- Supervisar el progreso del equipo
- Consolidar resultados y presentártelos

### 2. Teammates (Compañeros de Equipo)

Cada teammate es un agente especializado con:

#### Propia Ventana de Contexto
Cada teammate tiene su propio contexto aislado, similar a un subagente pero persistente durante toda la sesión.

#### Propias Instrucciones (CLAUDE.md)
Cada teammate puede tener su propio archivo de instrucciones que define su especialización:

```markdown
# Teammate: Frontend Developer

## Especialización
Trabajo exclusivamente en el frontend de la aplicación.

## Stack
- React 18 con TypeScript
- TailwindCSS para estilos
- React Query para data fetching
- Vitest para tests

## Reglas
- Seguir los patrones de componentes existentes
- Cada componente debe tener su archivo de test
- Usar hooks personalizados para lógica reutilizable
- NO tocar archivos fuera de src/frontend/
```

#### Lista de Tareas Compartida
Todos los teammates (y el Team Lead) pueden ver y actualizar una lista de tareas común:

```
+--------------------------------------------------+
|          Lista de Tareas Compartida               |
|                                                   |
| [x] Crear esquema de base de datos (Backend)     |
| [>] Implementar endpoint POST /users (Backend)   |
| [>] Crear formulario de registro (Frontend)       |
| [ ] Escribir tests de integración (Tests)         |
| [ ] Documentar API endpoints (Backend)            |
+--------------------------------------------------+
  [x] = completada  [>] = en progreso  [ ] = pendiente
```

#### Mailbox (Buzón de Mensajes)
Los teammates pueden enviarse mensajes entre sí para coordinarse:

```
[Backend -> Frontend]: "El endpoint POST /users ya está listo.
                        Espera un body con {name, email, password}.
                        Devuelve {id, name, email, createdAt}."

[Frontend -> Backend]: "Recibido. Necesito también un endpoint
                        GET /users/:id para la página de perfil."

[Team Lead -> Tests]:  "Backend y Frontend están listos.
                        Puedes empezar con los tests de integración."
```

---

## Crear y Gestionar un Agent Team

### Crear Teammates

```bash
# Usando el comando /agents en una sesión interactiva
> /agents

# Esto abre un menú para:
# 1. Crear un nuevo teammate
# 2. Ver teammates existentes
# 3. Asignar tareas
# 4. Eliminar un teammate
```

### Desde la Línea de Comandos

```bash
# Iniciar Claude Code con agentes predefinidos
claude --agent frontend-dev --agent backend-dev --agent test-runner
```

### Definir Teammates con Archivos

Puedes predefinir tus teammates en `.claude/agents/`:

```
.claude/
  agents/
    frontend-dev.md
    backend-dev.md
    test-writer.md
```

Y lanzarlos como equipo:

```bash
claude --agents frontend-dev,backend-dev,test-writer
```

---

## Modos de Visualización

### Modo in-process (por defecto)

Todos los teammates se ejecutan en el **mismo terminal**. Verás su output intercalado con etiquetas que identifican a cada agente:

```
[Team Lead] Dividiendo la tarea en tres partes...
[Team Lead] Asignando frontend a Teammate-Frontend
[Team Lead] Asignando backend a Teammate-Backend

[Teammate-Frontend] Comenzando trabajo en componente UserForm...
[Teammate-Backend] Creando modelo User en la base de datos...
[Teammate-Frontend] Componente UserForm creado en src/components/UserForm.tsx
[Teammate-Backend] Modelo User creado. Creando endpoint POST /api/users...
```

**Ventajas:**
- No requiere software adicional
- Fácil de seguir para tareas pequeñas

**Desventajas:**
- Output mezclado puede ser confuso con muchos teammates
- Difícil de seguir el progreso individual de cada agente

### Modo tmux

Cada teammate se ejecuta en un **panel separado de tmux**:

```
+----------------------------+----------------------------+
|  [Team Lead]               |  [Teammate-Frontend]       |
|                            |                            |
|  > Coordinando equipo...   |  > Creando UserForm.tsx... |
|  > Asignando tareas...     |  > Añadiendo validación... |
|                            |  > Ejecutando tests...     |
+----------------------------+----------------------------+
|  [Teammate-Backend]        |  [Teammate-Tests]          |
|                            |                            |
|  > Creando modelo User...  |  > Esperando a que         |
|  > Endpoint POST /users... |    Backend y Frontend      |
|  > Añadiendo validación... |    terminen...             |
+----------------------------+----------------------------+
```

**Requisitos:**
```bash
# Instalar tmux si no lo tienes
# Ubuntu/Debian
sudo apt install tmux

# macOS
brew install tmux
```

**Ventajas:**
- Visión clara del progreso de cada teammate
- Puedes hacer scroll en cada panel individualmente
- Experiencia más profesional y organizada

**Desventajas:**
- Requiere tmux instalado
- Consume más recursos de terminal

**Habilitar modo tmux:**
```bash
# Al lanzar el equipo, especificar el modo de display
claude --agents frontend-dev,backend-dev --teammate-mode tmux
```

---

## Modo Delegate (Delegación Autónoma)

En el modo delegate, el Team Lead puede **asignar tareas autónomamente** a los teammates sin tu intervención directa para cada subtarea.

### Cómo Funciona

1. Tú le das una tarea grande al Team Lead:
   > "Implementa la funcionalidad de registro de usuarios completa"

2. El Team Lead automáticamente:
   - Analiza la tarea y la descompone
   - Crea subtareas en la lista compartida
   - Asigna cada subtarea al teammate apropiado
   - Monitoriza el progreso
   - Coordina dependencias entre teammates
   - Te presenta el resultado final

### Flujo de Trabajo con Delegate

```
Tú: "Implementa registro de usuarios"
         |
         v
    Team Lead:
    1. Crea tarea "Modelo User" -> asigna a Backend
    2. Crea tarea "Endpoint POST /users" -> asigna a Backend
    3. Crea tarea "Formulario registro" -> asigna a Frontend
    4. Crea tarea "Tests e2e" -> asigna a Tests
    5. Establece dependencias:
       - Frontend depende de Backend (necesita conocer la API)
       - Tests dependen de Frontend + Backend
         |
         v
    Teammates trabajan en paralelo (donde es posible)
         |
         v
    Team Lead: "Registro de usuarios implementado.
                Backend: modelo + 2 endpoints creados.
                Frontend: formulario con validación.
                Tests: 8 tests e2e pasando."
```

---

## Advertencia sobre Costos

> **MUY IMPORTANTE:** Los Agent Teams consumen significativamente más tokens que
> una sesión estándar de Claude Code.

### Estimación de Consumo

| Configuración | Consumo relativo |
|--------------|-----------------|
| Sesión estándar (sin subagentes) | 1x |
| Sesión con subagentes ocasionales | 1.5-2x |
| Agent Team (2 teammates, modo plan) | ~5x |
| Agent Team (3 teammates, modo plan) | ~7x |
| Agent Team (3 teammates, modo delegate) | ~7-10x |

### Por qué es Tan Alto

- Cada teammate mantiene su propia ventana de contexto activa
- La lista de tareas compartida se sincroniza continuamente
- Los mensajes del mailbox consumen tokens en cada agente que los lee
- El Team Lead consume tokens al coordinar y supervisar

### Estrategias para Reducir Costos

1. **Usa Sonnet para los teammates:**
   ```bash
   # El Team Lead usa Opus, los teammates usan Sonnet
   claude --model opus --teammate-model sonnet
   ```

2. **Minimiza el equipo:** Usa solo los teammates estrictamente necesarios

3. **Cierra teammates cuando terminen:** No mantengas teammates ociosos

4. **Establece límites de tokens:** Monitoriza el consumo activamente

---

## Hooks para Agent Teams

Los Agent Teams introducen hooks específicos para la coordinación:

### TeammateIdle

Se dispara cuando un teammate no tiene tareas asignadas:

```json
{
  "hook": "TeammateIdle",
  "teammate": "frontend-dev",
  "action": "assign_new_task_or_dismiss"
}
```

**Uso típico:** Asignar automáticamente nuevas tareas de un backlog, o finalizar al teammate si no hay más trabajo.

### TaskCompleted

Se dispara cuando un teammate completa una tarea de la lista compartida:

```json
{
  "hook": "TaskCompleted",
  "teammate": "backend-dev",
  "task": "Implementar endpoint POST /users",
  "action": "notify_dependents"
}
```

**Uso típico:** Notificar a otros teammates que una dependencia está lista, o disparar la siguiente fase del trabajo.

---

## Buenas Prácticas para Agent Teams

### 1. Mantener Equipos Pequeños

```
BIEN:  Team Lead + 2 teammates (Frontend + Backend)
BIEN:  Team Lead + 2 teammates (Implementación + Tests)
MAL:   Team Lead + 5 teammates (demasiado overhead de coordinación)
```

**Regla general:** 2-3 teammates máximo. Más allá de eso, el costo de coordinación supera el beneficio del paralelismo.

### 2. Usar Modelos Económicos para Teammates

El Team Lead necesita ser inteligente (Opus) para coordinar bien. Los teammates pueden usar modelos más baratos:

```
Team Lead:  Opus    (coordinación compleja)
Teammate A: Sonnet  (implementación estándar)
Teammate B: Sonnet  (implementación estándar)
Teammate C: Haiku   (tareas simples, formateo, búsqueda)
```

### 3. Limpiar Equipos al Terminar

No dejes teammates corriendo sin tareas. Cierra el equipo cuando el trabajo esté completo:

```bash
# Finalizar un teammate específico
> /agents dismiss frontend-dev

# Finalizar todo el equipo
> /agents dismiss-all
```

### 4. Usar Teams para Trabajo Genuinamente Paralelo

```
BUEN USO:
- Frontend y Backend trabajan en paralelo en la misma feature
- Implementación y documentación simultáneas
- Múltiples módulos independientes al mismo tiempo

MAL USO:
- Tareas secuenciales (primero A, luego B, luego C)
- Una sola tarea que no se puede descomponer
- Tareas triviales que un solo agente haría en segundos
```

### 5. Definir Instrucciones Claras para Cada Teammate

Cuanto más específicas sean las instrucciones de cada teammate, mejor será su rendimiento y menos tokens desperdiciará:

```markdown
# Teammate: API Developer

## Alcance
SOLO trabajar en archivos dentro de src/api/ y src/models/

## NO hacer
- No modificar archivos de frontend
- No modificar configuración de infraestructura
- No ejecutar despliegues

## Patrones a seguir
- Controladores en src/api/controllers/
- Modelos en src/models/
- Validación con Zod en src/api/validators/
- Tests en tests/api/
```

---

## Configuraciones de Equipo de Ejemplo

### Equipo 1: Frontend + Backend + Tests

```
Team Lead: Coordina la implementación de una feature completa

Teammate "frontend":
  - Trabaja en componentes React
  - Conecta con la API
  - Escribe tests unitarios de componentes

Teammate "backend":
  - Crea modelos y migraciones
  - Implementa endpoints REST/GraphQL
  - Escribe tests unitarios de API

Teammate "qa":
  - Escribe tests de integración/e2e
  - Verifica que frontend y backend interactúan correctamente
  - Reporta bugs encontrados vía mailbox
```

### Equipo 2: Feature Developer + Code Reviewer

```
Team Lead: Gestiona el flujo de desarrollo + revisión

Teammate "developer":
  - Implementa la feature solicitada
  - Escribe tests
  - Crea commits atómicos

Teammate "reviewer":
  - Revisa el código del developer
  - Identifica problemas y sugiere mejoras
  - Verifica que se siguen las convenciones del proyecto
```

### Equipo 3: Implementación + Documentación

```
Team Lead: Coordina implementación y documentación simultáneas

Teammate "implementor":
  - Escribe el código de la feature
  - Crea tests
  - Actualiza CHANGELOG

Teammate "documenter":
  - Actualiza la documentación de la API
  - Escribe guías de uso
  - Actualiza el README si es necesario
  - Añade JSDoc/docstrings al código nuevo
```

---

## Ejemplo Completo: Flujo de Trabajo con Agent Team

### Escenario

Tu equipo necesita implementar un sistema CRUD de "Productos" con:
- API REST (backend)
- Interfaz de administración (frontend)
- Tests completos

### Paso a Paso

**1. Habilitar la funcionalidad:**
```bash
export CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1
```

**2. Lanzar el equipo:**
```bash
claude --agents backend-dev,frontend-dev --teammate-mode tmux
```

**3. Dar la instrucción al Team Lead:**
```
"Implementa un CRUD completo de Productos. El backend debe tener endpoints
REST para GET/POST/PUT/DELETE en /api/products. El frontend debe tener una
tabla listado con paginación y un formulario para crear/editar productos.
Ambos deben tener tests."
```

**4. El Team Lead descompone y asigna:**
```
Lista de Tareas Compartida:
  [Backend] Crear modelo Product (name, price, description, stock)
  [Backend] Implementar GET /api/products (con paginación)
  [Backend] Implementar POST /api/products
  [Backend] Implementar PUT /api/products/:id
  [Backend] Implementar DELETE /api/products/:id
  [Backend] Escribir tests de API
  [Frontend] Crear componente ProductTable con paginación
  [Frontend] Crear componente ProductForm (crear/editar)
  [Frontend] Conectar con la API usando React Query
  [Frontend] Escribir tests de componentes
```

**5. Teammates trabajan en paralelo:**
```
[Backend]  > Creando modelo Product...
[Frontend] > Preparando estructura de componentes...
[Backend]  > Modelo creado. Implementando endpoints...
[Frontend] > ProductTable creado. Esperando definición de API...
[Backend -> Frontend vía mailbox]: "API lista. GET /api/products
             devuelve {data: Product[], total: number, page: number}"
[Frontend] > Conectando ProductTable con la API...
```

**6. Team Lead presenta el resultado:**
```
"CRUD de Productos implementado:
 - Backend: 5 endpoints REST, modelo con validación, 12 tests pasando
 - Frontend: tabla con paginación, formulario con validación, 8 tests pasando
 - Archivos creados: [lista de archivos]"
```

---

## Limitaciones Actuales

Como funcionalidad experimental, Agent Teams tiene algunas limitaciones:

1. **Estabilidad:** Puede haber errores inesperados o cierres abruptos
2. **Costo:** El consumo de tokens es significativamente mayor
3. **Complejidad:** La coordinación entre agentes no siempre es perfecta
4. **Depuración:** Cuando algo falla, es más difícil diagnosticar qué pasó
5. **Rendimiento:** Con muchos teammates, el sistema puede volverse lento
6. **API inestable:** Los comandos y parámetros pueden cambiar entre versiones

---

## Resumen

| Concepto | Descripción |
|----------|-------------|
| Agent Team | Equipo de agentes que colaboran en paralelo |
| Team Lead | Agente principal que coordina al equipo |
| Teammate | Agente especializado con su propio contexto |
| Shared Task List | Lista de tareas visible para todos los agentes |
| Mailbox | Sistema de mensajes entre agentes |
| in-process | Todos en el mismo terminal (por defecto) |
| tmux | Cada teammate en un panel separado |
| Delegate mode | Team Lead asigna tareas autónomamente |
| Habilitación | `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` |
| Costo | ~7x más tokens que una sesión estándar |
| Equipo ideal | 2-3 teammates máximo |
| TeammateIdle hook | Se dispara cuando un teammate no tiene trabajo |
| TaskCompleted hook | Se dispara cuando se completa una tarea |
