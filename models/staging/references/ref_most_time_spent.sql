
with source as (
    select distinct trim(peak_usage_time_raw) as most_time_spent
    from {{ ref('stg_survey_1000') }}
    where peak_usage_time_raw is not null
)
select
    md5(cast(lower(most_time_spent) as varchar)) as most_time_spent_key,
    most_time_spent
from source