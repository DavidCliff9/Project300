-- This code creates the medical suite Database 

-- 1. Check for users and create the database

DO
$$
BEGIN

-- Data Declaration

DECLARE
MedAdminChk SMALLINT;
UserAppChk SMALLINT;
GPAppChk SMALLINT;

-- Check Users

SELECT COUNT(rolname) 
FROM pg_roles
WHERE rolname = 'MedAdmin'

SELECT COUNT(rolname)
FROM pg_roles 
WHERE rolname = 'UserApplication'

SELECT COUNT(rolname)
FROM pg_roles 
WHERE rolname = 'GPApplication'

-- Create Users if not created

IF (MedAdminChk = 0) THEN 
CREATE USER MedAdmin WITH PASSWORD 'password';
CREATE DATABASE MedicalSuite WITH OWNER = MedAdmin;
END IF;

IF (UserAppChk = 0) THEN
CREATE USER UserApplication WITH PASSWORD 'password';  
END IF;

IF (GPAppChk = 0) THEN 
CREATE USER GPApplication WITH PASSWORD 'password';  
END IF;



-- 2. Create the tables, schemas and grant rights

-- Create Schemas

CREATE SCHEMA Records;
CREATE SCHEMA GP;
CREATE SCHEMA Accounts;
CREATE SCHEMA Patients;

-- User Privileges

GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA Records, Accounts, GP, Users;

-- Finish Other Users (PlaceHolder)









-- Create Tables and Insert Inital Rows


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
                        CHECK (Email LIKE('%@%_._%')
                 -- Use Current Date if not date provided,
                Signed_up_at DATE NOT NULL DEFAULT CURRENT_DATE
	
         		-- !! Table should NEVER be used in Queries !!
                CREATE TABLE IF NOT EXISTS accounts.users_accounts (
                 -- Allows the incremention of id, Primary Key
                Account_Id SERIAL PRIMARY KEY,
                 -- Foreign Key 1:1
                User_Id INT NOT NULL UNIQUE,
                Email VARCHAR(50) NOT NULL UNIQUE
                 -- Eneforce Proper Email Entry (Any character before @, least one after before . and one after that)
                        CHECK (Email LIKE('%@%_._%'))
                Password_Hash VARCHAR(255) NOT NULL,
                 -- Foreign Key Constraint
                CONSTRAINT fk_user_id
                        FOREIGN KEY (UserId)
                        REFERENCES patients.patients (User_Id)
                        ON DELETE CASCADE -- Delete Account info if patient is deleted WITHOUT records
        );


                CREATE TABLE IF NOT EXISTS GP.gp (
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

        RAISE NOTICE 'Tables already exist.';
END;
$$;

-- Insert Test Data into Tables


