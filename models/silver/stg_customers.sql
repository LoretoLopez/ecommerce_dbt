WITH source AS (
    SELECT * FROM {{ source('bronze', 'BRONZE_CUSTOMERS') }}
),

deduplicado AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY customer_email 
            ORDER BY signup_date DESC
        ) AS rn
    FROM source
    WHERE customer_email IS NOT NULL
      AND customer_email LIKE '%@%'
      AND LENGTH(customer_email) - LENGTH(REPLACE(customer_email, '@', '')) = 1
      AND customer_email NOT LIKE '%@%.%.%'
),

limpio AS (
    SELECT
        {{ dbt_utils.generate_surrogate_key(['customer_email']) }} AS customer_id,
        LOWER(TRIM(customer_email))                                 AS customer_email,
        COALESCE(INITCAP(TRIM(customer_name)), 'Unknown')           AS customer_name,
        COALESCE(INITCAP(TRIM(city)), 'Unknown')                    AS city,
        COALESCE(
            CASE UPPER(TRIM(country))
                WHEN 'ESPAÑA' THEN 'España'
                WHEN 'SPAIN'  THEN 'España'
                WHEN 'ES'     THEN 'España'
                WHEN 'ESP'    THEN 'España'
                ELSE 'España'
            END, 'España')                                          AS country,
        COALESCE(
            TRY_TO_DATE(signup_date, 'YYYY-MM-DD'),
            TRY_TO_DATE(signup_date, 'DD/MM/YYYY'),
            TRY_TO_DATE(signup_date, 'MM-DD-YYYY'),
            TRY_TO_DATE(signup_date, 'DD-MM-YYYY'),
            TRY_TO_DATE(signup_date, 'YYYY/MM/DD'),
            TRY_TO_DATE(signup_date, 'MON DD, YYYY')
        )                                                           AS signup_date,
        COALESCE(INITCAP(TRIM(segment)), 'Sin segmento')            AS segment,
        CURRENT_TIMESTAMP()                                         AS _loaded_at
    FROM deduplicado
    WHERE rn = 1
)

SELECT * FROM limpio