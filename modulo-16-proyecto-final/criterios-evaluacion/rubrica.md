# Rúbrica de Evaluación - Proyecto Final TaskFlow API

---

## Resumen de Puntuación

| Calificación | Puntos | Descripción |
|-------------|--------|-------------|
| **Distinción** | 85-100 | Dominio excepcional de Claude Code |
| **Notable** | 70-84 | Buen dominio, áreas menores de mejora |
| **Aprobado** | 60-69 | Cumple los requisitos mínimos |
| **No aprobado** | < 60 | No cumple los requisitos mínimos |

**Total máximo: 100 puntos**

---

## Criterios de Evaluación Detallados

### 1. CLAUDE.md Efectivo (10 puntos) - Capítulo 04

| Puntos | Nivel | Descripción |
|--------|-------|-------------|
| 9-10 | Excelente | CLAUDE.md conciso (<80 líneas), bien estructurado, incluye convenciones de código, comandos frecuentes, stack tecnológico, y se actualizó durante el proyecto. Las instrucciones son específicas y accionables. |
| 7-8 | Bueno | CLAUDE.md completo con la información esencial. Podría ser más conciso o tener mejor estructura. |
| 5-6 | Aceptable | CLAUDE.md existe y tiene información útil, pero es demasiado largo, demasiado corto, o le falta información clave. |
| 3-4 | Insuficiente | CLAUDE.md existe pero es genérico, no aporta valor real al proyecto. |
| 0-2 | Ausente | No hay CLAUDE.md, o es un placeholder sin contenido útil. |

**Qué se evalúa:**
- Que sea conciso y no desperdicie tokens
- Que incluya convenciones de código específicas
- Que tenga los comandos frecuentes del proyecto
- Que se haya actualizado conforme avanzó el proyecto
- Que incluya configuración de `.claude/settings.json`
- Que tenga reglas en `.claude/rules/`

---

### 2. Gestión de Contexto y Tokens (15 puntos) - Capítulo 03

| Puntos | Nivel | Descripción |
|--------|-------|-------------|
| 13-15 | Excelente | Uso estratégico de `/clear` entre funcionalidades, `/compact` cuando el contexto crece, subagentes para investigación. Documentado el uso de tokens en cada fase. Costo total razonable. |
| 10-12 | Bueno | Uso regular de `/clear`, evidencia de gestión de contexto. Alguna documentación de uso de tokens. |
| 7-9 | Aceptable | Algún uso de `/clear` pero sin estrategia clara. No hay documentación de tokens. |
| 4-6 | Insuficiente | Poco o ningún uso de `/clear`. Conversaciones largas sin gestión de contexto. |
| 0-3 | Ausente | Sin evidencia de gestión de contexto o tokens. |

**Qué se evalúa:**
- Frecuencia y timing de `/clear` (mínimo 3 veces durante implementación)
- Uso de `/compact` cuando el contexto crece
- Uso de subagentes para investigación (al menos 1 vez)
- Registro de uso de tokens por fase
- Estimación del costo total del proyecto
- Capacidad de mantener el contexto esencial a través de CLAUDE.md

---

### 3. Metodología y Diseño (15 puntos) - Capítulos 06 y 12

| Puntos | Nivel | Descripción |
|--------|-------|-------------|
| 13-15 | Excelente | SPEC.md con SDD, features Gherkin completas (happy path + errores + edge cases), Plan Mode con Opus, ARCHITECTURE.md completo. Trazabilidad Gherkin → Tests → Código verificada. |
| 10-12 | Bueno | SPEC.md básico, features Gherkin con escenarios principales, Plan Mode usado. Arquitectura razonable. |
| 7-9 | Aceptable | Algo de especificación o Gherkin, algo de planificación. Poca documentación de decisiones. |
| 4-6 | Insuficiente | Planificación mínima. Sin Gherkin ni spec. Se empezó a implementar sin diseñar. |
| 0-3 | Ausente | Sin evidencia de planificación ni metodología previa a la implementación. |

**Qué se evalúa:**
- `SPEC.md` creado con Spec-Driven Development (C12)
- Features Gherkin en `features/` con escenarios completos (C12)
- Evidencia de uso de Plan Mode (no solo implementación directa)
- Uso de Opus para la planificación (no solo Sonnet)
- Calidad del diseño arquitectónico
- Preguntas hechas sobre el diseño (revisión crítica)
- Archivo ARCHITECTURE.md con decisiones justificadas
- Coherencia entre spec, Gherkin, diseño y la implementación final

---

### 4. Código Funcional (20 puntos) - Capítulos 02 y 06

| Puntos | Nivel | Descripción |
|--------|-------|-------------|
| 18-20 | Excelente | Todos los endpoints funcionan. Validación completa. Paginación y filtros. Manejo de errores consistente. Código limpio y bien organizado. |
| 14-17 | Bueno | La mayoría de endpoints funcionan. Buena validación. Manejo de errores. Código organizado. |
| 10-13 | Aceptable | Endpoints básicos funcionan (auth + CRUD). Algunas validaciones. Algún manejo de errores. |
| 6-9 | Insuficiente | Solo algunos endpoints funcionan. Poca validación. Errores no manejados. |
| 0-5 | Ausente | La API no arranca o la mayoría de endpoints no funcionan. |

**Desglose detallado:**

| Funcionalidad | Puntos |
|---------------|--------|
| Registro de usuario funcional | 2 |
| Login con JWT funcional | 2 |
| Middleware de autenticación | 2 |
| Crear tarea | 2 |
| Listar tareas | 2 |
| Obtener tarea por ID | 1 |
| Actualizar tarea (con permisos) | 2 |
| Eliminar tarea (con permisos) | 2 |
| Completar tarea | 1 |
| Filtros y paginación | 2 |
| Manejo de errores global | 2 |

---

### 5. Testing y TDD (10 puntos) - Capítulos 09 y 12

| Puntos | Nivel | Descripción |
|--------|-------|-------------|
| 9-10 | Excelente | Tests derivados de Gherkin + unitarios + integración. Ciclo TDD evidenciado (Red → Green → Refactor). Cobertura >= 80%. Trazabilidad Gherkin → Test completa. |
| 7-8 | Bueno | Tests unitarios e integración. Cobertura >= 60%. Algo de TDD o derivación desde Gherkin. |
| 5-6 | Aceptable | Al menos 5 tests que pasan. Cobertura >= 40%. Casos básicos cubiertos. |
| 3-4 | Insuficiente | Pocos tests. Algunos no pasan. Cobertura baja. |
| 0-2 | Ausente | Sin tests o los tests no se ejecutan. |

**Qué se evalúa:**
- Tests derivados de escenarios Gherkin (cada Scenario = 1 test) (C12)
- Evidencia de ciclo TDD: tests escritos antes de la implementación (C12)
- Número y calidad de tests unitarios (mínimo 5)
- Número y calidad de tests de integración (mínimo 5)
- Porcentaje de cobertura de código
- Que los tests cubran casos de éxito Y de error
- Que los tests sean independientes (no dependan del orden)
- (Bonus) Creación de skill de test-runner

---

### 6. CI/CD (10 puntos) - Capítulo 10

| Puntos | Nivel | Descripción |
|--------|-------|-------------|
| 9-10 | Excelente | GitHub Actions funcional con matrix, lint, tests, cobertura y build Docker. Dockerfile multi-stage optimizado. docker-compose funcional. |
| 7-8 | Bueno | GitHub Actions con lint y tests. Dockerfile funcional. docker-compose básico. |
| 5-6 | Aceptable | GitHub Actions básico que ejecuta tests. Dockerfile funcional. |
| 3-4 | Insuficiente | GitHub Actions existe pero tiene errores. Dockerfile básico. |
| 0-2 | Ausente | Sin CI/CD o sin Docker. |

**Qué se evalúa:**
- `.github/workflows/ci.yml` con triggers correctos (push + PR)
- Pipeline ejecuta: instalación, lint, tests, build
- `Dockerfile` funcional y optimizado (multi-stage, non-root user)
- `docker-compose.yml` que levanta la app completa
- La app funciona correctamente dentro de Docker
- (Bonus) Revisión automatizada de código con Claude en CI

---

### 7. Seguridad (10 puntos) - Capítulo 11

| Puntos | Nivel | Descripción |
|--------|-------|-------------|
| 9-10 | Excelente | Auditoría de seguridad documentada. Todos los hallazgos críticos corregidos. Helmet, rate limiting, CORS, validación de inputs. Revisión humana evidenciada. |
| 7-8 | Bueno | Auditoría realizada. Principales problemas corregidos. Headers de seguridad configurados. |
| 5-6 | Aceptable | Algunas medidas de seguridad implementadas. Passwords hasheadas. JWT con expiración. |
| 3-4 | Insuficiente | Seguridad básica (passwords hasheadas) pero sin revisión completa. |
| 0-2 | Ausente | Sin medidas de seguridad o passwords en texto plano. |

**Checklist de seguridad:**

| Ítem | Puntos |
|------|--------|
| Passwords hasheadas con bcrypt/argon2 | 1.5 |
| JWT con expiración y secret en env var | 1.5 |
| Inputs validados (no inyección SQL) | 1.5 |
| Helmet o headers de seguridad equivalentes | 1 |
| Rate limiting en auth | 1 |
| CORS configurado | 1 |
| No hay secretos en el código ni en logs | 1 |
| Auditoría de seguridad documentada | 1.5 |

---

### 8. Documentación (10 puntos) - General

| Puntos | Nivel | Descripción |
|--------|-------|-------------|
| 9-10 | Excelente | README completo y claro. OpenAPI/Swagger con todos los endpoints. ARCHITECTURE.md con decisiones. PR descriptions descriptivos. |
| 7-8 | Bueno | README con instrucciones de instalación, ejecución y test. Documentación de API básica. |
| 5-6 | Aceptable | README con instrucciones básicas. Alguna documentación de API. |
| 3-4 | Insuficiente | README mínimo. Sin documentación de API. |
| 0-2 | Ausente | Sin README o documentación. |

**Qué se evalúa:**
- README.md del proyecto con: descripción, instalación, ejecución, tests, Docker
- Documentación de API (OpenAPI/Swagger o equivalente)
- ARCHITECTURE.md con decisiones de diseño
- `.env.example` con todas las variables documentadas
- Commits descriptivos y PR descriptions claros
- Comentarios en código donde sea necesario (no excesivos)

---

## Puntos Extra (hasta +10 puntos adicionales)

Estos puntos pueden sumarse al total pero no superar 100:

| Extra | Puntos | Capítulo |
|-------|--------|----------|
| Servidor MCP para base de datos funcional | +3 | C07 |
| Hooks de auto-formateo/validación | +2 | C08 |
| Agent Teams configurado y funcional | +3 | C09 |
| Generación automática de documentación | +2 | C07/C09 |
| Refresh tokens implementados | +1 | C11 |
| Tests de seguridad automatizados | +2 | C11 |
| Script de revisión automatizada en CI | +2 | C10 |
| Writer/Reviewer pattern aplicado (sesión separada de review) | +2 | C12 |
| Tabla de trazabilidad Gherkin → Test → Código completa | +1 | C12 |
| Visual-Driven Development (screenshot → código) | +2 | C13 |
| Agente personalizado con Agent SDK funcional | +3 | C14 |
| Uso de memoria estructurada con tipos (user, feedback, project, reference) | +1 | C04 |
| Plugin propio empaquetado y funcional | +2 | C15 |
| Auto Mode configurado con documentación de resultados | +2 | C05 |
| Uso de nuevos hooks (PostCompact, CwdChanged, FileChanged) | +2 | C08 |
| Compaction API configurada en tarea larga | +1 | C03 |
| Computer Use para testing visual | +2 | C13 |

> **Nota:** Los puntos extra requieren que la funcionalidad extra funcione correctamente y esté documentada.

---

## Ejemplo de Evaluación

### Proyecto de ejemplo: Nota 78/100 (Notable)

| Criterio | Puntos | Comentario |
|----------|--------|------------|
| CLAUDE.md | 8/10 | Bueno pero algo largo (120 líneas) |
| Gestión contexto | 11/15 | Usó /clear 4 veces pero no documentó tokens |
| Plan Mode | 12/15 | Buen diseño, falta ARCHITECTURE.md |
| Código funcional | 17/20 | Falta paginación, filtros parciales |
| Tests | 7/10 | 8 tests, cobertura 55% |
| CI/CD | 8/10 | Pipeline funcional, Dockerfile básico |
| Seguridad | 8/10 | Auditoría realizada, falta rate limiting |
| Documentación | 7/10 | Buen README, falta OpenAPI |
| **Total** | **78/100** | **Notable** |

---

## Entrega

### Qué entregar
1. URL del repositorio de GitHub con todo el código
2. Registro de la sesión (prompts clave usados, momentos de /clear, modelos utilizados)
3. Estimación de tokens consumidos y costo aproximado

### Cómo entregar
- Push del repositorio a GitHub
- El registro de la sesión puede ser un archivo `SESION.md` en el repositorio
- Asegúrate de que el README tenga instrucciones claras para ejecutar el proyecto

### Fecha límite
- Según el calendario acordado

---

## Consejos para Maximizar tu Puntuación

1. **Empieza por el CLAUDE.md.** Es lo primero que se evalúa y afecta todo lo demás.

2. **Empieza con SPEC.md y Gherkin.** 15 puntos dependen de que especifiques y diseñes antes de implementar. Las features Gherkin te dan tests "gratis".

3. **No te olvides de `/clear`.** 15 puntos dependen de la gestión de contexto.

4. **Prueba TODO manualmente.** Cada endpoint que no funcione resta puntos.

5. **Los tests son puntos fáciles.** Pide a Claude que los genere; es lo que mejor hace.

6. **Docker y CI/CD son puntos fáciles también.** Claude puede generar estos archivos en minutos.

7. **La seguridad es la que más se olvida.** Reserva 30 minutos para la auditoría.

8. **Documenta conforme avanzas.** Es mucho más fácil que documentar al final.

9. **Haz los extras solo si te sobra tiempo.** Es mejor tener un proyecto sólido de 85 puntos que un proyecto incompleto de 60 puntos con extras.

10. **Guarda tu registro de sesión.** Los tokens consumidos y los momentos de `/clear` son evidencia valiosa.
