WITH source AS (
    SELECT * FROM {{ source('bronze', 'BRONZE_PRODUCTS') }}
),

limpio AS (
    SELECT
        {{ dbt_utils.generate_surrogate_key(['INITCAP(TRIM(product_name))']) }}  AS product_id,
        INITCAP(TRIM(product_name))                               AS product_name,
        COALESCE(INITCAP(TRIM(category)), 'Sin categoría')        AS category,
        COALESCE(INITCAP(TRIM(subcategory)), 'Sin subcategoría')  AS subcategory,
        TRY_TO_DECIMAL(
            REGEXP_REPLACE(
                REGEXP_REPLACE(cost_price, '[^0-9,.]', ''),
                ',', '.'
            ), 10, 2
        )                                                         AS cost_price,
        TRY_TO_DECIMAL(
            REGEXP_REPLACE(
                REGEXP_REPLACE(sale_price, '[^0-9,.]', ''),
                ',', '.'
            ), 10, 2
        )                                                         AS sale_price,
        COALESCE(INITCAP(TRIM(supplier)), 'Unknown')              AS supplier,
        CURRENT_TIMESTAMP()                                       AS _loaded_at
    FROM source
    WHERE product_name IS NOT NULL
)

SELECT * FROM limpio