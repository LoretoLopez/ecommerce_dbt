{% snapshot customers_snapshot %}

{{
    config(
        target_schema='SNAPSHOTS_' ~ target.name | upper,
        unique_key='customer_id',
        strategy='check',
        check_cols=['segment']
    )
}}

SELECT * FROM {{ ref('stg_customers') }}

{% endsnapshot %}