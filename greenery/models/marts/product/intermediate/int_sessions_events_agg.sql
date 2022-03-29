
WITH fact_events AS (
    SELECT * 
    FROM {{ ref('fact_events') }}
    ),

int_session_events_agg AS (
    SELECT 
        session_id
        ,created_at_utc
        ,user_id
        ,{{get_column_values(ref('fact_events'),'event_type')}}
    FROM fact_events

    {{ dbt_utils.group_by(3) }}
    )

SELECT * FROM int_session_events_agg


