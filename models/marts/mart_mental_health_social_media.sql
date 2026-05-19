
with fct_survey as (
    select * from {{ ref('core_survey_responses') }}
),

dim_platform as (
    select * from {{ ref('ref_socialmedia_platform') }} 
),

dim_time as (
    select * from {{ ref('ref_most_time_spent') }}
),

dim_withdrawal as (
    select * from {{ ref('ref_withdrawal_symptom') }} 
)

select
    f.survey_id,
    p.social_media_platform,
    t.most_time_spent as peak_usage_time,
    f.time_spent_social_media_hours,
    w.withdrawal_symptom,
    f.anxiety_scale,
    f.depression_scale,
    f.self_esteem_scale,
    f.sleep_disturbance_scale,
    f.mood_modification_scale

from fct_survey f
left join dim_platform p on f.social_media_platform_key = p.social_media_platform_key
left join dim_time t on f.most_time_spent_key = t.most_time_spent_key
left join dim_withdrawal w on f.withdrawal_symptoms_key = w.withdrawal_symptom_key