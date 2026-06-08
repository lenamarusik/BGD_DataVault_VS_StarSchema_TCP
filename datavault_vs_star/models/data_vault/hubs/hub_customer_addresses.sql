WITH source_keys AS (
    SELECT distinct
        {{ hash_key(["ca_address_id"]) }} AS address_hk,
        ca_address_id,
        {{ batch_load_date() }} AS load_date,
        'tpcds.item' AS record_source
    FROM {{ ref("stg_customer_addresses") }}
    WHERE ca_address_id IS NOT NULL
),

ghost as (
    SELECT
        {{ ghost_key() }} AS address_hk,
        cast(null AS varchar) AS ca_address_id,
        {{ ghost_load_date() }} AS load_date,
        'SYSTEM' AS record_source
)


SELECT * FROM (
    SELECT * FROM source_keys
    UNION ALL
    SELECT * FROM ghost
)

{% if is_incremental() %}
WHERE address_hk NOT IN (SELECT address_hk FROM {{ this }})
{% endif %}