--Create external schema to access curated data in S3 via AWS Glue Data Catalog
CREATE EXTERNAL SCHEMA IF NOT EXISTS spectrum_validated
FROM DATA CATALOG
DATABASE 'day12_validated_db'
IAM_ROLE 'arn:aws:iam::228120216594:role/service-role/AmazonRedshift-CommandsAccessRole-20260118T011947';
DROP TABLE IF EXISTS staging.trips_raw;

CREATE TABLE staging.trips_raw
AS
SELECT *
FROM spectrum_validated.trips
LIMIT 0;

--Load current month's data into staging table
INSERT INTO staging.trips_raw
SELECT *
FROM spectrum_validated.trips;

--Create fact table
DROP TABLE IF EXISTS fact.trip_fact;

CREATE TABLE fact.trip_fact (
  trip_fact_sk          BIGINT IDENTITY(1,1),

  vendor_dim_sk         BIGINT,
  ratecode_dim_sk       BIGINT,
  payment_type_sk       BIGINT,
  pickup_zone_dim_sk    BIGINT,
  dropoff_zone_dim_sk   BIGINT,

  pickup_datetime       TIMESTAMP,
  dropoff_datetime      TIMESTAMP,

  passenger_count       INTEGER,
  trip_distance         DOUBLE PRECISION,

  fare_amount           DOUBLE PRECISION,
  extra                 DOUBLE PRECISION,
  mta_tax               DOUBLE PRECISION,
  tip_amount            DOUBLE PRECISION,
  tolls_amount          DOUBLE PRECISION,
  improvement_surcharge DOUBLE PRECISION,
  total_amount          DOUBLE PRECISION,
  congestion_surcharge  DOUBLE PRECISION,
  airport_fee           DOUBLE PRECISION,
  cbd_congestion_fee    DOUBLE PRECISION,

  created_at            TIMESTAMP DEFAULT GETDATE()
)
DISTSTYLE AUTO
SORTKEY (pickup_datetime);

--Populate fact table by joining staging table with dimension tables
INSERT INTO fact.trip_fact (
  vendor_dim_sk, ratecode_dim_sk, payment_type_sk,
  pickup_zone_dim_sk, dropoff_zone_dim_sk,
  pickup_datetime, dropoff_datetime,
  passenger_count, trip_distance,
  fare_amount, extra, mta_tax, tip_amount, tolls_amount,
  improvement_surcharge, total_amount, congestion_surcharge, airport_fee, cbd_congestion_fee
)
SELECT
  v.vendor_dim_sk,
  r.ratecode_dim_sk,
  p.payment_type_sk,
  zpu.zone_dim_sk,
  zdo.zone_dim_sk,

  t.tpep_pickup_datetime,
  t.tpep_dropoff_datetime,

  t.passenger_count,
  t.trip_distance,

  t.fare_amount,
  t.extra,
  t.mta_tax,
  t.tip_amount,
  t.tolls_amount,
  t.improvement_surcharge,
  t.total_amount,
  t.congestion_surcharge,
  t.airport_fee,
  t.cbd_congestion_fee
FROM staging.trips_raw t
LEFT JOIN dim.vendor_dim v
  ON v.vendor_id = t.vendorid AND v.is_current = TRUE
LEFT JOIN dim.ratecode_dim r
  ON r.ratecode_id = COALESCE(t.ratecodeid, 99) AND r.is_current = TRUE
LEFT JOIN dim.payment_type_dim p
  ON p.payment_type_id = COALESCE(t.payment_type, 5)
LEFT JOIN dim.zone_dim zpu
  ON zpu.zone_id = t.pulocationid AND zpu.is_current = TRUE
LEFT JOIN dim.zone_dim zdo
  ON zdo.zone_id = t.dolocationid AND zdo.is_current = TRUE;