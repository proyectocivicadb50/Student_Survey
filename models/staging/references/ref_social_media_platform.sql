
with source as (
    select distinct trim(social_media_platform_raw) as social_media_platform
    from {{ ref('stg_survey_1000') }}
    where social_media_platform_raw is not null
)
select
    md5(cast(lower(social_media_platform) as varchar)) as social_media_platform_key,
    social_media_platform
from source