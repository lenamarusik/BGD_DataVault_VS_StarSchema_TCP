SELECT
    hc.c_customer_id,
    scp.c_first_name,
    scp.c_last_name,
    scp.c_email_address,
    SUM(ssm.ss_net_paid)                     AS total_spent,
    COUNT(DISTINCT lss.sales_transaction_hk) AS num_orders
FROM {{ ref('link_store_sales') }} lss
JOIN {{ ref('sat_store_sale_measures') }}  ssm ON lss.store_sale_hk = ssm.store_sale_hk
JOIN {{ ref('hub_customers') }}            hc  ON lss.customer_hk   = hc.customer_hk
JOIN {{ ref('sat_customer_profiles') }}    scp ON lss.customer_hk   = scp.customer_hk
GROUP BY hc.c_customer_id, scp.c_first_name, scp.c_last_name, scp.c_email_address
ORDER BY total_spent DESC
