SELECT *
FROM {{ ref('stg_order_items') }}
WHERE line_total < 0