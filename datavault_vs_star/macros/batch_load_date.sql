{% macro batch_load_date() %}
  cast('{{ run_started_at.strftime("%Y-%m-%d %H:%M:%S.%f") }}' as timestamp)
{% endmacro %}