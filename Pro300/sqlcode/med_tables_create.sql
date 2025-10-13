--This code creates the FlaskAPITable as a reusable function
-- Boiler Plate function code
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
        --Inform user if table already exists
        RAISE NOTICE 'Tables already exist.';
END;
$$;
