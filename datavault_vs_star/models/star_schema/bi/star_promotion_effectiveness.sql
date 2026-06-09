SELECT
    p.p_promo_name,
    p.p_channel_tv,
    p.p_channel_email,
    i.i_category,
    SUM(ss.ss_ext_sales_price)    AS gross_revenue,
    SUM(ss.ss_ext_discount_amt)   AS total_discount,
    SUM(ss.ss_net_profit)         AS net_profit,
    ROUND(
        SUM(ss.ss_ext_discount_amt) * 100.0
        / NULLIF(SUM(ss.ss_ext_sales_price), 0), 2
    )                             AS discount_pct
FROM {{ ref('facts_store_sales') }}  ss
JOIN {{ ref('dim_dates') }}          d  ON ss.ss_sold_date_sk = d.d_date_sk
JOIN {{ ref('dim_items') }}          i  ON ss.ss_item_sk      = i.i_item_sk
JOIN {{ ref('dim_promotions') }}     p  ON ss.ss_promo_sk     = p.p_promo_sk
GROUP BY p.p_promo_name, p.p_channel_tv, p.p_channel_email, i.i_category
HAVING SUM(ss.ss_ext_sales_price) > 10000
ORDER BY discount_pct DESC