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
    ssd.s_store_name,
    ssl.s_state,
    sd.d_year,
    sd.d_qoy,
    sid.i_category,
    SUM(ssm.ss_ext_sales_price) AS revenue,
    SUM(ssm.ss_net_profit)      AS profit,
    SUM(ssm.ss_coupon_amt)      AS total_coupons,
    COUNT(*)                    AS txn_count
FROM {{ ref('link_store_sales') }} lss
JOIN {{ ref('sat_store_sale_measures') }} ssm ON lss.store_sale_hk = ssm.store_sale_hk
JOIN {{ ref('sat_dates') }}              sd   ON lss.date_hk        = sd.date_hk
JOIN current_items                       sid  ON lss.item_hk        = sid.item_hk
JOIN {{ ref('sat_store_details') }}      ssd  ON lss.store_hk       = ssd.store_hk
JOIN {{ ref('sat_store_locations') }}    ssl  ON lss.store_hk       = ssl.store_hk
LEFT JOIN {{ ref('sat_promotions') }}    sp   ON lss.promotion_hk   = sp.promotion_hk
WHERE (sp.p_channel_tv = 'Y' OR sp.p_channel_tv IS NULL)
GROUP BY ssd.s_store_name, ssl.s_state, sd.d_year, sd.d_qoy, sid.i_category
ORDER BY ssl.s_state, sd.d_year, sd.d_qoy, revenue DESC
