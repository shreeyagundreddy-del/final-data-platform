CREATE TABLE IF NOT EXISTS dim.zone_dim (
  zone_dim_sk     BIGINT IDENTITY(1,1),
  zone_id         INTEGER NOT NULL,
  borough         VARCHAR(50),
  zone_name       VARCHAR(100),
  service_zone    VARCHAR(50),

  effective_from  DATE,
  effective_to    DATE,
  is_current      BOOLEAN,

  record_source   VARCHAR(100),
  dim_created_at  TIMESTAMP,
  dim_updated_at  TIMESTAMP
);

CREATE OR REPLACE PROCEDURE dim.sp_upsert_zone_dim_scd2()
LANGUAGE plpgsql
AS $$
BEGIN
  -- 1. Expire changed current rows
  UPDATE dim.zone_dim d
  SET effective_to   = CURRENT_DATE - 1,
      is_current     = FALSE,
      dim_updated_at = GETDATE()
  FROM mdm.zone_master m
  WHERE d.zone_id = m.location_id
    AND d.is_current = TRUE
    AND m.is_current = TRUE
    AND (
      COALESCE(d.borough,'')      <> COALESCE(m.borough,'')
      OR COALESCE(d.zone_name,'') <> COALESCE(m.zone,'')
      OR COALESCE(d.service_zone,'') <> COALESCE(m.service_zone,'')
    );

  -- 2. Insert NEW or CHANGED rows
  INSERT INTO dim.zone_dim (
    zone_id, borough, zone_name, service_zone,
    effective_from, effective_to, is_current,
    record_source, dim_created_at, dim_updated_at
  )
  SELECT
    m.location_id,
    m.borough,
    m.zone,
    m.service_zone,
    CURRENT_DATE,
    NULL,
    TRUE,
    'mdm.zone_master',
    GETDATE(),
    GETDATE()
  FROM mdm.zone_master m
  LEFT JOIN dim.zone_dim d
    ON d.zone_id = m.location_id
   AND d.is_current = TRUE
  WHERE m.is_current = TRUE
    AND (
      d.zone_id IS NULL
      OR COALESCE(d.borough,'')      <> COALESCE(m.borough,'')
      OR COALESCE(d.zone_name,'') <> COALESCE(m.zone,'')
      OR COALESCE(d.service_zone,'') <> COALESCE(m.service_zone,'')
    );
END;
$$;

CALL dim.sp_upsert_zone_dim_scd2();