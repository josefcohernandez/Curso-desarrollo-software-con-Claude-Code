# Ejercicio 02: Crear un Skill Personalizado

## Objetivo

Aprender a diseñar, crear y utilizar skills personalizados en Claude Code. Crearemos dos skills: uno básico que se ejecuta en el contexto principal y otro avanzado con `context: fork`.

**Tiempo estimado:** 15 minutos
**Nivel:** Intermedio-Avanzado

---

## Prerrequisitos

- Claude Code CLI instalado y configurado
- Un proyecto con estructura de directorio (puede ser cualquier proyecto)
- Haber leído el capítulo sobre el Sistema de Skills (Capítulo 9, teoría 02)

---

## Parte 1: Crear la Estructura de Directorio

### Instrucciones

1. En la raíz de tu proyecto, crea el directorio de skills si no existe:

   ```bash
   mkdir -p .claude/skills
   ```

2. Verifica la estructura:
   ```bash
   ls -la .claude/
   # Debería mostrar: skills/
   ```

> **Importante:** Cada skill es un **directorio** con un archivo `SKILL.md` como entrypoint, no un fichero plano. La estructura correcta es `.claude/skills/nombre-skill/SKILL.md`.

---

## Parte 2: Crear un Skill Básico de Despliegue

### Instrucciones

1. Crea el directorio del skill y su archivo `SKILL.md`:

   ```bash
   mkdir -p .claude/skills/deploy-staging
   ```

   Crea el archivo `.claude/skills/deploy-staging/SKILL.md` con el siguiente contenido:

   ```markdown
   ---
   name: "Deploy to Staging"
   description: "Ejecuta el flujo completo de despliegue al entorno de staging"
   ---

   # Deploy to Staging

   ## Prerrequisitos
   Antes de desplegar, verifica:
   - Estás en la rama correcta (debe ser `develop` o una rama de feature)
   - No hay cambios sin commitear (ejecuta `git status`)

   ## Pasos

   1. Ejecutar la suite de tests:
      ```bash
      npm test
      ```
      Si algún test falla, DETENER el proceso e informar al usuario.

   2. Construir el proyecto:
      ```bash
      npm run build
      ```
      Si la build falla, DETENER el proceso e informar al usuario.

   3. Verificar que la build generó los archivos correctos:
      ```bash
      ls -la dist/
      ```

   4. Mostrar resumen pre-despliegue:
      - Rama actual
      - Último commit
      - Número de archivos en dist/
      - Preguntar al usuario si desea continuar

   5. Si el usuario confirma, ejecutar:
      ```bash
      echo "Desplegando a staging... (simulación)"
      echo "Deploy completado exitosamente"
      ```

   ## Post-despliegue
   - Informar la URL de staging: https://staging.ejemplo.com
   - Sugerir verificar el health check
   ```

2. Guarda el archivo y abre una sesión de Claude Code:
   ```bash
   claude
   ```

3. Verifica que el skill está disponible:
   ```
   /skills
   ```
   Deberías ver "Deploy to Staging" en la lista.

4. Invoca el skill:
   ```
   /deploy-staging
   ```

5. Claude ejecutará los pasos definidos en el skill.

### Puntos de atención

- ¿El skill apareció en la lista de `/skills`?
- ¿Claude ejecutó los pasos en orden?
- ¿Se detuvo correctamente si hubo errores (ej: si no existe `npm test`)?
- ¿El flujo fue coherente y útil?

---

## Parte 3: Crear un Skill con Argumentos ($ARGUMENTS)

### Instrucciones

1. Crea el directorio del skill y su archivo `SKILL.md`:

   ```bash
   mkdir -p .claude/skills/crear-componente
   ```

   Crea el archivo `.claude/skills/crear-componente/SKILL.md`:

   ```markdown
   ---
   name: "Crear Componente"
   description: "Genera la estructura completa de un componente con test y estilos"
   ---

   # Crear Componente: $ARGUMENTS

   ## Estructura a Generar

   Crea los siguientes archivos para el componente "$ARGUMENTS":

   ### 1. Archivo principal del componente
   `src/components/$ARGUMENTS/$ARGUMENTS.tsx`:
   ```tsx
   import React from 'react';
   import styles from './$ARGUMENTS.module.css';

   interface ${ARGUMENTS}Props {
     // Define las props aquí
   }

   export const $ARGUMENTS: React.FC<${ARGUMENTS}Props> = (props) => {
     return (
       <div className={styles.container}>
         <h2>$ARGUMENTS</h2>
       </div>
     );
   };
   ```

   ### 2. Archivo de estilos
   `src/components/$ARGUMENTS/$ARGUMENTS.module.css`:
   ```css
   .container {
     /* Estilos del componente */
   }
   ```

   ### 3. Archivo de test
   `src/components/$ARGUMENTS/$ARGUMENTS.test.tsx`:
   ```tsx
   import { render, screen } from '@testing-library/react';
   import { $ARGUMENTS } from './$ARGUMENTS';

   describe('$ARGUMENTS', () => {
     it('renders correctly', () => {
       render(<$ARGUMENTS />);
       expect(screen.getByText('$ARGUMENTS')).toBeInTheDocument();
     });
   });
   ```

   ### 4. Archivo index (barrel export)
   `src/components/$ARGUMENTS/index.ts`:
   ```typescript
   export { $ARGUMENTS } from './$ARGUMENTS';
   ```

   ## Después de crear
   - Verificar que los archivos se crearon correctamente
   - Ejecutar el test del nuevo componente
   - Informar al usuario los archivos creados
   ```

2. Invoca el skill con un argumento:
   ```
   /crear-componente UserProfile
   ```

3. `$ARGUMENTS` se sustituirá por `UserProfile` en todas las instancias.

4. Verifica que los archivos se crearon correctamente:
   ```bash
   ls -la src/components/UserProfile/
   ```

### Puntos de atención

- ¿La sustitución de `$ARGUMENTS` funcionó correctamente en todos los lugares?
- ¿Los archivos creados tienen la estructura esperada?
- ¿El test se ejecutó correctamente?

---

## Parte 4: Crear un Skill con `context: fork`

### Instrucciones

1. Crea el directorio del skill y su archivo `SKILL.md`:

   ```bash
   mkdir -p .claude/skills/analizar-dependencias
   ```

   Crea el archivo `.claude/skills/analizar-dependencias/SKILL.md`:

   ```markdown
   ---
   name: "Analizar Dependencias"
   description: "Analiza las dependencias del proyecto, busca vulnerabilidades y sugiere actualizaciones"
   context: fork
   ---

   # Analizar Dependencias del Proyecto

   ## Objetivo
   Realizar un análisis completo de las dependencias del proyecto.

   ## Pasos

   1. Identificar el tipo de proyecto:
      - Si existe `package.json` -> proyecto Node.js
      - Si existe `requirements.txt` o `pyproject.toml` -> proyecto Python
      - Si existe `go.mod` -> proyecto Go
      - Si existe `Cargo.toml` -> proyecto Rust
      - Si existe `pom.xml` o `build.gradle` -> proyecto Java

   2. Leer el archivo de dependencias principal

   3. Clasificar las dependencias:
      - Dependencias de producción
      - Dependencias de desarrollo
      - Dependencias transitivas (si es posible detectarlas)

   4. Para cada dependencia, identificar:
      - Versión actual instalada
      - Si hay versiones más recientes disponibles (si hay acceso a npm/pip/etc.)
      - Si hay vulnerabilidades conocidas

   5. Buscar dependencias sin usar:
      - Buscar imports/requires en el código fuente
      - Identificar dependencias declaradas pero no importadas

   6. Generar informe con formato:
      ```
      ## Informe de Dependencias

      ### Resumen
      - Total de dependencias: X
      - Producción: X | Desarrollo: X
      - Posibles actualizaciones: X
      - Sin usar (sospechosas): X

      ### Dependencias de Producción
      | Paquete | Versión | Estado |
      |---------|---------|--------|
      | ...     | ...     | ...    |

      ### Recomendaciones
      1. ...
      2. ...
      ```
   ```

2. Invoca el skill:
   ```
   /analizar-dependencias
   ```

3. Este skill se ejecuta en un subagente (`context: fork`):
   - La lectura de archivos de dependencias ocurre en el subagente
   - La búsqueda de imports en el codebase ocurre en el subagente
   - Solo el informe final llega a tu contexto principal

### Puntos de atención

- ¿Se notó alguna diferencia respecto a los skills sin `context: fork`?
- ¿El informe final llegó limpio al contexto principal?
- ¿El contexto principal se mantuvo limpio (sin archivos leídos directamente)?

---

## Parte 5: Crear un Skill de Solo Texto (`disable-model-invocation: true`)

### Instrucciones

1. Crea el directorio del skill y su archivo `SKILL.md`:

   ```bash
   mkdir -p .claude/skills/checklist-pr
   ```

   Crea el archivo `.claude/skills/checklist-pr/SKILL.md`:

   ```markdown
   ---
   name: "Checklist de PR"
   description: "Muestra el checklist de revisión para Pull Requests"
   disable-model-invocation: true
   ---

   # Checklist de Revisión de Pull Request

   ## Antes de Enviar el PR

   ### Código
   - [ ] El código compila sin errores
   - [ ] No hay warnings nuevos del linter
   - [ ] Los nombres de variables/funciones son descriptivos
   - [ ] No hay código comentado sin explicación
   - [ ] No hay console.log / print de debug
   - [ ] Las funciones tienen un máximo de 30 líneas

   ### Tests
   - [ ] Todos los tests existentes pasan
   - [ ] Se añadieron tests para la nueva funcionalidad
   - [ ] Los tests cubren los casos límite (edge cases)
   - [ ] Los tests son independientes entre sí

   ### Seguridad
   - [ ] No se exponen credenciales o secrets
   - [ ] Los inputs del usuario se validan
   - [ ] Se usa parametrización en queries SQL
   - [ ] Los endpoints tienen autorización adecuada

   ### Documentación
   - [ ] Se actualizó el README si es necesario
   - [ ] Los endpoints nuevos están documentados
   - [ ] Los cambios breaking tienen notas de migración

   ### Git
   - [ ] Los commits son atómicos y descriptivos
   - [ ] La rama está actualizada con main/develop
   - [ ] El título del PR es claro y conciso
   - [ ] La descripción del PR explica el "por qué"
   ```

2. Invoca el skill:
   ```
   /checklist-pr
   ```

3. Claude NO ejecutará las instrucciones: simplemente mostrará el texto del checklist para que lo uses como referencia.

### Puntos de atención

- ¿Claude mostró el texto sin intentar ejecutar nada?
- ¿El checklist fue útil como referencia?
- ¿En qué otros casos usarías `disable-model-invocation: true`?

---

## Reflexión Final

Responde a estas preguntas:

1. ¿Cuál es la ventaja principal de los skills sobre poner todo en CLAUDE.md?

2. ¿En qué situaciones usarías `context: fork` en un skill?

3. ¿Para qué tipo de skills es útil `disable-model-invocation: true`?

4. ¿Cómo organizarías los skills para un equipo políglota (Python + Node.js + Go)?

> **Consejo:** Ver respuestas sugeridas
>
> 1. **Tokens bajo demanda**: Los skills solo se cargan cuando se necesitan, mientras que CLAUDE.md se carga en cada sesión. Esto ahorra tokens significativamente.
>
> 2. **`context: fork`**: Cuando el skill genera mucho output (logs, análisis de muchos archivos, benchmarks) y no necesitas todo el detalle en tu contexto principal.
>
> 3. **`disable-model-invocation: true`**: Para checklists de referencia, guías de estilo, documentación de procedimientos que el humano sigue manualmente (no necesita que Claude los ejecute).
>
> 4. **Organización políglota**: Crear skills con prefijo de lenguaje (`python-deploy/SKILL.md`, `node-deploy/SKILL.md`, etc.) o usar argumentos: `/deploy python`, `/deploy node`.
