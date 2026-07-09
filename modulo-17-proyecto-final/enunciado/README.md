# Módulo 17: Proyecto Final Integrador

## Construir una Aplicación Completa Usando Claude Code como Copiloto

---

## Descripción General

Este es el proyecto final del libro. Tu objetivo es construir una **API REST de gestión de tareas** completa, utilizando Claude Code como tu copiloto de desarrollo durante todo el proceso.

No se trata solo de escribir código. Se trata de demostrar que dominas las técnicas y flujos de trabajo que hemos aprendido a lo largo de los capítulos 1-15: desde la configuración inicial del entorno, pasando por la gestión inteligente de contexto y tokens, las metodologías de desarrollo con IA (Spec-Driven Development, Gherkin, TDD), hasta la automatización CI/CD y la revisión de seguridad.

---

## El Proyecto: TaskFlow API

**TaskFlow** es una API REST para gestión de tareas en equipo. Piensa en una versión simplificada de Trello o Jira, pero solo el backend.

### Funcionalidades principales

1. **Autenticación de usuarios**
   - Registro de nuevos usuarios
   - Login con JWT (JSON Web Tokens)
   - Protección de rutas autenticadas

2. **Gestión de tareas (CRUD completo)**
   - Crear tareas con título, descripción, estado, prioridad y asignado
   - Leer tareas (listado con filtros y detalle individual)
   - Actualizar tareas (cambiar estado, reasignar, editar campos)
   - Eliminar tareas

3. **Filtrado y búsqueda**
   - Filtrar por estado (pendiente, en progreso, completada)
   - Filtrar por prioridad (baja, media, alta, crítica)
   - Filtrar por usuario asignado

4. **Asignación y colaboración**
   - Asignar tareas a usuarios registrados
   - Marcar tareas como completadas

---

## Objetivo Pedagógico

Este proyecto evalúa tu capacidad para:

| Habilidad | Capítulos relacionados |
|-----------|------------------------|
| Configurar Claude Code para un proyecto real | C01, C02, C05 |
| Crear un CLAUDE.md efectivo y reglas de proyecto | C04 |
| Gestionar contexto y tokens eficientemente | C03 |
| Usar Plan Mode con Opus para diseñar antes de implementar | C06 |
| Implementar código funcional con ayuda de Claude | C02, C06 |
| Usar servidores MCP para extender capacidades | C07 |
| Configurar hooks para automatizar flujos | C08 |
| Crear agentes, skills y equipos de agentes | C09 |
| Automatizar con CI/CD | C10 |
| Aplicar prácticas de seguridad empresarial | C11 |
| Aplicar metodologías de desarrollo con IA (SDD, Gherkin, TDD) | C12 |
| Usar multimodalidad (imágenes, PDFs) para documentar y verificar | C13 |
| (Opcional) Construir un agente personalizado con Agent SDK | C14 |
| (Opcional) Empaquetar skills y hooks como plugin distribuible | C15 |

---

## Requisitos Previos

Antes de comenzar, asegúrate de tener:

- [ ] Claude Code instalado y configurado (Capítulo 01)
- [ ] Acceso a una terminal con Git
- [ ] Node.js >= 18, Python >= 3.10, Go >= 1.21, o Java >= 17 (según tu elección de stack)
- [ ] Docker instalado (para la fase de contenedorización)
- [ ] Una cuenta en GitHub (para CI/CD)
- [ ] Haber completado al menos los capítulos 1-6 del libro (idealmente 1-15)

---

## Duración Estimada

| Fase | Duración |
|------|----------|
| Fase 1: Preparación | 30-45 min |
| Fase 2: Especificación y Diseño | 45-60 min |
| Fase 3: Implementación | 1.5-2.5 horas |
| Fase 4: Testing | 45-60 min |
| Fase 5: Automatización | 30-45 min |
| Fase 6: Seguridad y Revisión | 30-45 min |
| Fase 7: Extras opcionales | 30-60 min |
| **Total** | **4-6 horas** |

> **Nota:** Puedes distribuir el trabajo en múltiples sesiones. De hecho, es una buena práctica para ejercitar el uso de `CLAUDE.md` como memoria persistente entre sesiones.

---

## Libertad de Elección Tecnológica

Puedes elegir **cualquier stack tecnológico** para el backend:

| Stack | Framework | Base de datos | Dificultad |
|-------|-----------|---------------|------------|
| Node.js | Express / Fastify | SQLite / PostgreSQL | Media |
| Python | FastAPI / Flask | SQLite / PostgreSQL | Media |
| Go | Gin / Echo | SQLite / PostgreSQL | Media-Alta |
| Java | Spring Boot | H2 / PostgreSQL | Alta |
| Rust | Actix / Axum | SQLite / PostgreSQL | Alta |

> **Recomendación:** Si quieres enfocarte en aprender Claude Code (y no en aprender un nuevo lenguaje), elige un stack con el que ya tengas experiencia. La solución de referencia usa Node.js + Express + SQLite por simplicidad.

---

## Entregables

Al finalizar el proyecto, tu repositorio debe contener:

1. **`CLAUDE.md`** - Archivo de memoria del proyecto
2. **`.claude/`** - Directorio con settings y reglas
3. **`SPEC.md`** - Especificación técnica del proyecto (metodología SDD, C12)
4. **`features/`** - Historias de usuario en formato Gherkin (C12)
5. **Código fuente** - La API completa y funcional
6. **Tests** - Tests unitarios e de integración (derivados de Gherkin/TDD)
7. **`Dockerfile`** - Para contenedorización
8. **`.github/workflows/`** - Pipeline CI/CD
9. **`README.md`** - Documentación del proyecto
10. **Documentación API** - OpenAPI/Swagger
11. **(Opcional) Script de agente con Agent SDK** - Si se implementó la opción C14

---

## Cómo Empezar

1. Lee el archivo `requisitos.md` para entender los requisitos detallados
2. Lee el archivo `fases.md` para seguir el plan de trabajo fase por fase
3. Consulta la `rubrica.md` en `criterios-evaluacion/` para saber cómo serás evaluado
4. Si te atascas, consulta la `solucion-referencia/` (pero intenta primero por tu cuenta)

```bash
# Crea tu directorio de proyecto
mkdir taskflow-api
cd taskflow-api
git init

# Abre Claude Code y comienza
claude
```

---

## Consejo Final

> El objetivo NO es escribir todo el código tú mismo. El objetivo es **dirigir a Claude Code de manera efectiva** para que produzca código de calidad. Piensa en ti como el arquitecto y director del proyecto, y en Claude como tu desarrollador senior que necesita instrucciones claras y contexto adecuado.

Recuerda: un buen prompt vale más que cien líneas de código escritas a mano.

---

**Siguiente paso:** Lee `requisitos.md` para los requisitos detallados.
