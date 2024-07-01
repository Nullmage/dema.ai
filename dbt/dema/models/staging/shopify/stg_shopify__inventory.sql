WITH source AS (
	SELECT * FROM {{ source('dema', 'inventory') }} FINAL
),

result AS (
	SELECT
		productId AS product_id,
		name,
		toInt32(quantity) AS quantity,
		category,
		subCategory AS sub_category
	FROM source
)

SELECT * FROM result
