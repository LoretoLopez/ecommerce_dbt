WITH customers AS (
    SELECT DISTINCT
        city,
        country
    FROM {{ ref('stg_customers') }}
)

SELECT
    {{ dbt_utils.generate_surrogate_key(['city', 'country']) }} AS location_id,
    city,
    country
FROM customers