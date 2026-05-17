
with countries_seed as (
    select trim(nationality) as nationality from {{ ref('countries_seed') }}
),
source as (
    select distinct trim(nationality_raw) as nationality 
    from {{ ref('stg_survey_1000') }}
    where nationality_raw is not null
)
select
    md5(cast(lower(s.nationality) as varchar)) as nationality_key,
    s.nationality,
    case when cs.nationality is not null then true else false end as is_european_profile
from source s
left join countries_seed cs on lower(s.nationality) = lower(cs.nationality)