{% snapshot customers_snapshot %}

{{
    config(
        target_schema="{{ env_var('DBT_SNAPSHOTS_SCHEMA') }}",
        unique_key='customer_id',
        strategy='check',
        check_cols=['segment']
    )
}}

SELECT * FROM {{ ref('stg_customers') }}

{% endsnapshot %}