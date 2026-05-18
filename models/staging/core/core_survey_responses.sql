{{ config(
    materialized='incremental',
    unique_key='survey_id'
) }}

with source as (
    select * from {{ ref('stg_survey_1000') }}

    {% if is_incremental() %}
        where submitted_at_raw > (select max(submitted_at_raw) from {{ this }})
    {% endif %}

),

transformed as (
    select
        -- Id único de la encuesta (para poder contar filas en BI)
        survey_id as survey_id,
        submitted_at_raw as survey_timestamp,
        
        -- MÉTRICAS NUMÉRICAS LIMPIAS (Reglas de negocio aplicadas)
        cast(age_raw as integer) as age,
        cast(regexp_substr(study_time_raw, '\\d+') as integer) as study_time_hours,
        cast(regexp_substr(attendance_rate_raw, '\\d+') as integer) as attendance_rate_percentile,
        cast(regexp_substr(social_media_hours_raw, '\\d+') as integer) as time_spent_social_media_hours,
        cast(try_to_numeric(replace(trim(hours_exercise_per_week_raw), ',', '.'), 5, 2) as numeric(5,2)) as hours_exercise_per_week,
        
        cast(social_media_distraction_score_raw as integer) as social_media_distraction_scale,
        cast(sleep_disturbance_score_raw as integer) as sleep_disturbance_scale,
        cast(mood_modification_score_raw as integer) as mood_modification_scale,
        cast(anxiety_score_raw as integer) as anxiety_scale,
        cast(depression_score_raw as integer) as depression_scale,
        cast(selfesteem_score_raw as integer) as self_esteem_scale,

        -- Mapeo estricto del GPA/Notas a escala decimal 0-5
        cast(
            case 
                when trim(academic_result_raw) = 'A+' then 5.0
                when trim(academic_result_raw) = 'A'  then 4.8
                when trim(academic_result_raw) = 'A-' then 4.5
                when trim(academic_result_raw) = 'B+' then 4.0
                when trim(academic_result_raw) = 'B'  then 3.5
                when trim(academic_result_raw) = 'B-' then 3.0
                when trim(academic_result_raw) = 'C+' then 2.5
                when trim(academic_result_raw) = 'C'  then 2.0
                when trim(academic_result_raw) = 'D'  then 1.0
                when trim(academic_result_raw) = 'F'  then 0.0
                else try_to_numeric(replace(trim(academic_result_raw), ',', '.'), 5, 2)
            end as numeric(5,2)
        ) as last_academic_results,

        -- LLAVES FORÁNEAS (Uniones exactas a las dimensiones independientes)
        md5(cast(lower(trim(gender_raw)) as varchar)) as gender_key,
        md5(cast(lower(trim(residence_area_raw)) as varchar)) as residence_area_key,
        md5(cast(lower(trim(education_level_raw)) as varchar)) as education_level_key,
        md5(cast(lower(trim(parent_education_raw)) as varchar)) as socioeconomic_status_key,
        md5(cast(lower(trim(social_media_platform_raw)) as varchar)) as social_media_platform_key,
        md5(cast(lower(trim(peak_usage_time_raw)) as varchar)) as most_time_spent_key,
        md5(cast(lower(trim(withdrawal_symptom_raw)) as varchar)) as withdrawal_symptoms_key,
        md5(cast(lower(trim(exercise_frequency_raw)) as varchar)) as exercise_frequency_key,
        md5(cast(lower(coalesce(trim(exercise_type_raw), 'none')) as varchar)) as exercise_type_key,
        md5(cast(lower(trim(nationality_raw)) as varchar)) as nationality_key

    from source
)

select * from transformed