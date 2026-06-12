SELECT
    d.d_year,
    d.d_moy,
    d.d_day_name,
    SUM(ss.ss_ext_sales_price)    AS daily_revenue,
    AVG(ss.ss_quantity)           AS avg_qty,
    COUNT(DISTINCT ss.ss_ticket_number) AS num_tickets
FROM {{ ref('facts_store_sales') }} ss
JOIN {{ ref('dim_dates') }}        d  ON ss.ss_sold_date_sk = d.d_date_sk
GROUP BY d.d_year, d.d_moy, d.d_day_name
ORDER BY d.d_moy, daily_revenue DESC