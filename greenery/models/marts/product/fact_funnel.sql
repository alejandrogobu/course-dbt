WITH sessions AS (

  SELECT 
  * 
  FROM {{ ref('agg_user_sessions') }}
  ), 


funnel AS (

    SELECT 
      '1. Total Sessions' AS step
      , COUNT( DISTINCT CASE WHEN 
                page_view > 0
                OR add_to_cart > 0
                OR checkout > 0 
                OR package_shipped > 0
                THEN session_id 
                ELSE NULL END) AS data_value
    FROM sessions

    UNION ALL

    SELECT
      '2. Add to Cart Sessions' AS step
      , COUNT(DISTINCT CASE WHEN 
                add_to_cart > 0
                OR checkout > 0 
                OR package_shipped > 0
              THEN session_id
              ELSE NULL END) AS data_value
    FROM sessions

    UNION ALL
    
    SELECT
        '3. Checkout Sessions' AS step
        , COUNT(DISTINCT CASE WHEN 
                checkout > 0 
                OR package_shipped > 0
                THEN session_id 
                ELSE NULL END) AS data_value
    FROM sessions

    ), 

previous_steps AS (

    SELECT 
        step
        , data_value
        , LAG(data_value) OVER () AS previous_step
        , MAX(data_value) OVER () AS first_step
    FROM funnel 

    ),

final AS (

    SELECT 
        step
        , data_value
        , previous_step
        , ROUND(data_value / previous_step::NUMERIC, 2) AS step_conversion
    FROM previous_steps
    
    )

SELECT * FROM FINAL
