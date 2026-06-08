WITH source_keys AS (
    SELECT distinct
        {{ hash_key(["i_item_id"]) }} AS item_hk,
        i_item_id,
        {{ batch_load_date() }} AS load_date,
        'tpcds.item' AS record_source
    FROM {{ ref("stg_items") }}
    WHERE i_item_id IS NOT NULL
),

ghost as (
    SELECT
        {{ ghost_key() }} AS item_hk,
        cast(null AS varchar) AS i_item_id,
        {{ ghost_load_date() }} AS load_date,
        'SYSTEM' AS record_source
)


SELECT * FROM (
    SELECT * FROM source_keys
    UNION ALL
    SELECT * FROM ghost
)

{% if is_incremental() %}
WHERE item_hk NOT IN (SELECT item_hk FROM {{ this }})
{% endif %}