WITH subcategories AS (
    SELECT DISTINCT
        category    AS category_name,
        subcategory AS subcategory_name
    FROM {{ ref('stg_products') }}
)

SELECT
    {{ dbt_utils.generate_surrogate_key(['subcategory_name']) }} AS subcategory_id,
    {{ dbt_utils.generate_surrogate_key(['category_name']) }}    AS category_id,
    subcategory_name
FROM subcategories