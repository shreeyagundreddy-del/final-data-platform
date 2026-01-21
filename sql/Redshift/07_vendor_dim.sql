CREATE TABLE IF NOT EXISTS dim.vendor_dim (
  vendor_dim_sk   BIGINT IDENTITY(1,1),
  vendor_id       INTEGER NOT NULL,
  vendor_name     VARCHAR(100) NOT NULL,

  -- SCD2 columns
  effective_from  DATE     NOT NULL,
  effective_to    DATE,
  is_current      BOOLEAN  NOT NULL DEFAULT TRUE,

  -- lineage & audit
  record_source   VARCHAR(200) NOT NULL DEFAULT 'mdm.vendor_master',
  dim_created_at  TIMESTAMP NOT NULL DEFAULT GETDATE(),
  dim_updated_at  TIMESTAMP NOT NULL DEFAULT GETDATE(),

  CONSTRAINT pk_vendor_dim PRIMARY KEY (vendor_dim_sk)
)
DISTSTYLE ALL
SORTKEY (vendor_id);

CREATE OR REPLACE PROCEDURE dim.sp_upsert_vendor_dim_scd2()
LANGUAGE plpgsql
AS $$
BEGIN
  -- 1. Expire changed current records
  UPDATE dim.vendor_dim d
  SET effective_to   = CURRENT_DATE - 1,
      is_current     = FALSE,
      dim_updated_at = GETDATE()
  FROM mdm.vendor_master m
  WHERE d.vendor_id = m.vendor_id
    AND d.is_current = TRUE
    AND m.is_current = TRUE
    AND COALESCE(d.vendor_name,'') <> COALESCE(m.vendor_name,'');

  -- 2. Insert new OR changed records as current
  INSERT INTO dim.vendor_dim (
    vendor_id,
    vendor_name,
    effective_from,
    effective_to,
    is_current,
    record_source,
    dim_created_at,
    dim_updated_at
  )
  SELECT
    m.vendor_id,
    m.vendor_name,
    CURRENT_DATE,
    NULL,
    TRUE,
    'mdm.vendor_master',
    GETDATE(),
    GETDATE()
  FROM mdm.vendor_master m
  LEFT JOIN dim.vendor_dim d
    ON d.vendor_id = m.vendor_id
   AND d.is_current = TRUE
  WHERE m.is_current = TRUE
    AND (
      d.vendor_id IS NULL
      OR COALESCE(d.vendor_name,'') <> COALESCE(m.vendor_name,'')
    );
END;
$$;

CALL dim.sp_upsert_vendor_dim_scd2();