WITH joined AS (
    SELECT
        c.c_customer_id,
        c.c_salutation,
        c.c_first_name,
        c.c_last_name,
        c.c_preferred_cust_flag,
        c.c_birth_day,
        c.c_birth_month,
        c.c_birth_year,
        c.c_birth_country,
        c.c_login,
        c.c_email_address,
        d_ship.d_date AS c_first_shipto_date,
        d_sales.d_date AS c_first_sales_date,
        d_rev.d_date AS c_last_review_date
    FROM {{ ref('stg_customers') }} c
    LEFT JOIN {{ ref('stg_dates') }} d_ship ON c.c_first_shipto_date_sk = d_ship.d_date_sk
    LEFT JOIN {{ ref('stg_dates') }} d_sales ON c.c_first_sales_date_sk = d_sales.d_date_sk
    LEFT JOIN {{ ref('stg_dates') }} d_rev ON c.c_last_review_date_sk = d_rev.d_date_sk
    WHERE c.c_customer_id IS NOT NULL
),
source AS (
    SELECT
        {{ hash_key(['c_customer_id']) }} AS customer_hk,
        {{ batch_load_date() }} AS load_date,
        'tpcds.customer' AS record_source,
        {{ hash_key(['c_salutation', 'c_first_name', 'c_last_name', 'c_preferred_cust_flag', 'c_birth_day', 'c_birth_month', 'c_birth_year', 'c_birth_country', 'c_login', 'c_email_address', 'c_first_shipto_date', 'c_first_sales_date', 'c_last_review_date']) }} AS hash_diff,
        c_salutation,
        c_first_name,
        c_last_name,
        c_preferred_cust_flag,
        c_birth_day,
        c_birth_month,
        c_birth_year,
        c_birth_country,
        c_login,
        c_email_address,
        c_first_shipto_date,
        c_first_sales_date,
        c_last_review_date
    FROM joined
)

{% if is_incremental() %}

, latest AS (
    SELECT customer_hk, hash_diff
    FROM (
        SELECT
            customer_hk,
            hash_diff,
            ROW_NUMBER() OVER (PARTITION BY customer_hk ORDER BY load_date DESC) AS rn
        FROM {{ this }}
    )
    WHERE rn = 1
)

{% endif %}

SELECT source.*
FROM source

{% if is_incremental() %}

LEFT JOIN latest ON source.customer_hk = latest.customer_hk
WHERE latest.hash_diff IS NULL
    OR latest.hash_diff <> source.hash_diff

{% endif %}
