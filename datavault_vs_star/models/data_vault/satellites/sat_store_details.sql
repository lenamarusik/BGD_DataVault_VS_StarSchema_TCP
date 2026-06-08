WITH source AS (
    SELECT
        {{ hash_key(['s_store_id']) }} AS store_hk,
        {{ batch_load_date() }} AS load_date,
        'tpcds.store' AS record_source,
        {{ hash_key(['s_store_name', 's_number_employees', 's_floor_space', 's_hours', 's_manager', 's_market_id', 's_market_desc', 's_market_manager', 's_division_id', 's_division_name', 's_company_id', 's_company_name', 's_tax_percentage']) }} AS hash_diff,
        s_store_name,
        s_number_employees,
        s_floor_space,
        s_hours,
        s_manager,
        s_market_id,
        s_market_desc,
        s_market_manager,
        s_division_id,
        s_division_name,
        s_company_id,
        s_company_name,
        s_tax_percentage
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
