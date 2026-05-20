# 📊 Student Survey — Social Media & Academic Performance

> Pipeline de datos end-to-end construido con **dbt + Snowflake + Power BI** para analizar el impacto del uso de redes sociales en el rendimiento académico, salud mental y actividad física de adolescentes.

---

## 📋 Tabla de contenidos

- [Descripción del proyecto](#descripción-del-proyecto)
- [Dataset](#dataset)
- [Stack tecnológico](#stack-tecnológico)
- [Arquitectura del pipeline](#arquitectura-del-pipeline)
- [Estructura del proyecto](#estructura-del-proyecto)
- [Modelos dbt](#modelos-dbt)
- [Tests de calidad de datos](#tests-de-calidad-de-datos)
- [Configuración y variables de entorno](#configuración-y-variables-de-entorno)
- [Cómo ejecutar el proyecto](#cómo-ejecutar-el-proyecto)
- [Paquetes dbt utilizados](#paquetes-dbt-utilizados)
- [Casos de uso analíticos](#casos-de-uso-analíticos)

---

## Descripción del proyecto

Este proyecto implementa un pipeline de datos completo para explorar la relación entre el uso de redes sociales y distintos indicadores de bienestar en adolescentes. A partir de una encuesta de 1.000 registros obtenida de Kaggle, los datos se transforman en capas sucesivas (Bronze → Silver → Gold) siguiendo la arquitectura **Medallion**, y finalmente se consumen desde un dashboard de **Power BI**.

Los análisis cubren cuatro dimensiones principales:

- **Rendimiento académico**: GPA, horas de estudio, asistencia y distracción digital.
- **Salud mental**: ansiedad, depresión, autoestima, calidad del sueño y alteración del estado de ánimo.
- **Actividad física**: tipo de ejercicio, frecuencia e intensidad semanal.
- **Demografía**: edad, género, nacionalidad, área de residencia (urbana/rural) y nivel socioeconómico familiar.

---

## Dataset

| Atributo | Detalle |
|---|---|
| **Fuente** | [Kaggle — Student Social Media & Academic Performance](https://www.kaggle.com/) |
| **Registros** | 1.000 |
| **Población** | Adolescentes |
| **Formato** | CSV |
| **Tabla en Snowflake** | `DEV_BRONZE_DB.KAGGLE.SURVEY_1000` |

### Campos principales del CSV

| Columna | Descripción |
|---|---|
| `TIMESTAMP` | Fecha y hora de respuesta |
| `AGE` | Edad del encuestado |
| `GENDER` | Género (Male / Female) |
| `RESIDENCE_AREA` | Área de residencia (Urban / Rural) |
| `NATIONALITY` | Nacionalidad |
| `EDUCATION_LEVEL` | Nivel educativo actual |
| `SOCIOECONOMIC_STATUS` | Nivel máximo de estudios de los padres (proxy socioeconómico) |
| `STUDY_TIME_HOURS` | Horas de estudio diarias |
| `ATTENDANCE_RATE_PERCENTILE` | Tasa de asistencia (0–100) |
| `LAST_ACADEMIC_RESULTS` | Calificación académica (A+, A, B+… / GPA) |
| `SOCIAL_MEDIA_PLATFORM` | Red social principal (YouTube, TikTok, Instagram…) |
| `TIME_SPENT_SOCIAL_MEDIA_HOURS` | Horas diarias en redes sociales |
| `MOST_TIME_SPENT_IN_A_DAY` | Momento del día de mayor uso (Morning / Afternoon / Evening / Night) |
| `WITHDRAWAL_SYMPTOMS` | Síntomas al no acceder a redes sociales |
| `SLEEP_DISTURBANCE_ON_SLEEP_QUALITY` | Escala 1–5 de afectación del sueño |
| `MOOD_MODIFICATION_SCALE` | Escala 1–5 de alteración del ánimo |
| `ANXIETY_SCALE` | Escala 1–5 de ansiedad |
| `DEPRESSION_SCALE` | Escala 1–5 de depresión |
| `SELF_ESTEEM_SCALE` | Escala 1–5 de autoestima |
| `PHYSICAL_ACTIVITY` | Realiza ≥30 min de actividad física al día (Yes / No) |
| `HOURS_EXERCISE_PER_WEEK` | Horas de ejercicio semanales |
| `EXERCISE_FREQUENCY` | Frecuencia de ejercicio (Low / Medium / High) |
| `EXERCISE_TYPE` | Tipo de deporte (Cardio / Gym / Team Sports) |

---

## Stack tecnológico

| Herramienta | Rol |
|---|---|
| **Snowflake** | Data warehouse (almacenamiento y cómputo en las 3 capas) |
| **dbt Core** | Transformación, modelado y testing de datos |
| **Power BI** | Visualización y dashboards de consumo final |
| **Python / dbt CLI** | Orquestación y ejecución local |

---

## Arquitectura del pipeline

```
┌─────────────────────────────────────────────────────────────────────┐
│                          FUENTE DE DATOS                            │
│              Kaggle CSV → Snowflake (BRONZE_DB.KAGGLE)              │
└─────────────────────────┬───────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────────────┐
│  🥉 BRONZE  |  {ENV}_BRONZE_DB.INTERMEDIATE                         │
│                                                                     │
│  stg_survey_1000                                                    │
│  • Renombrado de columnas a nombres SQL manejables                  │
│  • Generación de survey_id (ROW_NUMBER)                             │
│  • Parseo de TIMESTAMP → TIMESTAMP nativo                           │
│  • Sin transformaciones de negocio                                  │
│  • Materialización: VIEW                                            │
└─────────────────────────┬───────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────────────┐
│  🥈 SILVER  |  {ENV}_SILVER_DB.CORE  +  {ENV}_SILVER_DB.REFERENCES │
│                                                                     │
│  core_survey_responses   ← Tabla de hechos central (incremental)    │
│  • Limpieza y casting de todos los campos numéricos                 │
│  • Mapeo de calificaciones literales (A+, B…) a escala GPA 0–5     │
│  • Generación de claves foráneas MD5 hacia todas las dimensiones    │
│  • Join con ref_time para la clave de fecha                         │
│                                                                     │
│  Dimensiones de referencia (ref_*)                                  │
│  ref_gender              ref_residence_area    ref_education_level  │
│  ref_socioeconomic_status ref_socialmedia_platform                  │
│  ref_most_time_spent     ref_withdrawal_symptom                     │
│  ref_exercise_frequency  ref_exercise_type     ref_nationality      │
│  ref_time                dim_time                                   │
│                                                                     │
│  Materialización: VIEW                                              │
└─────────────────────────┬───────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────────────┐
│  🥇 GOLD  |  {ENV}_GOLD_DB.MARTS                                    │
│                                                                     │
│  mart_academic_performance        → Rendimiento académico           │
│  mart_mental_health_social_media  → Salud mental y redes sociales   │
│  mart_physical_activity_wellbeing → Actividad física y bienestar    │
│  mart_european_demographics       → Análisis demográfico            │
│                                                                     │
│  Materialización: TABLE                                             │
└─────────────────────────┬───────────────────────────────────────────┘
                          │
                          ▼
                    📊 POWER BI
              (consume directamente los marts)
```

> `{ENV}` se resuelve dinámicamente mediante la variable de entorno `DBT_ENVIRONMENTS` (ej. `DEV`, `PRO`, `CI_CD`).

---

## Estructura del proyecto

```
student_survey/
│
├── dbt_project.yml              # Configuración principal del proyecto dbt
├── packages.yml                 # Paquetes dbt de terceros
├── profiles.yml                 # Conexión a Snowflake (NO commitear con credenciales reales)
│
├── macros/
│   └── generate_schema_name.sql # Macro para resolución dinámica de schemas por entorno
│
├── models/
│   ├── bronze/
│   │   ├── __student_survey__sources.yml  # Declaración de la fuente Kaggle + tests
│   │   └── stg_survey_1000.sql            # Ingesta raw y renombrado de columnas
│   │
│   ├── staging/
│   │   ├── silver_schema.yml              # Documentación y tests de la capa Silver
│   │   ├── core/
│   │   │   └── core_survey_responses.sql  # Tabla de hechos central (incremental)
│   │   └── references/
│   │       ├── ref_gender.sql
│   │       ├── ref_residence_area.sql
│   │       ├── ref_education_level.sql
│   │       ├── ref_socioeconomic_status.sql
│   │       ├── ref_socialmedia_platform.sql
│   │       ├── ref_most_time_spent.sql
│   │       ├── ref_withdrawal_symptom.sql
│   │       ├── ref_exercise_frequency.sql
│   │       ├── ref_exercise_type.sql
│   │       ├── ref_nationality.sql
│   │       └── ref_time.sql
│   │
│   └── marts/
│       ├── gold_schema.yml                        # Documentación de los marts
│       ├── dim_time.sql
│       ├── mart_academic_performance.sql
│       ├── mart_mental_health_social_media.sql
│       ├── mart_physical_acivity_wellbeing.sql
│       └── mart_european_demographics.sql
│
└── seeds/
    ├── countries_seed.csv         # Catálogo de países con enriquecimiento de perfil europeo
    └── schema.yml
```

---

## Modelos dbt

### 🥉 Bronze — `stg_survey_1000`

Lectura directa de la fuente Kaggle sin transformaciones de negocio. Aplica únicamente:
- Renombrado de columnas a nombres SQL estándar (`_raw` suffix).
- Generación de `survey_id` con `ROW_NUMBER()`.
- Parsing del timestamp de texto a tipo `TIMESTAMP`.
- Preservación de `COLUMN_19` sin identificar para auditoría.

### 🥈 Silver — `core_survey_responses` *(incremental)*

Tabla de hechos central. Aplica limpieza profunda y estructuración:
- Extracción de valores numéricos con `REGEXP_SUBSTR` (campos que vienen como texto con unidades).
- Normalización de calificaciones literales (`A+` → `5.0`, `B` → `3.5`, etc.) a escala GPA decimal.
- Generación de todas las claves foráneas mediante `MD5(LOWER(TRIM(campo)))`.
- Carga incremental: sólo procesa registros nuevos comparando `survey_timestamp` con el máximo ya cargado.

### 🥈 Silver — Dimensiones de referencia (`ref_*`)

11 tablas de dimensión que normalizan los valores categóricos de la encuesta. Cada una genera su propia `*_key` con MD5 para garantizar joins consistentes con `core_survey_responses`.

| Dimensión | Descripción |
|---|---|
| `ref_gender` | Catálogo de géneros |
| `ref_residence_area` | Urban / Rural |
| `ref_education_level` | Nivel educativo del encuestado |
| `ref_socioeconomic_status` | Nivel educativo de los padres |
| `ref_socialmedia_platform` | YouTube, TikTok, Instagram, etc. |
| `ref_most_time_spent` | Franja horaria de mayor uso |
| `ref_withdrawal_symptom` | Síntomas de abstinencia digital |
| `ref_exercise_frequency` | Low / Medium / High |
| `ref_exercise_type` | Cardio / Gym / Team Sports |
| `ref_nationality` | Nacionalidad + flag `is_european_profile` |
| `ref_time` | Dimensión de fechas completa |

### 🥇 Gold — Marts

Tablas desnormalizadas y optimizadas para consumo directo desde Power BI.

| Mart | Descripción | Dimensiones clave |
|---|---|---|
| `mart_academic_performance` | GPA, horas de estudio, asistencia, distracción por redes | Nivel educativo, educación parental |
| `mart_mental_health_social_media` | Escalas de ansiedad, depresión, autoestima, sueño y ánimo | Plataforma, franja horaria, síntomas de abstinencia |
| `mart_physical_activity_wellbeing` | Horas de ejercicio, frecuencia, tipo y su relación con bienestar mental | Frecuencia e intensidad de ejercicio |
| `mart_european_demographics` | Análisis cruzado de demografía, GPA y uso de redes | Edad, género, nacionalidad, área de residencia |

---

## Tests de calidad de datos

El proyecto implementa una cobertura de tests exhaustiva en todas las capas:

| Tipo de test | Ejemplos aplicados |
|---|---|
| `not_null` | `survey_id`, `age`, `survey_timestamp`, todas las FK |
| `unique` | `survey_id`, PKs de todas las dimensiones |
| `accepted_values` | `gender`, `residence_area`, escalas 1–5, días de la semana |
| `relationships` (integridad referencial) | Todas las FK de `core_survey_responses` hacia sus dimensiones |
| `dbt_expectations.expect_column_values_to_be_between` | `attendance_rate` (0–100), GPA (0–5), todas las escalas 1–5 |
| `dbt_utils.accepted_range` | Escalas de salud mental y distracción |

---

## Configuración y variables de entorno

El proyecto **no hardcodea credenciales**. Todas las conexiones y bases de datos se inyectan mediante variables de entorno.

### Variables requeridas

| Variable | Descripción | Ejemplo |
|---|---|---|
| `DBT_ENVIRONMENTS` | Entorno activo | `DEV`, `PRO`, `CI_CD` |
| `DBT_SNOWFLAKE_ACCOUNT` | Identificador de cuenta Snowflake | `xy12345.eu-west-1` |
| `DBT_SNOWFLAKE_USER` | Usuario de Snowflake | `dbt_user` |
| `DBT_SNOWFLAKE_PASSWORD` | Contraseña del usuario | `***` |
| `DBT_SNOWFLAKE_ROLE` | Rol de Snowflake con permisos sobre las DBs | `TRANSFORMER` |
| `DBT_SNOWFLAKE_WAREHOUSE` | Virtual Warehouse a utilizar | `COMPUTE_WH` |

### Bases de datos por entorno

Según `DBT_ENVIRONMENTS`, dbt creará los modelos en:

| Capa | Base de datos |
|---|---|
| Bronze | `{ENV}_BRONZE_DB` |
| Silver | `{ENV}_SILVER_DB` |
| Gold | `{ENV}_GOLD_DB` |

### `.env` de ejemplo

```bash
export DBT_ENVIRONMENTS=DEV
export DBT_SNOWFLAKE_ACCOUNT=tu_cuenta.region
export DBT_SNOWFLAKE_USER=tu_usuario
export DBT_SNOWFLAKE_PASSWORD=tu_contraseña
export DBT_SNOWFLAKE_ROLE=tu_rol
export DBT_SNOWFLAKE_WAREHOUSE=tu_warehouse
```

> ⚠️ **Nunca** commitees `profiles.yml` con credenciales reales. Asegúrate de que esté cubierto por `.gitignore`.

---

## Cómo ejecutar el proyecto

### Pre-requisitos

- Python 3.8+
- dbt Core con adaptador Snowflake instalado
- Acceso a una cuenta de Snowflake con las bases de datos creadas
- Variables de entorno configuradas (ver sección anterior)

### Instalación

```bash
# 1. Clonar el repositorio
git clone https://github.com/tu-usuario/student-survey.git
cd student-survey

# 2. Instalar dbt y el adaptador de Snowflake
pip install dbt-snowflake

# 3. Instalar los paquetes dbt del proyecto
dbt deps
```

### Ejecución

```bash
# Verificar la conexión con Snowflake
dbt debug

# Cargar los seeds (catálogo de países)
dbt seed

# Ejecutar todos los modelos
dbt run

# Ejecutar sólo una capa específica
dbt run --select tag:bronze
dbt run --select tag:silver
dbt run --select tag:gold

# Ejecutar los tests de calidad
dbt test

# Ejecutar modelos + tests en un solo comando
dbt build

# Generar y visualizar la documentación
dbt docs generate
dbt docs serve
```

### Ejecución por entorno

```bash
# Entorno de desarrollo
DBT_ENVIRONMENTS=DEV dbt build

# Entorno de producción
DBT_ENVIRONMENTS=PRO dbt build
```

---

## Paquetes dbt utilizados

| Paquete | Versión | Uso |
|---|---|---|
| [`dbt-labs/dbt_utils`](https://github.com/dbt-labs/dbt-utils) | `1.3.3` | `accepted_range`, utilidades generales de testing |
| [`dbt-labs/codegen`](https://github.com/dbt-labs/codegen) | `0.14.0` | Generación automática de YAML de modelos y fuentes |
| [`metaplane/dbt_expectations`](https://github.com/metaplane/dbt-expectations) | `0.10.10` | Tests avanzados tipo Great Expectations (`between`, etc.) |

---

## Casos de uso analíticos

Los marts de la capa Gold están diseñados para responder preguntas de negocio concretas:

**Rendimiento académico**
- ¿Cuántas horas de redes sociales diarias se correlacionan con una caída en el GPA?
- ¿El nivel educativo de los padres influye en la asistencia y el tiempo de estudio?
- ¿Qué plataforma genera mayor distracción durante actividades académicas?

**Salud mental**
- ¿Los usuarios de TikTok presentan niveles más altos de ansiedad o depresión que los de YouTube?
- ¿El uso nocturno de redes sociales se asocia con mayor alteración del sueño?
- ¿Qué síntomas de abstinencia son más frecuentes y en qué perfiles demográficos?

**Actividad física**
- ¿Los adolescentes con alta frecuencia de ejercicio reportan menor depresión y ansiedad?
- ¿Existe diferencia entre tipos de deporte (Cardio vs. Gym vs. Team Sports) en indicadores de bienestar?

**Demografía**
- ¿Hay diferencias en el uso de redes sociales entre residentes urbanos y rurales?
- ¿El perfil europeo presenta patrones distintos de rendimiento académico respecto al resto?
- ¿Cómo varía el GPA y el uso digital según género y franja de edad?

---

<p align="center">
  Construido con dbt · Snowflake · Power BI
</p>
