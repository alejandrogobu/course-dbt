WITH src_orders AS (
    SELECT * 
    FROM {{ source('postgres', 'orders') }}
),

stg_promos AS (
    SELECT * 
    FROM {{ ref('base_promos') }}
),

renamed_casted AS (
    SELECT
        O.order_id 
        , O.user_id 
        , P.promo_id
        , O.address_id
        , O.created_at AS created_at_utc
        , O.order_cost AS item_order_cost_usd
        , O.shipping_cost AS shipping_cost_usd
        , O.order_total AS total_order_cost_usd
        , O.tracking_id
        , O.shipping_service
        , O.estimated_delivery_at AS estimated_delivery_at_utc
        , O.delivered_at AS delivered_at_utc
        , O.status AS status_order
    FROM src_orders O
    LEFT JOIN stg_promos P
        ON O.promo_id = P.name_promo
    )

SELECT * FROM renamed_casted