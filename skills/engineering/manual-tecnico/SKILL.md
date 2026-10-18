---
name: manual-tecnico
description: Crea o actualiza docs/manual-tecnico.md de cualquier proyecto analizando el código y los últimos cambios de git, aplicando la estructura estándar del manual técnico de arquitectura (Dirección TI). Usar solo cuando el usuario invoque /manual-tecnico o pida explícitamente actualizar el manual técnico.
disable-model-invocation: true
argument-hint: '[lang:en|es] [ref-git-base]'
allowed-tools: Read, Glob, Grep, Edit, Write, AskUserQuestion, Bash(git log:*), Bash(git diff:*), Bash(git status:*), Bash(git config:*), Bash(date:*), Bash(python:*), Bash(python3:*), Bash(ls:*), Bash(cat:*)
---

# Manual técnico

Eres el responsable de mantener el manual técnico de arquitectura del proyecto actual. Analiza el
código y los últimos cambios del repositorio y refléjalos en `docs/manual-tecnico.md`, respetando
estrictamente la estructura definida en `references/estructura-manual-tecnico.md` (léela antes de
empezar).

## Argumentos

La skill acepta hasta dos argumentos opcionales en cualquier orden:

- **Idioma:** `lang:es` o `lang:en`. Por defecto es `es` (español).
- **Ref git base:** cualquier otro argumento se trata como ref git (ej. `HEAD~10`, `main`, `v1.0.1`).

Ejemplos: `/manual-tecnico`, `/manual-tecnico lang:en`, `/manual-tecnico lang:en HEAD~5`, `/manual-tecnico main`.

### Reglas de idioma

- **`lang:es`** (por defecto): redacta todo el manual en español con tono formal técnico.
- **`lang:en`**: redacta todo el manual en inglés sencillo (nivel B1 aproximado). Usa oraciones
  cortas, vocabulario directo, voz activa, y evita jerga innecesaria. Prefiere palabras comunes
  sobre sinónimos técnicos rebuscados (ej. "use" en vez de "leverage", "set up" en vez de
  "provision", "send" en vez de "dispatch"). Los títulos de sección de la plantilla también se
  traducen al inglés.

El idioma elegido aplica a **todo** el contenido del manual: encabezado, secciones, tablas, ADRs,
placeholders `[PENDIENTE]`/`[PENDING]`, y el resumen final en el chat.

## Paso 0 — Identificar el autor

1. Ejecuta `git config user.name`.
2. Si el resultado está vacío o no existe, **pregunta al usuario** su nombre completo antes de continuar.
3. Guarda el nombre para usarlo en el Control de Cambios (Paso 5).

## Paso 1 — Determinar el tipo de proyecto y el modo

1. **Detecta el tipo de proyecto** escaneando la raíz del repositorio y sus archivos clave:
   - `serverless*.yml`, `template.yaml`, `cdk.json` → proyecto serverless / IaC AWS
   - `Dockerfile`, `docker-compose.yml` → proyecto containerizado
   - `package.json` con framework (Next.js, React, Angular, Vue, Express, NestJS, etc.) → webapp / API Node
   - `pom.xml`, `build.gradle` → proyecto Java / Kotlin
   - `go.mod` → proyecto Go
   - `Cargo.toml` → proyecto Rust
   - `requirements.txt`, `pyproject.toml`, `setup.py` → proyecto Python
   - `.csproj`, `.sln` → proyecto .NET
   - Otro → proyecto genérico

   Adapta las secciones del manual al tipo de proyecto detectado. No todas las secciones aplican a
   todos los proyectos (ej. un CLI no tiene endpoints, una librería no tiene estrategia de despliegue
   con ambientes). **Incluye solo las secciones relevantes** y omite o marca como "No aplica" las que
   no correspondan.

2. **Obtén el nombre del proyecto** en este orden de prioridad:
   - Campo `name` de `package.json`, `Cargo.toml`, `pyproject.toml`, `go.mod`, `pom.xml`, o equivalente.
   - Nombre del directorio raíz del repositorio.
   - Si no se puede determinar, pregunta al usuario.

3. Verifica si existe `docs/manual-tecnico.md`.
   - **No existe → MODO CREACIÓN**: analiza el proyecto completo y genera el manual desde cero con
     todas las secciones relevantes al tipo de proyecto detectado.
   - **Existe → MODO ACTUALIZACIÓN**: continúa con el Paso 2.

4. Si el manual tiene imágenes embebidas en base64 (`data:image/...;base64,`), extráelas a
   `docs/img/` con un script de Python y reemplaza cada referencia por `![](img/<nombre>.png)`.
   Se hace una sola vez y deja el Markdown liviano y revisable en los diffs.

## Paso 2 — Identificar los cambios a documentar

1. Ref base, en este orden de prioridad:
   - El argumento recibido, si existe.
   - El marcador del manual: `<!-- manual-tecnico:ultimo-commit=<sha> -->`.
   - Si no hay ninguno: últimos 20 commits e informa que no había marcador.
2. Ejecuta:
   - `git log --no-merges --pretty=format:'%h | %ad | %an | %s' --date=short <base>..HEAD`
   - `git diff --stat <base>..HEAD`
   - `git diff <base>..HEAD -- <archivos relevantes>` (ver tabla del Paso 3).
   - `git status --short` → si hay cambios sin commitear, inclúyelos y avísalo en el resumen.
3. Si no hay cambios desde la base, no modifiques nada y responde: "El manual ya está al día (commit X)".

## Paso 3 — Mapear cada cambio a las secciones afectadas

La siguiente tabla es una **guía de referencia**. Aplica las filas que correspondan al tipo de
proyecto detectado en el Paso 1 e ignora las que no sean relevantes. Para tipos de proyecto no
listados, usa tu criterio para mapear los cambios a las secciones equivalentes de la plantilla.

### Proyectos serverless / IaC AWS

| Si cambió…                                                        | Revisa y actualiza                                     |
|-------------------------------------------------------------------|--------------------------------------------------------|
| `serverless*.yml` / recursos CloudFormation                       | 2.1, 2.7, 2.9, 6.2, 7.3, 8.x                           |
| Nueva función Lambda / nuevo endpoint (`functions:`, `http:`)     | 1, 1.2, 2.7, 2.9, 3.1, 3.2, 4.1, 7.2                   |
| WAF (reglas, geobloqueo, allowlist, regex de endpoints)           | 1.4, 2.7, 2.9, 7.3.1, RNF de restricción               |
| Headers de seguridad / ResponseHeadersPolicy / CSP / CORS         | 1.4, 2.7, 7.3.3, RNF de headers                        |
| Secretos (`getSecret`, rutas Secrets Manager, variables entorno)  | 1.4, 2.7, 2.9, 3.5.2, 3.5.3, 7.4, RNF de secretos      |
| Certificados / TLS / mTLS / fingerprint                           | 1.3, 1.4, 2.7, 2.9, 3.5.2, 3.5.3, 9.2, RNF, ADRs       |
| Cognito (pool, TTL de tokens, authorizer)                         | 2.7, 2.9, 3.5.2, RNF de autenticación                  |

### Cualquier tipo de proyecto

| Si cambió…                                                        | Revisa y actualiza                                     |
|-------------------------------------------------------------------|--------------------------------------------------------|
| Integraciones externas (URLs, clientes HTTP, OAuth, SDKs)         | 2.7, 2.9, 3.1, 6.1, 7.2                                |
| Validaciones (esquemas, sanitización, límites de tamaño)          | 3.4, 4.1, 7.2, 7.3.3, RNF de validación                |
| Dependencias (nuevas/actualizadas/eliminadas)                     | 5 (si es librería core → ADR), 7.2, 9.1                |
| Modelo de datos / queries / esquema BD / migraciones              | 3.1, 3.4, 3.5.2                                        |
| Variables de entorno / configuración                              | 7.4                                                    |
| Scripts de despliegue / CI-CD / stages                            | 8.1, 8.2, 8.3                                          |
| Tests                                                             | 8.4                                                    |
| Autenticación / autorización (JWT, OAuth, sesiones, roles)        | 2.7, 2.9, 3.5.2, 7.3.3, RNF de autenticación           |
| Dockerfile / docker-compose / infraestructura de contenedores     | 2.1, 2.7, 2.9, 8.x                                     |
| Rutas / controladores / endpoints nuevos                          | 1, 1.2, 2.7, 3.1, 3.2, 4.1                             |

Lee el código fuente necesario para entender el cambio; **no documentes solo a partir del mensaje del commit**.

## Paso 4 — Decidir si el cambio amerita un ADR

Crea un ADR cuando el cambio sea una decisión de arquitectura: nuevo servicio o componente
de infraestructura, cambio de mecanismo de seguridad o autenticación, cambio de librería o
framework core, cambio de patrón de integración o cambio de estrategia (secretos, certificados,
despliegue, base de datos).

- Numeración **consecutiva y única** (revisa el último ADR; nunca repitas número).
- Formato: Fecha (DD-MM-AAAA) · Estado · Contexto · Decisión · Consecuencias · Alternativas consideradas.
- Si un ADR nuevo reemplaza a otro, cambia el estado del anterior a "Reemplazado por ADR-NNN".
- Si el contexto o las alternativas no se deducen del código:
  `**[PENDIENTE: confirmar contexto/alternativas con el equipo]**`.

## Paso 5 — Editar el manual

1. **Respeta la estructura** de la plantilla: mismos títulos, numeración y orden.
   Omite secciones que no apliquen al tipo de proyecto, pero mantén la numeración para consistencia.
2. **Encabezado**: el manual siempre debe incluir el nombre del proyecto (obtenido en Paso 1) y el
   título "Manual Técnico" en el encabezado principal.
3. **Edita solo lo afectado**; no reescribas el documento completo. Conserva redacción, tono formal
   y tablas de las secciones no afectadas.
4. **No inventes datos.** IPs, cuentas de servicios cloud, correos, responsables, URLs de producción,
   tickets o resultados de herramientas de análisis que no estén en el código →
   `**[PENDIENTE: confirmar <dato>]**`.
5. **Nunca escribas valores de secretos** (passwords, keys privadas, tokens, client secrets); solo
   nombres y rutas donde se almacenan. Las claves públicas sí pueden ir.
6. **Diagramas**: no se regeneran. Si un cambio los deja desactualizados, agrega debajo:
   `> ⚠️ Diagrama pendiente de actualizar: <qué cambió>`.
7. **Tabla de contenido**: regenérala si cambian títulos o se agregan ADRs.
8. **Control de Cambios**: agrega una fila nueva:
   - Versión SemVer respecto a la última fila: MAJOR = rediseño de arquitectura; MINOR = nueva
     funcionalidad, endpoint, integración o ADR; PATCH = ajustes o correcciones menores.
   - Fecha: `date +%d/%m/%Y`. Autor: el nombre obtenido en el Paso 0.
   - Cambios: resumen factual y cronológico, mencionando los ADR creados.
9. **Marcador**: actualiza (o crea debajo del título) `<!-- manual-tecnico:ultimo-commit=<sha corto de HEAD> -->`.

## Paso 6 — Verificación de coherencia (obligatorio)

Busca en todo el manual contradicciones con lo documentado. Revisa:

- ADRs con número duplicado.
- Numeración de secciones repetida o fuera de orden.
- Requerimientos duplicados (mismo texto con distinto ID).
- Tablas de configuración o secretos que no coincidan entre sí ni con el código.
- Matriz de retención (3.5.2) y mecanismos de borrado (3.5.3) que no coincidan 1 a 1.
- Contradicciones de alcance (ej. "primer despliegue" vs "actualización sobre servicio existente").
- Secciones que referencien tecnologías o servicios que ya no se usan en el proyecto.

Corrige lo que se pueda deducir del código; lo demás, márcalo como `[PENDIENTE]`.

## Paso 7 — Resumen final (en el chat, no en el manual)

Responde en el idioma elegido, breve:

- Modo (creación / actualización) y rango analizado (`<base>..<HEAD>`, N commits).
- Versión nueva del manual.
- Secciones modificadas y ADRs creados.
- Pendientes `[PENDIENTE]` que requieren intervención humana.
- Inconsistencias corregidas.

No hagas commit; deja los cambios para que el autor los revise con `git diff docs/`.
