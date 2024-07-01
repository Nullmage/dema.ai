{{
    config(
        materialized='incremental',
        order_by='(date_time, product_id, order_id)',
		unique_key='date_time, product_id, order_id',
        engine='MergeTree()',
    )
}}

SELECT
	inventory.product_id,
	inventory.name AS product_name,
	inventory.quantity,
	inventory.category,
	inventory.sub_category,
	orders.order_id,
	orders.date_time,
	orders.currency,
	orders.shipping_cost,
	orders.amount,
	orders.channel,
	orders.channel_group,
	orders.campaign
FROM {{ ref('stg_shopify__inventory') }} AS inventory
INNER JOIN {{ ref('stg_shopify__orders') }} AS orders ON inventory.product_id = orders.product_id

{% if is_incremental() %}

WHERE date_time >= (SELECT MAX(COALESCE(date_time, '1900-01-01'::DATETIME)) FROM {{ this }})

{% endif %}
