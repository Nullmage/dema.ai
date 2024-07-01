import logging
import requests

from io import StringIO
from os import environ
from pathlib import Path
from csv import reader as csv_reader

from clickhouse_connect import get_client

logging.getLogger().setLevel(logging.INFO)

class Main:
	DATA_DIR = Path("data")

	def __init__(self):
		self.DATA_DIR.mkdir(exist_ok=True)

		self._client = get_client(
			host = environ["CLICKHOUSE_HOST"],
			database = environ["CLICKHOUSE_DB"],
			username = environ["CLICKHOUSE_USER"],
			password = environ["CLICKHOUSE_PASSWORD"]
		)

		self.create_tables()

	def create_tables(self):
		logging.info("Creating raw tables...")

		self._client.command("""
			CREATE TABLE IF NOT EXISTS inventory (
				productId		String	NOT NULL,
				name			String	NOT NULL,
				quantity		String	NOT NULL,
				category		String	NOT NULL,
				subCategory		String	NOT NULL,
				insertTime		DateTime64	DEFAULT now()
			)
			ENGINE = ReplacingMergeTree(insertTime)
			ORDER BY productId
		""")

		self._client.command("""
			CREATE TABLE IF NOT EXISTS orders (
				orderId			String	NOT NULL,
				productId		String	NOT NULL,
				currency		String	NOT NULL,
				quantity		String	NOT NULL,
				shippingCost	String	NOT NULL,
				amount			String	NOT NULL,
				channel			String	NOT NULL,
				channelGroup	String	NOT NULL,
				campaign		String	NOT NULL,
				dateTime		String	NOT NULL,
				insertTime		DateTime64	DEFAULT now()
			)
			ENGINE = ReplacingMergeTree(insertTime)
			ORDER BY (orderId, productId, dateTime)
		""")

	def run(self):
		content = self.fetch("https://dema-tech-assets.s3.eu-west-1.amazonaws.com/hiring-tests/inventory.csv")
		self.write(self.DATA_DIR / "inventory.csv", content)
		self.load("inventory", content)

		content = self.fetch("https://dema-tech-assets.s3.eu-west-1.amazonaws.com/hiring-tests/orders.csv")
		self.write(self.DATA_DIR / "orders.csv", content)
		self.load("orders", content)

	def fetch(self, url):
		logging.info(f"Fetching '{url}'...")
		return requests.get(url).content.decode("utf-8")

	def write(self, file_path, content):
		logging.info(f"Writing '{file_path}'...")
		with open(file_path, "w") as out:
			out.write(content)

	def load(self, table, content):
		logging.info(f"Loading data into table '{table}'...")
		reader = csv_reader(StringIO(content))
		header = next(reader)
		data = list(reader)
		result = self._client.insert(table, data, column_names = header)
		logging.info(result.summary)

Main().run()
