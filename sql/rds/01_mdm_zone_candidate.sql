-- Table: mdm.zone_candidate

-- DROP TABLE IF EXISTS mdm.zone_candidate;

CREATE TABLE IF NOT EXISTS mdm.zone_candidate
(
    zone_id integer,
    zone_name text COLLATE pg_catalog."default",
    borough text COLLATE pg_catalog."default",
    service_zone text COLLATE pg_catalog."default",
    match_score numeric(5,2),
    approval_status text COLLATE pg_catalog."default" DEFAULT 'PENDING'::text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    reviewed_by text COLLATE pg_catalog."default",
    reviewed_at timestamp without time zone
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS mdm.zone_candidate
    OWNER to mdmadmin;