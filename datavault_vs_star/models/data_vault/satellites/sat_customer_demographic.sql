WITH joined AS (
    SELECT
        c.c_customer_id,
        cd.cd_gender,
        cd.cd_marital_status,
        cd.cd_education_status,
        cd.cd_purchase_estimate,
        cd.cd_credit_rating,
        cd.cd_dep_count,
        cd.cd_dep_employed_count,
        cd.cd_dep_college_count
    FROM {{ ref('stg_customers') }} c
    LEFT JOIN {{ ref('stg_customer_demographics') }} cd ON c.c_current_cdemo_sk = cd.cd_demo_sk
    WHERE c.c_customer_id IS NOT NULL
),
source AS (
    SELECT
        {{ hash_key(['c_customer_id']) }} AS customer_hk,
        {{ batch_load_date() }} AS load_date,
        'tpcds.customer' AS record_source,
        {{ hash_key(['cd_gender', 'cd_marital_status', 'cd_education_status', 'cd_purchase_estimate', 'cd_credit_rating', 'cd_dep_count', 'cd_dep_employed_count', 'cd_dep_college_count']) }} AS hash_diff,
        cd_gender,
        cd_marital_status,
        cd_education_status,
        cd_purchase_estimate,
        cd_credit_rating,
        cd_dep_count,
        cd_dep_employed_count,
        cd_dep_college_count
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
