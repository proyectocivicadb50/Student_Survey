-- =============================================================================
-- BRONZE | brz_survey_raw
-- Raw ingestion from source CSV. Sin transformaciones, sin limpieza.
-- Solo renombrado de columnas para hacerlas manejables en SQL.
-- =============================================================================


SELECT
    -- Metadata de ingesta
    CURRENT_TIMESTAMP()                                                             AS _loaded_at,
    
    -- Identificador surrogate (no hay PK natural en el CSV)
    ROW_NUMBER() OVER (ORDER BY TIMESTAMP)                                          AS survey_id,

    -- Timestamp original
    TRY_TO_TIMESTAMP(TIMESTAMP, 'DD/MM/YYYY HH24:MI:SS')                            AS submitted_at_raw,
    

    -- Demografía
    AGE                                                                             AS age_raw,
    GENDER                                                                          AS gender_raw,
    RESIDENCE_AREA                                                                  AS residence_area_raw,
    NATIONALITY                                                                     AS nationality_raw,

    -- Nivel educativo
    EDUCATION_LEVEL                                                                 AS education_level_raw,
    SOCIOECONOMIC_STATUS                                                            AS parent_education_raw,

    -- Hábitos académicos
    STUDY_TIME_HOURS                                                                AS study_time_raw,
    ATTENDANCE_RATE_PERCENTILE                                                      AS attendance_rate_raw,
    LAST_ACADEMIC_RESULTS                                                           AS academic_result_raw,
    SOCIAL_MEDIA_DISTRACTION_DURING_ACADEMIC_ACTIVITIES                             AS social_media_distraction_score_raw,

    -- Redes sociales
    SOCIAL_MEDIA_PLATFORM                                                           AS social_media_platform_raw,
    TIME_SPENT_SOCIAL_MEDIA_HOURS                                                   AS social_media_hours_raw,
    MOST_TIME_SPENT_IN_A_DAY                                                        AS peak_usage_time_raw,
    WITHDRAWAL_SYMPTOMS                                                             AS withdrawal_symptom_raw,

    -- Salud mental (escalas 1-5)
    SLEEP_DISTURBANCE_ON_SLEEP_QUALITY                                              AS sleep_disturbance_score_raw,
    MOOD_MODIFICATION_SCALE                                                         AS mood_modification_score_raw,
    ANXIETY_SCALE                                                                   AS anxiety_score_raw,
    DEPRESSION_SCALE                                                                AS depression_score_raw,
    SELF_ESTEEM_SCALE                                                               AS selfesteem_score_raw,

    -- Actividad física
    PHYSICAL_ACTIVITY                                                               AS physical_activity_30min_raw,
    HOURS_EXERCISE_PER_WEEK                                                         AS hours_exercise_per_week_raw,
    EXERCISE_FREQUENCY                                                              AS exercise_frequency_raw,
    EXERCISE_TYPE                                                                   AS exercise_type_raw,

    -- Columna sin identificar (ignorada en capas superiores pero preservada)
    COLUMN_19                                                                       AS column_19_raw

FROM {{ source('student_survey', 'survey_1000') }}