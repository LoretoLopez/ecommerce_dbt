WITH source AS (
    SELECT * FROM {{ source('bronze', 'BRONZE_ORDERS') }}
),

deduplicado AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY order_id
            ORDER BY order_date DESC
        ) AS rn
    FROM source
    WHERE order_id IS NOT NULL
      AND customer_email LIKE '%@%'
      AND LENGTH(customer_email) - LENGTH(REPLACE(customer_email, '@', '')) = 1
      AND customer_email NOT LIKE '%@%.%.%'
),

limpio AS (
    SELECT
        TRIM(order_id)                                              AS order_id,
        LOWER(TRIM(customer_email))                                 AS customer_email,
        COALESCE(INITCAP(TRIM(customer_name)), 'Unknown')           AS customer_name,
        COALESCE(
        TRY_TO_DATE(order_date, 'YYYY-MM-DD'),
        TRY_TO_DATE(order_date, 'YYYY/MM/DD'),
        TRY_TO_DATE(order_date, 'DD/MM/YYYY'),
        TRY_TO_DATE(order_date, 'DD-MM-YYYY')
    ) AS order_date,
        CASE UPPER(TRIM(status))
            WHEN 'COMPLETADO' THEN 'COMPLETADO'
            WHEN 'COMP.'      THEN 'COMPLETADO'
            WHEN 'COMP'       THEN 'COMPLETADO'
            WHEN 'PENDIENTE'  THEN 'PENDIENTE'
            WHEN 'CANCELADO'  THEN 'CANCELADO'
            WHEN 'ENVIADO'    THEN 'ENVIADO'
            WHEN 'DEVUELTO'   THEN 'DEVUELTO'
            ELSE 'DESCONOCIDO'
        END                                                         AS status,
        TRY_TO_DECIMAL(
            REGEXP_REPLACE(
                REGEXP_REPLACE(total_amount, '[^0-9,.]', ''),
                ',', '.'
            ), 10, 2
        )                                                           AS total_amount,
        CURRENT_TIMESTAMP()                                         AS _loaded_at
    FROM deduplicado
    WHERE rn = 1
)

SELECT * FROM limpio