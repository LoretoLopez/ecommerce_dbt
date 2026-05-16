{{
    config(
        materialized='incremental',
        unique_key='fact_id',
        incremental_strategy='merge'
    )
}}

WITH order_items AS (
    SELECT * FROM {{ ref('stg_order_items') }}
),

orders AS (
    SELECT * FROM {{ ref('stg_orders') }}
),

customers AS (
    SELECT * FROM {{ ref('dim_customers') }}
    WHERE is_current = TRUE
),

products AS (
    SELECT * FROM {{ ref('dim_products') }}
)

SELECT
    oi.item_id                                                      AS fact_id,
    o.order_id,
    c.customer_key,
    p.product_key,
    o.order_date                                                    AS date_key,
    oi.quantity,
    oi.unit_price,
    oi.discount,
    oi.line_total,
    ROUND(
        COALESCE(oi.line_total, 0) - 
        (oi.quantity * COALESCE(p.cost_price, 0)),
    2)                                                              AS margin_amount
FROM order_items oi
LEFT JOIN orders o      ON oi.order_id = o.order_id
LEFT JOIN customers c   ON o.customer_email = c.customer_email
LEFT JOIN products p    ON oi.product_name = p.product_name

{% if is_incremental() %}
    WHERE o.order_date > (SELECT MAX(date_key) FROM {{ this }})
{% endif %}