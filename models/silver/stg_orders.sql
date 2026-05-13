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
),

limpio AS (
    SELECT
        TRIM(order_id)                                              AS order_id,
        LOWER(TRIM(
            REGEXP_REPLACE(
                REGEXP_REPLACE(
                    REGEXP_REPLACE(
                        REGEXP_REPLACE(
                            REGEXP_REPLACE(
                                REGEXP_REPLACE(customer_email,
                                    '[áàäâ]', 'a'),
                                '[éèëê]', 'e'),
                            '[íìïî]', 'i'),
                        '[óòöô]', 'o'),
                    '[úùüû]', 'u'),
                'ñ', 'n')
        ))                                                          AS customer_email,
        COALESCE(INITCAP(TRIM(customer_name)), 'Unknown')           AS customer_name,
        COALESCE(
            TRY_TO_DATE(order_date, 'YYYY-MM-DD'),
            TRY_TO_DATE(order_date, 'DD/MM/YYYY'),
            TRY_TO_DATE(order_date, 'MM-DD-YYYY'),
            TRY_TO_DATE(order_date, 'DD-MM-YYYY'),
            TRY_TO_DATE(order_date, 'YYYY/MM/DD'),
            TRY_TO_DATE(order_date, 'MON DD, YYYY')
        )                                                           AS order_date,
        CASE UPPER(TRIM(status))
        WHEN 'COMPLETADO' THEN 'COMPLETADO'
        WHEN 'COMP.'      THEN 'COMPLETADO'
        WHEN 'COMP'       THEN 'COMPLETADO'
        WHEN 'PENDIENTE'  THEN 'PENDIENTE'
        WHEN 'CANCELADO'  THEN 'CANCELADO'
        WHEN 'ENVIADO'    THEN 'ENVIADO'
        WHEN 'DEVUELTO'   THEN 'DEVUELTO'
        ELSE 'DESCONOCIDO'
    END                                          AS status,
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