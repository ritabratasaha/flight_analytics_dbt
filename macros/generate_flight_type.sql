{% macro generate_flight_type(actual_departure, actual_arrival) %}
    case
        when {{ actual_departure }} is null or {{ actual_arrival }} is null then null
        when datediff('second', {{ actual_departure }}, {{ actual_arrival }}) / 3600 <= 1 then 'short flight'
        when datediff('second', {{ actual_departure }}, {{ actual_arrival }}) / 3600 <= 5 then 'average flight'
        else 'long flight'
    end
{% endmacro %}
