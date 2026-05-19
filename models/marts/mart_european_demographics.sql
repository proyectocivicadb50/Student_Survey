with fct_survey as (
    select * from {{ ref('core_survey_responses') }}
),

dim_nat as (
    select * from {{ ref('ref_nationality') }}
),

dim_gender as (
    select * from {{ ref('ref_gender') }}
),

dim_residence as (
    select * from {{ ref('ref_residence_area') }}
)

select
    f.survey_id,
    f.age,
    g.gender,
    r.residence_area,
    n.nationality,
    n.is_european_profile,
    f.last_academic_results as gpa_score,
    f.time_spent_social_media_hours,
    f.anxiety_scale,
    f.depression_scale

from fct_survey f
left join dim_nat n on f.nationality_key = n.nationality_key
left join dim_gender g on f.gender_key = g.gender_key
left join dim_residence r on f.residence_area_key = r.residence_area_key