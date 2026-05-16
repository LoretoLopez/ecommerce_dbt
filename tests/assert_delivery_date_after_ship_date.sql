{{ config(severity='warn') }}

SELECT *
FROM {{ ref('stg_shipping') }}
WHERE delivery_date < ship_date
AND delivery_date IS NOT NULL
AND ship_date IS NOT NULL