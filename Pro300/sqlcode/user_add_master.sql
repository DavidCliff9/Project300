-- This Procedure will work with Flask API to add a user to the patient Database
-- It will first insert into the accounts table, then into the patients table

CREATE OR REPLACE PROCEDURE add_patient_master(EFirstName VARCHAR(50), 
ELastName VARCHAR(50), 
EGender VARCHAR(10), 
EEmail VARCHAR(50),
EPassword VARCHAR(255))
LANGUAGE plpgsql
AS $$
DECLARE
-- Variables go here

ValidEmailChk SMALLINT;
ValidGenderChk SMALLINT;
NewPatientId INT;

BEGIN
-- 1. Read in Data 

-- Query the Patient Table to see if the email already exists

SELECT COUNT(email)
INTO ValidEmailChk
FROM patients.patients
WHERE email =EEmail;

-- 2. Perform Logcial Operations on the Data

-- Check if email is in a valid format as per constraint
IF (EEmail NOT LIKE ('%@%_._%')) THEN
	RAISE EXCEPTION 'Invalid Email format detected: %', EEmail
		USING hint = 'Validate Email';
END IF;

IF (ValidEmailChk != 0) THEN
	RAISE EXCEPTION 'Patient Already Exists: '
		USING hint = 'Please Log in to your account';
END IF;

--IF (EEmail NOT LIKE ('%@%_._%')) THEN
--        RAISE EXCEPTION 'Invalid Email format detected: %', EEmail
--                USING hint = 'Validate Email';
--END IF;

-- 3. Perform Data Insertion with Error Handling

-- Try
BEGIN
	-- Insert Into Patient Tables
	NewPatientId := add_patient_details(EFirstName, ELastName, EGender, EEmail, EPassword);
	RAISE NOTICE 'User Created: %', NewPatientId;

-- Handling Errors Gracefully
EXCEPTION
	-- Fallback
	WHEN others THEN
	PERFORM error_log(SQLERRM);
	RAISE NOTICE 'Error Logged. Contact Admin';
END;
	
end; 
$$;
