
with source as (
    select distinct trim(withdrawal_symptom_raw) as withdrawal_symptom
    from {{ ref('stg_survey_1000') }}
    where withdrawal_symptom_raw is not null
)
select
    md5(cast(lower(withdrawal_symptom) as varchar)) as withdrawal_symptom_key,
    withdrawal_symptom
from source