{% macro hash_key(columns, algorithm='md5', null_placeholder='^^', delimiter='||') %}
    {%- set parts = [] -%}
    {%- for col in columns -%}
        {%- do parts.append(
            "upper(trim(coalesce(cast(" ~ col ~ " as varchar), '" ~ null_placeholder ~ "')))"
        ) -%}
    {%- endfor -%}
    {{ algorithm }}(
        {{ parts | join(" || '" ~ delimiter ~ "' || ") }}
    )
{%- endmacro %}