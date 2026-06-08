WITH source_keys AS (
    SELECT distinct
        {{ hash_key(["p_promo_id"]) }} AS promotion_hk,
        p_promo_id,
        {{ batch_load_date() }} AS load_date,
        'tpcds.item' AS record_source
    FROM {{ ref("stg_promotions") }}
    WHERE p_promo_id IS NOT NULL
),

ghost as (
    SELECT
        {{ ghost_key() }} AS promotion_hk,
        cast(null AS varchar) AS p_promo_id,
        {{ ghost_load_date() }} AS load_date,
        'SYSTEM' AS record_source
)


SELECT * FROM (
    SELECT * FROM source_keys
    UNION ALL
    SELECT * FROM ghost
)

{% if is_incremental() %}
WHERE promotion_hk NOT IN (SELECT promotion_hk FROM {{ this }})
{% endif %}