SELECT
    s.s_store_name,
    s.s_state,
    d.d_year,
    d.d_qoy,
    i.i_category,
    SUM(ss.ss_ext_sales_price)    AS revenue,
    SUM(ss.ss_net_profit)         AS profit,
    SUM(ss.ss_coupon_amt)         AS total_coupons,
    COUNT(*)                      AS txn_count
FROM {{ ref('facts_store_sales') }}  ss
JOIN {{ ref('dim_dates') }}          d  ON ss.ss_sold_date_sk = d.d_date_sk
JOIN {{ ref('dim_items') }}          i  ON ss.ss_item_sk      = i.i_item_sk
JOIN {{ ref('dim_stores') }}         s  ON ss.ss_store_sk     = s.s_store_sk
LEFT JOIN {{ ref('dim_promotions') }} p  ON ss.ss_promo_sk     = p.p_promo_sk
WHERE (p.p_channel_tv = 'Y' OR p.p_channel_tv IS NULL)
GROUP BY s.s_store_name, s.s_state, d.d_year, d.d_qoy, i.i_category
ORDER BY s.s_state, d.d_year, d.d_qoy, revenue DESC