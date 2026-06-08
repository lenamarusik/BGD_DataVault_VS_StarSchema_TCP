WITH source_keys AS (
    SELECT distinct
        {{ hash_key(["s_store_id"]) }} AS store_hk,
        s_store_id,
        {{ batch_load_date() }} AS load_date,
        'tpcds.item' AS record_source
    FROM {{ ref("stg_stores") }}
    WHERE s_store_id IS NOT NULL
),

ghost as (
    SELECT
        {{ ghost_key() }} AS store_hk,
        cast(null AS varchar) AS s_store_id,
        {{ ghost_load_date() }} AS load_date,
        'SYSTEM' AS record_source
)


SELECT * FROM (
    SELECT * FROM source_keys
    UNION ALL
    SELECT * FROM ghost
)

{% if is_incremental() %}
WHERE store_hk NOT IN (SELECT store_hk FROM {{ this }})
{% endif %}