WITH source AS (
    SELECT * FROM {{ source('bronze', 'BRONZE_ORDER_ITEMS') }}
),

limpio AS (
    SELECT
        {{ dbt_utils.generate_surrogate_key(['order_id', 'product_name']) }} AS item_id,
        TRIM(order_id)                                              AS order_id,
        INITCAP(TRIM(product_name))                                AS product_name,
        COALESCE(INITCAP(TRIM(category)), 'Sin categoría')         AS category,
        CASE 
            WHEN TRY_TO_NUMBER(quantity) IS NULL THEN NULL
            WHEN TRY_TO_NUMBER(quantity) <= 0 THEN NULL
            ELSE TRY_TO_NUMBER(quantity)::INT
        END                                                        AS quantity,
        TRY_TO_DECIMAL(
            REGEXP_REPLACE(
                REGEXP_REPLACE(unit_price, '[^0-9,.]', ''),
                ',', '.'
            ), 10, 2
        )                                                          AS unit_price,
        CASE
            WHEN TRY_TO_DECIMAL(discount, 10, 2) < 0 THEN 0
            WHEN TRY_TO_DECIMAL(discount, 10, 2) > 1 THEN NULL
            ELSE TRY_TO_DECIMAL(discount, 10, 2)
        END                                                        AS discount,
        CASE
            WHEN TRY_TO_NUMBER(quantity) > 0 
             AND TRY_TO_DECIMAL(
                REGEXP_REPLACE(
                    REGEXP_REPLACE(unit_price, '[^0-9,.]', ''),
                    ',', '.'
                ), 10, 2) IS NOT NULL
            THEN ROUND(
                TRY_TO_NUMBER(quantity) *
                TRY_TO_DECIMAL(
                    REGEXP_REPLACE(
                        REGEXP_REPLACE(unit_price, '[^0-9,.]', ''),
                        ',', '.'
                    ), 10, 2) *
                (1 - COALESCE(TRY_TO_DECIMAL(discount, 10, 2), 0)),
                2)
            ELSE NULL
        END                                                        AS line_total,
        CURRENT_TIMESTAMP()                                        AS _loaded_at
    FROM source
    WHERE order_id IS NOT NULL
      AND product_name IS NOT NULL
      AND TRY_TO_NUMBER(quantity) > 0
)

SELECT * FROM limpio