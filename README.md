Final Data Platform – Master Data & Analytics Pipeline

Architecture 

<img width="881" height="681" alt="architecture" src="https://github.com/user-attachments/assets/fef6d0fe-304c-4a91-9778-fef7b260577b" />










Overview

This project demonstrates an end-to-end data platform that implements Master Data Management (MDM), data governance, and analytical modeling using AWS services.
It covers the full lifecycle from master data ingestion → steward approval → golden records → analytics-ready data → reporting.

The implementation focuses on NYC Taxi data, with Zone treated as governed master data.

Flow Summary:

- Master data (Zone) is ingested from CSV into RDS as candidate records
- Data Steward reviews and approves/rejects candidates
- Approved records become Golden Records
- Golden records are published as snapshots to S3
- Transactional trip data is validated and curated
- Data is loaded into Amazon Redshift
- Dimensions & facts are derived
- QuickSight is used for analytics and dashboards


* Master Data Management (RDS)
  Zone Master Flow

Candidate Table: Stores incoming zone records

Approval Process: Data steward approves or rejects records

Golden Table: Approved records become the single source of truth

Key SQLs (RDS):

01_mdm_zone_candidate.sql

03_approve_zone_candidate.sql

04_reject_zone_candidate.sql

mdm_zone_golden.sql

* ETL & Data Processing (AWS Glue)
  Glue Jobs Implemented

Zone Master Candidate Loader

Trip Validation

Trip Curation

Golden Snapshot Publisher

Golden records are published to S3 after approval and consumed by downstream analytics.

* Data Lake Zones (S3)

Validated – Quality-checked data

Curated – Analytics-ready data

Snapshots – Golden master data snapshots

S3 lifecycle and security policies are handled via Python scripts.

* Analytics Layer (Amazon Redshift)
  Redshift Modeling

Staging tables for raw ingestion

Dimensions derived from master data

Fact table created from curated trips

Analytical queries provided for reporting

Key Concepts Used:

Star schema

Conformed dimensions

Master-to-analytics derivation

* Visualization (Amazon QuickSight)

Redshift used as data source

Custom SQL datasets

Dashboards built on curated facts & dimensions

* Infrastructure as Code

AWS resources provisioned using Terraform

IAM, backend state, and providers configured

GitHub Actions used for Glue deployment automation
