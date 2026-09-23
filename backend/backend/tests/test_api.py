import pytest
from datetime import datetime, timezone, timedelta
from fastapi.testclient import TestClient
from app.main import app
from app.core.database import SessionLocal, init_db
from app.core.seed import seed_database
from app.models.patient import Patient


@pytest.fixture(scope="session", autouse=True)
def setup_test_database():
    """Ensure tables and seed data exist."""
    init_db()
    db = SessionLocal()
    seed_database(db)
    db.close()


@pytest.fixture
def client():
    with TestClient(app) as c:
        yield c


def test_00_health_check(client):
    response = client.get("/health")
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "ok"


def test_01_patient_registration(client):
    payload = {
        "email": f"test_patient_{int(datetime.now().timestamp())}@mindsetu.in",
        "password": "Password123!",
        "full_name": "Kalyan Barua",
        "role": "PATIENT",
        "age": 75,
        "dob": "1951-03-22",
        "gender": "Male",
        "region": "assam",
        "preferred_language": "Assamese",
        "cultural_preferences": {
            "foods": ["Masor Tenga", "Pitha"],
            "music": ["Bihu songs"],
        },
        "emergency_contact_name": "Rohan Barua",
        "emergency_contact_phone": "+91 94350 99999",
        "emergency_contact_relation": "Son",
    }
    response = client.post("/api/v1/auth/register", json=payload)
    assert response.status_code == 201
    data = response.json()
    assert data["success"] is True
    assert "access_token" in data["data"]
    assert data["data"]["role"] == "PATIENT"
    assert data["data"]["patient_id"] is not None


def test_02_caregiver_registration(client):
    payload = {
        "email": f"test_cg_{int(datetime.now().timestamp())}@mindsetu.in",
        "password": "Password123!",
        "full_name": "Rohan Barua",
        "role": "CAREGIVER",
        "phone": "+91 94350 99999",
        "relationship": "Son & Caregiver",
    }
    response = client.post("/api/v1/auth/register", json=payload)
    assert response.status_code == 201
    data = response.json()
    assert data["success"] is True
    assert data["data"]["role"] == "CAREGIVER"


def test_03_doctor_registration(client):
    payload = {
        "email": f"test_doc_{int(datetime.now().timestamp())}@mindsetu.in",
        "password": "Password123!",
        "full_name": "Dr. Pranjal Saikia",
        "role": "DOCTOR",
        "qualification": "MD, Neurology & Cognitive Care",
        "hospital": "Silchar Medical College & Hospital",
        "license_number": "NMC-NER-99881",
    }
    response = client.post("/api/v1/auth/register", json=payload)
    assert response.status_code == 201
    data = response.json()
    assert data["success"] is True
    assert data["data"]["role"] == "DOCTOR"


def test_04_login(client):
    payload = {
        "email": "patient@mindsetu.in",
        "password": "MindSetu@2026",
    }
    response = client.post("/api/v1/auth/login", json=payload)
    assert response.status_code == 200
    data = response.json()
    assert data["success"] is True
    assert "access_token" in data["data"]
    assert data["data"]["email"] == "patient@mindsetu.in"


def test_05_jwt_authentication(client):
    # 1. Login to get valid token
    login_res = client.post("/api/v1/auth/login", json={"email": "patient@mindsetu.in", "password": "MindSetu@2026"})
    token = login_res.json()["data"]["access_token"]

    # 2. Call protected /me endpoint with token
    headers = {"Authorization": f"Bearer {token}"}
    me_res = client.get("/api/v1/auth/me", headers=headers)
    assert me_res.status_code == 200
    assert me_res.json()["data"]["email"] == "patient@mindsetu.in"


def test_06_role_authorization(client):
    # Patient token
    login_res = client.post("/api/v1/auth/login", json={"email": "patient@mindsetu.in", "password": "MindSetu@2026"})
    pat_token = login_res.json()["data"]["access_token"]
    pat_headers = {"Authorization": f"Bearer {pat_token}"}

    # Patient trying to access doctor registry endpoint -> must return 403 Forbidden
    doc_res = client.get("/api/v1/doctors/patients", headers=pat_headers)
    assert doc_res.status_code == 403


def test_07_patient_profile_and_dashboard(client):
    login_res = client.post("/api/v1/auth/login", json={"email": "patient@mindsetu.in", "password": "MindSetu@2026"})
    token = login_res.json()["data"]["access_token"]
    headers = {"Authorization": f"Bearer {token}"}

    # GET /patients/me
    profile_res = client.get("/api/v1/patients/me", headers=headers)
    assert profile_res.status_code == 200
    assert profile_res.json()["data"]["name"] == "Bhaben Borah"
    assert profile_res.json()["data"]["region"] == "assam"

    # GET /patients/me/dashboard
    dash_res = client.get("/api/v1/patients/me/dashboard", headers=headers)
    assert dash_res.status_code == 200
    data = dash_res.json()["data"]
    assert "todays_reminders" in data
    assert "recent_activities" in data


def test_08_activities_catalog(client):
    response = client.get("/api/v1/activities")
    assert response.status_code == 200
    activities = response.json()["data"]
    assert len(activities) >= 6
    act_ids = [a["id"] for a in activities]
    assert "act-memory-recall" in act_ids
    assert "act-sequence" in act_ids


def test_09_activity_result_submission(client):
    login_res = client.post("/api/v1/auth/login", json={"email": "patient@mindsetu.in", "password": "MindSetu@2026"})
    token = login_res.json()["data"]["access_token"]
    headers = {"Authorization": f"Bearer {token}"}

    payload = {
        "activity_id": "act-sequence",
        "score": 100,
        "accuracy": 1.0,
        "duration_seconds": 95,
        "difficulty": "Gentle",
        "feedback": "Perfect routine recall!",
    }
    response = client.post("/api/v1/activities/results", json=payload, headers=headers)
    assert response.status_code == 201
    assert response.json()["data"]["score"] == 100


def test_10_progress_calculation(client):
    login_res = client.post("/api/v1/auth/login", json={"email": "patient@mindsetu.in", "password": "MindSetu@2026"})
    token = login_res.json()["data"]["access_token"]
    headers = {"Authorization": f"Bearer {token}"}

    summary_res = client.get("/api/v1/progress/summary", headers=headers)
    assert summary_res.status_code == 200
    summary = summary_res.json()["data"]
    assert summary["total_activities_completed"] >= 1
    assert summary["average_score"] > 0
    # Must NOT have clinical diagnosis wording
    assert "diagnosis" not in summary["activity_trend_label"].lower()


def test_11_memories_crud(client):
    login_res = client.post("/api/v1/auth/login", json={"email": "patient@mindsetu.in", "password": "MindSetu@2026"})
    token = login_res.json()["data"]["access_token"]
    headers = {"Authorization": f"Bearer {token}"}

    # 1. Create memory
    create_payload = {
        "title": "Veranda Morning Rain",
        "description": "Sitting peacefully listening to raindrops falling on tea leaves.",
        "people": "Bhaben & Nirmala",
        "place": "Jorhat Veranda",
        "memory_date": "August 2023",
        "photo_url": "🌧️ 🌿 ☕",
        "tags": ["Peaceful", "Veranda"],
    }
    create_res = client.post("/api/v1/memories", json=create_payload, headers=headers)
    assert create_res.status_code == 201
    mem_id = create_res.json()["data"]["id"]

    # 2. Get single
    get_res = client.get(f"/api/v1/memories/{mem_id}", headers=headers)
    assert get_res.status_code == 200
    assert get_res.json()["data"]["title"] == "Veranda Morning Rain"

    # 3. Update
    up_res = client.put(f"/api/v1/memories/{mem_id}", json={"description": "Updated quiet rainy morning."}, headers=headers)
    assert up_res.status_code == 200
    assert up_res.json()["data"]["description"] == "Updated quiet rainy morning."

    # 4. Delete
    del_res = client.delete(f"/api/v1/memories/{mem_id}", headers=headers)
    assert del_res.status_code == 200


def test_12_reminders_crud(client):
    login_res = client.post("/api/v1/auth/login", json={"email": "patient@mindsetu.in", "password": "MindSetu@2026"})
    token = login_res.json()["data"]["access_token"]
    headers = {"Authorization": f"Bearer {token}"}

    # 1. Create reminder
    create_payload = {
        "title": "Evening Warm Ginger Milk",
        "category": "Hydration",
        "time_str": "08:15 PM",
        "instructions": "Drink warm milk before sleep.",
    }
    c_res = client.post("/api/v1/reminders", json=create_payload, headers=headers)
    assert c_res.status_code == 201
    rem_id = c_res.json()["data"]["id"]

    # 2. Mark completed
    up_res = client.put(f"/api/v1/reminders/{rem_id}", json={"completed": True}, headers=headers)
    assert up_res.status_code == 200
    assert up_res.json()["data"]["completed"] is True


def test_13_caregiver_notes(client):
    login_res = client.post("/api/v1/auth/login", json={"email": "caregiver@mindsetu.in", "password": "MindSetu@2026"})
    token = login_res.json()["data"]["access_token"]
    headers = {"Authorization": f"Bearer {token}"}

    # Post daily note
    payload = {
        "mood": "Calm & Cheerful",
        "mood_emoji": "😊",
        "sleep_quality": "Restful 8 hours",
        "appetite": "Finished breakfast",
        "behavioral_notes": "Smiled while looking at old photos",
        "clinical_observations": "Cooperative and peaceful",
    }
    res = client.post("/api/v1/notes", json=payload, headers=headers)
    assert res.status_code == 201
    assert res.json()["data"]["mood"] == "Calm & Cheerful"

    # List notes
    list_res = client.get("/api/v1/notes", headers=headers)
    assert list_res.status_code == 200
    assert len(list_res.json()["data"]) >= 1


def test_14_doctor_patient_access_and_reports(client):
    login_res = client.post("/api/v1/auth/login", json={"email": "doctor@mindsetu.in", "password": "MindSetu@2026"})
    token = login_res.json()["data"]["access_token"]
    headers = {"Authorization": f"Bearer {token}"}

    # 1. Get doctor patients registry
    reg_res = client.get("/api/v1/doctors/patients", headers=headers)
    assert reg_res.status_code == 200
    patients = reg_res.json()["data"]
    assert len(patients) >= 1
    patient_id = patients[0]["patient"]["id"]

    # 2. Get patient clinical details
    detail_res = client.get(f"/api/v1/doctors/patients/{patient_id}", headers=headers)
    assert detail_res.status_code == 200

    # 3. Get clinical insights
    ins_res = client.get(f"/api/v1/doctors/patients/{patient_id}/insights", headers=headers)
    assert ins_res.status_code == 200
    insights = ins_res.json()["data"]
    assert len(insights) >= 1
    assert "disclaimer" in insights[0]

    # 4. Generate report
    rep_res = client.get(f"/api/v1/doctors/patients/{patient_id}/reports", headers=headers)
    assert rep_res.status_code == 200
    report = rep_res.json()["data"]
    assert "cognitive_domain_trends" in report


def test_15_cultural_content_ner(client):
    # List all cultural content
    res = client.get("/api/v1/cultural")
    assert res.status_code == 200
    items = res.json()["data"]
    assert len(items) >= 8

    # Check 8 NER states metadata
    reg_res = client.get("/api/v1/cultural/regions/all")
    assert reg_res.status_code == 200
    states = reg_res.json()["data"]["states"]
    for state_id in ["assam", "meghalaya", "manipur", "nagaland", "mizoram", "arunachal", "tripura", "sikkim"]:
        assert state_id in states


def test_16_sync_push(client):
    login_res = client.post("/api/v1/auth/login", json={"email": "patient@mindsetu.in", "password": "MindSetu@2026"})
    token = login_res.json()["data"]["access_token"]
    headers = {"Authorization": f"Bearer {token}"}

    payload = {
        "client_id": "tablet-device-001",
        "items": [
            {
                "entity_type": "reminders",
                "entity_id": "rem-offline-01",
                "operation": "CREATE",
                "client_timestamp": datetime.now(timezone.utc).isoformat(),
                "payload": {
                    "title": "Offline Recorded Medication",
                    "category": "Medicine",
                    "time_str": "09:00 AM",
                    "completed": True,
                },
            }
        ],
    }
    res = client.post("/api/v1/sync/push", json=payload, headers=headers)
    assert res.status_code == 200
    data = res.json()["data"]
    assert data["synced_count"] == 1


def test_17_sync_pull(client):
    login_res = client.post("/api/v1/auth/login", json={"email": "patient@mindsetu.in", "password": "MindSetu@2026"})
    token = login_res.json()["data"]["access_token"]
    headers = {"Authorization": f"Bearer {token}"}

    res = client.get("/api/v1/sync/pull", headers=headers)
    assert res.status_code == 200
    data = res.json()["data"]
    assert "reminders" in data
    assert "memories" in data


def test_18_sync_status(client):
    login_res = client.post("/api/v1/auth/login", json={"email": "patient@mindsetu.in", "password": "MindSetu@2026"})
    token = login_res.json()["data"]["access_token"]
    headers = {"Authorization": f"Bearer {token}"}

    res = client.get("/api/v1/sync/status", headers=headers)
    assert res.status_code == 200
    data = res.json()["data"]
    assert "sync_attention_required" in data


def test_19_two_day_sync_detection(client):
    login_res = client.post("/api/v1/auth/login", json={"email": "patient@mindsetu.in", "password": "MindSetu@2026"})
    token = login_res.json()["data"]["access_token"]
    patient_id = login_res.json()["data"]["patient_id"]
    headers = {"Authorization": f"Bearer {token}"}

    # Artificially set last_synced_at to 3 days ago in database to simulate offline gap
    db = SessionLocal()
    pat = db.query(Patient).filter((Patient.id == patient_id) | (Patient.patient_code == patient_id)).first()
    pat.last_synced_at = datetime.now(timezone.utc) - timedelta(days=3)
    db.commit()
    db.close()

    # Query /sync/status -> must detect overdue and flag sync_attention_required
    status_res = client.get("/api/v1/sync/status", headers=headers)
    assert status_res.status_code == 200
    data = status_res.json()["data"]
    assert data["sync_attention_required"] is True
    assert data["alert_message"] is not None
    assert "Sync attention required" in data["alert_message"]


def test_20_invalid_and_unauthorized_requests(client):
    # 1. Invalid login
    bad_login = client.post("/api/v1/auth/login", json={"email": "unknown@mindsetu.in", "password": "wrong"})
    assert bad_login.status_code == 401

    # 2. Missing bearer token on protected endpoint
    no_auth = client.get("/api/v1/patients/me")
    assert no_auth.status_code == 401

    # 3. Invalid token
    fake_token_res = client.get("/api/v1/patients/me", headers={"Authorization": "Bearer invalid_token_123"})
    assert fake_token_res.status_code == 401
