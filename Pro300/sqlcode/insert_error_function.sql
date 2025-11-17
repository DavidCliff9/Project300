-- This Function is a reusable function for use in other stored procedures for error logging

CREATE OR REPLACE FUNCTION error_log(EErrorMSG VARCHAR(50))

-- Use plpgsql and create function
-- Return nothig

RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE

-- Declare Variables

BEGIN

-- Insert error message and timestamp from stored procedures upon reaching an error

INSERT INTO admin.errorlog (error_msg)
VALUES (EErrorMSG);

END;
$$;
