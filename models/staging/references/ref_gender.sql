

with source as (
    select distinct trim(gender_raw) as gender
    from {{ ref('stg_survey_1000') }}
    where gender_raw is not null
)
select
    md5(cast(lower(gender) as varchar)) as gender_key,
    gender
from source