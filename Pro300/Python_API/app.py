from fastapi import FastAPI
import psycopg2
import hashlib

app = FastAPI()

#Connect to database
def get_db():
    return psycopg2.connect(
        host="localhost",
        database="medicalsuite",
        user="medadmin",
        password="password"
    )

#password hashing
def hash_password(password):
    return hashlib.md5(password.encode()).hexdigest()

@app.get("/")
def home():
    return "Medical API"

'''
#secure password cryp and hash this one is used by companies
from passlib.context import CryptContext

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")
def hash_password(password):
    return pwd_context.hash(password) 
'''

#get patients
@app.get("/patients")
def get_patients():
    db = get_db()
    cur = db.cursor()
    cur.execute("SELECT * FROM patients.patients")
    patients = cur.fetchall()
    cur.close()
    db.close()
    return patients

#add patient
@app.post("/patients")
def add_patient(first_name: str, last_name: str, age:  str):
    db = get_db()
    cur = db.cursor()
    cur.execute(
        "INSERT INTO patients.patients (first_name, last_name, gender, age) VALUES (%s, %s, %s, %s)",
        (first_name, last_name, gender, age)
    )
    db.commit()
    cur.close()
    db.close()
    return "Patient added"

#update patient
@app.put("/patients/{patient_id}")
def update_patient(patient_id: int, first_name: str = None, last_name: str = None, age: str = None):
    db = get_db()
    cur = db.cursor()
    
    if first_name:
        cur.execute("UPDATE patients.patients SET first_name = %s WHERE user_id = %s", (first_name, patient_id))
    if last_name:
        cur.execute("UPDATE patients.patients SET last_name = %s WHERE user_id = %s", (last_name, patient_id))
    if age:
        cur.execute("UPDATE patients.patients SET age = %s WHERE user_id = %s", (age, patient_id))
    
    db.commit()
    cur.close()
    db.close()
    return "Patient updated"

#delete patient
@app.delete("/patients/{patient_id}")
def delete_patient(patient_id: int):
    db = get_db()
    cur = db.cursor()
    cur.execute("DELETE FROM patients.patients WHERE user_id = %s", (patient_id,))
    db.commit()
    cur.close()
    db.close()
    return "Patient deleted"

# Get patient records
@app.get("/patients/{patient_id}/records")
def get_records(patient_id: int):
    db = get_db()
    cur = db.cursor()
    cur.execute("SELECT * FROM records.records WHERE user_id = %s", (patient_id,))
    records = cur.fetchall()
    cur.close()
    db.close()
    return records

# Create account (simple hashing)
@app.post("/accounts")
def create_account(username: str, role: str = "patient"):
    db = get_db()
    cur = db.cursor()
    
    # Default password is "password123"
    hashed_password = hash_password("password123")
    
    cur.execute(
        "INSERT INTO accounts.users_accounts (user_id, age, password_hash) VALUES (%s, %s, %s)",
        (username, f"{username}@hospital.com", hashed_password)
    )
    db.commit()
    cur.close()
    db.close()
    return f"Account created for {username} with role {role}. Password: password123"

# Create GP (doctor/nurse)
@app.post("/gps")
def create_gp(first_name: str, last_name: str, role: str, employed_at: str = "Hospital"):
    db = get_db()
    cur = db.cursor()
    
    cur.execute(
        "INSERT INTO gp.gp (first_name, last_name, role, employed_at) VALUES (%s, %s, %s, %s)",
        (first_name, last_name, role, employed_at)
    )
    db.commit()
    cur.close()
    db.close()
    return f"GP {first_name} {last_name} added as {role}"

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
