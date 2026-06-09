SELECT
    *
FROM
    {{ ref('stg_items') }}

{% if is_incremental() %}
WHERE i_item_sk NOT IN (SELECT i_item_sk FROM {{ this }})
{% endif %}