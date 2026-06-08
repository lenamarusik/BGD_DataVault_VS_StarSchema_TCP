WITH joined AS (
    SELECT
        p.p_promo_id,
        p.p_promo_name,
        p.p_cost,
        p.p_response_target,
        sd.d_date AS p_start_date,
        ed.d_date AS p_end_date,
        p.p_channel_dmail,
        p.p_channel_email,
        p.p_channel_catalog,
        p.p_channel_tv,
        p.p_channel_radio,
        p.p_channel_press,
        p.p_channel_event,
        p.p_channel_demo,
        p.p_channel_details,
        p.p_purpose,
        p.p_discount_active
    FROM {{ ref('stg_promotions') }} p
    LEFT JOIN {{ ref('stg_dates') }} sd ON p.p_start_date_sk = sd.d_date_sk
    LEFT JOIN {{ ref('stg_dates') }} ed ON p.p_end_date_sk = ed.d_date_sk
    WHERE p.p_promo_id IS NOT NULL
),
source AS (
    SELECT
        {{ hash_key(['p_promo_id']) }} AS promotion_hk,
        {{ batch_load_date() }} AS load_date,
        'tpcds.promotion' AS record_source,
        {{ hash_key(['p_promo_name', 'p_cost', 'p_response_target', 'p_start_date', 'p_end_date', 'p_channel_dmail', 'p_channel_email', 'p_channel_catalog', 'p_channel_tv', 'p_channel_radio', 'p_channel_press', 'p_channel_event', 'p_channel_demo', 'p_channel_details', 'p_purpose', 'p_discount_active']) }} AS hash_diff,
        p_promo_name,
        p_cost,
        p_response_target,
        p_start_date,
        p_end_date,
        p_channel_dmail,
        p_channel_email,
        p_channel_catalog,
        p_channel_tv,
        p_channel_radio,
        p_channel_press,
        p_channel_event,
        p_channel_demo,
        p_channel_details,
        p_purpose,
        p_discount_active
    FROM joined
)

{% if is_incremental() %}

, latest AS (
    SELECT promotion_hk, hash_diff
    FROM (
        SELECT
            promotion_hk,
            hash_diff,
            ROW_NUMBER() OVER (PARTITION BY promotion_hk ORDER BY load_date DESC) AS rn
        FROM {{ this }}
    )
    WHERE rn = 1
)

{% endif %}

SELECT source.*
FROM source

{% if is_incremental() %}

LEFT JOIN latest ON source.promotion_hk = latest.promotion_hk
WHERE latest.hash_diff IS NULL
    OR latest.hash_diff <> source.hash_diff

{% endif %}
