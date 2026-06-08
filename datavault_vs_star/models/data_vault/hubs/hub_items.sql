WITH source_keys AS (
    SELECT distinct
        {{ hash_key(["i_item_id"]) }} AS item_hk,
        i_item_id,
        {{ batch_load_date() }} AS load_date,
        'tpcds.item' AS record_source
    FROM {{ ref("stg_items") }}
    WHERE i_item_id IS NOT NULL
)

SELECT * FROM source_keys

{% if is_incremental() %}
WHERE item_hk NOT IN (SELECT item_hk FROM {{ this }})
{% endif %}