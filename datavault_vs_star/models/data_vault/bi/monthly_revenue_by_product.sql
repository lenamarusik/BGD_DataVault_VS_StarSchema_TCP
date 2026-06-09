WITH cur_item AS (
    SELECT *
    FROM {{ ref('sat_item_details') }}
    QUALIFY ROW_NUMBER() OVER (PARTITION BY item_hk ORDER BY load_date DESC) = 1
),
cur_date AS (
    SELECT *
    FROM {{ ref('sat_dates') }}
    QUALIFY ROW_NUMBER() OVER (PARTITION BY date_hk ORDER BY load_date DESC) = 1
),
cur_measures AS (
    SELECT *
    FROM {{ ref('sat_store_sale_measures') }}
    QUALIFY ROW_NUMBER() OVER (PARTITION BY store_sale_hk ORDER BY load_date DESC) = 1
)
SELECT
    ci.i_category as Category,
    ci.i_brand as Brand,
    cd.d_year as Year,
    strftime(make_date(2000, cd.d_moy::INTEGER, 1), '%B') AS Month,
    SUM(cm.ss_ext_sales_price) AS "Monthly revenue",
    COUNT(*) AS "Items sold",
    ROUND(AVG(cm.ss_sales_price), 2) AS "Average sale price"
FROM {{ ref('link_store_sales') }} lss
JOIN cur_measures cm  ON lss.store_sale_hk = cm.store_sale_hk
JOIN cur_item ci  ON lss.item_hk = ci.item_hk
JOIN cur_date cd  ON lss.date_hk = cd.date_hk
GROUP BY ci.i_category, ci.i_brand, cd.d_year, cd.d_moy
ORDER BY ci.i_category, cd.d_year, cd.d_moy, "Monthly revenue" DESC
