Final Data Platform – Master Data & Analytics Pipeline

Architecture 

<img width="881" height="681" alt="architecture" src="https://github.com/user-attachments/assets/fef6d0fe-304c-4a91-9778-fef7b260577b" />

# End-to-End Data Platform with Master Data Management (MDM) on AWS

## 📌 Overview

This project implements a scalable, end-to-end data platform on AWS, integrating Master Data Management (MDM), data governance, and analytical modeling. It demonstrates how raw data is transformed into trusted, analytics-ready datasets through governed pipelines.

The platform is built using NYC Taxi data, with **Zone** treated as governed master data.

---

## 🏗️ Architecture

![Data Lake Architecture](./architecture.png)

The platform follows a layered data lake architecture:

* **Raw Layer** → Immutable ingestion of source data
* **Validated Layer** → Data quality checks and schema validation
* **Curated Layer** → Business-ready, analytics-optimized datasets
* **Master Data Layer** → Golden records with strict governance
* **Downstream** → BI, Analytics, and ML consumption

---

## 🔄 End-to-End Data Flow

1. Master data (Zone) is ingested from CSV into Amazon RDS as candidate records
2. Data steward reviews and approves/rejects records
3. Approved records become **Golden Records** (single source of truth)
4. Golden records are published as snapshots to Amazon S3
5. Transactional trip data is validated and curated via AWS Glue
6. Data is loaded into Amazon Redshift
7. Dimensions and fact tables are created
8. Amazon QuickSight is used for analytics and dashboards

---

## 🧩 Master Data Management (MDM)

### Zone Master Flow (Amazon RDS)

* **Candidate Table**: Stores incoming records
* **Approval Workflow**: Data steward approves/rejects
* **Golden Table**: Approved records become authoritative data

### Key SQL Scripts

* `01_mdm_zone_candidate.sql`
* `03_approve_zone_candidate.sql`
* `04_reject_zone_candidate.sql`
* `mdm_zone_golden.sql`

---

## ⚙️ ETL & Data Processing (AWS Glue)

### Glue Jobs Implemented

* Zone Master Candidate Loader
* Trip Validation
* Trip Curation
* Golden Snapshot Publisher

👉 Golden records are published to S3 and consumed by downstream systems.

---

## 🗄️ Data Lake Design (Amazon S3)

* **Validated Layer** → Quality-checked data
* **Curated Layer** → Analytics-ready datasets
* **Snapshots Layer** → Golden master data

✔️ Lifecycle policies and security handled via Python automation

---

## 📊 Analytics Layer (Amazon Redshift)

### Data Modeling

* Staging tables for ingestion
* Dimension tables derived from master data
* Fact table built from curated trip data

### Concepts Applied

* Star schema design
* Conformed dimensions
* Master-to-analytics data propagation

---

## 📈 Visualization (Amazon QuickSight)

* Redshift used as the primary data source
* Custom SQL datasets created
* Interactive dashboards built on curated data

---

## 🛠️ Infrastructure as Code

* AWS infrastructure provisioned using **Terraform**
* IAM roles, backend state, and providers configured
* CI/CD implemented using **GitHub Actions** for Glue job deployment

---

## 🔑 Key Highlights

* End-to-end data pipeline from ingestion to BI
* Strong implementation of **data governance and MDM**
* Scalable architecture using AWS services
* Production-style data modeling and ETL workflows
* Automation using Terraform and CI/CD pipelines

---

## 🚀 Future Improvements

* Add real-time streaming (Kafka / Kinesis)
* Implement data quality monitoring dashboards
* Introduce data catalog (AWS Glue Data Catalog / Lake Formation)
* Enhance observability and lineage tracking

---

## 🧠 Tech Stack

* **AWS**: S3, Glue, RDS, Redshift, QuickSight
* **Languages**: Python, SQL
* **IaC**: Terraform
* **Orchestration**: Glue Workflows / CI-CD
* **Concepts**: MDM, Data Governance, Star Schema













