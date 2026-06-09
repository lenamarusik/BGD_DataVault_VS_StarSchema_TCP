WITH joined AS (
    SELECT
        ss.ss_ticket_number,
        c.c_customer_id,
        i.i_item_id,
        s.s_store_id,
        p.p_promo_id,
        ca.ca_address_id,
        d.d_date,
        t.t_time AS ss_sold_time,
        ss.ss_quantity,
        ss.ss_wholesale_cost,
        ss.ss_list_price,
        ss.ss_sales_price,
        ss.ss_ext_discount_amt,
        ss.ss_ext_sales_price,
        ss.ss_ext_wholesale_cost,
        ss.ss_ext_list_price,
        ss.ss_ext_tax,
        ss.ss_coupon_amt,
        ss.ss_net_paid,
        ss.ss_net_paid_inc_tax,
        ss.ss_net_profit
    FROM {{ ref('stg_store_sales') }} ss
    LEFT JOIN {{ ref('stg_customers') }} c ON ss.ss_customer_sk = c.c_customer_sk
    LEFT JOIN {{ ref('stg_items') }} i ON ss.ss_item_sk = i.i_item_sk
    LEFT JOIN {{ ref('stg_stores') }} s ON ss.ss_store_sk = s.s_store_sk
    LEFT JOIN {{ ref('stg_promotions') }} p ON ss.ss_promo_sk = p.p_promo_sk
    LEFT JOIN {{ ref('stg_customer_addresses') }} ca ON ss.ss_addr_sk = ca.ca_address_sk
    LEFT JOIN {{ ref('stg_dates') }} d ON ss.ss_sold_date_sk = d.d_date_sk
    LEFT JOIN {{ ref('stg_times') }} t ON ss.ss_sold_time_sk = t.t_time_sk
),
source AS (
    SELECT
        {{ hash_key(['ss_ticket_number', 'c_customer_id', 'i_item_id', 's_store_id', 'd_date', 'p_promo_id', 'ca_address_id']) }} AS store_sale_hk,
        {{ batch_load_date() }} AS load_date,
        'tpcds.store_sales' AS record_source,
        {{ hash_key(['ss_sold_time', 'ss_quantity', 'ss_wholesale_cost', 'ss_list_price', 'ss_sales_price', 'ss_ext_discount_amt', 'ss_ext_sales_price', 'ss_ext_wholesale_cost', 'ss_ext_list_price', 'ss_ext_tax', 'ss_coupon_amt', 'ss_net_paid', 'ss_net_paid_inc_tax', 'ss_net_profit']) }} AS hash_diff,
        ss_sold_time,
        ss_quantity,
        ss_wholesale_cost,
        ss_list_price,
        ss_sales_price,
        ss_ext_discount_amt,
        ss_ext_sales_price,
        ss_ext_wholesale_cost,
        ss_ext_list_price,
        ss_ext_tax,
        ss_coupon_amt,
        ss_net_paid,
        ss_net_paid_inc_tax,
        ss_net_profit
    FROM joined
)

{% if is_incremental() %}

, latest AS (
    SELECT store_sale_hk, hash_diff
    FROM (
        SELECT
            store_sale_hk,
            hash_diff,
            ROW_NUMBER() OVER (PARTITION BY store_sale_hk ORDER BY load_date DESC) AS rn
        FROM {{ this }}
    )
    WHERE rn = 1
)

{% endif %}

SELECT source.*
FROM source

{% if is_incremental() %}

LEFT JOIN latest ON source.store_sale_hk = latest.store_sale_hk
WHERE latest.hash_diff IS NULL
    OR latest.hash_diff <> source.hash_diff

{% endif %}
