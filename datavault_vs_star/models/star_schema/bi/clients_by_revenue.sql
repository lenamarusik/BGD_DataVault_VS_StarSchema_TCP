SELECT
    c.c_customer_id,
    c.c_first_name,
    c.c_last_name,
    c.c_email_address,
    SUM(ss.ss_net_paid)     AS total_spent,
    COUNT(DISTINCT ss.ss_ticket_number) AS num_orders
FROM {{ ref('facts_store_sales') }}  ss
JOIN {{ ref('dim_customers') }}     c  ON ss.ss_customer_sk  = c.c_customer_sk
JOIN {{ ref('dim_dates') }}         d  ON ss.ss_sold_date_sk = d.d_date_sk
GROUP BY c.c_customer_id, c.c_first_name, c.c_last_name, c.c_email_address
ORDER BY total_spent DESC