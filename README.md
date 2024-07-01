# dema.ai - Home Assignment

## Installation

Docker is required to run the project ([Docker Desktop on Windows](https://docs.docker.com/desktop/install/windows-install/)).

1. Clone the repo:
```
git clone https://github.com/Nullmage/dema.ai.git
```

2. Build the image files
```
docker-compose build
```

3. Spin up the containers
```
docker-compose up -d
```

## Overview

The stack consists of three containers:

* **ingest** - Responsible of extracting and loading the data. Upon startup, a Python script (`main.py`) will execute and:
	* Create the "landing" tables in the data warehouse for the raw data
	* Download the CSV files and store them in /app/data (which is mounted to /ingest/data)
	* Insert the CSV files to the "landing" tables in the `dema` schema
	* Upon finishing the container will exit
* **dbt** - Contains the dbt project + dependencies.
	* Data flows from raw "source systems" tables (orders, inventory, stg_shopify__inventory, etc) to refined "business conformed" tables (int_finance__orders -> marts_finance__orders_per_month, etc)
* **warehouse** - Responsible for hosting the data warehouse (Clickhouse)
	* A database (dema) is created upon start, as well as a user (dema) with password (d3m4)
	* Data is persistent through volumes
	* Port 8123 and 9000 are exposed to the host machine for clients to connect (e.g TablePlus)

## Usage

* To materialize the dbt project execute
```
docker exec -it dbt dbt run
```

* To run the dbt tests execute
```
docker exec -it dbt dbt test
```

## Possible improvements

* Write documentation for the tables, views and columns
* dbt data freshness can be used to detect stale data
* Use SQL fluff to ensure consistency for the dbt project (should be executed with git pre-commit hooks)
* Use a python formatter to ensure consistency (e.g [black](https://github.com/psf/black)) and [mypy static type checker](https://github.com/python/mypy) for the ingest script

## Bigger changes

* Use an orchestrator (Airflow, Airbyte, etc) to fetch the raw data periodically and trigger dbt
* Orchestrate the infrastructure using Terraform on GCP (BigQuery, PubSub, Dataflow, Cloud Storage, etc)
* Use dbt Cloud instead of dbt Core
