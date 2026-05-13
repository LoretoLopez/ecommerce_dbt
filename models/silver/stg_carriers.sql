WITH carriers AS (
    SELECT DISTINCT
        carrier AS carrier_name
    FROM {{ ref('stg_shipping') }}
)

SELECT
    {{ dbt_utils.generate_surrogate_key(['carrier_name']) }} AS carrier_id,
    carrier_name
FROM carriers