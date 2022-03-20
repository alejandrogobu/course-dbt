WITH src_products AS (
    SELECT * 
    FROM {{ source('postgres', 'products') }}
    ),

renamed_casted AS (
    SELECT
        product_id AS product_id
        , name AS product_name
        , price AS unit_price_usd
        , inventory AS inventory
        FROM src_products
    )

SELECT * FROM renamed_casted