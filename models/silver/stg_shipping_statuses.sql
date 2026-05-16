WITH statuses AS (
    SELECT DISTINCT
        status AS status_name
    FROM {{ ref('stg_shipping') }}
)

SELECT
    {{ dbt_utils.generate_surrogate_key(['status_name']) }} AS shipping_status_id,
    status_name
FROM statuses