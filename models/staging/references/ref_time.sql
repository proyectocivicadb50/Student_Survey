
with source as (
    select distinct 
        -- Aseguramos que Snowflake lo interprete como un Timestamp válido
        to_timestamp(submitted_at_raw) as submitted_timestamp
    from {{ ref('stg_survey_1000') }} 
    where submitted_at_raw is not null
),

transformed as (
    select
        -- Llave primaria de la dimensión (usamos la fecha pura como ID, ej: 20231024)
        to_char(submitted_timestamp, 'YYYYMMDD') as date_key,
        
        -- Atributos de fecha desglosados para los filtros de Power BI / Tableau
        cast(submitted_timestamp as date) as full_date,
        extract(year from submitted_timestamp) as calendar_year,
        extract(month from submitted_timestamp) as month_number,
        to_char(submitted_timestamp, 'MMMM') as month_name, -- Ej: October / Octubre
        extract(day from submitted_timestamp) as day_of_month,
        extract(dayofweek from submitted_timestamp) as day_of_week,
        to_char(submitted_timestamp, 'DY') as day_name, -- Ej: Mon / Lunes
        
        -- Atributos opcionales de hora por si quieres analizar momentos del día
        extract(hour from submitted_timestamp) as hour_of_day
    from source
)

select * from transformed