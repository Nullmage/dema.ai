{{
    config(
        materialized='incremental',
        order_by='(month_start, channel, channel_group, campaign)',
		unique_key='month_start, channel, channel_group, campaign',
        engine='MergeTree()',
    )
}}

SELECT
	toStartOfMonth(date_time) AS month_start,
	channel,
	channel_group,
	campaign,
	COUNT(*) num_orders,
	SUM(quantity) AS quantity_total,
	SUM(amount) AS total_amount
FROM {{ ref('stg_shopify__orders') }}

{% if is_incremental() %}

WHERE month_start >= (SELECT MAX(month_start) FROM {{ this }})

{% endif %}

GROUP BY 1, 2, 3, 4
ORDER BY 1, 2, 3, 4
