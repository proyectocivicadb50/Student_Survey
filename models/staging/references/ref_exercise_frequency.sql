
with source as (
    select distinct trim(exercise_frequency_raw) as exercise_frequency
    from {{ ref('stg_survey_1000') }}
    where exercise_frequency_raw is not null
)
select
    md5(cast(lower(exercise_frequency) as varchar)) as exercise_frequency_key,
    exercise_frequency
from source