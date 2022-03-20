WITH stg_orders AS (
    SELECT * 
    FROM {{ ref('stg_orders') }}
    ),

stg_order_items AS (
    SELECT * 
    FROM {{ ref('stg_order_items') }}
    ),

renamed_casted AS (
    SELECT
        O.order_id 
        , O.user_id 
        , O.promo_id
        , O.address_id
        , OI.product_id
        , O.created_at_utc
        , OI.quantity
        , O.status_order
    FROM stg_orders O
    LEFT JOIN stg_order_items OI
      ON O.order_id = OI.order_id
    )
SELECT * FROM renamed_casted