# Analytics engineering with dbt

Template repository for the projects and environment of the course: Analytics engineering with dbt

> Please note that this sets some environment variables so if you create some new terminals please load them again.

## License

Apache 2.0

## Week 4

### Part 2a: Product Funnel

I have created a new model, fact_funnel in which I have used the following query, this model is built on the model we had of sessions and users.

``` sql
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

SELECT * FROM final

```

Answer:

| step                    | data_value  | previous_step  | step_conversion |
| ------------------------| ------------| ---------------| ----------------|
| 1. Total Sessions	      | 578         | NULL           | NULL            |
| 2. Add to Cart Sessions	| 467         | 578            | 0.81            |
| 3. Checkout Sessions    | 361         | 467            | 0.77            |


### 3A. dbt next steps for you


Currently in my company we use dbt to build models and to be able to perform internal analysis on our users etc..
At the time of implementing dbt internally, the most valuable aspect of dbt was the documentation, since the data team created models for the business team to use, but since there was no documentation, it was complex. On the other hand, being able to add tests easily allowed us to add more data quality. Finally, it was code-based so that we could have version control and make it more developer-friendly.

After the course I think we can improve the organization of the models and refactor some models using jinja and macros.

The next step will be to start helping customers to implement dbt in their analytical stack.


### Part 3b: Setting up for production / scheduled dbt run of your project

Currently I think dbt cloud would be more than enough as the data is uploaded once a day and could be easily configured. Also with dbt cloud CI it makes it easy to deploy the code and also to create development environments. 

These days I have been testing Dagster and Prefect, I think it would be a very good idea that you organize a Dasgter course :) 

## Week 3  

## Part 1

### 1. What is our overall conversion rate?

``` sql
SELECT
ROUND(SUM(checkout)::NUMERIC / COUNT(DISTINCT session_id)::NUMERIC,4)*100 AS conversion_rate
FROM "dbt_alejandro_g_product"."agg_user_sessions"
```

Answer: **62.46%**

### 2. What is our conversion rate by product?

``` sql
WITH product_sessions AS (
  SELECT
  product_id
  , COUNT (DISTINCT session_id) AS number_sessions
FROM "dbt_alejandro_g_core"."fact_events"
WHERE product_id IS NOT NULL
GROUP BY 1
  ),

product_purchases AS (
  SELECT
    product_id
    , COUNT (distinct order_id) AS number_purchases
  FROM "dbt_alejandro_g_core"."fact_orders_products"
  GROUP BY 1
  )
  
SELECT
  S.product_id
  , P.product_name
  , S.number_sessions
  , PU.number_purchases
  , ROUND((PU.number_purchases::NUMERIC / S.number_sessions::NUMERIC)*100,2) AS conversion_rate
FROM product_sessions S
LEFT JOIN product_purchases PU
  ON S.product_id = PU.product_id
LEFT JOIN "dbt_alejandro_g_core"."dim_products" P 
  ON S.product_id = P.product_id
ORDER BY 5 DESC
```

Answer:

| product_id                           | name                | conversion_rate |
|--------------------------------------|---------------------|-----------------|
| 05df0866-1a66-41d8-9ed7-e2bbcddd6a3d | Bird of Paradise    | 0.45            |
| 35550082-a52d-4301-8f06-05b30f6f3616 | Devil's Ivy         | 0.48            |
| 37e0062f-bd15-4c3e-b272-558a86d90598 | Dragon Tree         | 0.46            |
| 4cda01b9-62e2-46c5-830f-b7f262a58fb1 | Pothos              | 0.34            |
| 55c6a062-5f4a-4a8b-a8e5-05ea5e6715a3 | Philodendron        | 0.48            |
| 579f4cd0-1f45-49d2-af55-9ab2b72c3b35 | Rubber Plant        | 0.51            |
| 58b575f2-2192-4a53-9d21-df9a0c14fc25 | Angel Wings Begonia | 0.39            |
| 5b50b820-1d0a-4231-9422-75e7f6b0cecf | Pilea Peperomioides | 0.47            |
| 5ceddd13-cf00-481f-9285-8340ab95d06d | Majesty Palm        | 0.49            |
| 615695d3-8ffd-4850-bcf7-944cf6d3685b | Aloe Vera           | 0.49            |
| 64d39754-03e4-4fa0-b1ea-5f4293315f67 | Spider Plant        | 0.47            |
| 689fb64e-a4a2-45c5-b9f2-480c2155624d | Bamboo              | 0.53            |
| 6f3a3072-a24d-4d11-9cef-25b0b5f8a4af | Alocasia Polly      | 0.41            |
| 74aeb414-e3dd-4e8a-beef-0fa45225214d | Arrow Head          | 0.55            |
| 80eda933-749d-4fc6-91d5-613d29eb126f | Pink Anthurium      | 0.41            |
| 843b6553-dc6a-4fc4-bceb-02cd39af0168 | Ficus               | 0.42            |
| a88a23ef-679c-4743-b151-dc7722040d8c | Jade Plant          | 0.47            |
| b66a7143-c18a-43bb-b5dc-06bb5d1d3160 | ZZ Plant            | 0.53            |
| b86ae24b-6f59-47e8-8adc-b17d88cbd367 | Calathea Makoyana   | 0.50            |
| bb19d194-e1bd-4358-819e-cd1f1b401c0c | Birds Nest Fern     | 0.42            |
| be49171b-9f72-4fc9-bf7a-9a52e259836b | Monstera            | 0.51            |
| c17e63f7-0d28-4a95-8248-b01ea354840e | Cactus              | 0.54            |
| c7050c3b-a898-424d-8d98-ab0aaad7bef4 | Orchid              | 0.45            |
| d3e228db-8ca5-42ad-bb0a-2148e876cc59 | Money Tree          | 0.46            |
| e18f33a6-b89a-4fbc-82ad-ccba5bb261cc | Ponytail Palm       | 0.4             |
| e2e78dfc-f25c-4fec-a002-8e280d61a2f2 | Boston Fern         | 0.41            |
| e5ee99b6-519f-4218-8b41-62f48f59f700 | Peace Lily          | 0.40            |
| e706ab70-b396-4d30-a6b2-a1ccf3625b52 | Fiddle Leaf Fig     | 0.5             |
| e8b6528e-a830-4d03-a027-473b411c7f02 | Snake Plant         | 0.39            |
| fb0e8be7-5ac4-4a76-a1fa-2cc4bf0b2d80 | String of pearls    | 0.60            |

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

### 2. What are good indicators of a user who will likely purchase again? What about indicators of users who are likely NOT to purchase again? If you had more data, what features would you want to look into to answer this question?

With the demographics we have, users from Texas and California represent 37% of the users who purchase more than once.

It would be interesting to have information such as age, gender...

### 2. Explain the marts models you added. Why did you organize the models in the way you did? ?

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

### 3. Your stakeholders at Greenery want to understand the state of the data each day. Explain how you would ensure these tests are passing regularly and how you would alert stakeholders about bad data getting through.

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

