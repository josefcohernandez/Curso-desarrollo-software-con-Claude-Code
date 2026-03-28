# 02 - Top 10 Técnicas de Ahorro de Tokens

> Tiempo estimado: 25 minutos | Nivel: Intermedio

## Por qué ahorrar tokens

Cada token consumido tiene un **coste económico** y un **impacto en la calidad**.
Al mantener el contexto limpio, Claude genera mejores respuestas y tú gastas menos.

---

## Consumo por Operación

| Operación | Tokens input | Tokens output |
|-----------|-------------|--------------|
| Lectura archivo pequeño (<100 lín) | 500 - 1,500 | 50 - 200 |
| Lectura archivo grande (>500 lín) | 2,000 - 10,000 | 50 - 200 |
| Comando bash simple | 200 - 500 | 100 - 500 |
| Búsqueda Grep/Glob | 300 - 2,000 | 100 - 500 |
| Edición de archivo | 500 - 2,000 | 200 - 800 |
| Escritura archivo nuevo | 200 - 500 | 500 - 5,000 |
| Carga CLAUDE.md | 500 - 3,000 | 0 |
| Tool call MCP | 300 - 1,500 | 200 - 2,000 |

---

## Las 10 Técnicas

### 1. `/clear` entre tareas no relacionadas

```
# Mal: acumular contexto
> Revisa tests auth        (contexto: 15K)
> Refactoriza pagos        (contexto: 35K, contaminado)
> Genera docs API          (contexto: 60K, degradado)

# Bien: limpiar entre tareas
> Revisa tests auth        (15K)
> /clear
> Refactoriza pagos        (18K, limpio)
> /clear
> Genera docs API          (12K, limpio)
```

**Ahorro**: 40-60% por sesión multi-tarea.

### 2. Prompts específicos y acotados

| Vago | Específico |
|------|-----------|
| "Arregla los tests" | "El test user.service.spec.ts:45 falla por mock incorrecto de findById" |
| "Mejora rendimiento" | "Añade useMemo a ProductList para evitar re-renders al filtrar" |
| "Revisa el código" | "Revisa src/api/auth.py buscando SQL injection en login y register" |

**Ahorro**: 30-50% menos ida-vuelta.

### 3. Subagentes para investigación

```
# Sin subagente: 200 archivos * ~1000 tokens = 200K en contexto
# Con subagente: investigación aislada, solo 500 tokens de resumen
```

**Ahorro**: 80-95% en tareas de exploración.

### 4. Sonnet como modelo por defecto

```
# Sonnet: $3/$15 por millón tokens (desarrollo diario)
# Opus:  $5/$25 por millón tokens (planificación, debug complejo)
```

**Ahorro**: 30-40% en coste para tareas rutinarias usando Sonnet en vez de Opus.

### 5. `/compact` con instrucción de foco

```bash
# Sin foco
/compact

# Con foco (mucho mejor)
/compact Mantener solo contexto sobre migración de BD

# Con exclusiones
/compact Conservar arquitectura pagos, descartar discusión CSS
```

**Ahorro**: 50-70% de contexto conservando lo relevante.

### 6. Desactivar MCPs no utilizados

| MCPs activos | Overhead por mensaje |
|-------------|---------------------|
| 0 | 0 tokens |
| 1 (5 tools) | ~500-1,000 |
| 3 (15 tools) | ~2,000-4,000 |
| 5+ (30+ tools) | ~5,000-10,000 |

**Ahorro**: 500-10,000 tokens/mensaje.

### 7. Skills bajo demanda

```bash
# Skills solo cargan cuando se invocan:
/commit          # Solo cuando necesitas hacer commit
/review-pr 123   # Solo cuando necesitas review
```

**Ahorro**: Variable, evita carga innecesaria.

### 8. Hooks para preprocessing

```bash
#!/bin/bash
# hook-truncate.sh - Limitar output de comandos
MAX_LINES=100
if [ $(wc -l < /dev/stdin) -gt $MAX_LINES ]; then
    echo "... (truncado, últimas $MAX_LINES líneas)"
    tail -n $MAX_LINES
fi
```

**Ahorro**: 60-90% en comandos con output verbose.

### 9. Sesiones cortas y enfocadas

```
# Regla: 1 sesión = 1 tarea concreta
Sesión 1 (15 min): Implementar POST /users
Sesión 2 (10 min): Tests para POST /users
Sesión 3 (20 min): Implementar GET /users/:id

# Anti-patrón: sesión de 2 horas con todo mezclado
```

**Ahorro**: 30-50% por evitar degradación.

### 10. Solicitar output conciso

```markdown
# En CLAUDE.md:
## Estilo de respuesta
- Respuestas concisas sin explicaciones innecesarias
- No repetir código sin cambios
- Usar diff format cuando sea posible
```

**Ahorro**: 40-60% en tokens de output.

---

## Prompt Caching

El caching automático de prefijos es otra fuente importante de ahorro. El capítulo
siguiente explica en detalle cómo funciona, qué condiciones lo activan y cómo
aprovecharlo al máximo junto con el resto de estrategias de optimización de costes.

---

## Anti-patrones

| Anti-patrón | Alternativa |
|-------------|------------|
| Pegar archivos en el prompt | Dejar que Claude lea con Read |
| Pedir "explica todo el código" | Preguntar partes concretas |
| Nunca usar /clear | /clear entre tareas |
| 5+ MCPs siempre activos | Solo los necesarios |
| Sesiones de 1h+ sin compactar | /compact o sesiones cortas |
| Copiar logs completos | Filtrar antes, pegar lo relevante |

---

## Resumen de Impacto

```
Sin optimizar:  ~500K tokens/día  (~$7.50/día con Opus)
Con optimizar:  ~100K tokens/día  (~$0.45/día con Sonnet + cache)
Reducción:      ~80% tokens, ~94% coste
```
