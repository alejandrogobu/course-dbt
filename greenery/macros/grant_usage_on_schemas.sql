{% macro grant_usage_on_schemas(grant_schema, group_name) %}
    grant usage on schema {{ grant_schema }} to {{ group_name }};
    grant select on all tables in schema {{ grant_schema }} to {{ group_name }};
    alter default privileges in schema {{ grant_schema }}
        grant select on tables to {{ group_name }};
{% endmacro %}