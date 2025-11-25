from flask import Flask, request, jsonify, send_from_directory
import db
import json

app = Flask(__name__)

# load configuration from the json file
with open('config.json', 'r') as file:
            config = json.load(file)
          
# database configuration
db_table = config['postgres'].get("db_table")

# Home route, displays a message
@app.route('/')
def home():
    return 'Welcome to the Pro300 App'

# Return a route for a front end - Generated with Gemini AI
@app.route('/tester', methods=['GET'])
def tester_ui():
    return send_from_directory('.', 'api_tester.html')

# Delete route for using a PostGreSQL function to wipe all data
@app.route('/delete', methods=['POST']) 
def delete():
    query = 'SELECT wipe_api_test()';
    try:
	#Params not requuried as the function takes none, reuse the write to db function
        db.write_to_db(query)

        return jsonify({'message': 'All data wiped from table!'})
    except Exception as e:
        return jsonify({'error': str(e)}), 500


# Read Data route, a get requests an endpoint from the PostgresSQL database.
# A query is built from the JSON config
@app.route('/readrecords', methods=['GET'])
def read():
    query = f'SELECT * FROM records.records;'
    try:
        result = db.read_from_db(query)
        return jsonify(result)
    except Exception as e:
        return jsonify({'error': str(e)}), 500
    
# Write data route, a get requests an endpoint from the PostgresSQL database.
# A query is built by creating a JSON format.
@app.route('/writerecord', methods=['POST'])
def write():
    data = request.json
#generates SQL from JSON - The placeholder values prevent SQL Injection attacks
    query = f'CALL add_record_master(email, gpfirstname, gplastname, recorddetail, practice);'
    params = (data['email'], data['gpfirstname'], data['gplastname'], data['recorddetail'], data['practice'])
    try:
        db.write_to_db(query, params)
        return jsonify({'message': 'Data inserted successfully!'})
    except Exception as e:
        return jsonify({'error': str(e)}), 500
    
if __name__ == '__main__':
    app.run(debug=True)
