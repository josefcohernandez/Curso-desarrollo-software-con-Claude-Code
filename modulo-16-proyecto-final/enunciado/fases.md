# Fases del Proyecto TaskFlow API

Cada fase del proyecto está diseñada para ejercitar las habilidades de capítulos específicos del libro. Sigue las fases en orden: cada una construye sobre la anterior.

> **Nota:** Este proyecto aplica las metodologías de desarrollo con IA descritas en el Capítulo 12: Spec-Driven Development para definir requisitos, Gherkin para escribir historias de usuario como especificación ejecutable, y TDD para implementar con tests primero.

---

## Fase 1: Preparación del Entorno (Capítulos 4 y 5)

**Duración estimada:** 30-45 minutos

**Objetivo:** Configurar Claude Code para que sea máximamente efectivo en este proyecto.

### Paso 1.1: Inicializar el proyecto

```bash
mkdir taskflow-api
cd taskflow-api
git init
```

### Paso 1.2: Crear el CLAUDE.md

Este es el paso más importante de todo el proyecto. Un buen `CLAUDE.md` hará que Claude Code sea mucho más efectivo durante toda la implementación.

Tu `CLAUDE.md` debe incluir:

- **Descripción del proyecto** (1-2 líneas)
- **Stack tecnológico** elegido
- **Convenciones de código** (idioma de variables, estilo, formateo)
- **Estructura de directorios** planeada
- **Comandos frecuentes** (ejecutar, test, lint, build)
- **Patrones a seguir** (ej: siempre usar async/await, nunca callbacks)
- **Patrones a evitar** (ej: no usar `var`, no usar `any` en TypeScript)

> **Consejo (Capítulo 04):** Recuerda que CLAUDE.md debe ser conciso. No escribas un libro; escribe una referencia rápida. Claude lo lee en CADA mensaje, así que cada línea tiene un costo en tokens.

### Paso 1.3: Configurar .claude/settings.json

Configura los permisos que Claude necesitará:

```json
{
  "permissions": {
    "allow": [
      "Bash(npm install:*)",
      "Bash(npm run:*)",
      "Bash(npm test:*)",
      "Bash(npx:*)",
      "Bash(mkdir:*)",
      "Bash(docker:*)",
      "Bash(git add:*)",
      "Bash(git commit:*)"
    ],
    "deny": [
      "Bash(rm -rf /)",
      "Bash(git push --force:*)"
    ]
  }
}
```

> **Consejo (Capítulo 05):** Piensa bien qué permisos necesita Claude. Ser demasiado restrictivo te obligará a aprobar cada comando manualmente. Ser demasiado permisivo es un riesgo de seguridad.

### Paso 1.4: Crear reglas de proyecto en .claude/rules/

Crea al menos dos archivos de reglas:

**`.claude/rules/codigo.md`** - Convenciones de código:
```markdown
- Usar nombres de variables y funciones en español para la lógica de negocio
- Usar nombres en inglés para elementos técnicos (middleware, router, etc.)
- Todas las funciones asíncronas deben tener manejo de errores try/catch
- Los errores deben propagarse con mensajes descriptivos
- Nunca hacer console.log en producción; usar un logger
```

**`.claude/rules/api.md`** - Convenciones de API:
```markdown
- Todos los endpoints deben devolver JSON
- Los errores deben tener formato: { "error": "mensaje descriptivo" }
- Usar códigos HTTP semánticos: 200, 201, 400, 401, 403, 404, 500
- Las respuestas de listado deben incluir paginación
- Los timestamps deben ser ISO 8601
```

### Paso 1.5: Inicializar el proyecto con el stack elegido

Pide a Claude que inicialice el proyecto:

```
Inicializa un proyecto Node.js con Express para una API REST.
Configura: eslint, prettier, nodemon para desarrollo, jest para tests.
Crea la estructura de directorios según nuestro CLAUDE.md.
```

### Checklist de la Fase 1

- [ ] Directorio del proyecto creado con git init
- [ ] `CLAUDE.md` creado y revisado
- [ ] `.claude/settings.json` configurado
- [ ] Al menos 2 archivos en `.claude/rules/`
- [ ] Proyecto inicializado con dependencias básicas
- [ ] `.gitignore` configurado
- [ ] `.env.example` creado
- [ ] Primer commit realizado

---

## Fase 2: Especificación y Diseño (Capítulos 6 y 12)

**Duración estimada:** 45-60 minutos

**Objetivo:** Aplicar Spec-Driven Development y Gherkin para definir requisitos antes de implementar, y usar Plan Mode para diseñar la arquitectura.

### Paso 2.1: Crear la especificación técnica (SDD - Capítulo 12)

Usa la metodología Spec-Driven Development del Capítulo 12. Pide a Claude que te entreviste:

```
Vamos a crear la especificación técnica (SPEC.md) para TaskFlow API usando
Spec-Driven Development. Entrevístame para entender los requisitos.

El proyecto es una API REST de gestión de tareas con:
- Autenticación JWT
- CRUD de tareas con filtros y paginación
- Base de datos SQLite
```

Claude te hará preguntas sobre decisiones técnicas. Responde y al final generará un `SPEC.md` completo.

### Paso 2.2: Escribir historias de usuario en Gherkin (Capítulo 12)

Con la spec definida, genera las historias de usuario en formato Gherkin:

```
A partir de SPEC.md, genera historias de usuario en formato Gherkin para:
1. features/auth.feature - Registro y login de usuarios
2. features/tareas.feature - CRUD completo de tareas
3. features/filtros.feature - Filtrado y paginación

Cada feature debe incluir:
- Background con precondiciones
- Escenarios de camino feliz (happy path)
- Escenarios de error y validación
- Scenario Outline para casos parametrizados
- Edge cases
```

> **Consejo (Capítulo 12):** Las features Gherkin serán la base para generar tests automáticamente en la Fase 4. Cada Scenario se convertirá en exactamente 1 test.

### Paso 2.3: Activar Plan Mode para arquitectura

```
Cambia a Plan Mode (Shift+Tab hasta ver "Plan")
Asegúrate de estar usando Opus como modelo para planificación
```

### Paso 2.4: Solicitar el diseño arquitectónico

Dale a Claude este prompt en Plan Mode:

```
Tenemos SPEC.md con los requisitos y features/ con las historias Gherkin.
Diseña la arquitectura para TaskFlow API:

- La estructura de capas (rutas -> controladores -> servicios -> modelos)
- El esquema de la base de datos
- El flujo de autenticación
- La estrategia de manejo de errores
- La estrategia de testing (TDD desde los escenarios Gherkin)

NO implementes nada todavía. Solo diseña y justifica cada decisión.
```

### Paso 2.5: Revisar y refinar el plan

Lee el plan cuidadosamente. Pregunta a Claude sobre decisiones que no entiendas:

```
¿Por qué elegiste ese patrón para el manejo de errores? ¿Qué alternativas consideraste?
```

```
¿Cómo se verá el flujo completo de una petición desde que llega al servidor hasta que se devuelve la respuesta?
```

### Paso 2.6: Aprobar el plan y documentar

Una vez satisfecho, aprueba el plan y documenta las decisiones:

```
Crea un archivo ARCHITECTURE.md con las decisiones de diseño que acabamos de tomar.
Incluye diagramas en texto (ASCII) si ayudan a explicar la arquitectura.
```

### Checklist de la Fase 2

- [ ] `SPEC.md` creado con Spec-Driven Development
- [ ] Features Gherkin escritas en `features/` (mínimo 3 archivos)
- [ ] Cada feature tiene escenarios happy path, error y edge cases
- [ ] Plan Mode activado con Opus para arquitectura
- [ ] Diseño arquitectónico generado y revisado
- [ ] Al menos 2 preguntas hechas sobre el diseño
- [ ] Plan aprobado
- [ ] `ARCHITECTURE.md` creado
- [ ] `CLAUDE.md` actualizado con las decisiones de arquitectura

---

## Fase 3: Implementación con TDD (Capítulos 2, 3, 6 y 12)

**Duración estimada:** 1.5-2.5 horas

**Objetivo:** Implementar la API usando TDD desde los escenarios Gherkin, gestionando contexto y tokens eficientemente.

### Estrategia General

Aplica el ciclo **Red → Green → Refactor** (Capítulo 12) para cada funcionalidad:

1. **Red:** Genera tests desde los escenarios Gherkin de `features/`
2. **Green:** Implementa el mínimo código para pasar los tests
3. **Refactor:** Mejora el código sin romper tests

Orden de implementación:

1. Configuración de base de datos y modelos
2. Autenticación (registro + login) — desde `features/auth.feature`
3. Middleware de autenticación
4. CRUD de tareas — desde `features/tareas.feature`
5. Filtros y paginación — desde `features/filtros.feature`
6. Manejo de errores global

> **Importante (Capítulo 03):** Haz `/clear` entre cada funcionalidad mayor. Esto libera contexto y reduce costos. Claude tiene tu `CLAUDE.md` para mantener el contexto esencial.
>
> **Importante (Capítulo 12):** Escribe tests ANTES del código. Cada Scenario Gherkin debe convertirse en exactamente 1 función de test. Los Scenario Outline generan tests parametrizados.

### Paso 3.1: Base de datos y modelos

```
Implementa la configuración de la base de datos SQLite y crea los modelos
de usuario y tarea según el esquema que diseñamos en la arquitectura.
Incluye migraciones o setup inicial de las tablas.
```

Después de que Claude implemente, verifica que funciona:
```bash
# Prueba rápida
node src/config/database.js
```

**Haz `/clear` antes de continuar.**

### Paso 3.2: Autenticación (TDD desde Gherkin)

Aplica el ciclo TDD usando los escenarios de `features/auth.feature`:

```
Paso 1 (Red): Lee features/auth.feature y genera tests en tests/ que
implementen cada escenario Gherkin. Cada Scenario = 1 test.
Los tests deben FALLAR porque no hay implementación.

Paso 2 (Green): Implementa el sistema de autenticación:
1. Endpoint POST /api/auth/register (registro con bcrypt)
2. Endpoint POST /api/auth/login (login que devuelve JWT)
3. Endpoint GET /api/auth/perfil (perfil del usuario autenticado)
El mínimo código para que TODOS los tests pasen.

Paso 3 (Refactor): Mejora la organización del código sin romper tests.

Ejecuta los tests después de cada paso.
```

Prueba manualmente:
```bash
# Levantar servidor
npm run dev

# En otra terminal
curl -X POST http://localhost:3000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"nombre":"Test","email":"test@test.com","password":"Password123"}'
```

**Haz `/clear` antes de continuar.**

### Paso 3.3: Middleware de autenticación

```
Crea un middleware de autenticación que:
1. Extraiga el token JWT del header Authorization
2. Verifique que sea válido
3. Adjunte el usuario decodificado a req.usuario
4. Devuelva 401 si no hay token o es inválido
```

**No necesitas `/clear` aquí; es un cambio pequeño.**

### Paso 3.4: CRUD de tareas (TDD desde Gherkin)

Este es el bloque más grande. Primero genera tests desde `features/tareas.feature`, luego implementa.

**Opción A - Todo junto (si tienes contexto disponible):**
```
Primero genera tests desde features/tareas.feature (Red).
Luego implementa el CRUD completo de tareas (Green):
- POST /api/tareas (crear)
- GET /api/tareas (listar con filtros: estado, prioridad, asignadoA; y paginación)
- GET /api/tareas/:id (detalle)
- PUT /api/tareas/:id (actualizar, solo creador o asignado)
- DELETE /api/tareas/:id (eliminar, solo creador)
- PATCH /api/tareas/:id/completar (marcar como completada)

Sigue la arquitectura de capas: rutas -> controladores -> servicios -> modelos.
```

**Opción B - Por partes (si necesitas gestionar contexto):**
```
Implementa los endpoints de crear y listar tareas (POST y GET /api/tareas).
```
**/clear**
```
Implementa los endpoints de detalle, actualizar y eliminar tareas (GET, PUT, DELETE /api/tareas/:id).
```
**/clear**
```
Implementa el endpoint de completar tarea (PATCH /api/tareas/:id/completar)
y el filtrado por estado, prioridad y usuario asignado.
```

### Paso 3.5: Manejo de errores global

```
Crea un middleware de manejo de errores global que:
1. Capture todos los errores no manejados
2. Devuelva respuestas JSON con formato consistente
3. En desarrollo muestre el stack trace, en producción no
4. Loguee errores con un logger (winston o similar)
```

### Paso 3.6: Verificación de uso de tokens

Después de cada `/clear`, observa el contador de tokens en Claude Code. Anota:
- Cuántos tokens usó cada funcionalidad
- Cuál fue el pico de uso de contexto
- Cuántas veces hiciste `/clear`

> **Consejo (Capítulo 03):** Si ves que el contexto se acerca al 50%, haz `/compact` para resumir. Si supera el 70%, haz `/clear` directamente.

### Paso 3.7: Uso de subagentes para investigación

Si necesitas investigar algo (ej: "cuál es la mejor forma de paginar con SQLite"), usa un subagente:

```
Usa un subagente para investigar las mejores prácticas de paginación
con SQLite y devuélveme un resumen con la recomendación.
```

Esto mantiene limpio tu contexto principal.

### Checklist de la Fase 3

- [ ] Base de datos configurada y funcionando
- [ ] Registro y login implementados
- [ ] Middleware de autenticación funcionando
- [ ] CRUD completo de tareas
- [ ] Filtros y paginación
- [ ] Manejo de errores global
- [ ] Al menos 3 usos de `/clear` durante la implementación
- [ ] Servidor arranca sin errores
- [ ] Todos los endpoints probados manualmente al menos una vez
- [ ] `CLAUDE.md` actualizado con comandos de ejecución

---

## Fase 4: Testing y Cobertura (Capítulos 2, 9 y 12)

**Duración estimada:** 45-60 minutos

**Objetivo:** Completar la cobertura de tests (muchos ya escritos vía TDD en Fase 3), verificar trazabilidad Gherkin → Test → Código, y opcionalmente crear un skill de testing.

### Paso 4.0: Verificar trazabilidad Gherkin → Tests (Capítulo 12)

Si aplicaste TDD desde Gherkin en la Fase 3, ya tendrás muchos tests. Verifica la trazabilidad:

```
Genera una tabla de trazabilidad que muestre:
- Escenario Gherkin → Función de test → Función/método implementado

Formato:
| Feature | Escenario | Test | Implementación |
|---------|-----------|------|----------------|

Verifica que cada escenario Gherkin tiene test y cada test tiene implementación.
Identifica escenarios sin test para cubrir en los pasos siguientes.
```

### Paso 4.1: Tests unitarios (complementarios)

Si ya tienes tests de integración derivados de Gherkin, complementa con tests unitarios que mockeen la base de datos:

```
Crea tests unitarios para los servicios de autenticación y tareas.
Mockea la base de datos. Cubre los casos:

Para authServicio:
- Registro exitoso
- Registro con email duplicado
- Login exitoso
- Login con credenciales inválidas

Para tareasServicio:
- Crear tarea exitosamente
- Listar tareas con filtros
- Actualizar tarea como creador (exitoso)
- Actualizar tarea como no-creador/no-asignado (fallo)
- Eliminar tarea como creador (exitoso)
```

### Paso 4.2: Tests de integración

**Haz `/clear` primero.**

```
Crea tests de integración que prueben los endpoints reales.
Usa una base de datos SQLite en memoria para los tests.
Cubre el flujo completo:
1. Registrar un usuario
2. Hacer login y obtener token
3. Crear una tarea
4. Listar tareas y verificar que aparece
5. Actualizar la tarea
6. Marcar como completada
7. Eliminar la tarea
8. Verificar que ya no existe
```

### Paso 4.3: Ejecutar tests y corregir

```bash
npm test
```

Si hay fallos, muestra los errores a Claude y pídele que los corrija.

### Paso 4.4: (Opcional) Crear un skill de test-runner (Capítulo 09)

Crea un skill personalizado para ejecutar tests:

```
Crea un slash command /test-suite que:
1. Ejecute todos los tests
2. Muestre un resumen de resultados
3. Si hay fallos, analice los errores y sugiera correcciones
4. Muestre el porcentaje de cobertura
```

### Paso 4.5: Verificar cobertura

```bash
npm test -- --coverage
```

Objetivo: al menos 60% de cobertura global.

### Checklist de la Fase 4

- [ ] Al menos 5 tests unitarios escritos y pasando
- [ ] Al menos 5 tests de integración escritos y pasando
- [ ] Cobertura mínima del 60%
- [ ] Todos los tests pasan con `npm test`
- [ ] (Opcional) Skill de test-runner creado

---

## Fase 5: Automatización y CI/CD (Capítulo 10)

**Duración estimada:** 30-45 minutos

**Objetivo:** Configurar pipeline de integración continua con GitHub Actions.

### Paso 5.1: Crear el workflow de CI

**Haz `/clear` primero.**

```
Crea un workflow de GitHub Actions (.github/workflows/ci.yml) que:
1. Se ejecute en push a main y en pull requests
2. Use Node.js 18 y 20 (matrix)
3. Instale dependencias
4. Ejecute el linter
5. Ejecute los tests con cobertura
6. Haga build de la imagen Docker
7. Suba el reporte de cobertura como artefacto
```

### Paso 5.2: Crear el Dockerfile

```
Crea un Dockerfile multi-stage para la aplicación:
- Stage 1: build (instalar dependencias de desarrollo, ejecutar tests)
- Stage 2: producción (solo dependencias de producción, copiar código)
- Usar node:18-alpine como base
- Exponer el puerto de la aplicación
- Usar un usuario non-root
```

### Paso 5.3: Crear docker-compose.yml

```
Crea un docker-compose.yml que:
- Levante la aplicación
- Monte un volumen para la base de datos SQLite
- Configure las variables de entorno
- (Opcional) Agregue un servicio de PostgreSQL si quieres la versión realista
```

### Paso 5.4: (Opcional) Script de revisión automatizada de código

```
Crea un script que use Claude Code en modo headless para revisar
automáticamente el código de un pull request.
Debe ejecutarse como parte del pipeline de CI.
```

### Paso 5.5: Probar el pipeline localmente

```bash
# Probar Docker
docker build -t taskflow-api .
docker run -p 3000:3000 taskflow-api

# Probar docker-compose
docker compose up

# Verificar que la API responde
curl http://localhost:3000/api/auth/register \
  -X POST \
  -H "Content-Type: application/json" \
  -d '{"nombre":"Docker Test","email":"docker@test.com","password":"Password123"}'
```

### Checklist de la Fase 5

- [ ] `.github/workflows/ci.yml` creado
- [ ] `Dockerfile` funcional
- [ ] `docker-compose.yml` funcional
- [ ] La app arranca correctamente con Docker
- [ ] (Opcional) Script de revisión automatizada
- [ ] Commit y push al repositorio de GitHub

---

## Fase 6: Seguridad y Revisión (Capítulo 11)

**Duración estimada:** 30-45 minutos

**Objetivo:** Realizar una auditoría de seguridad del código generado por IA.

### Paso 6.1: Auditoría de seguridad con Opus

**Haz `/clear` primero. Cambia a Opus si no lo estás usando.**

```
Realiza una auditoría de seguridad completa de este proyecto.
Revisa específicamente:

1. OWASP Top 10:
   - A01: Broken Access Control
   - A02: Cryptographic Failures
   - A03: Injection
   - A07: Authentication Failures

2. Verificar que:
   - Las passwords están correctamente hasheadas
   - El JWT tiene expiración y secret adecuado
   - No hay inyección SQL
   - CORS está configurado correctamente
   - Los inputs están validados
   - No hay datos sensibles en logs
   - Los errores no exponen información interna

3. Reporta cada hallazgo con:
   - Severidad (crítica/alta/media/baja)
   - Archivo y línea afectada
   - Recomendación de corrección
```

### Paso 6.2: Corregir hallazgos críticos y altos

Pide a Claude que corrija los problemas encontrados:

```
Corrige todos los hallazgos de severidad crítica y alta
del reporte de seguridad.
```

### Paso 6.3: Agregar headers de seguridad

```
Asegúrate de que la aplicación tenga:
1. Helmet configurado para headers de seguridad
2. Rate limiting en endpoints de autenticación (max 5 intentos por minuto)
3. CORS configurado solo para orígenes permitidos
4. Sanitización de inputs
```

### Paso 6.4: Revisión humana del código generado

Esto lo debes hacer TÚ, no Claude. Revisa manualmente:

- [ ] El middleware de autenticación es correcto y no tiene bypasses
- [ ] Las queries a la base de datos usan parámetros (no concatenación de strings)
- [ ] El `.gitignore` incluye `.env` y no hay secretos en el código
- [ ] Los permisos de acceso (creador/asignado) están correctamente implementados
- [ ] No hay `console.log` con datos sensibles

### Checklist de la Fase 6

- [ ] Auditoría de seguridad ejecutada con Opus
- [ ] Hallazgos críticos y altos corregidos
- [ ] Headers de seguridad configurados
- [ ] Rate limiting implementado
- [ ] Revisión humana completada
- [ ] `CLAUDE.md` actualizado con notas de seguridad

---

## Fase 7: Extras Opcionales (Capítulos 7, 8 y 9)

**Duración estimada:** 30-60 minutos

**Objetivo:** Demostrar dominio de funcionalidades avanzadas de Claude Code.

> **Nota:** Esta fase es opcional pero otorga puntos extra en la evaluación.

### Opción 7A: Servidor MCP para Base de Datos (Capítulo 7)

```
Crea un servidor MCP simple que permita a Claude Code
consultar directamente la base de datos SQLite del proyecto.
Debe exponer herramientas para:
1. Listar tablas
2. Ejecutar consultas SELECT (solo lectura)
3. Ver el esquema de una tabla
```

Configúralo en `.claude/settings.json`:

```json
{
  "mcpServers": {
    "taskflow-db": {
      "command": "node",
      "args": ["mcp/db-server.js"],
      "env": {
        "DATABASE_PATH": "./data/taskflow.db"
      }
    }
  }
}
```

### Opción 7B: Hooks para Auto-formateo (Capítulo 8)

Crea hooks que se ejecuten automáticamente:

**Hook pre-commit:**
```
Crea un hook de Claude Code que, antes de cada commit:
1. Ejecute el linter y corrija errores automáticamente
2. Verifique que no haya console.log en el código
3. Verifique que no haya secretos hardcodeados
```

**Hook post-save:**
```
Crea un hook que al guardar un archivo de test,
ejecute automáticamente ese test específico.
```

### Opción 7C: Agent Teams (Capítulo 9)

Configura un equipo de agentes para desarrollo paralelo:

```
Configura Agent Teams con dos agentes trabajando en paralelo:
- Agente 1: "implementador" - Escribe código de producción
- Agente 2: "tester" - Escribe tests para el código del agente 1

El agente tester debe leer el código escrito por el implementador
y crear tests que verifiquen su funcionamiento.
```

### Opción 7D: Documentación Automática

```
Crea un script o skill que genere automáticamente
la documentación OpenAPI/Swagger a partir del código fuente.
Debe:
1. Analizar las rutas definidas
2. Extraer los schemas de request/response
3. Generar un archivo openapi.yaml completo
```

### Opción 7E: Visual-Driven Development (Capítulo 13)

Proporciona un mockup o screenshot a Claude y genera código que lo implemente:

```
Aquí tienes un screenshot/mockup de la interfaz de documentación que quiero
para la API de TaskFlow. Analiza la imagen y genera el código HTML/CSS necesario
para implementar exactamente esa interfaz.

Una vez generado, compara el resultado con el original y documenta las diferencias.
```

Criterios de éxito:
- El código generado replica visualmente el mockup con fidelidad razonable
- Se documenta el proceso: qué se proporcionó, qué generó Claude, qué ajustes fueron necesarios
- El resultado se incluye como página de documentación del proyecto

> **Consejo (Capítulo 13):** Puedes proporcionar capturas de pantalla de herramientas como Swagger UI, Postman, o incluso bocetos dibujados a mano. Claude analizará la estructura visual y generará el código correspondiente.

### Opción 7F: Agente Personalizado con Agent SDK (Capítulo 14)

Crea un agente simple con el Agent SDK que automatice alguna tarea del proyecto:

```
Usando el Agent SDK de Claude, crea un agente en Python (o TypeScript) que
automatice la revisión de la documentación de la API. El agente debe:

1. Leer los archivos de rutas del proyecto
2. Verificar que cada endpoint tiene documentación OpenAPI correspondiente
3. Identificar endpoints sin documentar
4. Generar un reporte con las discrepancias encontradas
5. (Opcional) Proponer el texto de documentación para los endpoints faltantes
```

Alternativas igualmente válidas:
- Un agente que ejecute los tests y genere un reporte de regresión formateado
- Un agente que revise el CLAUDE.md y sugiera mejoras basadas en el código actual
- Un agente que analice el historial de commits y genere un CHANGELOG automáticamente

```bash
# Instalar el SDK
pip install anthropic

# Ejecutar el agente
python agente_docs.py
```

> **Consejo (Capítulo 14):** Empieza con un agente simple de un solo paso antes de añadir complejidad. El Agent SDK permite construir flujos de razonamiento multi-paso con herramientas personalizadas.

### Opción 7G: Auto Mode y Computer Use (Capítulos 5, 6, 13)

> **Novedad v3.0**

Configura Auto Mode para el proyecto y demuestra Computer Use:

```
1. Activa Auto Mode en tu sesión y realiza un refactoring completo
   de un módulo sin confirmar manualmente ningún permiso. Documenta
   cuántas confirmaciones te ahorró y si el clasificador IA bloqueó
   alguna acción inesperada.

2. (Opcional, requiere macOS) Usa Computer Use para automatizar
   un flujo de testing visual: que Claude abra el navegador,
   navegue a la documentación de tu API y verifique que los
   endpoints están correctamente documentados.
```

### Opción 7H: Nuevos Hooks y Compaction API (Capítulos 3, 8)

> **Novedad v3.0**

Configura hooks con los nuevos eventos y la Compaction API:

```
1. Configura un hook CwdChanged que cargue automáticamente las
   variables de entorno del directorio al cambiar de módulo.

2. Configura un hook PostCompact que registre cada compactación
   en un fichero de log con timestamp y tamaño del resumen.

3. Activa la Compaction API para una tarea larga y documenta
   cómo afectó al rendimiento de la sesión.
```

### Checklist de la Fase 7

- [ ] Al menos una opción extra implementada
- [ ] Funciona correctamente
- [ ] Documentada en el README

---

## Resumen de Fases y Capítulos

| Fase | Capítulos | Duración | Prioridad |
|------|-----------|----------|-----------|
| 1. Preparación | C04, C05 | 30-45 min | Obligatoria |
| 2. Especificación y Diseño | C06, C12 | 45-60 min | Obligatoria |
| 3. Implementación con TDD | C02, C03, C06, C12 | 1.5-2.5 h | Obligatoria |
| 4. Testing y Cobertura | C02, C09, C12 | 45-60 min | Obligatoria |
| 5. Automatización | C10 | 30-45 min | Obligatoria |
| 6. Seguridad | C11 | 30-45 min | Obligatoria |
| 7. Extras | C07, C08, C09, C13, C14 | 30-60 min | Opcional |

---

## Consejos Finales

1. **No intentes hacer todo en una sesión.** Divide el trabajo en 2-3 sesiones. El `CLAUDE.md` mantendrá tu contexto entre sesiones.

2. **Haz commits frecuentes.** Después de cada funcionalidad, haz un commit. Así puedes volver atrás si algo se rompe.

3. **Documenta conforme avanzas.** Es más fácil documentar mientras implementas que al final.

4. **Usa el modelo correcto para cada tarea:**
   - Opus para planificación y revisión de seguridad
   - Sonnet para implementación de código
   - Haiku para tareas rápidas y repetitivas

5. **Si te atascas**, consulta la solución de referencia. Pero recuerda que tu solución puede ser diferente y eso está bien.

---

**Siguiente paso:** Consulta la rúbrica de evaluación en `criterios-evaluacion/rubrica.md` para saber exactamente cómo será puntuado tu proyecto.
