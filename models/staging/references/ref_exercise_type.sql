
with source as (
    select distinct trim(exercise_type_raw) as exercise_type
    from {{ ref('stg_survey_1000') }}
    where exercise_type_raw is not null
)
select
    md5(cast(lower(exercise_type) as varchar)) as exercise_type_key,
    -- Si viene vacío en el origen, lo catalogamos como 'None'
    coalesce(exercise_type, 'None') as exercise_type
from source