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
    sid.i_category,
    sid.i_brand,
    sd.d_year,
    sd.d_moy,
    SUM(ssm.ss_ext_sales_price) AS monthly_revenue,
    AVG(ssm.ss_sales_price)     AS avg_sale_price,
    COUNT(*)                    AS num_transactions
FROM {{ ref('link_store_sales') }} lss
JOIN {{ ref('sat_store_sale_measures') }} ssm ON lss.store_sale_hk = ssm.store_sale_hk
JOIN current_items                        sid ON lss.item_hk        = sid.item_hk
JOIN {{ ref('sat_dates') }}              sd   ON lss.date_hk        = sd.date_hk
GROUP BY sid.i_category, sid.i_brand, sd.d_year, sd.d_moy
ORDER BY sid.i_category, monthly_revenue DESC
