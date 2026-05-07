# Spec-Driven Design para Claude Code

Versión en inglés: [README.md](README.md)

> Skills para Claude Code que implementan el método spec-driven: planificas la feature en un documento, lo apruebas, y luego se implementa paso a paso. Evita que Claude improvise decisiones de diseño que tú no tomaste.

Este paquete contiene dos skills complementarios:

- **`/spec`** — Diseña el documento de la feature haciendo preguntas de clarificación.
- **`/spec-impl`** — Valida que el spec esté aprobado, crea una rama git, e implementa paso a paso.

---

## Tabla de contenidos

- [Qué es spec-driven design](#qué-es-spec-driven-design)
- [El problema que resuelve](#el-problema-que-resuelve)
- [El procedimiento en seis pasos](#el-procedimiento-en-seis-pasos)
- [Anatomía de un spec útil](#anatomía-de-un-spec-útil)
- [Cuándo SÍ y cuándo NO usar specs](#cuándo-sí-y-cuándo-no-usar-specs)
- [Reglas que casi nadie sigue](#reglas-que-casi-nadie-sigue)
- [Instalación](#instalación)
- [Uso](#uso)

---

## Qué es spec-driven design

Spec-driven design es un enfoque donde **el spec es el artefacto principal del trabajo, no el código**. El código es la consecuencia.

Suena obvio. La diferencia con "documentar antes de programar" de toda la vida es que en spec-driven el spec **no es opcional ni decorativo**: es el contrato que guía la ejecución, se versiona en git, y se mantiene vivo. Si el código diverge del spec, uno de los dos está mal.

Cada spec captura las decisiones de una sola feature. Los specs viven en `specs/` como archivos `.md` numerados secuencialmente, y forman el registro de decisiones de diseño del proyecto.

---

## El problema que resuelve

Cuando trabajas con un LLM como Claude Code, hay un fenómeno muy concreto: si le pides _"hazme un Arkanoid con power-ups y niveles"_, **va a improvisar**. Va a tomar 50 decisiones de diseño implícitas (¿clases o funciones? ¿estado global o local? ¿cómo se nombran las entidades?) sin que tú las veas. Y cada una de esas decisiones se vuelve un acoplamiento caro de revertir después.

El problema no es nuevo — los humanos también improvisan — pero con un LLM es más agudo:

1. **La velocidad de generación oculta el costo de las decisiones.** Cuando un humano tarda dos horas en escribir un módulo, tiene tiempo de pensar. Cuando Claude lo hace en 30 segundos, las decisiones pasan invisibles.
2. **Cada conversación arranca de cero.** Sin un spec, en la siguiente sesión Claude no sabe qué decidiste antes y va a improvisar otra vez, posiblemente en dirección contraria.
3. **El contexto se llena rápido.** Sin un documento estable al que referirse, terminas pegando contexto a mano en cada prompt.

El spec resuelve los tres: hace explícitas las decisiones, persiste entre sesiones, y se carga una vez como referencia.

---

## El procedimiento en seis pasos

```
┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐
│  1. DESCRIBIR   │→ │  2. PLAN MODE   │→ │   3. REFINAR    │
│  el problema    │  │ Claude propone  │  │ Tú das          │
│  no la solución │  │ no edita        │  │ decisiones      │
└─────────────────┘  └─────────────────┘  └─────────────────┘
        ↑                                          │
        │                                          │
        └──────── 2-3 iteraciones hasta converger ─┘
                              │
                              ▼
┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐
│   4. GUARDAR    │→ │   5. EJECUTAR   │→ │   6. REVISAR    │
│ specs/NN-       │  │ Paso a paso     │  │ Diff por paso   │
│ feature.md      │  │ con pausas      │  │ no al final     │
└─────────────────┘  └─────────────────┘  └─────────────────┘
```

### 1. Describir

Le describes a Claude la feature en términos de **problema**, no de solución. Si dictas la solución, Claude solo la formatea — pierdes su capacidad de proponer estructura.

### 2. Plan mode

Activas plan mode (en plan mode Claude no puede escribir archivos, solo leer y proponer). Claude responde con un documento estructurado: alcance, modelo de datos, plan de implementación y criterios de aceptación.

### 3. Refinar

Lees el plan con resistencia y das **decisiones concretas**. "Saca X del alcance", "los datos viven en JSON, no en módulos JS", "añade una sección de riesgos". Iteras 2-3 veces.

### 4. Guardar

Cuando el spec está afinado, lo guardas en `specs/NN-slug.md` con estado `Borrador`. Sales del chat, **lo relees fuera del editor**, y solo cuando estás conforme cambias el estado a `Aprobado` manualmente. Ese cambio lo hace el humano, no Claude.

### 5. Ejecutar

Sales de plan mode y le pides a Claude que implemente el spec **paso a paso**, parando después de cada paso del plan de implementación. La pausa entre pasos es lo que hace que el método funcione.

### 6. Revisar

Después de cada paso, revisas el diff. Si está bien, sigues. Si no, corriges en el momento — no al final con 600 líneas mezcladas.

---

## Anatomía de un spec útil

No todos los documentos sirven. Un spec útil tiene seis partes — si falta alguna, probablemente no es suficiente para guiar la ejecución.

### 1. Objetivo en una frase

Si no cabe en una frase, la feature es demasiado grande. Divídela antes de escribir nada más.

### 2. Alcance explícito + lo que NO entra

El "no entra" es tan importante como el "entra". Sin él, los límites son borrosos y aparece scope creep durante la implementación. Captura las cosas que se mencionaron pero se decidió posponer.

### 3. Modelo de datos

Las estructuras y nombres concretos. Si dices "el módulo de niveles", di `src/levels.js`. Si dices "una clave", da el string exacto. Esta sección es la que más se cita después en otros specs y skills.

### 4. Plan de implementación ordenado

Pasos secuenciales numerados. **Cada paso debe dejar el sistema en estado funcional.** Si un paso requiere más de 30-50 líneas de código, divídelo. El último paso no es "probar todo" — eso son los criterios de aceptación.

### 5. Criterios de aceptación

Checklist booleano verificable. Cada item se puede contestar con sí o no.

- ❌ "Que funcione bien" — no es verificable
- ❌ "Buena UX" — subjetivo
- ❌ "Sin bugs" — no operacional
- ✅ "Pulsar Esc pausa el juego y muestra el menú" — verificable

### 6. Decisiones tomadas y descartadas

Lo que consideraste y por qué elegiste lo que elegiste. **Esto es oro dentro de tres meses** cuando alguien pregunte _"¿por qué la persistencia usa una key versionada?"_. La respuesta vive ahí.

Cada decisión idealmente tiene una razón breve. Las decisiones sin razón son las primeras que se cuestionan después.

---

## Cuándo SÍ y cuándo NO usar specs

Esta arquitectura tiene costo. No la apliques a todo.

### SÍ — escribe un spec cuando:

- La tarea tocará **más de dos archivos**.
- Hay **decisiones caras de revertir** (esquemas de datos, formatos, APIs).
- La feature ocupará **más de una sesión** de Claude Code.
- Existe un **contrato que otros artefactos van a reusar** (otro spec, un skill, un hook).
- Es algo que **vas a olvidar en una semana**.

### NO — usa un prompt directo cuando:

- Es un **bug fix puntual**.
- Es un **refactor mecánico** (renombrar, mover archivos).
- Es un **experimento exploratorio** donde el objetivo es descubrir la decisión, no ejecutarla.
- La tarea **cabe en un prompt** y se entiende a la primera.
- Es una **tarea única** que no se va a repetir.

### Regla mental

> **Si te tienta abrir plan mode, probablemente lo necesites.** > **Si la feature te aburre planearla, probablemente no.**

El sentido común vence a la regla — pero el sentido común se entrena con las dos columnas de arriba.

---

## Reglas que casi nadie sigue

Cuatro patrones de uso que distinguen al método funcionando bien del método como burocracia decorativa:

### 1. En la fase de descripción, describe el problema, no la solución

❌ _"Añade un array de niveles cargados desde JSON, una función `loadLevel()`, y persistencia con localStorage versionado."_

Eso ya es un spec mal escrito por ti. Claude solo lo va a formatear.

✅ _"Quiero que el juego deje de ser de una sola pantalla. La siguiente feature es: progresión por niveles con dificultad creciente, y persistencia de mejores puntajes entre sesiones."_

Esa segunda versión deja espacio para que Claude **decida** y tú **revises**. Esa es la naturaleza del flujo.

### 2. En la fase de refinar, da decisiones concretas, no sugerencias

Plan mode es donde **tú diriges**. "Saca X", "el formato es JSON", "añade riesgos". Si dices "creo que tal vez sería bueno...", Claude va a dejarlo como está.

### 3. En la ejecución, pide pausas entre pasos

La diferencia es:

- **Sin pausas:** Claude tira 400 líneas. Tú revisas un commit gigantesco. Si algo está mal en el paso 2, está mezclado con cambios del paso 5 y 6. Doloroso.
- **Con pausas:** Claude tira 50-80 líneas (paso 1). Lees el diff. Apruebas o ajustas. Sigue al paso 2. Cada paso es un commit limpio. Revertir es trivial.

### 4. Si a mitad de la ejecución quieres cambiar algo, vuelves al paso 2 — nunca improvisas

A mitad de implementación se te ocurre algo. Lo correcto es: parar, volver a plan mode, actualizar el spec, salir, seguir. **No improvisar sobre el código.**

Esa separación es lo que evita el scope creep silencioso.

---

## Instalación

### Opción 1 — Personal (todos tus proyectos)

```bash
mkdir -p ~/.claude/skills
cp -r skills/spec ~/.claude/skills/
cp -r skills/spec-impl ~/.claude/skills/
```

### Opción 2 — De proyecto (versionado en git)

```bash
mkdir -p .claude/skills
cp -r skills/spec .claude/skills/
cp -r skills/spec-impl .claude/skills/
```

Para que el método funcione, también necesitas crear la carpeta `specs/` en la raíz del proyecto:

```bash
mkdir specs
```

Opcionalmente, añade un `specs/README.md` que documente la convención (ver el ejemplo en este repo).

---

## Uso

### Ciclo completo de una feature

```bash
# 1. Diseñar el spec con preguntas de clarificación
/spec niveles-y-highscores

# Claude lee CLAUDE.md y specs/ existentes, hace preguntas
# en bloques, desarrolla el spec sección por sección,
# y al final lo guarda como specs/03-niveles-y-highscores.md
# con estado: Borrador.

# 2. Releer el spec fuera del chat y aprobarlo manualmente
# (abrir el archivo en el editor, cambiar Estado: Borrador → Aprobado)

# 3. Implementar el spec aprobado
/spec-impl 03-niveles-y-highscores

# Claude valida que el estado sea Aprobado, crea la rama
# spec-03-niveles-y-highscores, se mueve a ella, muestra
# el resumen del spec, y arranca la implementación
# paso a paso con pausas para revisar diffs.
```

### Qué hace cada skill

#### `/spec [tema-corto]`

Diseña el documento de la feature. Pasa por cuatro fases:

1. **Contexto** — lee `CLAUDE.md` y los specs previos.
2. **Clarificación** — hace preguntas en bloques de 3-5 hasta que la feature está claramente definida.
3. **Desarrollo sección por sección** — genera y confirma cada sección del spec antes de pasar a la siguiente.
4. **Guardar** — escribe el archivo en `specs/NN-slug.md` con estado `Borrador`.

#### `/spec-impl <NN-nombre>`

Implementa un spec aprobado. Pasa por cuatro fases:

1. **Identificar** — busca el archivo del spec.
2. **Validar** — verifica que el estado sea `Aprobado`. Si no, se detiene.
3. **Crear rama** — `git checkout -b spec-NN-slug` y se mueve a ella.
4. **Implementar** — paso a paso con pausas, mostrando el resumen del spec primero.

### Estados de un spec

| Estado         | Significado                                                              |
| -------------- | ------------------------------------------------------------------------ |
| `Borrador`     | El skill `/spec` lo generó pero el humano no lo ha releído.              |
| `En revisión`  | El humano lo está revisando o iterando con Claude.                       |
| `Aprobado`     | El humano lo leyó y autorizó. `/spec-impl` solo trabaja con este estado. |
| `Implementado` | El código existe y pasa los criterios de aceptación.                     |
| `Obsoleto`     | Reemplazado por otro spec. No se borra — se referencia.                  |

**Cambiar el estado a `Aprobado` es un acto humano deliberado.** Es la única firma del contrato — Claude no puede aprobar su propio trabajo.

---

## Por qué los dos skills funcionan como pareja

```
┌───────────────────────────────────────────────────────────┐
│                                                           │
│   /spec     Claude pregunta y diseña                      │
│             ↓                                             │
│             specs/NN-slug.md  (Estado: Borrador)          │
│                                                           │
│   ──────── humano relee y aprueba ────────                │
│             ↓                                             │
│             specs/NN-slug.md  (Estado: Aprobado)          │
│                                                           │
│   /spec-impl  Claude valida e implementa                  │
│             ↓                                             │
│             rama spec-NN-slug + código                    │
│                                                           │
└───────────────────────────────────────────────────────────┘
```

El gap entre los dos skills — releer y cambiar el estado a mano — es deliberado. Es el único momento donde **solo tú puedes hacer algo**. Sin ese gap, el método se degrada a "Claude escribe documentación bonita y luego escribe el código que se le ocurra de todos modos".

---

## Licencia

MIT

---

_Si encuentras una forma de mejorar el método o los skills, abre un issue o un PR. La parte más valiosa de un skill personal es que evoluciona con el uso._
