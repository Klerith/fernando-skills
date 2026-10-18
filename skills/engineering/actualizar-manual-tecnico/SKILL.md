---
name: actualizar-manual-tecnico
description: Crea o actualiza docs/manual-tecnico.md de un proyecto de API analizando los últimos cambios de git y aplicando la estructura estándar del manual técnico de arquitectura (Dirección TI). Usar solo cuando el usuario invoque /actualizar-manual-tecnico o pida explícitamente actualizar el manual técnico.
disable-model-invocation: true
argument-hint: '[ref-git-base]'
allowed-tools: Read, Glob, Grep, Edit, Write, AskUserQuestion, Bash(git log:*), Bash(git diff:*), Bash(git status:*), Bash(git config:*), Bash(date:*), Bash(python:*), Bash(python3:*), Bash(ls:*), Bash(cat:*)
---

# Actualizar manual técnico

Eres el responsable de mantener el manual técnico de arquitectura del proyecto actual. Analiza el
código y los últimos cambios del repositorio y refléjalos en `docs/manual-tecnico.md`, respetando
estrictamente la estructura definida en `references/estructura-manual-tecnico.md` (léela antes de
empezar).

Si el usuario pasó un argumento al invocar la skill, trátalo como la ref git base (ej. `HEAD~10`,
`main`, `v1.0.1`).

## Paso 1 — Determinar el modo

1. Verifica si existe `docs/manual-tecnico.md`.
   - **No existe → MODO CREACIÓN**: analiza el proyecto completo (`serverless*.yml`, `src/`,
     `package.json`, `.env.example`, README) y genera el manual desde cero con todas las secciones.
   - **Existe → MODO ACTUALIZACIÓN**: continúa con el Paso 2.
2. Si el manual tiene imágenes embebidas en base64 (`data:image/...;base64,`), extráelas a
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

| Si cambió…                                                        | Revisa y actualiza                                     |
|-------------------------------------------------------------------|--------------------------------------------------------|
| `serverless*.yml` / recursos CloudFormation                       | 2.1, 2.7, 2.9, 6.2, 7.3, 8.x                           |
| Nueva función Lambda / nuevo endpoint (`functions:`, `http:`)     | 1, 1.2, 2.7, 2.9, 3.1, 3.2, 4.1, 7.2                   |
| WAF (reglas, geobloqueo, allowlist, regex de endpoints)           | 1.4, 2.7, 2.9, 7.3.1, RNF de restricción               |
| Headers de seguridad / ResponseHeadersPolicy / CSP / CORS         | 1.4, 2.7, 7.3.3, RNF de headers                        |
| Secretos (`getSecret`, rutas Secrets Manager, variables entorno)  | 1.4, 2.7, 2.9, 3.5.2, 3.5.3, 7.4, RNF de secretos      |
| Certificados / TLS / mTLS / fingerprint                           | 1.3, 1.4, 2.7, 2.9, 3.5.2, 3.5.3, 9.2, RNF, ADRs       |
| Integraciones externas (URLs, clientes HTTP, OAuth)               | 2.7, 2.9, 3.1, 6.1, 7.2                                |
| Validaciones (yup, magic bytes, tamaños, lista negra)             | 3.4, 4.1, 7.2, 7.3.3, RNF de validación                |
| Cognito (pool, TTL de tokens, authorizer)                         | 2.7, 2.9, 3.5.2, RNF de autenticación                  |
| `package.json` (dependencias nuevas/actualizadas/eliminadas)      | 5 (si es librería core → ADR), 7.2, 9.1                |
| Modelo de datos / queries / esquema BD                            | 3.1, 3.4, 3.5.2                                        |
| `.env*` / variables `VITE_*`                                      | 7.4 (tabla de variables públicas)                      |
| Scripts de despliegue / stages                                    | 8.1, 8.2, 8.3                                          |
| Tests                                                             | 8.4                                                    |

Lee el código fuente necesario para entender el cambio; **no documentes solo a partir del mensaje del commit**.

## Paso 4 — Decidir si el cambio amerita un ADR

Crea un ADR cuando el cambio sea una decisión de arquitectura: nuevo servicio AWS, cambio de
mecanismo de seguridad o autenticación, cambio de librería o framework core, cambio de patrón de
integración o cambio de estrategia (secretos, certificados, despliegue).

- Numeración **consecutiva y única** (revisa el último ADR; nunca repitas número).
- Formato: Fecha (DD-MM-AAAA) · Estado · Contexto · Decisión · Consecuencias · Alternativas consideradas.
- Si un ADR nuevo reemplaza a otro, cambia el estado del anterior a "Reemplazado por ADR-NNN".
- Si el contexto o las alternativas no se deducen del código:
  `**[PENDIENTE: confirmar contexto/alternativas con el equipo]**`.

## Paso 5 — Editar el manual

1. **Respeta la estructura** de la plantilla: mismos títulos, numeración y orden.
2. **Edita solo lo afectado**; no reescribas el documento completo. Conserva redacción, tono formal
   y tablas de las secciones no afectadas.
3. **No inventes datos.** IPs, cuentas AWS, correos, responsables, URLs de producción, tickets o
   resultados de SonarQube/pentest que no estén en el código → `**[PENDIENTE: confirmar <dato>]**`.
4. **Nunca escribas valores de secretos** (passwords, keys privadas, tokens, client secrets); solo
   nombres y rutas de Secrets Manager. Las claves públicas (ej. site key de Turnstile) sí pueden ir.
5. **Diagramas**: no se regeneran. Si un cambio los deja desactualizados, agrega debajo:
   `> ⚠️ Diagrama pendiente de actualizar: <qué cambió>`.
6. **Tabla de contenido**: regenérala si cambian títulos o se agregan ADRs.
7. **Control de Cambios**: agrega una fila nueva:
   - Versión SemVer respecto a la última fila: MAJOR = rediseño de arquitectura; MINOR = nueva
     funcionalidad, endpoint, integración o ADR; PATCH = ajustes o correcciones menores.
   - Fecha: `date +%d/%m/%Y`. Autor: `git config user.name`.
   - Cambios: resumen factual y cronológico, mencionando los ADR creados.
8. **Marcador**: actualiza (o crea debajo del título) `<!-- manual-tecnico:ultimo-commit=<sha corto de HEAD> -->`.

## Paso 6 — Verificación de coherencia (obligatorio)

Busca en todo el manual contradicciones con lo documentado. Ejemplo: si los certificados pasaron a
Secrets Manager, ninguna sección puede seguir diciendo "empaquetados en el bundle Lambda". Revisa:

- ADRs con número duplicado.
- Numeración de secciones repetida o fuera de orden.
- Requerimientos duplicados (mismo texto con distinto ID).
- Tablas de secretos (2.7, 2.9, 7.4) que no coincidan entre sí ni con el código.
- Matriz de retención (3.5.2) y mecanismos de borrado (3.5.3) que no coincidan 1 a 1.
- Contradicciones de alcance (ej. "primer despliegue" vs "actualización sobre servicio existente").

Corrige lo que se pueda deducir del código; lo demás, márcalo como `[PENDIENTE]`.

## Paso 7 — Resumen final (en el chat, no en el manual)

Responde en español, breve:

- Modo (creación / actualización) y rango analizado (`<base>..<HEAD>`, N commits).
- Versión nueva del manual.
- Secciones modificadas y ADRs creados.
- Pendientes `[PENDIENTE]` que requieren intervención humana.
- Inconsistencias corregidas.

No hagas commit; deja los cambios para que el autor los revise con `git diff docs/`.
