WITH src_order_items AS (
    SELECT * 
    FROM {{ source('postgres', 'order_items') }}
    ),

renamed_casted AS (
    SELECT
        order_id AS order_id
        , product_id AS product_id
        , quantity AS quantity
    FROM src_order_items
    )

SELECT * FROM renamed_casted
