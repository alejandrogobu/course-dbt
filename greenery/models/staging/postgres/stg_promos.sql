WITH src_promos AS (
    SELECT * 
    FROM {{ ref('base_promos') }}
    ),

renamed_casted AS (
    SELECT
    promo_id
    , name_promo
    , total_discount_usd
    , status_promo
    FROM src_promos
    )

SELECT * FROM renamed_casted