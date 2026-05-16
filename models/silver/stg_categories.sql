WITH categories AS (
    SELECT DISTINCT
        category AS category_name
    FROM {{ ref('stg_products') }}
)

SELECT
    {{ dbt_utils.generate_surrogate_key(['category_name']) }} AS category_id,
    category_name
FROM categories