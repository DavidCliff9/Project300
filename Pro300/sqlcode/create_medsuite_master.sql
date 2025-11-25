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
Error_msg VARCHAR(50),
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
INSERT INTO gp.gp (First_Name, Last_Name, Role, Employed_At)
VALUES
    ('Sarah', 'Lee', 'Doctor', 'City Health Clinic'),
    ('John', 'Patel', 'Surgeon', 'Downtown General Hospital'),
    ('Emily', 'Wong', 'Nurse', 'Community Medical Center')
ON CONFLICT (Gp_Id) DO NOTHING;

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


