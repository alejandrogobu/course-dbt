WITH stg_addresses AS (
    SELECT * 
    FROM {{ ref ('stg_addresses') }}
    ),

renamed_casted AS (
    SELECT
        address_id
        , address
        , zipcode
        , state
        , country
    FROM stg_addresses
    )

SELECT * FROM renamed_casted