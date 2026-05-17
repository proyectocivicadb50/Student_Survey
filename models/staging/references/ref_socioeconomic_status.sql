
with source as (
    select distinct trim(parent_education_raw) as parent_education
    from {{ ref('stg_survey_1000') }}
    where parent_education_raw is not null
)
select
    md5(cast(lower(parent_education) as varchar)) as parent_education_key,
    parent_education
from source