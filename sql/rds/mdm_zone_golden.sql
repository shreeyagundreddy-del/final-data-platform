-- Table: mdm.zone_golden

-- DROP TABLE IF EXISTS mdm.zone_golden;

CREATE TABLE IF NOT EXISTS mdm.zone_golden
(
    zone_id integer NOT NULL,
    zone_name text COLLATE pg_catalog."default",
    borough text COLLATE pg_catalog."default",
    service_zone text COLLATE pg_catalog."default",
    approved_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    approved_by text COLLATE pg_catalog."default",
    CONSTRAINT zone_golden_pkey PRIMARY KEY (zone_id)
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS mdm.zone_golden
    OWNER to mdmadmin;