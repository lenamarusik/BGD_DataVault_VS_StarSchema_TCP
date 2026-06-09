SELECT
    *
FROM
    {{ ref('stg_stores') }}

{% if is_incremental() %}
WHERE s_store_sk NOT IN (SELECT s_store_sk FROM {{ this }})
{% endif %}