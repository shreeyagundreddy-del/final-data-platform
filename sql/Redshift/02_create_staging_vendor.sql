DROP TABLE IF EXISTS staging.vendor_raw;
CREATE TABLE staging.vendor_raw (
    vendor_id INT,
    vendor_name VARCHAR(100)
);

INSERT INTO staging.vendor_raw (vendor_id, vendor_name) VALUES
  (1, 'Creative Mobile Technologies, LLC'),
  (2, 'Curb Mobility, LLC'),
  (6, 'Myle Technologies Inc'),
  (7, 'Helix');

CREATE TABLE IF NOT EXISTS mdm.vendor_master (
    vendor_sk INT IDENTITY(1,1),
    vendor_id INT,
    vendor_name VARCHAR(100),
    is_current BOOLEAN,
    effective_from TIMESTAMP,
    effective_to TIMESTAMP
);

CREATE OR REPLACE PROCEDURE mdm.upsert_vendor_master()
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE mdm.vendor_master m
    SET is_current = FALSE,
        effective_to = GETDATE()
    FROM staging.vendor_raw s
    WHERE m.vendor_id = s.vendor_id
      AND m.vendor_name <> s.vendor_name
      AND m.is_current = TRUE;

    INSERT INTO mdm.vendor_master
    (vendor_id, vendor_name, is_current, effective_from, effective_to)
    SELECT
        s.vendor_id,
        s.vendor_name,
        TRUE AS is_current,
        CURRENT_DATE AS effective_from,
        NULL AS effective_to
    FROM staging.vendor_raw s
    LEFT JOIN mdm.vendor_master m
      ON s.vendor_id = m.vendor_id
     AND m.is_current = TRUE
    WHERE m.vendor_id IS NULL
       OR m.vendor_name <> s.vendor_name;
END;
$$;
CALL mdm.upsert_vendor_master();