{% macro ghost_key() %}'00000000000000000000000000000000'{% endmacro %}
{% macro ghost_load_date() %}cast('1900-01-01' as timestamp){% endmacro %}