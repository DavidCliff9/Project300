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

-- Check Users

SELECT COUNT(rolname) 
INTO MedAdminChk
FROM pg_roles
WHERE rolname = 'medadmin';

SELECT COUNT(rolname)
INTO UserAppChk
FROM pg_roles 
WHERE rolname = 'UserApplication';

SELECT COUNT(rolname)
INTO GPAppChk
FROM pg_roles 
WHERE rolname = 'GPApplication';

-- Create Users if not created
-- Tells the PSQL block to execute SQL Commands

IF (MedAdminChk = 0) THEN 
EXECUTE 'CREATE USER medadmin WITH PASSWORD ''password'';
CREATE DATABASE medicalsuite WITH OWNER = medadmin;';
END IF;
/*
IF (UserAppChk = 0) THEN
CREATE USER UserApplication WITH PASSWORD 'password';  
END IF;

IF (GPAppChk = 0) THEN 
CREATE USER GPApplication WITH PASSWORD 'password';  
END IF;

*/

END;
$$;

/c medicalsuite
-- 2. Create Schemas and grant rights to schemas

-- Create Schemas
-- IF NOT EXISTS allows the script to re-run and avoid termination when running into existing schema

CREATE SCHEMA IF NOT EXISTS records;
CREATE SCHEMA IF NOT EXISTS gp;
CREATE SCHEMA IF NOT EXISTS accounts;
CREATE SCHEMA IF NOT EXISTS patients;


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
        

        --Inform user if table already exists (Only works if run from select * from)

       -- RAISE NOTICE 'Tables already exist.';
-- 4. Insert Data using earlier check

IF (MedAdminChk = 0) THEN 
-- Insert patients
INSERT INTO patients.patients (First_Name, Last_Name, Gender, Email)
VALUES
    ('Alice', 'Johnson', 'Female', 'alice.johnson@example.com'),
    ('Bob', 'Smith', 'Male', 'bob.smith@example.com'),
    ('Clara', 'Nguyen', 'Female', 'clara.nguyen@example.com'),
    ('David', 'Brown', 'Male', 'david.brown@example.com');

-- Insert accounts (1:1 with patients)
INSERT INTO accounts.users_accounts (User_Id, Email, Password_Hash)
VALUES
    (1, 'alice.johnson@example.com', 'hash_a1b2c3'),
    (2, 'bob.smith@example.com', 'hash_d4e5f6'),
    (3, 'clara.nguyen@example.com', 'hash_g7h8i9'),
    (4, 'david.brown@example.com', 'hash_j1k2l3');

-- Insert GPs
INSERT INTO gp.gp (First_Name, Last_Name, Role, Employed_At)
VALUES
    ('Sarah', 'Lee', 'Doctor', 'City Health Clinic'),
    ('John', 'Patel', 'Surgeon', 'Downtown General Hospital'),
    ('Emily', 'Wong', 'Nurse', 'Community Medical Center');

-- Insert records (linking patients ↔ GPs)
INSERT INTO records.records (User_Id, Gp_Id, Record_Details, Practice)
VALUES
    (1, 1, 'Routine check-up. All vitals normal.', 'City Health Clinic'),
    (2, 2, 'Appendectomy follow-up. Healing well.', 'Downtown General Hospital'),
    (3, 3, 'Blood test and immunization administered.', 'Community Medical Center'),
    (4, 1, 'High blood pressure noted. Recommended diet changes.', 'City Health Clinic');
END IF;

-- 5. User Privileges

-- Finish Other Users (PlaceHolder)

GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA records TO medadmin;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA accounts TO medadmin;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA gpo TO medadmin;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA patients TO medadmin;

-- Insert Test Data into Tables


