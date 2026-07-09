# Requisitos Detallados del Proyecto TaskFlow API

---

## 1. Requisitos Funcionales

### 1.1 Autenticación y Usuarios

#### RF-01: Registro de usuarios
- El sistema debe permitir registrar nuevos usuarios
- Campos obligatorios: `nombre`, `email`, `password`
- El email debe ser único en el sistema
- La password debe tener mínimo 8 caracteres
- La password debe almacenarse hasheada (bcrypt o argon2)
- Respuesta exitosa: usuario creado con id, nombre, email (sin password)

```
POST /api/auth/register
Body: { "nombre": "Ana Garcia", "email": "ana@ejemplo.com", "password": "MiPassword123" }
Response 201: { "id": 1, "nombre": "Ana Garcia", "email": "ana@ejemplo.com" }
Response 400: { "error": "El email ya está registrado" }
```

#### RF-02: Login de usuarios
- El sistema debe permitir autenticarse con email y password
- Debe devolver un token JWT válido
- El token debe expirar en 24 horas
- El token debe contener el id y email del usuario

```
POST /api/auth/login
Body: { "email": "ana@ejemplo.com", "password": "MiPassword123" }
Response 200: { "token": "eyJhbGciOi...", "usuario": { "id": 1, "nombre": "Ana Garcia" } }
Response 401: { "error": "Credenciales inválidas" }
```

#### RF-03: Perfil de usuario
- Un usuario autenticado puede ver su propio perfil
- Requiere token JWT en header Authorization

```
GET /api/auth/perfil
Headers: { "Authorization": "Bearer eyJhbGciOi..." }
Response 200: { "id": 1, "nombre": "Ana Garcia", "email": "ana@ejemplo.com" }
Response 401: { "error": "Token no proporcionado o inválido" }
```

---

### 1.2 Gestión de Tareas

#### RF-04: Crear tarea
- Un usuario autenticado puede crear tareas
- Campos obligatorios: `titulo`
- Campos opcionales: `descripcion`, `estado`, `prioridad`, `asignadoA`
- Estado por defecto: `pendiente`
- Prioridad por defecto: `media`
- El creador se registra automáticamente

```
POST /api/tareas
Headers: { "Authorization": "Bearer ..." }
Body: {
  "titulo": "Implementar login",
  "descripcion": "Crear endpoint de autenticación con JWT",
  "prioridad": "alta",
  "asignadoA": 2
}
Response 201: {
  "id": 1,
  "titulo": "Implementar login",
  "descripcion": "Crear endpoint de autenticación con JWT",
  "estado": "pendiente",
  "prioridad": "alta",
  "creadoPor": 1,
  "asignadoA": 2,
  "creadoEn": "2025-01-15T10:30:00Z",
  "actualizadoEn": "2025-01-15T10:30:00Z"
}
```

#### RF-05: Listar tareas
- Un usuario autenticado puede ver todas las tareas
- Soporta paginación con `pagina` y `limite`
- Soporta filtros por `estado`, `prioridad` y `asignadoA`

```
GET /api/tareas?estado=pendiente&prioridad=alta&pagina=1&limite=10
Headers: { "Authorization": "Bearer ..." }
Response 200: {
  "tareas": [...],
  "total": 25,
  "pagina": 1,
  "limite": 10,
  "totalPaginas": 3
}
```

#### RF-06: Obtener tarea por ID
- Un usuario autenticado puede ver el detalle de una tarea

```
GET /api/tareas/:id
Headers: { "Authorization": "Bearer ..." }
Response 200: { "id": 1, "titulo": "...", ... }
Response 404: { "error": "Tarea no encontrada" }
```

#### RF-07: Actualizar tarea
- Un usuario autenticado puede actualizar cualquier campo de una tarea
- Solo el creador o el asignado pueden actualizar la tarea
- Se actualiza automáticamente el campo `actualizadoEn`

```
PUT /api/tareas/:id
Headers: { "Authorization": "Bearer ..." }
Body: { "estado": "en_progreso", "prioridad": "critica" }
Response 200: { "id": 1, "titulo": "...", "estado": "en_progreso", ... }
Response 403: { "error": "No tienes permiso para modificar esta tarea" }
Response 404: { "error": "Tarea no encontrada" }
```

#### RF-08: Eliminar tarea
- Solo el creador de la tarea puede eliminarla

```
DELETE /api/tareas/:id
Headers: { "Authorization": "Bearer ..." }
Response 200: { "mensaje": "Tarea eliminada correctamente" }
Response 403: { "error": "Solo el creador puede eliminar esta tarea" }
Response 404: { "error": "Tarea no encontrada" }
```

#### RF-09: Marcar tarea como completada
- Atajo para cambiar el estado a `completada`
- Solo el creador o el asignado pueden completar la tarea

```
PATCH /api/tareas/:id/completar
Headers: { "Authorization": "Bearer ..." }
Response 200: { "id": 1, "estado": "completada", ... }
```

---

### 1.3 Enumeraciones

#### Estados válidos
| Valor | Descripción |
|-------|-------------|
| `pendiente` | Tarea creada pero no iniciada |
| `en_progreso` | Tarea en desarrollo |
| `en_revision` | Tarea esperando revisión |
| `completada` | Tarea finalizada |

#### Prioridades válidas
| Valor | Descripción |
|-------|-------------|
| `baja` | Puede esperar |
| `media` | Importancia normal |
| `alta` | Requiere atención pronto |
| `critica` | Requiere atención inmediata |

---

## 2. Requisitos Técnicos

### 2.1 Framework y Lenguaje

Elige **uno** de los siguientes stacks:

| Stack | Framework sugerido | ORM/Driver sugerido |
|-------|-------------------|---------------------|
| **Node.js** | Express o Fastify | Sequelize, Prisma, Knex, o better-sqlite3 |
| **Python** | FastAPI o Flask | SQLAlchemy, Tortoise ORM, o sqlite3 |
| **Go** | Gin o Echo | GORM o database/sql |
| **Java** | Spring Boot | JPA/Hibernate |
| **Rust** | Actix-web o Axum | Diesel o SQLx |

> **Importante:** La solución de referencia usa Node.js + Express + better-sqlite3 + Knex. Pero cualquier stack es válido siempre que cumpla los requisitos funcionales.

### 2.2 Base de Datos

- **Opción simple:** SQLite (un archivo, sin servidor, perfecto para desarrollo)
- **Opción realista:** PostgreSQL (requiere Docker o instalación local)

**Esquema mínimo de tablas:**

```
Tabla: usuarios
- id (PK, autoincrement)
- nombre (string, not null)
- email (string, unique, not null)
- password_hash (string, not null)
- creado_en (timestamp, default now)

Tabla: tareas
- id (PK, autoincrement)
- titulo (string, not null)
- descripcion (text, nullable)
- estado (enum: pendiente|en_progreso|en_revision|completada, default pendiente)
- prioridad (enum: baja|media|alta|critica, default media)
- creado_por (FK -> usuarios.id, not null)
- asignado_a (FK -> usuarios.id, nullable)
- creado_en (timestamp, default now)
- actualizado_en (timestamp, default now)
```

### 2.3 Autenticación

- Usar JWT (JSON Web Tokens)
- Token en header `Authorization: Bearer <token>`
- Middleware de autenticación que valide el token en cada ruta protegida
- Secret del JWT en variable de entorno (nunca hardcodeado)

### 2.4 Validación

- Validar todos los inputs del usuario
- Devolver errores descriptivos con códigos HTTP apropiados
- Usar una librería de validación (Joi, Zod, Pydantic, etc.)

### 2.5 Estructura del Proyecto

Estructura sugerida (adáptala a tu stack):

```
taskflow-api/
  CLAUDE.md
  .claude/
    settings.json
    rules/
      codigo.md
      api.md
  src/
    index.js (o main.py, main.go, etc.)
    config/
      database.js
      auth.js
    middleware/
      autenticacion.js
      validacion.js
      errores.js
    rutas/
      auth.js
      tareas.js
    modelos/
      usuario.js
      tarea.js
    controladores/
      authControlador.js
      tareasControlador.js
    servicios/
      authServicio.js
      tareasServicio.js
  tests/
    unit/
      servicios/
        authServicio.test.js
        tareasServicio.test.js
    integration/
      auth.test.js
      tareas.test.js
    setup.js
  docs/
    openapi.yaml
  Dockerfile
  docker-compose.yml
  .github/
    workflows/
      ci.yml
  .env.example
  .gitignore
  package.json (o equivalente)
  README.md
```

---

## 3. Requisitos de Testing

### 3.1 Tests Unitarios
- Mínimo 5 tests unitarios
- Cubrir lógica de servicios (autenticación, CRUD de tareas)
- Mockear dependencias de base de datos

### 3.2 Tests de Integración
- Mínimo 5 tests de integración
- Probar los endpoints reales con una base de datos de test
- Cubrir flujos completos: registro → login → crear tarea → listar → completar

### 3.3 Cobertura
- Objetivo mínimo: 60% de cobertura
- Objetivo deseable: 80% de cobertura

---

## 4. Requisitos de Documentación

### 4.1 README.md del proyecto
- Descripción del proyecto
- Instrucciones de instalación
- Cómo ejecutar en desarrollo
- Cómo ejecutar tests
- Cómo ejecutar con Docker
- Variables de entorno necesarias

### 4.2 Documentación de API
- Especificación OpenAPI/Swagger (archivo YAML o JSON)
- Debe documentar todos los endpoints
- Incluir ejemplos de request/response
- Documentar códigos de error

### 4.3 Documentación de decisiones
- Registrar por qué se eligió cada tecnología
- Documentar patrones arquitectónicos usados
- Puede ser en el README o en un archivo ARCHITECTURE.md

---

## 5. Requisitos de DevOps

### 5.1 Docker
- `Dockerfile` funcional para la aplicación
- `docker-compose.yml` que incluya la app y la base de datos (si usa PostgreSQL)
- La app debe poder levantarse con `docker compose up`

### 5.2 CI/CD con GitHub Actions
- Workflow que se ejecute en cada push y pull request
- Pasos mínimos:
  1. Instalar dependencias
  2. Ejecutar linter
  3. Ejecutar tests
  4. Build de la imagen Docker

### 5.3 Variables de entorno
- Archivo `.env.example` con todas las variables necesarias
- Nunca commitear `.env` con secretos reales
- Usar variables de entorno para: JWT_SECRET, DATABASE_URL, PORT

---

## 6. Requisitos de Seguridad

### 6.1 Obligatorios
- Passwords hasheadas con bcrypt o argon2
- JWT con expiración
- Validación de inputs para prevenir inyección
- CORS configurado
- Helmet (o equivalente) para headers de seguridad
- Rate limiting en endpoints de autenticación

### 6.2 Deseables (puntos extra)
- Refresh tokens
- Audit log de acciones
- Sanitización de outputs
- Tests de seguridad automatizados

---

## 7. Restricciones Importantes

1. **Todo el código debe generarse usando Claude Code.** No copies código de tutoriales o Stack Overflow. El objetivo es practicar el uso de Claude Code como copiloto.

2. **Documenta tu proceso.** Guarda un registro de los prompts clave que usaste, cuándo hiciste `/clear`, cuándo cambiaste de modelo, etc.

3. **No busques la perfección.** Es mejor tener una API funcional con tests básicos que una API perfecta sin tests ni CI/CD.

4. **El CLAUDE.md es tu aliado.** Actualízalo conforme avanzas. Es tu memoria entre sesiones.

---

## Resumen de Endpoints

| Método | Ruta | Descripción | Auth |
|--------|------|-------------|------|
| POST | `/api/auth/register` | Registrar usuario | No |
| POST | `/api/auth/login` | Login | No |
| GET | `/api/auth/perfil` | Ver perfil propio | Sí |
| POST | `/api/tareas` | Crear tarea | Sí |
| GET | `/api/tareas` | Listar tareas (con filtros) | Sí |
| GET | `/api/tareas/:id` | Detalle de tarea | Sí |
| PUT | `/api/tareas/:id` | Actualizar tarea | Sí |
| DELETE | `/api/tareas/:id` | Eliminar tarea | Sí |
| PATCH | `/api/tareas/:id/completar` | Completar tarea | Sí |

---

**Siguiente paso:** Lee `fases.md` para el plan de trabajo detallado.
