{%- for example in examples %}
{%- if example.with_clause is defined %}
WITH sample AS (
{{ example.with_clause }}
)
{%- endif %}
SELECT `{{ project_id }}.{{ dataset_id }}.{{ function_name }}`(
{%- set result = [] %}
{%- for i in range(arguments | length) %}
{%- set argument_type = arguments[i].type %}
{%- if argument_type.lower() in ['string','date'] %}
  {%- set _ = result.append('"' + example.arguments[i]|string + '"' ) %}
{%- else %}
  {%- set _ =  result.append(example.arguments[i]|string) %}
{%- endif %}
{%- endfor %}{{ result | join(', ') }})
{%- if example.with_clause is defined %}
FROM sample
{%- endif %}
{%- endfor %}
