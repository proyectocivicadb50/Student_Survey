with source as (
    select distinct trim(exercise_type_raw) as exercise_type
    from {{ ref('stg_survey_1000') }}
    -- Quitamos el where not null para que los vacíos generen la llave 'none' que espera la Fact Table
)
select
    -- CORREGIDO: Usamos 'exercise_type' (el alias que sale de source) en lugar de '_raw'
    md5(cast(lower(coalesce(exercise_type, 'none')) as varchar)) as exercise_type_key,
    coalesce(exercise_type, 'None') as exercise_type
from source