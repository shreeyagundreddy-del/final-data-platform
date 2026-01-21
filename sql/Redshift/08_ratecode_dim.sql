CREATE TABLE IF NOT EXISTS dim.ratecode_dim (
  ratecode_dim_sk BIGINT IDENTITY(1,1),
  ratecode_id     INTEGER NOT NULL,
  ratecode_desc   VARCHAR(100) NOT NULL,

  effective_from  DATE     NOT NULL,
  effective_to    DATE,
  is_current      BOOLEAN  NOT NULL DEFAULT TRUE,

  record_source   VARCHAR(200) NOT NULL DEFAULT 'mdm.ratecode_master',
  dim_created_at  TIMESTAMP NOT NULL DEFAULT GETDATE(),
  dim_updated_at  TIMESTAMP NOT NULL DEFAULT GETDATE(),

  CONSTRAINT pk_ratecode_dim PRIMARY KEY (ratecode_dim_sk)
)
DISTSTYLE ALL
SORTKEY (ratecode_id);

CREATE OR REPLACE PROCEDURE dim.sp_upsert_ratecode_dim_scd2()
LANGUAGE plpgsql
AS $$
BEGIN
  -- 1. Expire changed current records
  UPDATE dim.ratecode_dim d
  SET effective_to   = CURRENT_DATE - 1,
      is_current     = FALSE,
      dim_updated_at = GETDATE()
  FROM mdm.ratecode_master m
  WHERE d.ratecode_id = m.ratecode_id
    AND d.is_current = TRUE
    AND m.is_current = TRUE
    AND COALESCE(d.ratecode_desc,'') <> COALESCE(m.ratecode_desc,'');

  -- 2. Insert new OR changed records as current
  INSERT INTO dim.ratecode_dim (
    ratecode_id,
    ratecode_desc,
    effective_from,
    effective_to,
    is_current,
    record_source,
    dim_created_at,
    dim_updated_at
  )
  SELECT
    m.ratecode_id,
    m.ratecode_desc,
    CURRENT_DATE,
    NULL,
    TRUE,
    'mdm.ratecode_master',
    GETDATE(),
    GETDATE()
  FROM mdm.ratecode_master m
  LEFT JOIN dim.ratecode_dim d
    ON d.ratecode_id = m.ratecode_id
   AND d.is_current = TRUE
  WHERE m.is_current = TRUE
    AND (
      d.ratecode_id IS NULL
      OR COALESCE(d.ratecode_desc,'') <> COALESCE(m.ratecode_desc,'')
    );
END;
$$;

CALL dim.sp_upsert_ratecode_dim_scd2();