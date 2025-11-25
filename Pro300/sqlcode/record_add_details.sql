-- This Function will insert details once it passes checks from the stored procedure its called

CREATE OR REPLACE FUNCTION add_record_details(EPatientEmail VARCHAR(50),
EGPFirstName VARCHAR(50),
EGPLastName VARCHAR(50),
ERecordDetails TEXT,
EPractice VARCHAR(50))

-- Return int to master procedure

RETURNS int
LANGUAGE plpgsql
AS $$
DECLARE

-- Declare Variables

return_msg int;

BEGIN

-- Insert into records table

INSERT INTO records.records (User_Id, GP_Id, Record_Details, Practice)
-- Using Subqueries to find the relevant foreign keys to insert into the table from Email and Names
VALUES ((SELECT User_Id FROM patients.patients WHERE Email=EPatientEmail),
(SELECT Gp_Id FROM gp.gp WHERE First_Name=EGPFirstName AND Last_Name=EGPLastName),
ERecordDetails, EPractice)
RETURNING user_id INTO return_msg;

-- Return a message

RETURN return_msg;

END;
$$;
