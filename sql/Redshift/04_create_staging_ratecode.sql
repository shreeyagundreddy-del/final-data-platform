DROP TABLE IF EXISTS staging.ratecode_raw;
CREATE TABLE staging.ratecode_raw (
    ratecode_id INT,
    ratecode_desc VARCHAR(50)
);

INSERT INTO staging.ratecode_raw VALUES
(1,'Standard'),(2,'JFK'),(3,'Newark'),(4,'Nassau'),
(5,'Negotiated'),(6,'Group'),(99,'Null');

CREATE TABLE IF NOT EXISTS mdm.ratecode_master (
    ratecode_sk INT IDENTITY(1,1),
    ratecode_id INT,
    ratecode_desc VARCHAR(50),
    is_current BOOLEAN,
    effective_from TIMESTAMP,
    effective_to TIMESTAMP
);

CREATE OR REPLACE PROCEDURE mdm.upsert_ratecode_master()
LANGUAGE plpgsql
AS $$
BEGIN

    -- 1. Expire existing current records if description changed
    UPDATE mdm.ratecode_master m
    SET is_current = FALSE,
        effective_to = GETDATE()
    FROM staging.ratecode_raw s
    WHERE m.ratecode_id = s.ratecode_id
      AND m.ratecode_desc <> s.ratecode_desc
      AND m.is_current = TRUE;

    -- 2. Insert new current records (new or changed)
    INSERT INTO mdm.ratecode_master (
        ratecode_id,
        ratecode_desc,
        is_current,
        effective_from,
        effective_to
    )
    SELECT
        s.ratecode_id,
        s.ratecode_desc,
        TRUE,
        GETDATE(),
        '9999-12-31'
    FROM staging.ratecode_raw s
    LEFT JOIN mdm.ratecode_master m
      ON s.ratecode_id = m.ratecode_id
     AND m.is_current = TRUE
    WHERE m.ratecode_id IS NULL
       OR m.ratecode_desc <> s.ratecode_desc;

END;
$$;
CALL mdm.upsert_ratecode_master();