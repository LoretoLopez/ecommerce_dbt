WITH segments AS (
    SELECT DISTINCT
        segment AS segment_name
    FROM {{ ref('stg_customers') }}
)

SELECT
    {{ dbt_utils.generate_surrogate_key(['segment_name']) }} AS segment_id,
    segment_name
FROM segments