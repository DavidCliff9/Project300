CREATE OR REPLACE FUNCTION delete_test_row(_test_data TEXT)
--Count Rows 
RETURNS BIGINT
LANGUAGE plpgsql
AS $$
Declare
	deleted_rows BIGINT := 0;
BEGIN
	DELETE FROM test
	WHERE name = _test_data;

	GET DIAGNOSTICS deleted_rows = ROW_COUNT;

	RETURN deleted_rows;
END;
$$; 

