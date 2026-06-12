SELECT
    sd.d_year,
    sd.d_moy,
    sd.d_day_name,
    SUM(ssm.ss_ext_sales_price)              AS daily_revenue,
    AVG(ssm.ss_quantity)                     AS avg_qty,
    COUNT(DISTINCT lss.sales_transaction_hk) AS num_tickets
FROM {{ ref('link_store_sales') }} lss
JOIN {{ ref('sat_store_sale_measures') }} ssm ON lss.store_sale_hk = ssm.store_sale_hk
JOIN {{ ref('sat_dates') }}              sd   ON lss.date_hk        = sd.date_hk
GROUP BY sd.d_year, sd.d_moy, sd.d_day_name
ORDER BY sd.d_moy, daily_revenue DESC
