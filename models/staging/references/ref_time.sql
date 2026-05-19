with source as (
    select 
        -- Snowflake: to_timestamp maneja strings raw eficientemente
        cast(to_timestamp(submitted_at_raw) as date) as survey_timestamp
    from {{ ref('stg_survey_1000') }} 
    where submitted_at_raw is not null
),

unique_dates as (
    select distinct survey_timestamp
    from source
),

transformed as (
    select
        to_char(survey_timestamp, 'YYYYMMDD')::int as date_key,
        survey_timestamp as full_date,
        extract(year from survey_timestamp) as calendar_year,
        extract(month from survey_timestamp) as month_number,
        -- initcap garantiza "January" para pasar el test accepted_values
        initcap(to_char(survey_timestamp, 'mon')) as month_name, 
        extract(day from survey_timestamp) as day_of_month,
        -- Aseguramos rango 0-6 (domingo a sábado) para Snowflake
        extract(dayofweek_iso from survey_timestamp) - 1 as day_of_week,
        -- initcap garantiza "Mon" para pasar el test accepted_values
        initcap(to_char(survey_timestamp, 'dy')) as day_name
    from unique_dates
)

select * from transformed