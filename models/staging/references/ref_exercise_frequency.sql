with source as (
    select distinct trim(exercise_frequency_raw) as exercise_frequency
    from {{ ref('stg_survey_1000') }}
    -- Eliminamos el filter 'not null' para que los vacíos se mapeen a 'none' y cruce con la Fact
)
select
    -- Corregido: Ahora usamos 'exercise_frequency', que es el nombre válido que sale de source
    md5(cast(lower(coalesce(exercise_frequency, 'none')) as varchar)) as exercise_frequency_key,
    coalesce(exercise_frequency, 'None') as exercise_frequency
from source