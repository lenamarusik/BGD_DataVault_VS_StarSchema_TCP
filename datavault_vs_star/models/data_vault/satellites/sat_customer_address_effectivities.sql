WITH source AS (
    SELECT
        {{ hash_key(['c_customer_id', 'ca_address_id']) }} AS customer_address_hk,
        {{ batch_load_date() }} AS load_date,
        'tpcds.customer' AS record_source,
        md5('Y') AS hash_diff,
        'Y'::VARCHAR(1) AS is_current
    FROM {{ ref('stg_customers') }} c
    JOIN {{ ref('stg_customer_addresses') }} ca ON c.c_current_addr_sk = ca.ca_address_sk
    WHERE c.c_customer_id IS NOT NULL
        AND ca.ca_address_id IS NOT NULL
)

{% if is_incremental() %}

, latest AS (
    SELECT customer_address_hk, hash_diff
    FROM (
        SELECT
            customer_address_hk,
            hash_diff,
            ROW_NUMBER() OVER (PARTITION BY customer_address_hk ORDER BY load_date DESC) AS rn
        FROM {{ this }}
    )
    WHERE rn = 1
)

{% endif %}

SELECT source.*
FROM source

{% if is_incremental() %}

LEFT JOIN latest ON source.customer_address_hk = latest.customer_address_hk
WHERE latest.hash_diff IS NULL
    OR latest.hash_diff <> source.hash_diff

{% endif %}
