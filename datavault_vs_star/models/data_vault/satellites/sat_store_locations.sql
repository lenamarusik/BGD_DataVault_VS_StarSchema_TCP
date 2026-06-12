WITH source AS (
    SELECT
        {{ hash_key(['s_store_id']) }} AS store_hk,
        {{ batch_load_date() }} AS load_date,
        'tpcds.store' AS record_source,
        {{ hash_key(['s_street_number', 's_street_name', 's_street_type', 's_suite_number', 's_city', 's_county', 's_state', 's_zip', 's_country', 's_gmt_offset']) }} AS hash_diff,
        s_street_number,
        s_street_name,
        s_street_type,
        s_suite_number,
        s_city,
        s_county,
        s_state,
        s_zip,
        s_country,
        s_gmt_offset
    FROM {{ ref('stg_stores') }}
    WHERE s_store_id IS NOT NULL
        AND s_rec_end_date IS NULL
)

{% if is_incremental() %}

, latest AS (
    SELECT store_hk, hash_diff
    FROM (
        SELECT
            store_hk,
            hash_diff,
            ROW_NUMBER() OVER (PARTITION BY store_hk ORDER BY load_date DESC) AS rn
        FROM {{ this }}
    )
    WHERE rn = 1
)

{% endif %}

SELECT source.*
FROM source

{% if is_incremental() %}

LEFT JOIN latest ON source.store_hk = latest.store_hk
WHERE latest.hash_diff IS NULL
    OR latest.hash_diff <> source.hash_diff

{% endif %}
