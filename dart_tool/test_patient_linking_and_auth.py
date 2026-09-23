import urllib.request
import json
import sys

BASE_URL = "http://127.0.0.1:8000"

def post(path, data, token=None):
    headers = {"Content-Type": "application/json", "Accept": "application/json"}
    if token:
        headers["Authorization"] = f"Bearer {token}"
    req = urllib.request.Request(f"{BASE_URL}{path}", data=json.dumps(data).encode(), headers=headers, method="POST")
    with urllib.request.urlopen(req) as resp:
        return json.loads(resp.read().decode())

def get(path, token=None):
    headers = {"Accept": "application/json"}
    if token:
        headers["Authorization"] = f"Bearer {token}"
    req = urllib.request.Request(f"{BASE_URL}{path}", headers=headers)
    with urllib.request.urlopen(req) as resp:
        return json.loads(resp.read().decode())

print("=" * 60)
print("TESTING COMPLETE MINDSETU AUTHENTICATION & PATIENT-LINKING FLOW")
print("=" * 60)

# SCENARIO A: Patient Login as Bhaben Borah
print("\n--- SCENARIO A: PATIENT LOGIN (Bhaben Borah) ---")
pat_login = post("/api/v1/auth/login", {"email": "patient@mindsetu.in", "password": "MindSetu@2026"})
assert pat_login["success"] is True, "Patient login failed"
pat_token = pat_login["data"]["access_token"]
pat_id = pat_login["data"]["patient_id"]
pat_code = pat_login["data"]["patient_code"]
pat_name = pat_login["data"]["full_name"]
print(f"[PASS] Patient authenticated: {pat_name}")
print(f"[PASS] Primary Patient ID assigned: {pat_id} (Code: {pat_code})")
assert pat_id == "MS-ASSAM-001", f"Expected MS-ASSAM-001 but got {pat_id}"

# Verify /api/v1/patients/me
pat_profile = get("/api/v1/patients/me", token=pat_token)
assert pat_profile["success"] is True
assert pat_profile["data"]["name"] == "Bhaben Borah"
assert pat_profile["data"]["patient_id"] == "MS-ASSAM-001"
bhaben_internal_uuid = pat_profile["data"]["id"]
print(f"[PASS] Verified Patient Home Profile: Name={pat_profile['data']['name']}, Patient ID={pat_profile['data']['patient_id']}")

# SCENARIO B: Caregiver Login & Connect to MS-ASSAM-001
print("\n--- SCENARIO B: CAREGIVER LOGIN & LINKING (Anamika Borah) ---")
cg_login = post("/api/v1/auth/login", {"email": "caregiver@mindsetu.in", "password": "MindSetu@2026"})
assert cg_login["success"] is True, "Caregiver login failed"
cg_token = cg_login["data"]["access_token"]
print(f"[PASS] Caregiver authenticated: {cg_login['data']['full_name']}")

# Connect to MS-ASSAM-001
connect_res = post("/api/v1/caregivers/connect", {"patient_id": "MS-ASSAM-001"}, token=cg_token)
assert connect_res["success"] is True, "Connecting caregiver to patient failed"
print(f"[PASS] Connected Caregiver to Patient: {connect_res['message']}")
assert connect_res["data"]["patient_id"] == "MS-ASSAM-001"
assert connect_res["data"]["patient_name"] == "Bhaben Borah"

# Caregiver retrieves connected patient details
cg_patient = get(f"/api/v1/caregivers/patients/{bhaben_internal_uuid}", token=cg_token)
assert cg_patient["success"] is True
print(f"[PASS] Caregiver retrieved Bhaben's data: Reminders={len(cg_patient['data']['reminders'])}, Notes={len(cg_patient['data']['notes'])}")

# SCENARIO C: Doctor Login & Open Patient MS-ASSAM-001
print("\n--- SCENARIO C: DOCTOR LOGIN & OPEN PATIENT (Dr. Debabrata Sarma) ---")
doc_login = post("/api/v1/auth/login", {"email": "doctor@mindsetu.in", "password": "MindSetu@2026"})
assert doc_login["success"] is True, "Doctor login failed"
doc_token = doc_login["data"]["access_token"]
print(f"[PASS] Doctor authenticated: {doc_login['data']['full_name']}")

# Doctor opens patient by Patient ID MS-ASSAM-001
open_res = post("/api/v1/doctors/open_patient", {"patient_id": "MS-ASSAM-001"}, token=doc_token)
assert open_res["success"] is True, "Doctor opening patient failed"
print(f"[PASS] Doctor opened patient record: {open_res['message']}")
assert open_res["data"]["patient"]["name"] == "Bhaben Borah"
assert open_res["data"]["patient_id"] == "MS-ASSAM-001"

# Doctor fetches clinical report for MS-ASSAM-001
report_res = get("/api/v1/doctors/patients/MS-ASSAM-001/reports", token=doc_token)
assert report_res["success"] is True
rep_data = report_res["data"]["patient_summary"]
print(f"[PASS] Doctor Clinical Report: Patient={rep_data['name']}, ID={rep_data['patient_id']}, History items={len(report_res['data']['activity_history'])}")

# SCENARIO D: Verify all 3 roles reference the SAME patient record
print("\n--- SCENARIO D: VERIFY SHARED PATIENT RECORD INTEGRITY ---")
print(f"Patient internal UUID : {bhaben_internal_uuid}")
print(f"Patient displayed ID  : {pat_id}")
print(f"Caregiver linked ID   : {connect_res['data']['patient_id']} (UUID: {connect_res['data']['patient']['id']})")
print(f"Doctor opened ID      : {open_res['data']['patient_id']} (UUID: {open_res['data']['patient']['id']})")
assert bhaben_internal_uuid == connect_res['data']['patient']['id'] == open_res['data']['patient']['id']
assert pat_id == connect_res['data']['patient_id'] == open_res['data']['patient_id'] == "MS-ASSAM-001"
print("[PASS] Confirmed: Patient, Caregiver, and Doctor all reference the EXACT same patient database record!")

# SCENARIO E: New Patient Signup with Auto-Generated ID
print("\n--- SCENARIO E: NEW PATIENT SIGNUP & ID GENERATION ---")
new_patient_email = f"newpatient_{int(urllib.request.time.time())}@mindsetu.in"
new_pat = post("/api/v1/auth/register", {
    "email": new_patient_email,
    "password": "MindSetu@2026",
    "full_name": "Kalyan Phukan",
    "role": "PATIENT",
    "region": "assam",
    "preferred_language": "Assamese",
    "age": 68
})
assert new_pat["success"] is True
new_id = new_pat["data"]["patient_id"]
print(f"[PASS] New Patient Registered: Name={new_pat['data']['full_name']}, Generated Patient ID={new_id}")
assert new_id.startswith("MS-ASSAM-"), f"Unexpected generated ID format: {new_id}"

# Caregiver connects to the new patient using their generated ID
connect_new = post("/api/v1/caregivers/connect", {"patient_id": new_id}, token=cg_token)
assert connect_new["success"] is True
print(f"[PASS] Caregiver dynamically connected to new patient using {new_id}: {connect_new['message']}")

print("\n" + "=" * 60)
print("ALL PATIENT-LINKING & AUTH SCENARIOS SUCCESSFULLY VERIFIED!")
print("=" * 60)
