-- PROCEDURE: mdm.approve_zone_candidate(integer, text)

-- DROP PROCEDURE IF EXISTS mdm.approve_zone_candidate(integer, text);

CREATE OR REPLACE PROCEDURE mdm.approve_zone_candidate(
	IN p_zone_id integer,
	IN p_reviewer text)
LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
    -- Insert into golden table
    INSERT INTO mdm.zone_golden (
        zone_id,
        zone_name,
        borough,
        service_zone,
        approved_by
    )
    SELECT
        zone_id,
        zone_name,
        borough,
        service_zone,
        p_reviewer
    FROM mdm.zone_candidate
    WHERE zone_id = p_zone_id
      AND approval_status = 'PENDING';

    -- Update candidate status
    UPDATE mdm.zone_candidate
    SET approval_status = 'APPROVED',
        reviewed_by = p_reviewer,
        reviewed_at = CURRENT_TIMESTAMP
    WHERE zone_id = p_zone_id;
END;
$BODY$;
ALTER PROCEDURE mdm.approve_zone_candidate(integer, text)
    OWNER TO mdmadmin;

