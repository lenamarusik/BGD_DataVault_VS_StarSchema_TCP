# BGD_DataVault_VS_StarSchema_TPC

# Data Vault vs Star Schema – E-commerce Data Warehouse Project

## Overview

This project presents a comparison between two popular data warehouse modeling approaches:

* **Data Vault**
* **Star Schema**

The goal of the project is to evaluate both architectures in the context of an e-commerce analytical system using the **TPC-DS benchmark dataset**.

The project focuses on:

* scalability,
* historical data tracking,
* analytical query performance,
* flexibility of schema evolution,
* and maintainability of the warehouse.

Dataset source:

* https://www.tpc.org/tpcds/

---

# Project Goal

Modern e-commerce systems generate massive amounts of transactional and behavioral data. Traditional warehouse architectures often struggle with:

* rapid growth of datasets,
* integration of multiple data sources,
* maintaining full historical traceability,
* and supporting both operational and analytical workloads.

This project compares how **Star Schema** and **Data Vault** address these challenges.

The main research question is:

> When should we use Star Schema and when does Data Vault become a better architectural choice in Big Data environments?

---

# Repository Structure

```text
project/
│
├── data/               # Sample or generated datasets
├── sql/                # SQL scripts for Star Schema and Data Vault
├── diagrams/           # ERD and architecture diagrams
├── notebooks/          # Analysis notebooks (optional)
├── presentation/       # Final presentation slides
├── docs/               # Additional documentation
└── README.md
```

---

# Technologies & Concepts

## Star Schema

Star Schema is a dimensional modeling technique where:

* one central **fact table** stores business events and measures,
* multiple **dimension tables** provide analytical context.

### Advantages

* Simple and intuitive structure
* Fast analytical queries
* Easy SQL reporting
* Excellent for BI dashboards

### Disadvantages

* Limited scalability
* Less flexible schema evolution
* Weak historical tracking

---

## Data Vault

Data Vault is a modeling methodology designed for scalable and auditable enterprise data warehouses.

It consists of:

* **Hubs** – business keys
* **Links** – relationships between entities
* **Satellites** – descriptive attributes and history

### Advantages

* Highly scalable
* Full historical tracking
* Flexible integration of multiple data sources
* Strong auditability

### Disadvantages

* Higher complexity
* Large number of tables
* More difficult SQL queries

---

# Dataset

The project uses the **TPC-DS benchmark dataset**, which simulates a large-scale retail/e-commerce environment.

The dataset includes:

* customer data,
* store sales,
* promotions,
* products,
* dates,
* and transactional relationships.

Official benchmark:
https://www.tpc.org/tpcds/

---

# Star Schema Design

## Fact Table

* FACT_STORE_SALES

## Dimension Tables

* DIM_DATE
* DIM_STORE
* DIM_CUSTOMER
* DIM_ITEM
* DIM_PROMOTION

The Star Schema is optimized for:

* reporting,
* OLAP analysis,
* KPI dashboards,
* and aggregation-heavy workloads.

---

## Star Schema ERD

> TODO: Insert Star Schema ERD here

Example:

```md
![Star Schema ERD](./diagrams/star_schema_erd.png)
```

---

# Data Vault Design

## Scope

The project scope focuses on **store sales**.

## Hubs

* HUB_CUSTOMER
* HUB_ITEM
* HUB_STORE
* HUB_PROMOTION
* HUB_ADDRESS
* HUB_DATE
* HUB_SALES_TRANSACTION

## Links

### LINK_STORE_SALE

Represents:

* customer purchases,
* items sold,
* store transactions,
* promotions,
* dates,
* and addresses.

### LINK_CUSTOMER_ADDRESS

Represents customer-address relationships.

## Satellites

### Customer Satellites

* SAT_CUSTOMER_PROFILE
* SAT_CUSTOMER_DEMOGRAPHIC
* SAT_CUSTOMER_HOUSEHOLD

### Item Satellites

* SAT_ITEM_DETAIL
* SAT_ITEM_PRICE

### Store Satellites

* SAT_STORE_DETAIL
* SAT_STORE_LOCATION

### Other Satellites

* SAT_PROMOTION
* SAT_ADDRESS
* SAT_DATE
* SAT_STORE_SALE_MEASURES
* SAT_CUSTOMER_ADDRESS_EFFECTIVITY

---

## Data Vault ERD

> TODO: Insert Vault Schema ERD here

Example:

```md
![Data Vault ERD](./diagrams/data_vault_erd.png)
```

---

# Data Loading Strategy

Data loading follows the standard Data Vault loading order:

1. Hubs
2. Links
3. Satellites

Foreign keys are preserved in this implementation, therefore parallel loading is not used.

---

# Comparison Goals

The comparison between Data Vault and Star Schema focuses on:

* query complexity,
* analytical performance,
* scalability,
* schema flexibility,
* ease of maintenance,
* and historical data support.

---

# Benchmark / Demo

The project demonstrates:

* query complexity comparison,
* ETL complexity comparison,
* schema flexibility comparison,
* historical data tracking,
* scalability differences.

Example analytical queries:

* total sales by store,
* customer purchase history,
* promotion effectiveness,
* product sales trends.

Possible demo elements:

* ERD walkthrough,
* SQL query comparison,
* loading process demonstration,
* benchmark query execution,
* dashboard or analytics example.

---

# Expected Outcomes

The project aims to demonstrate that:

* **Star Schema** performs better for direct BI reporting and simpler analytics,
* while **Data Vault** provides better scalability, auditability, and long-term maintainability in enterprise-scale systems.

---

# Trade-offs

| Area                | Star Schema | Data Vault   |
| ------------------- | ----------- | ------------ |
| Query simplicity    | High        | Medium / Low |
| Scalability         | Medium      | High         |
| Historical tracking | Limited     | Excellent    |
| ETL complexity      | Low         | High         |
| Flexibility         | Medium      | High         |
| BI usability        | Excellent   | Moderate     |

---

# Setup & Run Instructions

## Requirements

* PostgreSQL / Snowflake / BigQuery / DuckDB
* SQL client
* Python 3.x (optional)
* TPC-DS dataset

---

## Dataset Preparation

Download the benchmark dataset from:

https://www.tpc.org/tpcds/

Generate or import the dataset according to the selected database platform.

---

## How to Run

### Star Schema

1. Create dimension tables
2. Create fact tables
3. Load data
4. Execute analytical queries

### Data Vault

1. Create hubs
2. Create links
3. Create satellites
4. Load historical data
5. Execute comparison queries

---

# Results & Recommendations

## Key Findings

### Star Schema

Best for:

* BI dashboards,
* fast analytical reporting,
* stable business requirements,
* simple reporting environments.

### Data Vault

Best for:

* evolving enterprise systems,
* multiple integrated data sources,
* historical auditability,
* scalable long-term storage.

---

# Future Improvements

Possible future extensions:

* real benchmark execution with performance metrics,
* cloud deployment,
* dbt integration,
* streaming data ingestion,
* automated ETL pipelines,
* data quality validation,
* Power BI / Tableau dashboards.

---

# Team Contributions

| Team Member        | Contribution                             |
| ------------------ | ---------------------------------------- |
| Maksymilian Białas | > TODO: Insert contribution here |
| Lena Marusik       | > TODO: Insert contribution here |
| Oskar Mazur        | > TODO: Insert contribution here |

---

# Final Conclusion

This project demonstrates that there is no universally best warehouse architecture.

* Star Schema is optimal for fast and simple analytics.
* Data Vault is optimal for scalable and auditable enterprise environments.

The choice depends on:

* business requirements,
* expected data growth,
* historical tracking needs,
* and system complexity.

---

# Authors

* Maksymilian Białas
* Lena Marusik
* Oskar Mazur

---

# License

Educational project created for database and data warehouse architecture comparison purposes.
