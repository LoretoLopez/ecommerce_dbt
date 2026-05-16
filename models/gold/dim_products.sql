WITH products AS (
    SELECT
        p.product_id                                                AS product_key,
        p.product_name,
        p.category,
        p.subcategory,
        p.supplier,
        p.cost_price,
        p.sale_price,
        ROUND((p.sale_price - p.cost_price) / p.sale_price, 2)    AS margin_pct
    FROM {{ ref('stg_products') }} p
)

SELECT * FROM products