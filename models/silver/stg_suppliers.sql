WITH suppliers AS (
    SELECT DISTINCT
        supplier AS supplier_name
    FROM {{ ref('stg_products') }}
)

SELECT
    {{ dbt_utils.generate_surrogate_key(['supplier_name']) }} AS supplier_id,
    supplier_name
FROM suppliers