-- This SQL Script deletes the MedicalSuite database. Used for providing a clean install as apart of the bootstrap loader

-- Drop Database command. If Exists stops the script from throwing an error if ran again. With Force terminates active connections

DROP DATABASE IF EXISTS medicalsuite WITH (FORCE)
