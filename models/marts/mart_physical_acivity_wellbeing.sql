with fct_survey as (
    select * from {{ ref('core_survey_responses') }}
),

dim_freq as (
    select * from {{ ref('ref_exercise_frequency') }}
),

dim_type as (
    select * from {{ ref('ref_exercise_type') }}
)

select
    f.survey_id,
    f.hours_exercise_per_week,
    freq.exercise_frequency as exercise_intensity,
    type.exercise_type,
    f.anxiety_scale,
    f.depression_scale,
    f.self_esteem_scale,
    f.sleep_disturbance_scale

from fct_survey f
left join dim_freq freq on f.exercise_frequency_key = freq.exercise_frequency_key
left join dim_type type on f.exercise_type_key = type.exercise_type_key