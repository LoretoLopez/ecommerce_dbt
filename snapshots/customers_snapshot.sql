{% snapshot customers_snapshot %}

{{
    config(
        target_schema='SNAPSHOTS_DEV',
        unique_key='customer_id',
        strategy='check',
        check_cols=['segment', 'city', 'country']
    )
}}

SELECT * FROM {{ ref('stg_customers') }}

{% endsnapshot %}