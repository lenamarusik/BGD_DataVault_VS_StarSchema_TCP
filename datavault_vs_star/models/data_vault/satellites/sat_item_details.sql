WITH source AS (
    SELECT
        {{ hash_key(['i_item_id']) }} AS item_hk,
        {{ batch_load_date() }} AS load_date,
        'tpcds.item' AS record_source,
        {{ hash_key(['i_product_name', 'i_item_desc', 'i_brand_id', 'i_brand', 'i_class_id', 'i_class', 'i_category_id', 'i_category', 'i_manufact_id', 'i_manufact', 'i_size', 'i_color', 'i_units', 'i_container', 'i_manager_id']) }} AS hash_diff,
        i_product_name,
        i_item_desc,
        i_brand_id,
        i_brand,
        i_class_id,
        i_class,
        i_category_id,
        i_category,
        i_manufact_id,
        i_manufact,
        i_size,
        i_color,
        i_units,
        i_container,
        i_manager_id
    FROM {{ ref('stg_items') }}
    WHERE i_item_id IS NOT NULL
)

{% if is_incremental() %}

, latest AS (
    SELECT item_hk, hash_diff
    FROM (
        SELECT
            item_hk,
            hash_diff,
            ROW_NUMBER() OVER (PARTITION BY item_hk ORDER BY load_date DESC) AS rn
        FROM {{ this }}
    )
    WHERE rn = 1
)

{% endif %}

SELECT source.*
FROM source

{% if is_incremental() %}

LEFT JOIN latest ON source.item_hk = latest.item_hk
WHERE latest.hash_diff IS NULL
    OR latest.hash_diff <> source.hash_diff

{% endif %}
