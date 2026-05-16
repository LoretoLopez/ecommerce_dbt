SELECT
    carrier_id      AS carrier_key,
    carrier_name
FROM {{ ref('stg_carriers') }}