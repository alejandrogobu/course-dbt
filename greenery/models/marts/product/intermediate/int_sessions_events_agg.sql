
WITH fact_events AS (
    SELECT * 
    FROM {{ ref('fact_events') }}
    ),

{% set sql_statement %}
    SELECT DISTINCT quote_literal(event_type) AS event_type, event_type AS column_name FROM {{ ref('fact_events') }}
{% endset %}

{%- set event_types = dbt_utils.get_query_results_as_dict(sql_statement) -%}


int_session_events_agg AS (
    SELECT 
        session_id
        ,created_at_utc
        ,user_id
        {% for event_type in event_types['event_type'] %}
        ,SUM(CASE WHEN event_type = {{event_type}} THEN 1 ELSE 0 END) AS {{ event_types['column_name'][loop.index0] }}
        {% endfor %}
    FROM fact_events

    {{ dbt_utils.group_by(3) }}
    )

SELECT * FROM int_session_events_agg


