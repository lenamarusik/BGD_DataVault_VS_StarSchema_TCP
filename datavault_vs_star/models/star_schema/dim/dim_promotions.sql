SELECT
    *
FROM
    {{ ref('stg_promotions') }}

{% if is_incremental() %}
WHERE p_promo_sk NOT IN (SELECT p_promo_sk FROM {{ this }})
{% endif %}