-- This Procedure will work with Flask API to add a record to the patient Database
-- It will search to ensure the patient exists, ensuring data

CREATE OR REPLACE PROCEDURE add_record_master(EPatientEmail VARCHAR(50),
EGPFirstName VARCHAR(50),
EGPLastName VARCHAR(50),
ERecordDetails TEXT,
EPractice VARCHAR(50))
LANGUAGE plpgsql
AS $$
DECLARE
-- Variables go here

ValidEmailChk SMALLINT;
ValidGPChk SMALLINT;
ValidGenderChk SMALLINT;
NewRecordId INT;

BEGIN
-- 1. Read in Data 

-- Query the Patient Table to see if the email already exists

SELECT COUNT(email)
INTO ValidEmailChk
FROM patients.patients
WHERE email = EPatientEmail;

-- Query the GP Table to see if the GP already exists (Retreived through enviornmental variable)

SELECT COUNT(first_name)
INTO ValidGPChk
FROM gp.gp
WHERE first_name = EGPFirstName AND last_name = EGPLastName;

-- Query the Practuce Table to see if the Practice exists

--SELECT COUNT(email)
--INTO ValidEmailChk
--FROM patients.patients
--WHERE email = EEmail;

-- 2. Perform Logcial Operations on the Data

-- Check if email is in a valid format as per constraint
IF (EPatientEmail NOT LIKE ('%@%_._%')) THEN
	RAISE EXCEPTION 'Invalid Email format detected: %', EPatientEmail
		USING hint = 'Validate Email';
END IF;

-- Check if Patient Exists
IF (ValidEmailChk = 0) THEN
	RAISE EXCEPTION 'Patient does not exist: '
		USING hint = 'Please check details entered';
END IF;

-- Check if GP Exists
IF (ValidGPChk = 0) THEN
        RAISE EXCEPTION 'Patient does not exist: '
                USING hint = 'Please check details entered';
END IF;

--IF (EEmail NOT LIKE ('%@%_._%')) THEN
--        RAISE EXCEPTION 'Invalid Email format detected: %', EEmail
--                USING hint = 'Validate Email';
--END IF;

-- 3. Perform Data Insertion with Error Handling

-- Try
BEGIN
	-- Insert Into Record Table
	NewRecordId := add_record_details(EPatientEmail,
EGPFirstName,
EGPLastName,
ERecordDetails,
EPractice);
	RAISE NOTICE 'User Created: %', NewRecordId;

-- Handling Errors Gracefully
EXCEPTION
	-- Fallback
	WHEN others THEN
	PERFORM error_log(SQLERRM);
	RAISE NOTICE 'Error Logged. Contact Admin';
END;
	
end; $$;
