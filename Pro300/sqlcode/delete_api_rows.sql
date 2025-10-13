CREATE OR REPLACE FUNCTION wipe_api_test()
-- Count Rows Deleted
RETURNS BIGINT
LANGUAGE plpgsql
AS $$
Declare
	-- Set to zero
        deleted_rows BIGINT := 0;
BEGIN
	-- Delete everything as there is no where caluse
        DELETE FROM FlaskAPITable;

	-- Retrieve the amount of rows deleted
        GET DIAGNOSTICS deleted_rows = ROW_COUNT;
        RETURN deleted_rows;
END;
$$;

-- psql -U pi -d pitestdb -f delete_api_rows.sql
