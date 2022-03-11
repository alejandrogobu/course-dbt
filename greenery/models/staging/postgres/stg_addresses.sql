WITH src_addresses AS (
    SELECT * 
    FROM {{ source('postgres', 'addresses') }}
    ),

renamed_casted AS (
    SELECT
        address_id AS address_id
        , address AS address
        , zipcode AS zipcode
        , state AS state
        , country AS country
    FROM src_addresses
    )

SELECT * FROM renamed_casted
