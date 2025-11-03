#!/bin/bash
# This is a script that allows the automatic update of the Medical Suite Database, with deletion script for testing purposes


# Hold the SQL Directory
SQL_DIR="/tmp/sqlcode"

# Bootstrap script URL
UPDATE_URL="https://raw.githubusercontent.com/DavidCliff9/Project300/refs/heads/main/Pro300/sqlcode/create_medsuite_master.sql"

# Delete script URL
#DELETE_URL="https://raw.githubusercontent.com/DavidCliff9/Project300/refs/heads/main/Pro300/sqlcode/medical_suite_delete.sql"

# Name of the output file
OUTPUT_FILENAME="bootstrap_medical_suite.sql"

# Name of the databsae user
DB_USER="postgres"

# Check if the SQL Directory exists

if [ -d "$SQL_DIR" ]; then
	echo  "SQLCode Directory exists: Skipping Creation"
else
	echo  "SQLCode does not exist, creating"
	mkdir -p "$SQL_DIR"
	# Fetch delete script from github
	
	wget -O "$SQL_DIR/$medical_suite_delete.sql" "https://raw.githubusercontent.com/DavidCliff9/Project300/refs/heads/main/Pro300/sqlcode/medical_suite_delete.sql"
	echo  "Created with delete script"

fi



# Check if the url is correct

if [ "$UPDATE_URL" != "https://raw.githubusercontent.com/DavidCliff9/Project300/refs/heads/main/Pro300/sqlcode/create_medsuite_master.sql" ]; then
	echo  "URL for the Bootstrap Script has been moved! Contact David on Discord"
	echo "URL for debugging:"
	echo -n "$UPDATE_URL"
	# Terminate Program here
	exit 1
else
	# Use wget to install the bootstrap script

	wget -O "$SQL_DIR/$OUTPUT_FILENAME" "https://raw.githubusercontent.com/DavidCliff9/Project300/main/Pro300/sqlcode/create_medsuite_master.sql"
fi

#Exit Code for wget to ensure file is correctly downloaded

if [ $? -eq 0 ]; then
	echo  "Latest File downloaded correctly"
else
	echo  "File download failed. Check Connection"
	exit 1
fi

# Prompt user for option
# Single Qoutes for literal String

echo  "Delete or run the Database bootstrap?"
echo ""
echo  '1. Run Updated Bootstrap Script (CRE)'
echo  '2. Delete Database (DEL)'
echo  '3. Exit (EXIT)'

read choice

# Loop if the option is incorrect

while ! ( [ "$choice" == "CRE" ] || [ "$choice" == "cre" ] || [ "$choice" == "1" ] || [ "$choice" == "DEL" ] || [ "$choice" == "del" ] || [ "$choice" == "2" ] || [ "$choice" == "EXIT" ]  || [ "$choice" == "exit" ] || [ "$choice" == "3" ] )
do
	echo -n  "Invalid Option. Select again: "
	read choice
done

# Perform Action Based on Input

if ( [ "$choice" == "CRE" ] || [ "$choice" == "cre" ] || [ "$choice" == "1" ] ); then
	echo "Running Latest Database Bootstrap"
	echo "-- Start of PostGre Command log --"
	# Brackets are not needed as this is a command and not a test
	#2> devnull suppresses Pi user change error

	if sudo -H -u "$DB_USER" psql -X -f "$SQL_DIR/$OUTPUT_FILENAME" 2> /dev/null; then
		echo "-- End of PostGre Command Log --"
		echo "Database Created/Updated Successfully"
	else
		echo "Database bootstrap failed. Check permissions or PostGres Logs"
	fi

elif ( [ "$choice" == "DEL" ] || [ "$choice" == "del" ] || [ "$choice" == "2" ] ); then
	echo "Deleting database"
	echo "-- Start of PostGre Command Log --"

	if sudo -H -u "$DB_USER" psql -X -f "$SQL_DIR/$medical_suite_delete.sql" 2> /dev/null; then
		echo "-- End of PostGre Command Log --"
		echo "Database Deleted. Re-run script and choose Create for fresh install"
	else
		echo "Deletion Script failed. Check permissions or PostGre Logs"
	fi

elif ( [ "$choice" == "EXIT" ] || [ "$choice" == "exit" ] || [ "$choice" == "3"]  ); then
	echo "Exiting program"
fi

