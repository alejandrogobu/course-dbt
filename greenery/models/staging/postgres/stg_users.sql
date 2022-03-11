WITH src_users AS (
    SELECT * 
    FROM {{ source('postgres', 'users') }}
    ),

renamed_casted AS (
    SELECT
    user_id AS user_id
    , first_name AS first_name
    , last_name AS last_name
    , email AS email
    , phone_number AS phone_number
    , created_at AS created_at_utc
    , updated_at AS updated_at_utc
    , address_id AS address_id
    FROM src_users
    )

SELECT * FROM renamed_casted


