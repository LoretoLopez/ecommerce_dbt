SELECT *
FROM {{ ref('dim_products') }}
WHERE margin_pct > 1
OR margin_pct < 0