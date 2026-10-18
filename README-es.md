[English](README.md) · [Español](README-es.md)

<p align="center">
  <h1 align="center">Development Custom Skills para Claude Code</h1>
  <p align="center">Planifica la feature. Apruébala. Impleméntala paso a paso.</p>
</p>

<p align="center">
  <img alt="Licencia" src="https://img.shields.io/github/license/emmanuel-tabares-ortiz-tech/spec-driven-develpment-custom-skills">
  <img alt="Último release" src="https://img.shields.io/github/v/release/emmanuel-tabares-ortiz-tech/spec-driven-develpment-custom-skills">
  <img alt="GitHub Stars" src="https://img.shields.io/github/stars/emmanuel-tabares-ortiz-tech/spec-driven-develpment-custom-skills?style=social">
  <img alt="Skills" src="https://img.shields.io/badge/skills-3-blue">
</p>

## Inicio rápido

```bash
npx skills@latest add emmanuel-tabares-ortiz-tech/spec-driven-develpment-custom-skills
```

## Skills

| Skill | Descripción | Argumento |
| --- | --- | --- |
| `/spec` | Diseña el documento de la feature haciendo preguntas de clarificación | — |
| `/spec-impl` | Valida que el spec esté aprobado e implementa paso a paso | `<NN-slug>` |

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

## Qué es spec-driven development

Spec-driven development es un enfoque donde **el spec es el artefacto principal del trabajo, no el código**. El código es la consecuencia.

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

### Opción 1 — skills.sh (recomendado, Claude Code)

```bash
npx skills@latest add emmanuel-tabares-ortiz-tech/spec-driven-develpment-custom-skills
```

Para desinstalar:

```bash
npx skills@latest remove emmanuel-tabares-ortiz-tech/spec-driven-develpment-custom-skills
```


### Opción 2 — Otros agentes (Cursor, Codex, Antigravity)

```bash
git clone https://github.com/emmanuel-tabares-ortiz-tech/spec-driven-develpment-custom-skills ~/.dev-custom-skills
cd ~/tu-proyecto
~/.dev-custom-skills/scripts/install-to-agent.sh <agent>
```

`<agent>` puede ser `claude`, `cursor`, `codex` o `antigravity`. Ver [README.md](./README.md#installation) para detalles.

### Opción 3 — Manual

```bash
# Personal (todos tus proyectos)
mkdir -p ~/.claude/skills
cp -r skills/engineering/spec ~/.claude/skills/
cp -r skills/engineering/spec-impl ~/.claude/skills/
cp -r skills/engineering/manual-tecnico ~/.claude/skills/

# O de proyecto (versionado en git)
mkdir -p .claude/skills
cp -r skills/engineering/spec .claude/skills/
cp -r skills/engineering/spec-impl .claude/skills/
cp -r skills/engineering/manual-tecnico .claude/skills/
```

Para el workflow de specs, también crea la carpeta `specs/` en la raíz del proyecto:

```bash
mkdir specs
```

---

## Releases

Este proyecto usa [release-please](https://github.com/googleapis/release-please) para releases automáticos. Los mensajes de commit deben seguir [Conventional Commits](https://www.conventionalcommits.org/):

| Prefijo | Efecto |
| --- | --- |
| `feat:` | Sube versión minor |
| `fix:` | Sube versión patch |
| `feat!:` / `fix!:` | Sube versión major |
| `docs:`, `chore:`, `refactor:` | Sin cambio de versión |

---

## Licencia

MIT

---

_Si encuentras una forma de mejorar el método o los skills, abre un issue o un PR. La parte más valiosa de un skill personal es que evoluciona con el uso._
