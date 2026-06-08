WITH source_keys AS (
    SELECT distinct
        {{ hash_key(["ss_ticket_number"]) }} AS sales_transaction_hk,
        ss_ticket_number,
        {{ batch_load_date() }} AS load_date,
        'tpcds.item' AS record_source
    FROM {{ ref("stg_store_sales") }}
    WHERE ss_ticket_number IS NOT NULL
),

ghost as (
    SELECT
        {{ ghost_key() }} AS sales_transaction_hk,
        cast(null AS varchar) AS ss_ticket_number,
        {{ ghost_load_date() }} AS load_date,
        'SYSTEM' AS record_source
)


SELECT * FROM (
    SELECT * FROM source_keys
    UNION ALL
    SELECT * FROM ghost
)

{% if is_incremental() %}
WHERE sales_transaction_hk NOT IN (SELECT sales_transaction_hk FROM {{ this }})
{% endif %}