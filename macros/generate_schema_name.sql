{% macro generate_schema_name(custom_schema_name, node) -%}

    {%- set default_schema = target.schema -%}

    {#- En entorno productivo o CI/CD usamos el custom_schema_name tal cual -#}
    {%- if env_var('DBT_ENVIRONMENTS', 'FAIL') in ['PRO', 'CI_CD']
            or custom_schema_name is not none -%}

        {{ custom_schema_name | trim }}

    {%- else -%}

        {{ default_schema }}

    {%- endif -%}

{%- endmacro %}