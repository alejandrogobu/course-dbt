# Analytics engineering with dbt

Template repository for the projects and environment of the course: Analytics engineering with dbt

> Please note that this sets some environment variables so if you create some new terminals please load them again.

## License

Apache 2.0

## Week 2  

## Part 1

### 1. What is our user repeat rate?

``` sql
WITH repeat_rate AS(
  SELECT
    SUM(CASE WHEN total_number_orders > 1 THEN 1 END) repeated_users,
    SUM(CASE WHEN total_number_orders > 0 THEN 1 END) purchases_users
from "dbt"."dbt_alejandro_g_marketing"."agg_users_orders"
  )

SELECT 
  ROUND(repeated_users::DECIMAL/purchases_users::DECIMAL,3) AS repeat_rate
FROM repeat_rate
```

Answer: **79,8%**

### 2. What are good indicators of a user who will likely purchase again? What about indicators of users who are likely NOT to purchase again? If you had more data, what features would you want to look into to answer this question?**

With the demographics we have, users from Texas and California represent 37% of the users who purchase more than once.

It would be interesting to have information such as age, gender...

### 2. Explain the marts models you added. Why did you organize the models in the way you did? ?**

1. I have created a base model to add a unique id for the promos so as not to use the name of the promo as a unique key.  This base model is used in the sgt_promos and stg_orders to add in these models also the unique key.

2. I have created an Enterprise Data Warehouse in the Core folder and these models are the ones that will be used to create the models for the different areas. It has the following dimensions and facts:

  - dim_addresses
  - dim_products
  - dim_promos
  - dim_users
  - fact_events
  - fact_orders_products
  - fact_orders

3. For the Marketing area I have created agg_users_orders with all the information about the users and the orders they have made.

4. For the Product area I have created the agg_user_sessions model in order to be able to analyze all the sessions of each user. To create this model I have previously created the intermediate model int_sessions_events_agg.

The final folder structure is as follows:

-Greenery:
  -Models
    -Marts:
      - Core
      - Marketing
      - Product:
          - Intermediate
    - Staging:
      - Postgres:
        - Base

In each folder there is a schema.yml file with the description of each model and the corresponding tests.


## Part 2  

### 1. What assumptions are you making about each model? (i.e. why are you adding each test?)

In total there are 179 tests in the whole project, to validate referential integrity between fact and dimension tables, validate primary keys, validate positive numbers, validate valid values in a specific column, validate creation date vs. delivery date...

In the case of dimensions that were exact copies of the staging I have not added tests as they are redundant.

### 2. Did you find any “bad” data as you added and ran tests on your models? How did you go about either cleaning the data in the dbt model or adjusting your assumptions/tests?

No, I found no errors in the data

### 3. Your stakeholders at Greenery want to understand the state of the data each day. Explain how you would ensure these tests are passing regularly and how you would alert stakeholders about bad data getting through.**

In the case of using dbt cloud we could plan the daily execution and send notifications through a slack channel. In the case of using dbt core we could orchestrate the pipeline with an external tool, for example Dagster or Airflow.


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

