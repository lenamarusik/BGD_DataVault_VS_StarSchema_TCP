SELECT
    {{ hash_key(['ss_ticket_number', 'ss_item_sk']) }} AS sale_sk,
    *
FROM
    {{ ref('stg_store_sales') }}

{% if is_incremental() %}
WHERE s_store_sk NOT IN (SELECT s_store_sk FROM {{ this }})
{% endif %}