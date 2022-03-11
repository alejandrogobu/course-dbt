WITH src_promos AS (
    SELECT * 
    FROM {{ source('postgres', 'promos') }}
    ),

renamed_casted AS (
    SELECT
    promo_id AS promo_id
    , discount AS total_discount_dollars
    , status AS status_promo
    FROM src_promos
    )

SELECT * FROM renamed_casted