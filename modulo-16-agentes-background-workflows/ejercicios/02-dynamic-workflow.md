# Ejercicio 02: Crear un Dynamic Workflow para una Migración a Gran Escala

## Contexto

El equipo de frontend de tu empresa ha decidido abandonar `PropTypes` en favor de TypeScript para la validación de props en todos los componentes React. El repositorio tiene más de 100 componentes que siguen el patrón antiguo. Hacerlo componente a componente con subagentes manuales sería lento; es el caso de uso perfecto para un Dynamic Workflow.

> Si no tienes un repositorio con este caso exacto disponible, sigue las instrucciones de la sección "Preparar un repositorio de ejemplo" antes de empezar.

---

## Objetivo

Crear un Dynamic Workflow con `ultracode` para una tarea de refactor/migración a gran escala, monitorizar su progreso con `/workflows`, filtrar los agentes por estado, y decidir con criterio si el tamaño de workflow elegido fue el adecuado.

---

## Requisitos previos

| Módulo / Fichero | Razón |
|-------------------|-------|
| [M09 - Subagentes, Skills y Agent Teams](../../modulo-09-agentes-skills-teams/README.md) | Entender qué son los subagentes antes de escalarlos |
| [01-agent-view.md](../teoria/01-agent-view.md) | Base de monitorización de sesiones background |
| [02-dynamic-workflows.md](../teoria/02-dynamic-workflows.md) | Teoría de este ejercicio |
| [Ejercicio 01](01-monitorizar-agentes.md) | Familiaridad previa con `claude agents` |

---

## Preparar un repositorio de ejemplo (si lo necesitas)

Si no dispones de un repositorio real con componentes `PropTypes`, genera uno mínimo de prueba:

```bash
mkdir -p dynamic-workflow-demo/src/components
cd dynamic-workflow-demo
git init
npm init -y
npm install --save-dev typescript

# Genera 15 componentes de ejemplo con PropTypes (suficiente para practicar
# la mecánica sin gastar tiempo/tokens de un caso de 100+ componentes reales)
for i in $(seq 1 15); do
cat > "src/components/Componente${i}.jsx" << EOF
import PropTypes from 'prop-types';

function Componente${i}({ titulo, activo, onClick }) {
  return (
    <button onClick={onClick} disabled={!activo}>
      {titulo}
    </button>
  );
}

Componente${i}.propTypes = {
  titulo: PropTypes.string.isRequired,
  activo: PropTypes.bool,
  onClick: PropTypes.func.isRequired,
};

Componente${i}.defaultProps = {
  activo: true,
};

export default Componente${i};
EOF
done

git add .
git commit -m "chore: repositorio de prueba con 15 componentes PropTypes"
```

---

## Instrucciones paso a paso

1. Abre Claude Code en el repositorio de prueba (o tu repositorio real):

    ```bash
    cd dynamic-workflow-demo
    claude
    ```

2. Antes de lanzar el workflow, ajusta el tamaño esperado en `/config`. Con 15 componentes de prueba, `small` es suficiente:

    ```text
    > /config
    ```

    Navega hasta "Dynamic workflow size" y selecciona `small`. Si usas un repositorio real con 100+ componentes, considera `medium`.

3. Lanza el Dynamic Workflow con la palabra clave `ultracode`:

    ```text
    ultracode: Migra todos los componentes de src/components de PropTypes
    a TypeScript. Hay componentes en formato .jsx con validación PropTypes.
    Para cada componente:
    1. Crea una interfaz TypeScript con las props (respeta los tipos
       opcionales según defaultProps)
    2. Renombra el fichero a .tsx
    3. Sustituye la validación PropTypes por el tipado de la interfaz
    4. Elimina el import de 'prop-types' y el bloque .propTypes /
       .defaultProps
    5. Verifica que el fichero resultante compila con tsc --noEmit

    Si un componente no puede migrarse automáticamente (por ejemplo,
    props con tipos muy dinámicos), repórtalo sin forzar la conversión.
    ```

4. Claude Code debería responder con un **plan de descomposición** antes de ejecutar nada: cuántos agentes lanzará, cómo reparte los componentes, y qué dependencias detecta (si las hay). Léelo antes de aprobar.

5. Aprueba el plan y deja que el workflow se ejecute.

6. Mientras se ejecuta, abre el monitor de workflows:

    ```text
    > /workflows
    ```

    Selecciona el run en curso para ver el detalle de progreso.

7. Dentro del detalle, usa el filtrado por estado para revisar primero los agentes que fallaron o necesitan intervención:

    ```text
    f
    ```

    Selecciona el estado `failed` (o equivalente en tu versión) y revisa qué componentes no pudieron migrarse automáticamente.

8. Cuando el workflow complete, verifica el resultado desde una terminal:

    ```bash
    ls src/components/*.tsx | wc -l
    npx tsc --noEmit
    ```

9. Compara el resultado con lo que habría costado hacerlo con subagentes manuales: pide a Claude una estimación retrospectiva.

    ```text
    > Basándote en el trabajo que acabas de completar con el Dynamic
      Workflow, estima cuántos subagentes manuales (M09) habría
      necesitado lanzar para hacer el mismo trabajo, y compara el
      tiempo aproximado de coordinación.
    ```

10. Reflexiona sobre el tamaño elegido: si usaste `small` para 15 componentes y el workflow completó sin cuellos de botella, confirma que fue la elección correcta. Si tu repositorio de prueba fuera de 150 componentes reales, ¿qué tamaño habrías elegido y por qué?

---

## Criterios de éxito

- El plan de descomposición se muestra y se revisa **antes** de aprobar la ejecución del workflow
- `/workflows` muestra el run en curso con progreso visible
- El filtrado por estado (`f`) se usa al menos una vez para aislar agentes fallidos o completados
- Al menos el 80% de los componentes se migran correctamente de `.jsx` con PropTypes a `.tsx` con interfaz TypeScript
- `npx tsc --noEmit` no reporta errores de tipo en los componentes migrados con éxito
- Se documenta (aunque sea en una nota propia) qué componentes, si los hay, no pudieron migrarse automáticamente y por qué
- Se justifica por escrito la elección del tamaño de workflow (`small`/`medium`/`large`) en función del volumen de trabajo

---

## Pistas

1. Si Claude no reconoce `ultracode` como trigger, verifica tu versión de Claude Code (`claude --version`); esta funcionalidad requiere v2.1.160 o superior para el nombre `ultracode` (v2.1.154+ si tu versión aún usa el trigger antiguo "workflow").
2. Si el repositorio de prueba es muy pequeño (menos de 10 componentes), es posible que Claude decida que no merece la pena crear un workflow dinámico y prefiera lanzar unos pocos subagentes directamente. Eso es correcto: es la propia decisión de "cuándo SÍ / cuándo NO" que cubre la teoría. Si quieres forzar la práctica del workflow, amplía el repositorio de prueba a 20-30 componentes.
3. Si `tsc --noEmit` falla tras la migración, revisa primero si el error viene de la configuración de `tsconfig.json` (puede que necesites crear uno mínimo) antes de asumir que la migración de un componente concreto fue incorrecta.
4. El plan de descomposición inicial es tu oportunidad de corregir el enfoque antes de gastar tokens en la ejecución. Si el reparto no te convence (por ejemplo, agentes con ámbitos solapados), pide a Claude que ajuste el plan antes de aprobar.

---

## Solución de referencia

No existe una única solución de código porque el resultado depende del repositorio de prueba de cada estudiante. Como referencia de forma (no de contenido exacto), un componente migrado correctamente debería pasar de este formato:

```jsx
import PropTypes from 'prop-types';

function Componente1({ titulo, activo, onClick }) {
  return (
    <button onClick={onClick} disabled={!activo}>
      {titulo}
    </button>
  );
}

Componente1.propTypes = {
  titulo: PropTypes.string.isRequired,
  activo: PropTypes.bool,
  onClick: PropTypes.func.isRequired,
};

Componente1.defaultProps = {
  activo: true,
};

export default Componente1;
```

a este formato:

```tsx
interface Componente1Props {
  titulo: string;
  activo?: boolean;
  onClick: () => void;
}

function Componente1({ titulo, activo = true, onClick }: Componente1Props) {
  return (
    <button onClick={onClick} disabled={!activo}>
      {titulo}
    </button>
  );
}

export default Componente1;
```

Si tu resultado sigue este patrón (interfaz con props opcionales marcadas con `?`, valores por defecto movidos a la desestructuración, sin `prop-types` importado), la migración es correcta.
