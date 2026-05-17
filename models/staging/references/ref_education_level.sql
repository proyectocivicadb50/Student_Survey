
with source as (
    select distinct trim(education_level_raw) as education_level
    from {{ ref('stg_survey_1000') }}
    where education_level_raw is not null
)
select
    md5(cast(lower(education_level) as varchar)) as education_level_key,
    education_level
from source