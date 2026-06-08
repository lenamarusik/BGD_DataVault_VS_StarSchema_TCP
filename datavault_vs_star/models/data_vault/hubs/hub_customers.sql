WITH source_keys AS (
    SELECT distinct
        {{ hash_key(["c_customer_id"]) }} AS customer_hk,
        c_customer_id,
        {{ batch_load_date() }} AS load_date,
        'tpcds.customer' AS record_source
    FROM {{ ref("stg_customers") }}
    WHERE c_customer_id IS NOT NULL
)

SELECT * FROM source_keys

{# do a full load on first run #}
{% if is_incremental() %}
WHERE customer_hk NOT IN (SELECT customer_hk FROM {{ this }})
{% endif %}