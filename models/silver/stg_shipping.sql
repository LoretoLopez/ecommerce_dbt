WITH source AS (
    SELECT * FROM {{ source('bronze', 'BRONZE_SHIPPING') }}
),

deduplicado AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY order_id
            ORDER BY ship_date DESC
        ) AS rn
    FROM source
    WHERE order_id IS NOT NULL
),

limpio AS (
    SELECT
        TRIM(order_id)                                              AS order_id,
        COALESCE(UPPER(TRIM(carrier)), 'DESCONOCIDO')               AS carrier,
        COALESCE(
            TRY_TO_DATE(ship_date, 'YYYY-MM-DD'),
            TRY_TO_DATE(ship_date, 'DD/MM/YYYY'),
            TRY_TO_DATE(ship_date, 'MM-DD-YYYY'),
            TRY_TO_DATE(ship_date, 'DD-MM-YYYY'),
            TRY_TO_DATE(ship_date, 'YYYY/MM/DD'),
            TRY_TO_DATE(ship_date, 'MON DD, YYYY')
        )                                                           AS ship_date,
        COALESCE(
            TRY_TO_DATE(delivery_date, 'YYYY-MM-DD'),
            TRY_TO_DATE(delivery_date, 'DD/MM/YYYY'),
            TRY_TO_DATE(delivery_date, 'MM-DD-YYYY'),
            TRY_TO_DATE(delivery_date, 'DD-MM-YYYY'),
            TRY_TO_DATE(delivery_date, 'YYYY/MM/DD'),
            TRY_TO_DATE(delivery_date, 'MON DD, YYYY')
        )                                                           AS delivery_date,
        CASE UPPER(TRIM(status))
        WHEN 'ENTREGADO'   THEN 'ENTREGADO'
        WHEN 'EN_TRANSITO' THEN 'EN_TRANSITO'
        WHEN 'EN TRANSITO' THEN 'EN_TRANSITO'
        WHEN 'PENDIENTE'   THEN 'PENDIENTE'
        WHEN 'DEVUELTO'    THEN 'DEVUELTO'
        WHEN 'PERDIDO'     THEN 'PERDIDO'
        ELSE 'DESCONOCIDO'
    END                                                                 AS status,
        CURRENT_TIMESTAMP()                                         AS _loaded_at
    FROM deduplicado
    WHERE rn = 1
)

SELECT
    order_id,
    carrier,
    ship_date,
    delivery_date,
    CASE
        WHEN ship_date IS NOT NULL AND delivery_date IS NOT NULL
         AND delivery_date >= ship_date
        THEN DATEDIFF('day', ship_date, delivery_date)
        ELSE NULL
    END                                                             AS delivery_days,
    status,
    _loaded_at
FROM limpio