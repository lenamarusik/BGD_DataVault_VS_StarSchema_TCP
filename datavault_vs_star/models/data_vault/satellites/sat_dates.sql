WITH source AS (
    SELECT
        {{ hash_key(['d_date']) }} AS date_hk,
        {{ batch_load_date() }} AS load_date,
        'tpcds.date_dim' AS record_source,
        {{ hash_key(['d_month_seq', 'd_week_seq', 'd_quarter_seq', 'd_year', 'd_dow', 'd_moy', 'd_dom', 'd_qoy', 'd_fy_year', 'd_fy_quarter_seq', 'd_fy_week_seq', 'd_day_name', 'd_quarter_name', 'd_holiday', 'd_weekend', 'd_following_holiday']) }} AS hash_diff,
        d_month_seq,
        d_week_seq,
        d_quarter_seq,
        d_year,
        d_dow,
        d_moy,
        d_dom,
        d_qoy,
        d_fy_year,
        d_fy_quarter_seq,
        d_fy_week_seq,
        d_day_name,
        d_quarter_name,
        d_holiday,
        d_weekend,
        d_following_holiday
    FROM {{ ref('stg_dates') }}
    WHERE d_date IS NOT NULL
)

{% if is_incremental() %}

, latest AS (
    SELECT date_hk, hash_diff
    FROM (
        SELECT
            date_hk,
            hash_diff,
            ROW_NUMBER() OVER (PARTITION BY date_hk ORDER BY load_date DESC) AS rn
        FROM {{ this }}
    )
    WHERE rn = 1
)

{% endif %}

SELECT source.*
FROM source

{% if is_incremental() %}

LEFT JOIN latest ON source.date_hk = latest.date_hk
WHERE latest.hash_diff IS NULL
    OR latest.hash_diff <> source.hash_diff

{% endif %}
