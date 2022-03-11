WITH src_orders AS (
    SELECT * 
    FROM {{ source('postgres', 'orders') }}
),

renamed_casted AS (
    SELECT
        order_id AS order_id
        , user_id AS user_id
        , promo_id AS promo_id
        , address_id AS address_id
        , created_at AS created_at_utc
        , order_cost AS item_order_cost
        , shipping_cost AS shipping_cost
        , order_cost AS total_order_cost
        , tracking_id AS tracking_id
        , shipping_service AS shipping_service
        , estimated_delivery_at AS estimated_delivery_at_utc
        , delivered_at AS delivered_at_utc
        , status AS status_order
    FROM src_orders
    )

SELECT * FROM renamed_casted