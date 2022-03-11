# WEEK 1

### 1. How many users do we have?

Query:
``` sql
SELECT 
  COUNT(DISTINCT user_id) AS total_users
FROM dbt_alejandro_g.stg_users
```

Answer: **130**

### 2. On average, how many orders do we receive per hour?

Query:
``` sql
WITH order_hour AS (
  SELECT
    DATE_TRUNC('HOUR', created_at_utc) AS created_hour
    , COUNT (DISTINCT order_id) AS orders_number
  FROM dbt_alejandro_g.stg_orders
  GROUP BY 1
)
  
SELECT
  ROUND(AVG(orders_number),2) AS avg_orders
FROM order_hour
```

Answer: **7.52**

## 3. On average, how long does an order take from being placed to being delivered?

Query:
``` sql
SELECT
  AVG(delivered_at_utc-created_at_utc) AS avg_delivery 
FROM dbt_alejandro_g.stg_orders 
WHERE delivered_at_utc IS NOT NULL
```

Answer: **3 days 21:24:11**

### 4. How many users have only made one purchase? Two purchases? Three+ purchases?

Query:
``` sql
WITH orders_users AS (
  SELECT
    user_id
    , COUNT(DISTINCT order_id) AS order_number
  FROM dbt_alejandro_g.stg_orders
  GROUP BY 1
)

SELECT
  CASE 
    WHEN order_number >= 3 THEN '3+'
    ELSE order_number::VARCHAR
  END AS order_number
  , COUNT(DISTINCT user_id) AS users
FROM orders_users
GROUP BY 1
```

Answer:
| # order_number | # users |
|----------------|---------|
|               1|       25|
|               2|       28|
|              3+|       71|

### 5. On average, how many unique sessions do we have per hour?

Query:
``` sql
WITH sessions_hour AS (
  SELECT
    DATE_TRUNC('HOUR', created_at_utc) AS created_hour
    , COUNT (DISTINCT session_id) AS unique_session_number
  from dbt_alejandro_g.stg_events
  group by 1
)

SELECT
  ROUND(AVG(unique_session_number),2)
FROM sessions_hour
```

Answer: **16.33**