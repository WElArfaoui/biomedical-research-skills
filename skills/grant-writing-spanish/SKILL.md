---
name: grant-writing-spanish
description: Drafting and reviewing fellowship and grant applications in the Spanish research system (PFIS-ISCIII, Joan Oró-AGAUR, FPI-AEI, FPU-MIU, Sara Borrell, Río Hortega, AECC, Marató TV3). Covers structure, language, scoring criteria, alignment with funder priorities, CV/CVN preparation, and the specific stylistic conventions of Spanish academic funding. Use when drafting, restructuring, or reviewing any section of a Spanish or Catalan fellowship/grant application.
version: 0.1.0
---

# Grant Writing — Spanish System

## When to use
- Writing or reviewing a PFIS, Joan Oró, FPI, FPU, Sara Borrell, Río Hortega, AECC, or similar Spanish/Catalan call.
- Adapting a project description from English to Spanish/Catalan or vice versa.
- Strengthening a draft against the official scoring criteria.
- Reviewing a colleague's application.

This skill does NOT replace the official call documents. Always cross-check against the current year's `convocatoria` and `bases reguladoras`.

## Process

### Phase 1 — Identify the call and its constraints

For any call, extract these facts FIRST:

| Item | Where to find it | Why it matters |
|---|---|---|
| Funder | Call PDF | Determines tone (ISCIII = clinical, AEI = scientific, AGAUR = catalán/regional priorities) |
| Total budget + per-item caps | Call PDF | Constrains realistic scope |
| Duration | Call PDF | 4 years for predoctoral usually |
| Eligibility | Call PDF | Date thresholds (PhD <3 years for postdoc, etc.) |
| Scoring rubric | Call PDF "criterios de evaluación" | This is how it's actually graded — write to the rubric |
| Required documents | Call PDF | Memoria, CVN, CV del IP, anexos |
| Page/character limits | Call PDF | Hard limits, do not violate |
| Submission deadline + portal | Call PDF | Plataforma SEDE, AGE, AGAUR portal |

### Phase 2 — Map sections to scoring criteria

Each call has its own structure but most share these blocks. Below are the typical sections for **PFIS (ISCIII)** as a reference; adapt for others.

#### Texto 1 — Justificación, antecedentes, hipótesis (PFIS) / Estado del arte
Goal: convince that the topic is important, well-grounded, and that there is a real gap.

Structure:
1. Burden of disease / clinical-scientific relevance (1-2 párrafos, con datos cuantitativos).
2. State of the art: ¿qué se ha hecho? Citar autores y resultados clave. Demuestra conocimiento de la literatura reciente.
3. Limitaciones del estado actual: ¿por qué no basta lo que hay?
4. Hipótesis explícita y testable. Enunciar como afirmación, no como pregunta.

Anti-patterns:
- Empezar con "Desde tiempos inmemoriales..." o introducción genérica. **Empezar con el problema concreto.**
- Citar revisiones generales en lugar de fuentes primarias.
- Hipótesis vaga ("estudiar el papel de X").

#### Texto 2a — Objetivos
Goal: que un evaluador en 30 segundos sepa qué vas a hacer.

Estructura recomendada:
- **Objetivo principal** (una frase, declarativa).
- **Objetivos específicos** (3-5, numerados, alineados con los WP del cronograma).

Anti-pattern: objetivos que son métodos disfrazados ("aplicar deep learning a..."). Un objetivo es lo que se quiere CONOCER o DEMOSTRAR.

#### Texto 2b — Metodología
Goal: el evaluador debe poder imaginar el experimento.

Estructura por objetivo específico:
- Diseño del estudio.
- Población / muestra (n estimado, criterios).
- Intervención / análisis (técnicas concretas, software, hardware).
- Outcome / variable de respuesta.
- Análisis estadístico.

Incluir:
- **Cronograma** (Gantt o tabla por trimestres / años).
- **Hitos** (milestones medibles).
- **Análisis de viabilidad** (datos preliminares si los hay → muy valorado).
- **Plan de contingencia** ante fallos previsibles.

Anti-patterns:
- "Se aplicarán técnicas de IA". → Concretar: nnU-Net v2, PyTorch 2.x, GPU RTX 4000 Ada disponible en el grupo.
- Cronograma desbalanceado (todo concentrado en el último año).

#### Texto 3 — Plan de formación (en convocatorias predoctorales)
Goal: justificar por qué el candidato + entorno + IP = combinación ganadora.

Estructura:
1. **Formación previa** del candidato y cómo se alinea con el proyecto.
2. **Plan de formación específico**: cursos, congresos previstos, estancias internacionales (si están planificadas).
3. **Entorno de investigación**: grupo, institución, recursos disponibles (HPC, biobancos, redes como a CIBER consortium).
4. **Tutorización**: experiencia del IP en formación, tesis dirigidas previas, productividad.

Esta sección suele puntuar mucho. **Concretar nombres, fechas, datos.**

#### CV / CVN del candidato y del IP
- Usa el formato CVN oficial (FECYT) cuando lo pidan.
- Para tu CV: secciones obligatorias en este orden — formación, publicaciones (con IF y cuartil), comunicaciones a congresos, financiación previa, estancias, premios, otros méritos.
- Cada publicación: cita completa + DOI + IF del año + cuartil JCR + posición de autor.
- Si eres primer autor o coautor de igual contribución, márcalo claramente.

### Phase 3 — Lenguaje y estilo

#### Tono
- Formal, técnico, en tercera persona impersonal o primera persona del plural ("se propone", "proponemos").
- Evitar el "yo" salvo en cartas de motivación.
- Castellano académico estándar (no calcos del inglés: "evidencia" como prueba, no "evidence" en sentido estadístico amplio).

#### Estructura de párrafos
- Una idea por párrafo.
- Frase tópico al inicio.
- Conectores explícitos entre párrafos ("Por tanto", "Sin embargo", "En consecuencia").

#### Anti-patterns lingüísticos
| Mal | Mejor |
|---|---|
| "Es muy importante" | "Es esencial para X porque Y" |
| "Avanzar el estado del arte" (anglicismo) | "Avanzar en el conocimiento" |
| "Implementar un modelo" (anglicismo) | "Desarrollar un modelo" |
| "Performance del modelo" | "Rendimiento del modelo" |
| "Background del candidato" | "Trayectoria del candidato" |
| Frases de >40 palabras | Partir en dos |
| Voz pasiva en cadena | Alternar con activa |

### Phase 4 — Alineación con prioridades del funder

Antes de enviar, verifica que el proyecto se alinea con:
- **PFIS / AES**: líneas estratégicas del Plan Estatal de I+D+I, Salud Global, Medicina de Precisión, Acción Estratégica en Salud.
- **AGAUR (Joan Oró)**: prioridades RIS3CAT, salud, IA aplicada.
- **AEI (FPI)**: alineación con el grupo del IP que tiene el proyecto vigente.
- **CIBER (a CIBER consortium en tu caso)**: si el grupo pertenece a CIBER, mencionar la integración explícitamente.

### Phase 5 — Self-review checklist

- [ ] Todos los textos respetan los límites de caracteres/páginas.
- [ ] Hipótesis explícita y testable.
- [ ] Objetivos numerados y alineados con WP/cronograma.
- [ ] Cronograma realista (sin solapes imposibles, con hitos).
- [ ] Plan de contingencia mencionado.
- [ ] Datos preliminares incluidos si los hay.
- [ ] CVN actualizado, todas las publicaciones con IF y cuartil.
- [ ] Lenguaje formal, sin anglicismos, sin frases >40 palabras.
- [ ] Citaciones recientes (≥50% últimos 5 años, excepto clásicos).
- [ ] Alineación con líneas estratégicas mencionada explícitamente.
- [ ] Sección de aspectos éticos completada (CEIm, RGPD, género).
- [ ] Aspectos transversales: género (Ley Orgánica 3/2007), ciencia abierta, ODS.

## Calls específicas — notas rápidas

### PFIS (ISCIII)
- **A quién**: predoctorales en el SNS / centros sanitarios.
- **Lo que más puntúa**: trayectoria del IP, productividad reciente del grupo, alineación con líneas estratégicas, viabilidad del proyecto (datos preliminares).
- **Trampa común**: subestimar la sección de IP y entorno.

### Joan Oró (AGAUR)
- **A quién**: predoctorales adscritos a universidades catalanas.
- **Específico**: secciones en catalán; valorar contribución al sistema R+D catalán.
- **Lo que más puntúa**: expediente académico, calidad del grupo, plan de tesis bien estructurado.

### FPI (AEI)
- **A quién**: contratos predoctorales asociados a un proyecto específico del PI.
- **Específico**: la elegibilidad depende del proyecto del IP; el candidato es secundario en orden de presentación.

### Sara Borrell / Río Hortega (ISCIII)
- **A quién**: postdoctorales (Sara Borrell) o especialistas en formación (Río Hortega).
- **Específico**: enfoque clínico-traslacional fuerte.

## Formato de entregable

Cuando se invoque esta skill, generar:
1. Texto pulido para la sección solicitada.
2. Comentarios en línea (entre corchetes) sobre dónde se podría reforzar.
3. Lista de checks pendientes basada en el checklist de Phase 5.
4. Si es relevante, una sugerencia de cómo enlazar con otras secciones para coherencia interna.
