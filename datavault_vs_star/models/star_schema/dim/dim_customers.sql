SELECT
    *
FROM
    {{ ref('stg_customers') }}

{% if is_incremental() %}
WHERE c_customer_sk NOT IN (SELECT c_customer_sk FROM {{ this }})
{% endif %}