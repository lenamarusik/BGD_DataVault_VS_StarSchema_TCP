{% macro hub(source_ref, bk_column, hk_alias, record_source) %}
WITH source_keys AS (
    SELECT DISTINCT
        {{ hash_key([bk_column]) }} AS {{ hk_alias }},
        {{ bk_column }},
        {{ batch_load_date() }} AS load_date,
        '{{ record_source }}' AS record_source
    FROM {{ ref(source_ref) }}
    WHERE {{ bk_column }} IS NOT NULL
),

ghost AS (
    SELECT
        {{ ghost_key() }} AS {{ hk_alias }},
        cast(null AS varchar) AS {{ bk_column }},
        {{ ghost_load_date() }} AS load_date,
        'SYSTEM' AS record_source
)

SELECT * FROM (
    SELECT * FROM source_keys
    UNION ALL
    SELECT * FROM ghost
)

{% if is_incremental() %}
WHERE {{ hk_alias }} NOT IN (SELECT {{ hk_alias }} FROM {{ this }})
{% endif %}
{% endmacro %}
