WITH stg_products AS (
    SELECT * 
    FROM {{ ref ('stg_products') }}
    ),

renamed_casted AS (
    SELECT
        product_id 
        , product_name
        , unit_price_usd
        , inventory
    FROM stg_products
    )

SELECT * FROM renamed_casted