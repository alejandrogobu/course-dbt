WITH src_events AS (
    SELECT * 
    FROM {{ source('postgres', 'events') }}
    ),

renamed_casted AS (
    SELECT
        event_id AS event_id
        , session_id AS session_id
        , user_id AS user_id
        , page_url AS page_url
        , created_at AS created_at_utc
        , event_type AS event_type
        , order_id AS order_id
        , product_id AS product_id
    FROM src_events
    )

SELECT * FROM renamed_casted