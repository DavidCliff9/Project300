-- This code creates the medical suite Database 

-- 1. Check for users and create the database

DO
$$	
-- Data Declaration
DECLARE	
MedAdminChk SMALLINT;
UserAppChk SMALLINT;
GPAppChk SMALLINT;	
BEGIN

-- Check Users by selecting against


	
SELECT COUNT(rolname) 
INTO MedAdminChk
FROM pg_roles
WHERE rolname = 'medadmin';

SELECT COUNT(rolname)
INTO UserAppChk
FROM pg_roles 
WHERE rolname = 'userapplication';

SELECT COUNT(rolname)
INTO GPAppChk
FROM pg_roles 
WHERE rolname = 'GPApplication';

-- Create Users and Database if not created
-- Tells the PSQL block to execute SQL Commands



IF (MedAdminChk = 0) THEN 
EXECUTE 'CREATE USER medadmin WITH PASSWORD ''password'';';
END IF;




IF (UserAppChk = 0) THEN
CREATE USER userapplication WITH PASSWORD 'password';  
END IF;
/*
IF (GPAppChk = 0) THEN 
CREATE USER GPApplication WITH PASSWORD 'password';  
END IF;

*/

END;
$$;

-- This is a psql variable. It will execute this search and store it for use within the script. -T no header, -A unaligned and -C run command

\set db_exists 'psql -tAc Select COUNT(datname) FROM pg_database WHERE datname = ''medicalsuite''';

\if :db_exists
	\echo 'Database exists'
\else
	CREATE DATABASE medicalsuite WITH OWNER = medadmin;
\endif


\c medicalsuite
	
-- 2. Create Schemas and grant rights to schemas

-- Create Schemas
-- IF NOT EXISTS allows the script to re-run and avoid termination when running into existing schema

CREATE SCHEMA IF NOT EXISTS records;
CREATE SCHEMA IF NOT EXISTS gp;
CREATE SCHEMA IF NOT EXISTS accounts;
CREATE SCHEMA IF NOT EXISTS patients;
CREATE SCHEMA IF NOT EXISTS admin;


-- 3. Create Tables and where valid, indexes


CREATE TABLE IF NOT EXISTS patients.patients (
 -- Allows the incremention of id, Primary Key
User_Id SERIAL PRIMARY KEY,
First_Name VARCHAR(50),
 Last_Name VARCHAR(50),
-- Enforce Male, Female or Other
Gender VARCHAR(10)
    CHECK (Gender IN ('Male', 'Female', 'Other')),
Email VARCHAR(50) NOT NULL UNIQUE
-- Eneforce Proper Email Entry (Any character before @, least one after before . and one after that)
 	CHECK (Email LIKE('%@%_._%')),
-- Use Current Date if not date provided,
Signed_up_at DATE NOT NULL DEFAULT CURRENT_DATE

	);
	
-- !! Table should NEVER be used in Queries !!
CREATE TABLE IF NOT EXISTS accounts.users_accounts (
 -- Allows the incremention of id, Primary Key
Account_Id SERIAL PRIMARY KEY,
 -- Foreign Key 1:1
User_Id INT NOT NULL UNIQUE,
Email VARCHAR(50) NOT NULL UNIQUE
 -- Eneforce Proper Email Entry (Any character before @, least one after before . and one after that)
    CHECK (Email LIKE('%@%_._%')),
Password_Hash VARCHAR(255) NOT NULL,
-- Foreign Key Constraint
CONSTRAINT fk_user_id
    FOREIGN KEY (User_Id)
    REFERENCES patients.patients (User_Id)
    ON DELETE CASCADE -- Delete Account info if patient is deleted WITHOUT records
        );

CREATE TABLE IF NOT EXISTS gp.gp (
 -- Allows the incremention of Primary Key
Gp_Id SERIAL PRIMARY KEY,
First_Name VARCHAR(50) NOT NULL,
Last_Name VARCHAR(50) NOT NULL,
role VARCHAR(50) NOT NULL
 -- Enforce Correct Role Entry
    CHECK (role in ('Surgeon','Doctor', 'Nurse', 'Physiotherapist')),
employed_at VARCHAR(100)
        );

CREATE TABLE IF NOT EXISTS records.records (
 -- Allows the incrementation of Primary Key
Record_Id SERIAL PRIMARY KEY,
 -- Foreign Keys to patient and GP table (Link Table)
User_Id INT NOT NULL,
Gp_Id INT NOT NULL,
 -- Body of the record
Record_Details TEXT NOT NULL,
Practice VARCHAR(100),
 -- If no value is entered, use the default timestamp
Created_At TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
 -- Foreign Key Constraints
CONSTRAINT fk_user_record_id
    FOREIGN KEY (User_Id)
    REFERENCES patients.patients (User_Id)
    ON DELETE RESTRICT, -- Prevent Deletion of a patient WITH records
CONSTRAINT fk_gp_record_id
    FOREIGN KEY (Gp_Id)
    REFERENCES GP.gp (Gp_Id)
    ON DELETE RESTRICT -- Prevent Deletion of a GP WITH records
        );	

CREATE TABLE IF NOT EXISTS admin.errorlog (
 -- Allows the incrementation of Primary Key
Error_Id SERIAL PRIMARY KEY,
Error_msg VARCHAR(500),
 -- If no value is entered, use the default timestamp
Created_At TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
        );	
        
-- 4. Insert Data using earlier check

-- Insert Patients
INSERT INTO patients.patients (First_Name, Last_Name, Gender, Email)
VALUES
    ('Alice', 'Johnson', 'Female', 'alice.johnson@example.com'),
    ('Bob', 'Smith', 'Male', 'bob.smith@example.com'),
    ('Clara', 'Nguyen', 'Female', 'clara.nguyen@example.com'),
    ('David', 'Brown', 'Male', 'david.brown@example.com')
ON CONFLICT (Email) DO NOTHING; -- Emails have to be unique, if PostGre detects the same Email skip the insert

-- Insert Accounts (1:1 mapping with patients)
-- We assume User_Id matches the patient IDs above (serial), so we can use subqueries. Select the ID from the patient table where the email exists
INSERT INTO accounts.users_accounts (User_Id, Email, Password_Hash)
VALUES
    ((SELECT User_Id FROM patients.patients WHERE Email='alice.johnson@example.com'), 'alice.johnson@example.com', 'hash_a1b2c3'),
    ((SELECT User_Id FROM patients.patients WHERE Email='bob.smith@example.com'), 'bob.smith@example.com', 'hash_d4e5f6'),
    ((SELECT User_Id FROM patients.patients WHERE Email='clara.nguyen@example.com'), 'clara.nguyen@example.com', 'hash_g7h8i9'),
    ((SELECT User_Id FROM patients.patients WHERE Email='david.brown@example.com'), 'david.brown@example.com', 'hash_j1k2l3')
ON CONFLICT (User_Id) DO NOTHING;

-- Insert GPs
INSERT INTO gp.gp (gp_id, First_Name, Last_Name, Role, Employed_At)
VALUES
    ('1','Sarah', 'Lee', 'Doctor', 'City Health Clinic'),
    ('2','John', 'Patel', 'Surgeon', 'Downtown General Hospital'),
    ('3','Emily', 'Wong', 'Nurse', 'Community Medical Center')
ON CONFLICT (gp_id) DO NOTHING;

-- Insert Records 
INSERT INTO records.records (User_Id, Gp_Id, Record_Details, Practice)
VALUES
    ((SELECT User_Id FROM patients.patients WHERE Email='alice.johnson@example.com'), 
     (SELECT Gp_Id FROM gp.gp WHERE First_Name='Sarah' AND Last_Name='Lee'),
     'Routine check-up. All vitals normal.', 'City Health Clinic'),
    ((SELECT User_Id FROM patients.patients WHERE Email='bob.smith@example.com'), 
     (SELECT Gp_Id FROM gp.gp WHERE First_Name='John' AND Last_Name='Patel'),
     'Appendectomy follow-up. Healing well.', 'Downtown General Hospital'),
    ((SELECT User_Id FROM patients.patients WHERE Email='clara.nguyen@example.com'), 
     (SELECT Gp_Id FROM gp.gp WHERE First_Name='Emily' AND Last_Name='Wong'),
     'Blood test and immunization administered.', 'Community Medical Center'),
    ((SELECT User_Id FROM patients.patients WHERE Email='david.brown@example.com'), 
     (SELECT Gp_Id FROM gp.gp WHERE First_Name='Sarah' AND Last_Name='Lee'),
     'High blood pressure noted. Recommended diet changes.', 'City Health Clinic')
ON CONFLICT (Record_Id) DO NOTHING;

-- 5. User Privileges

-- Tables are seperted into schemas to allow Granular Control

GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA records TO medadmin;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA accounts TO medadmin;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA gp TO medadmin;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA patients TO medadmin;
GRANT USAGE, SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA admin TO medadmin;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA patients TO medadmin;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA accounts TO medadmin;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA gp TO medadmin;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA records TO medadmin;

GRANT SELECT ON ALL TABLES IN SCHEMA records TO userapplication;
GRANT SELECT, INSERT, UPDATE ON ALL TABLES IN SCHEMA accounts TO userapplication;
GRANT SELECT ON ALL TABLES IN SCHEMA gp TO userapplication;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA patients TO userapplication;
GRANT INSERT ON ALL TABLES IN SCHEMA admin TO userapplication;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA patients TO userapplication;

ALTER SCHEMA records OWNER TO medadmin;
ALTER SCHEMA accounts OWNER TO medadmin;
ALTER SCHEMA gp OWNER TO medadmin;
ALTER SCHEMA patients OWNER TO medadmin;
ALTER SCHEMA admin OWNER TO medadmin;

-- Finish Other Users (PlaceHolder)



-- Insert Test Data into Tables

-- 6. Stored Procedures and Functions

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

-- This Function will insert details once it passes checks from the stored procedure its called

CREATE OR REPLACE FUNCTION add_patient_details(EFirstName VARCHAR(50), 
ELastName VARCHAR(50),
EGENDER VARCHAR(10), 
EEmail VARCHAR(50),
EPassword VARCHAR(255)
)

-- Return int to master procedure

RETURNS int
LANGUAGE plpgsql
AS $$
DECLARE

-- Declare Variables

return_msg int;

BEGIN

INSERT INTO accounts.users_accounts (email, password_hash)
VALUES (EEmail, EPassword)
  
-- Insert into patient table

INSERT INTO patients.patients (first_name, last_name, gender, email)
VALUES (EFirstName, ELastName, EGender, EEmail)
RETURNING user_id INTO return_msg;

-- Return a message

RETURN return_msg; 

END;
$$;

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


