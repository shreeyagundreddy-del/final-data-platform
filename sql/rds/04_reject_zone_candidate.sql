-- PROCEDURE: mdm.reject_zone_candidate(integer, text)

-- DROP PROCEDURE IF EXISTS mdm.reject_zone_candidate(integer, text);

CREATE OR REPLACE PROCEDURE mdm.reject_zone_candidate(
	IN p_zone_id integer,
	IN p_reviewer text)
LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
    UPDATE mdm.zone_candidate
    SET approval_status = 'REJECTED',
        reviewed_by = p_reviewer,
        reviewed_at = CURRENT_TIMESTAMP
    WHERE zone_id = p_zone_id;
END;
$BODY$;
ALTER PROCEDURE mdm.reject_zone_candidate(integer, text)
    OWNER TO mdmadmin;

