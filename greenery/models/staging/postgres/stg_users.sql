WITH src_users AS (
    SELECT * 
    FROM {{ source('postgres', 'users') }}
    ),

renamed_casted AS (
    SELECT
    user_id 
    , first_name
    , last_name
    , email
    , phone_number
    , created_at AS created_at_utc
    , updated_at AS updated_at_utc
    , address_id
    FROM src_users
    )

SELECT * FROM renamed_casted


