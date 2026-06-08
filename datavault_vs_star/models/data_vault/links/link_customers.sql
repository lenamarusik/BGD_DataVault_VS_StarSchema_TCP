WITH joined AS (
    SELECT
        *
    FROM
        {{ ref('stg_customers') }} c
        LEFT JOIN {{ ref('stg_customer_addresses') }} ca ON c.c_current_addr_sk = ca.ca_address_sk
        LEFT JOIN {{ ref('stg_customer_demographics') }} cd ON c.c_current_cdemo_sk = cd.cd_demo_sk
        LEFT JOIN {{ ref('stg_household_demographics') }} hd ON c.c_current_hdemo_sk = hd.hd_demo_sk
        LEFT JOIN {{ ref('stg_dates') }} d_ship ON c.c_first_shipto_date_sk = d_ship.d_date_sk
        LEFT JOIN {{ ref('stg_dates') }} d_sales ON c.c_first_shipto_date_sk = d_sales.d_date_sk
        LEFT JOIN {{ ref('stg_dates') }} d_rev ON c.c_last_review_date_sk = d_rev.d_date_sk
)
SELECT
    {{ hash_key(['c_customer_id', 'ca_address_id']) }} AS customer_address_hk,
    {{ hash_key(['c_customer_id']) }} AS customer_hk,
    {{ hash_key(['ca_address_id']) }} AS address_hk,
    {{ batch_load_date() }} AS load_date,
    'tpcds.customer' AS record_source
FROM
    joined

{% if is_incremental() %}

WHERE customer_address_hk NOT IN (SELECT store_sale_hk FROM {{ this }})

{% endif %}