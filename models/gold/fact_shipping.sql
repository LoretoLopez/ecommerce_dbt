WITH shipping AS (
    SELECT * FROM {{ ref('stg_shipping') }}
),

orders AS (
    SELECT * FROM {{ ref('stg_orders') }}
),

customers AS (
    SELECT * FROM {{ ref('dim_customers') }}
    WHERE is_current = TRUE
),

carriers AS (
    SELECT * FROM {{ ref('dim_carriers') }}
)

SELECT
    s.order_id,
    c.customer_key,
    ca.carrier_key,
    s.ship_date                                         AS ship_date_key,
    s.delivery_date                                     AS delivery_date_key,
    s.delivery_days,
    s.status,
    CASE 
    WHEN s.delivery_days IS NULL THEN NULL
    WHEN s.delivery_days > 5 THEN TRUE 
    ELSE FALSE 
END                                                 AS is_late
FROM shipping s
LEFT JOIN orders o      ON s.order_id = o.order_id
LEFT JOIN customers c   ON o.customer_email = c.customer_email
LEFT JOIN carriers ca   ON s.carrier = ca.carrier_name