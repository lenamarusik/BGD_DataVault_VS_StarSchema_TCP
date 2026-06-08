WITH source_keys AS (
    SELECT distinct
        {{ hash_key(["c_customer_id"]) }} AS customer_hk,
        c_customer_id,
        {{ batch_load_date() }} AS load_date,
        'tpcds.customer' AS record_source
    FROM {{ ref("stg_customers") }}
    WHERE c_customer_id IS NOT NULL
),

ghost as (
    SELECT
        {{ ghost_key() }} AS customer_hk,
        cast(null AS varchar) AS c_customer_id,
        {{ ghost_load_date() }} AS load_date,
        'SYSTEM' AS record_source
)

SELECT * FROM (
    SELECT * FROM source_keys
    UNION ALL
    SELECT * FROM ghost
)

{% if is_incremental() %}
WHERE customer_hk NOT IN (SELECT customer_hk FROM {{ this }})
{% endif %}