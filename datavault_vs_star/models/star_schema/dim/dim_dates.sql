SELECT
    *
FROM
    {{ ref('stg_dates') }}

{% if is_incremental() %}
WHERE d_date_sk NOT IN (SELECT d_date_sk FROM {{ this }})
{% endif %}