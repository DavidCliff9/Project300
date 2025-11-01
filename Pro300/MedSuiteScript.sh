#!/bin/bash
# This does things

# Hold the SQL Directory
SQL_DIR="$HOME/sqlcode"

# Bootstrap script URL
UPDATE_URL="https://raw.githubusercontent.com/DavidCliff9/Project300/main/Pro300/sqlcode/create_medsuite_master.sql"

# Delete script URL

#DELETE_URL=""
# Name of the output file
OUTPUT_FILENAME="bootstrap_medical_suite.sql"

# Check if the SQL Directory exists

if [ -d "$SQL_DIR" ]; then
	echo "SQLCode exists, skipping creation"
else
	echo "SQLCode does not exist, creating"
	mkdir -p "$SQL_DIR"
	echo -n "Created with delete script"

fi

# Check if the url is present

if ["$UPDATE_URL" != "https://raw.githubusercontent.com/DavidCliff9/Project300/main/Pro300/sqlcode/create_medsuite_master.sql" ]; then
	echo -n "URL for the Bootstrap Script has been moved! Contact David on Discord"
else
	wget -O "$SQL_DIR/$OUT_FILENAME" "https://raw.githubusercontent.com/DavidCliff9/Project300/main/Pro300/sqlcode/create_medsuite_master.sql"
fi

#Exit Code for wget

if [ $? -eq ]; then
	echo -n "Latest File downloaded correctly"
else
	echo -n "File download failed. Check Connection"
	exit 1
fi

# Prompt user for option

echo -n "Delete or run the Database bootstrap?"
echo -n "Delete (DEL)
echo -n "Run Updated Bootstrap (CRE)
echo -n "Exit (EXIT)

read choice

# Loop if the option is incorrect

while [ "$choice" != "CRE" OR "DEL" OR "EXIT" ]
do
	echo -n "Invalid Option. Select again"
	read choice
done

echo "program exitied"


