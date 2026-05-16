SELECT
    dbt_scd_id                  AS customer_key,
    customer_id,
    customer_email,
    customer_name,
    city,
    country,
    segment,
    signup_date,
    dbt_valid_from,
    dbt_valid_to,
    dbt_valid_to IS NULL        AS is_current
FROM {{ ref('customers_snapshot') }}