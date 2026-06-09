SELECT
    i.i_category,
    i.i_brand,
    d.d_year,
    d.d_moy,
    SUM(ss.ss_ext_sales_price)  AS monthly_revenue,
    AVG(ss.ss_sales_price)      AS avg_sale_price,
    COUNT(*)                    AS num_transactions
FROM {{ ref('facts_store_sales') }} ss
JOIN {{ ref('dim_items') }} i ON ss.ss_item_sk = i.i_item_sk
JOIN {{ ref('dim_dates') }} d ON ss.ss_sold_date_sk = d.d_date_sk
GROUP BY i.i_category, i.i_brand, d.d_year, d.d_moy
ORDER BY i.i_category, monthly_revenue DESC