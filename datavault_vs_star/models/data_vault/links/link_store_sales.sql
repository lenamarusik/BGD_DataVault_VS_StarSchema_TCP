WITH joined AS (
    SELECT
        *
    FROM
        {{ ref('stg_store_sales') }} ss
        LEFT JOIN {{ ref('stg_customers') }} c ON ss.ss_customer_sk = c.c_customer_sk
        LEFT JOIN {{ ref('stg_items') }} i ON ss.ss_item_sk = i.i_item_sk
        LEFT JOIN {{ ref('stg_stores') }} s ON ss.ss_store_sk = s.s_store_sk
        LEFT JOIN {{ ref('stg_promotions') }} p ON ss.ss_promo_sk = p.p_promo_sk
        LEFT JOIN {{ ref('stg_customer_addresses') }} ca ON ss.ss_addr_sk = ca.ca_address_sk
        LEFT JOIN {{ ref('stg_dates') }} d ON ss.ss_sold_date_sk = d.d_date_sk
        LEFT JOIN {{ ref('stg_times') }} t ON ss.ss_sold_time_sk = t.t_time_sk
)
SELECT
    {{ hash_key(['ss_ticket_number', 'c_customer_id', 'i_item_id', 's_store_id', 'd_date', 'p_promo_id', 'ca_address_id']) }} AS store_sale_hk,
    {{ hash_key(['ss_ticket_number']) }} AS sales_transaction_hk,
    {{ hash_key(['c_customer_id']) }} AS customer_hk,
    {{ hash_key(['i_item_id']) }} AS item_hk,
    {{ hash_key(['s_store_id']) }} AS store_hk,
    {{ hash_key(['d_date']) }} AS date_hk,
    {{ hash_key(['p_promo_id']) }} AS promotion_hk,
    {{ hash_key(['ca_address_id']) }} AS address_hk,
    {{ batch_load_date() }} AS load_date,
    'tpcds.store_sales' AS record_source
FROM
    joined

{% if is_incremental() %}

WHERE store_sale_hk NOT IN (SELECT store_sale_hk FROM {{ this }})

{% endif %}