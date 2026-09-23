import urllib.request
import json
import sys

BASE_URL = 'http://127.0.0.1:8000'

def request(method, path, body=None, token=None):
    url = f"{BASE_URL}{path}"
    headers = {'Content-Type': 'application/json', 'Accept': 'application/json'}
    if token:
        headers['Authorization'] = f"Bearer {token}"
    data = json.dumps(body).encode('utf-8') if body else None
    req = urllib.request.Request(url, data=data, headers=headers, method=method)
    try:
        with urllib.request.urlopen(req) as resp:
            content = resp.read().decode('utf-8')
            return resp.status, json.loads(content) if content else {}
    except urllib.error.HTTPError as e:
        content = e.read().decode('utf-8')
        return e.code, json.loads(content) if content else {}

def main():
    print("==================================================")
    print("MINDSETU PHASE 3: FASTAPI BACKEND INTEGRATION TEST")
    print("==================================================")
    
    # 1. Health Check
    status, res = request('GET', '/health')
    assert status == 200 and res.get('status') == 'ok', f"Health check failed: {res}"
    print("[PASS] 1. Backend Health Check: OK")

    # 2. Patient Auth
    status, res = request('POST', '/api/v1/auth/login', {'email': 'patient@mindsetu.in', 'password': 'MindSetu@2026'})
    assert status == 200 and 'access_token' in res['data'], f"Patient login failed: {res}"
    patient_token = res['data']['access_token']
    patient_id = res['data']['patient_id']
    print(f"[PASS] 2. Patient Login: OK (User: {res['data']['full_name']}, Role: {res['data']['role']})")

    # 3. Patient Dashboard
    status, res = request('GET', '/api/v1/patients/me/dashboard', token=patient_token)
    assert status == 200 and 'recent_activities' in res['data'], f"Patient dashboard failed: {res}"
    print(f"[PASS] 3. Patient Dashboard: OK ({len(res['data']['recent_activities'])} activities, {len(res['data']['todays_reminders'])} reminders)")

    # 4. Activities Catalog
    status, res = request('GET', '/api/v1/activities', token=patient_token)
    assert status == 200 and len(res['data']) >= 6, f"Activities list failed: {res}"
    print(f"[PASS] 4. Activities Catalog: OK ({len(res['data'])} activities available)")

    # 5. Submit Game Result (Tea Brewing Sequence)
    status, res = request('POST', '/api/v1/activities/results', {
        'activity_id': 'act-sequence',
        'score': 100,
        'accuracy': 100.0,
        'completion_time_seconds': 68,
        'moves_count': 4,
        'difficulty_level': 'gentle',
        'device_synced': True
    }, token=patient_token)
    assert status in (200, 201) and res['success'] is True, f"Submit activity result failed: {res}"
    res_id = res['data']['id']
    print(f"[PASS] 5. Submit Game Result: OK (Result ID: {res_id})")

    # 6. Reminders CRUD
    status, res = request('GET', '/api/v1/reminders', token=patient_token)
    assert status == 200 and len(res['data']) > 0, f"Get reminders failed: {res}"
    rem_id = res['data'][0]['id']
    status, update_res = request('PUT', f'/api/v1/reminders/{rem_id}', {'is_completed': True, 'verified_by_caregiver': True}, token=patient_token)
    assert status == 200, f"Update reminder failed: {update_res}"
    print(f"[PASS] 6. Reminders Read & Update: OK (Reminder: {res['data'][0]['title']})")

    # 7. Memories CRUD
    status, res = request('GET', '/api/v1/memories', token=patient_token)
    assert status == 200, f"Get memories failed: {res}"
    print(f"[PASS] 7. Memories Journal: OK ({len(res['data'])} memories accessible)")

    # 8. Caregiver Login & Notes
    status, res = request('POST', '/api/v1/auth/login', {'email': 'caregiver@mindsetu.in', 'password': 'MindSetu@2026'})
    assert status == 200, f"Caregiver login failed: {res}"
    cg_token = res['data']['access_token']
    status, note_res = request('POST', '/api/v1/notes', {
        'mood': 'Happy',
        'sleep_hours': 8.0,
        'appetite': 'Good',
        'behavior_notes': 'Father enjoyed morning tea and smiled warmly at Bihu memories.'
    }, token=cg_token)
    assert status in (200, 201) and note_res['success'] is True, f"Caregiver note failed: {note_res}"
    print("[PASS] 8. Caregiver Portal & Daily Note: OK (Mood logged: Happy, 8.0 hrs)")

    # 9. Doctor Login & Clinical Insights / Reports
    status, res = request('POST', '/api/v1/auth/login', {'email': 'doctor@mindsetu.in', 'password': 'MindSetu@2026'})
    assert status == 200, f"Doctor login failed: {res}"
    doc_token = res['data']['access_token']
    status, pats_res = request('GET', '/api/v1/doctors/patients', token=doc_token)
    assert status == 200 and len(pats_res['data']) > 0, f"Doctor patients failed: {pats_res}"
    target_patient_id = pats_res['data'][0]['patient']['id']
    status, ins_res = request('GET', f'/api/v1/doctors/patients/{target_patient_id}/insights', token=doc_token)
    assert status == 200, f"Doctor insights failed: {ins_res}"
    status, rep_res = request('GET', f'/api/v1/doctors/patients/{target_patient_id}/reports', token=doc_token)
    assert status == 200, f"Doctor reports failed: {rep_res}"
    print(f"[PASS] 9. Doctor Clinical Portal: OK (Patient: {pats_res['data'][0]['patient']['name']}, Insights count: {len(ins_res['data'])})")

    # 10. Offline Sync Engine (Push & Pull)
    status, sync_stat = request('GET', '/api/v1/sync/status', token=patient_token)
    assert status == 200, f"Sync status failed: {sync_stat}"
    sync_items = [
        {
            'entity_type': 'activity_result',
            'entity_id': 'res_offline_01',
            'operation': 'create',
            'payload': {
                'activity_id': 'act-matching',
                'score': 100,
                'accuracy': 1.0,
                'completion_time_seconds': 54
            }
        }
    ]
    status, push_res = request('POST', '/api/v1/sync/push', {'items': sync_items}, token=patient_token)
    assert status == 200 and push_res['success'] is True, f"Sync push failed: {push_res}"
    status, pull_res = request('GET', '/api/v1/sync/pull', token=patient_token)
    assert status == 200 and pull_res['success'] is True, f"Sync pull failed: {pull_res}"
    print("[PASS] 10. Offline Sync Push/Pull Engine: OK (Status: Synchronized)")

    print("==================================================")
    print("ALL 10 API & OFFLINE INTEGRATION TEST SUITES PASSED!")
    print("==================================================")

if __name__ == '__main__':
    main()
