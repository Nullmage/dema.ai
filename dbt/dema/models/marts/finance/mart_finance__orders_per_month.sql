{{
    config(
        materialized='incremental',
        order_by='(month_start, category, sub_category)',
		unique_key='month_start, category, sub_category',
        engine='MergeTree()',
    )
}}

SELECT
	toStartOfMonth(date_time) AS month_start,
	category,
	sub_category,
	COUNT(*) num_orders,
	SUM(quantity) AS quantity_total,
	SUM(shipping_cost) AS shipping_cost_total,
	SUM(amount) AS total_amount
FROM {{ ref('int_finance__orders') }}

{% if is_incremental() %}

WHERE month_start >= (SELECT MAX(month_start) FROM {{ this }})

{% endif %}

GROUP BY 1, 2, 3
ORDER BY 1, 2, 3
