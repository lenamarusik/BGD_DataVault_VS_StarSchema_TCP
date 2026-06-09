-- sat_item_details stores all SCD versions per item; pick one deterministically
-- (exact version-per-sale requires a PIT table, which is not available here)
WITH current_items AS (
    SELECT *
    FROM (
        SELECT *, ROW_NUMBER() OVER (PARTITION BY item_hk ORDER BY hash_diff) AS rn
        FROM {{ ref('sat_item_details') }}
    )
    WHERE rn = 1
)

SELECT
    sp.p_promo_name,
    sp.p_channel_tv,
    sp.p_channel_email,
    sid.i_category,
    SUM(ssm.ss_ext_sales_price)  AS gross_revenue,
    SUM(ssm.ss_ext_discount_amt) AS total_discount,
    SUM(ssm.ss_net_profit)       AS net_profit,
    ROUND(
        SUM(ssm.ss_ext_discount_amt) * 100.0
        / NULLIF(SUM(ssm.ss_ext_sales_price), 0), 2
    )                            AS discount_pct
FROM {{ ref('link_store_sales') }} lss
JOIN {{ ref('sat_store_sale_measures') }} ssm ON lss.store_sale_hk  = ssm.store_sale_hk
JOIN current_items                        sid ON lss.item_hk         = sid.item_hk
JOIN {{ ref('sat_promotions') }}          sp  ON lss.promotion_hk    = sp.promotion_hk
GROUP BY sp.p_promo_name, sp.p_channel_tv, sp.p_channel_email, sid.i_category
HAVING SUM(ssm.ss_ext_sales_price) > 10000
ORDER BY discount_pct DESC
