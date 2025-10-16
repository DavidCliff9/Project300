-This code creates the medical suite Database 

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
CREATE SCHEMA Users;

-- User Privileges

GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA Records, Accounts, GP, Users;

-- Finish Other Users (PlaceHolder)









-- Create Tables and Insert Inital Rows

CREATE OR REPLACE function create_med_tables()
RETURNS void
LANGUAGE plpgsql
AS $$
BEGIN
--Execute will allow the use of DDL commands

        EXECUTE '
                CREATE TABLE IF NOT EXISTS users.users (
                --Allows the incremention of id
                id SERIAL PRIMARY KEY,
                PatientName VARCHAR(255),
                PlaceHolder VARCHAR(255)
        );
                CREATE TABLE IF NOT EXISTS accounts.usersaccounts (
                --Allows the incremention of id
                id SERIAL PRIMARY KEY,
                Name VARCHAR(255),
                Description VARCHAR(255)
        );
        ';

        --Inform user if table already exists (Only works if run from select * from)

        RAISE NOTICE 'Tables already exist.';
END;
$$;

-- Insert Test Data into Tables

CREATE OR REPLACE function med_tables_test_data()
RETURNS void
LANGUAGE plpsql
AS $$
BEGIN
	INSERT INTO users.users('PatientName','PlaceHolder')
	VALUES ('PostGresUser','Forced to learn SQL'),
	VALUES ('MedAdmin','Admin can read this');
END;
$$;
