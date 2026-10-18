# Estructura estándar del manual técnico

Estructura obligatoria de `docs/manual-tecnico.md`. Títulos, numeración y orden deben mantenerse
exactamente. Debajo de cada sección se indica qué contenido va.

**Nota:** No todas las secciones aplican a todos los tipos de proyecto. Si una sección no es
relevante para el proyecto (ej. WAF en un CLI, endpoints en una librería), omítela o márcala
como "No aplica para este tipo de proyecto". Mantén la numeración original para consistencia.

## Encabezado

```
# **Manual Técnico — <Nombre del proyecto>**
## **DIRECCIÓN TI**
# <AUTOR EN MAYÚSCULAS>, <DD/MM/AAAA>
<!-- manual-tecnico:ultimo-commit=<sha> -->
```

## Control de Cambios
Tabla `| Versión | Fecha | Autor | Cambios |`. Una fila por actualización, la más reciente al final.
Versión inicial 1.0.0. Cambios redactados de forma factual (qué cambió y en qué secciones/ADR).

## Tabla de contenido
Lista con enlaces a todas las secciones y ADRs.

---

## 1. Resumen Ejecutivo
Qué es el sistema, para quién, stack tecnológico, dónde se despliega, controles de seguridad
principales y puntos de entrada del sistema (endpoints, comandos CLI, interfaces, etc.).
Estado de aprobación (ticket) si aplica.

### 1.1 Propósito del Sistema
Problema de negocio que resuelve y flujo automatizado de punta a punta.

### 1.2 Alcance de este Documento
Si es salida nueva o actualización. Listas **Dentro del alcance** / **Fuera del alcance**.

### 1.3 Contexto y Motivación
Por qué existe esta versión o este cambio.

### 1.4 Restricciones
#### Restricciones de Negocio
#### Restricciones Técnicas
#### Restricciones de Seguridad
(Viñetas; coherentes con los ADR vigentes.)

---

## 2. Arquitectura de Alto Nivel

### 2.1 Descripción de arquitectura
Componentes principales del sistema y cómo se relacionan (frontend, backend, servicios,
infraestructura, herramientas de build, etc.).

### 2.2 Diagrama conceptual de arquitectura (Actual)
### 2.3 Matriz de trazabilidad de arquitectura (Actual)
### 2.4 Diagrama de infraestructura o de despliegue (Actual)
### 2.5 Matriz de trazabilidad de entorno de ejecución (Actual)
(Primer despliegue: texto estándar indicando que no existe arquitectura previa. Actualización:
describir el estado anterior al cambio.)

### 2.6 Diagrama conceptual de arquitectura (Propuesta)
Imagen del diagrama.

### 2.7 Matriz de trazabilidad de arquitectura (Propuesta)
Tabla `| Componente | Ubicación | Detalle | Seguridad Aplicada |`: listar todos los componentes
relevantes del proyecto (cliente, frontend, backend, base de datos, servicios externos,
infraestructura, etc.).

### 2.8 Diagrama de infraestructura o de despliegue (Propuesta)
Imagen del diagrama.

### 2.9 Matriz de trazabilidad de entorno de ejecución (Propuesta)
Tabla `| Componente HW | Ubicación | Ruta artefactos | Seguridad Aplicada |`.

---

## 3. Flujo de Datos Seguro

### 3.1 Descripción de datos para el negocio
Tabla `| Funcionalidad | Origen | Destino | Tipo de Dato | Protocolo (Tránsito) | Cifrado (Reposo) | Límite de Confianza |`.

### 3.2 Especificación de Contratos de Comunicación
Por cada punto de entrada (endpoint, comando, interfaz): descripción, parámetros de entrada y
datos de salida (con ejemplos, nunca datos reales).

### 3.3 Diagrama ciclo de vida de los datos (Security DFD)
Imagen + convenciones del diagrama (entidades externas, flujos etiquetados, límites de confianza,
almacenes de datos, procesos).

### 3.4 Matriz de Trazabilidad del Ciclo de Vida del Dato
Tabla `| Componente | Acción | Datos Involucrados | Seguridad Aplicada |` (Ingesta, Procesamiento,
Transformación, Transmisión, Procesamiento Backend, Almacenamiento, Salida).

### 3.5 Política de Retención y Disposición Final de Datos
Versión, Clasificación, Referencia Normativa.
#### 3.5.1 Objetivo
#### 3.5.2 Matriz de Retención de Datos
Tabla `| Categoría de Dato | Tipo de Almacenamiento | Periodo de Retención | Justificación Legal/Técnica |`.
#### 3.5.3 Mecanismos de Borrado Seguro (Disposición Final)
Una entrada por cada categoría de 3.5.2 (deben coincidir 1 a 1).
#### 3.5.4 Responsabilidades
Rol (persona) — responsabilidad.

---

## 4. Requerimientos

### 4.1 Requerimientos Funcionales
Tabla `| ID | Descripción | Prioridad | Estado |` (RF-NN consecutivos, sin duplicados).

### 4.2 Requerimientos No Funcionales
RNF-NN consecutivos, agrupados en:
#### 4.2.1 Rendimiento
#### 4.2.2 Seguridad
#### 4.2.3 Usabilidad
#### 4.2.4 Mantenibilidad

---

## 5. Decisiones de Arquitectura (ADRs)

```
#### ADR-NNN: <Título>
**Fecha:** DD-MM-AAAA
**Estado:** Propuesto | Aceptado | Reemplazado por ADR-XXX | Obsoleto

**Contexto:** ...
**Decisión:** ...
**Consecuencias:** (viñetas, positivas y negativas)
**Alternativas consideradas:** (viñetas: alternativa — motivo de descarte)
```

---

## 6. Administración

### 6.1 Administración de cuenta o servidor
Tabla `| IP/Cuenta | Área | Correo |`.

### 6.2 Servicios de infraestructura
Tabla `| Cuenta/Servicio | Tipo | Permisos | Área | Correo |` (permisos reales derivados de la
configuración del proyecto: IaC, Dockerfile, CI/CD, etc.).

---

## 7. Seguridad

### 7.1 Seguridad Implementada
Resumen en viñetas.

### 7.2 Modelo de Amenazas
Tabla `| Amenaza | Probabilidad | Impacto | Mitigación | Estado |` (ninguna mitigación vacía).

### 7.3 Controles de Seguridad Implementados
#### 7.3.1 Perimetral (firewall, WAF, rate limiting, IP filtering — lo que aplique)
#### 7.3.2 Red (aislamiento de red, VPC, security groups, políticas de acceso — lo que aplique)
#### 7.3.3 Aplicación (headers de seguridad, CORS, validaciones, sanitización, controles en código)
#### 7.3.4 Datos (cifrado en tránsito/reposo, limpieza de datos temporales)

### 7.4 Gestión de Secretos
Tabla `| Secreto | Ubicación | Propietario |` (rutas o mecanismo de almacenamiento usado).
Si hay variables públicas expuestas al cliente, listarlas con advertencia de visibilidad.

### 7.5 Análisis Estático de Código
Enlaces a herramientas de análisis (SonarQube, ESLint, etc.) + evidencia si existe.

### 7.6 Pentesting
Estado y evidencia.

---

## 8. Estrategia de Despliegue

### 8.1 Ambientes
Tabla `| Ambiente | URL | Identificador | Propósito |`.

### 8.2 Comandos de Despliegue
Bloque de código con los scripts o comandos reales de despliegue del proyecto.

### 8.3 Estrategia de Rollback
Pasos numerados con comandos, smoke tests, notificación a stakeholders y tiempo estimado.

### 8.4 Testing
Pruebas automatizadas existentes (tipo, herramienta, cobertura) o declaración de que no existen.

---

## 9. Políticas para la gestión del Mantenimiento
### 9.1 Actualizaciones de Dependencias
### 9.2 Renovación de Certificados
### 9.3 Revisión de Logs
### 9.4 Pruebas de Seguridad

---

## 10. Referencias
### 10.1 Documentación Técnica
### 10.2 Documentación Interna
### 10.3 Repositorios Relacionados
