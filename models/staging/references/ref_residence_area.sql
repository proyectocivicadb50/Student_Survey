
with source as (
    select distinct trim(residence_area_raw) as residence_area
    from {{ ref('stg_survey_1000') }}
    where residence_area_raw is not null
)
select
    md5(cast(lower(residence_area) as varchar)) as residence_area_key,
    residence_area
from source