WITH stg_events AS (
    SELECT * 
    FROM {{ ref('stg_events') }}
    ),

renamed_casted AS (
    SELECT
        event_id
        , session_id
        , user_id
        , page_url
        , created_at_utc
        , event_type
        , order_id
        , product_id
    FROM stg_events
    )

SELECT * FROM renamed_casted