WITH source AS (
    SELECT
        {{ hash_key(['ca_address_id']) }} AS address_hk,
        {{ batch_load_date() }} AS load_date,
        'tpcds.customer_address' AS record_source,
        {{ hash_key(['ca_street_number', 'ca_street_name', 'ca_street_type', 'ca_suite_number', 'ca_city', 'ca_county', 'ca_state', 'ca_zip', 'ca_country', 'ca_gmt_offset', 'ca_location_type']) }} AS hash_diff,
        ca_street_number,
        ca_street_name,
        ca_street_type,
        ca_suite_number,
        ca_city,
        ca_county,
        ca_state,
        ca_zip,
        ca_country,
        ca_gmt_offset,
        ca_location_type
    FROM {{ ref('stg_customer_addresses') }}
    WHERE ca_address_id IS NOT NULL
)

{% if is_incremental() %}

, latest AS (
    SELECT address_hk, hash_diff
    FROM (
        SELECT
            address_hk,
            hash_diff,
            ROW_NUMBER() OVER (PARTITION BY address_hk ORDER BY load_date DESC) AS rn
        FROM {{ this }}
    )
    WHERE rn = 1
)

{% endif %}

SELECT source.*
FROM source

{% if is_incremental() %}

LEFT JOIN latest ON source.address_hk = latest.address_hk
WHERE latest.hash_diff IS NULL
    OR latest.hash_diff <> source.hash_diff

{% endif %}
