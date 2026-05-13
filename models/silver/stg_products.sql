WITH source AS (
    SELECT * FROM {{ source('bronze', 'BRONZE_PRODUCTS') }}
),

limpio AS (
    SELECT
        {{ dbt_utils.generate_surrogate_key(['product_name']) }}  AS product_id,
        INITCAP(TRIM(product_name))                               AS product_name,
        INITCAP(TRIM(category))                                   AS category,
        INITCAP(TRIM(subcategory))                                AS subcategory,
        TRY_TO_DECIMAL(cost_price, 10, 2)                         AS cost_price,
        TRY_TO_DECIMAL(sale_price, 10, 2)                         AS sale_price,
        INITCAP(TRIM(supplier))                                   AS supplier,
        CURRENT_TIMESTAMP()                                       AS _loaded_at
    FROM source
    WHERE product_name IS NOT NULL
)

SELECT * FROM limpio