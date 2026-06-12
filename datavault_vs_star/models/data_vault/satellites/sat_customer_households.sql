WITH joined AS (
    SELECT
        c.c_customer_id,
        hd.hd_income_band_sk,
        hd.hd_buy_potential,
        hd.hd_dep_count,
        hd.hd_vehicle_count
    FROM {{ ref('stg_customers') }} c
    LEFT JOIN {{ ref('stg_household_demographics') }} hd ON c.c_current_hdemo_sk = hd.hd_demo_sk
    WHERE c.c_customer_id IS NOT NULL
),
source AS (
    SELECT
        {{ hash_key(['c_customer_id']) }} AS customer_hk,
        {{ batch_load_date() }} AS load_date,
        'tpcds.customer' AS record_source,
        {{ hash_key(['hd_income_band_sk', 'hd_buy_potential', 'hd_dep_count', 'hd_vehicle_count']) }} AS hash_diff,
        hd_income_band_sk,
        hd_buy_potential,
        hd_dep_count,
        hd_vehicle_count
    FROM joined
)

{% if is_incremental() %}

, latest AS (
    SELECT customer_hk, hash_diff
    FROM (
        SELECT
            customer_hk,
            hash_diff,
            ROW_NUMBER() OVER (PARTITION BY customer_hk ORDER BY load_date DESC) AS rn
        FROM {{ this }}
    )
    WHERE rn = 1
)

{% endif %}

SELECT source.*
FROM source

{% if is_incremental() %}

LEFT JOIN latest ON source.customer_hk = latest.customer_hk
WHERE latest.hash_diff IS NULL
    OR latest.hash_diff <> source.hash_diff

{% endif %}
