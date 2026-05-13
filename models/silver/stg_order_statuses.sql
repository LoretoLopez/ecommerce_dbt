WITH statuses AS (
    SELECT DISTINCT
        status AS status_name
    FROM {{ ref('stg_orders') }}
)

SELECT
    {{ dbt_utils.generate_surrogate_key(['status_name']) }} AS order_status_id,
    status_name
FROM statuses