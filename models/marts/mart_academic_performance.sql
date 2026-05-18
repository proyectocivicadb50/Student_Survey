
with fct_survey as (
    select * from {{ ref('core_survey_responses') }}
),

dim_education as (
    select * from {{ ref('ref_education_level') }}
),

dim_socioeconomic as (
    select * from {{ ref('ref_socioeconomic_status') }}
)

select
    f.survey_id,
    e.education_level,
    s.parent_education as parents_education_level,
    
    -- Variables del comportamiento del estudiante
    f.study_time_hours as daily_study_time_hours,
    f.attendance_rate_percentile,
    f.social_media_distraction_scale,
    
    -- Resultado / Métrica de éxito
    f.last_academic_results as gpa_score

from fct_survey f
left join dim_education e on f.education_level_key = e.education_level_key
left join dim_socioeconomic s on f.socioeconomic_status_key = s.parent_education_key