WITH source AS (
	SELECT * FROM {{ source('dema', 'orders') }} FINAL
),

result AS (
	SELECT
		orderId AS order_id,
		productId AS product_id,
		parseDateTimeBestEffort(dateTime) AS date_time,
		currency,
		toInt32(quantity) AS quantity,
		toDecimal32(shippingCost, 4) AS shipping_cost,
		toDecimal32(amount, 4) AS amount,
		channel,
		channelGroup AS channel_group,
		campaign
		
	FROM source
)

SELECT * FROM result
