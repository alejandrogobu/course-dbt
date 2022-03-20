WITH src_promos AS (
    SELECT * 
    FROM {{ source('postgres', 'promos') }}
    ),

renamed_casted AS (
    SELECT
    {{ dbt_utils.surrogate_key('promo_id') }} AS promo_id
    , promo_id AS name_promo
    , discount AS total_discount_usd
    , status AS status_promo
    FROM src_promos
    )

SELECT * FROM renamed_casted