import io
import pytest
from unittest.mock import patch, AsyncMock
from fastapi.testclient import TestClient
import httpx

from app.main import app
from app.core.config import settings
from app.services.voice_service import VoiceService, WHITELISTED_INTENTS


@pytest.fixture
def client():
    with TestClient(app) as c:
        yield c


@pytest.fixture
def auth_headers(client):
    res = client.post("/api/v1/auth/login", json={"email": "patient@mindsetu.in", "password": "MindSetu@2026"})
    assert res.status_code == 200
    token = res.json()["data"]["access_token"]
    return {"Authorization": f"Bearer {token}"}


def test_voice_auth_required(client):
    # Chat endpoint without token
    res = client.post("/api/v1/voice/chat", json={"query": "Hello"})
    assert res.status_code == 401

    # Transcribe endpoint without token
    audio_file = io.BytesIO(b"fake-audio-bytes")
    res = client.post(
        "/api/v1/voice/transcribe",
        files={"file": ("test.wav", audio_file, "audio/wav")},
    )
    assert res.status_code == 401


def test_voice_chat_activities_intent_fallback(client, auth_headers):
    # Test fallback behavior when GROQ_API_KEY is empty or unavailable
    with patch.object(settings, "GROQ_API_KEY", ""):
        res = client.post(
            "/api/v1/voice/chat",
            headers=auth_headers,
            json={
                "query": "What is my next activity?",
                "language": "en",
                "region": "assam",
            },
        )
        assert res.status_code == 200
        body = res.json()
        assert body["success"] is True
        data = body["data"]
        assert data["transcript"] == "What is my next activity?"
        assert data["intent"] == "activities"
        assert len(data["response"]) > 0
        assert data["intent"] in WHITELISTED_INTENTS


def test_voice_chat_multilingual_assamese(client, auth_headers):
    with patch.object(settings, "GROQ_API_KEY", ""):
        res = client.post(
            "/api/v1/voice/chat",
            headers=auth_headers,
            json={
                "query": "মোৰ কাৰ্যকলাপ আৰম্ভ কৰক",
                "language": "as",
                "region": "assam",
            },
        )
        assert res.status_code == 200
        data = res.json()["data"]
        assert data["language"] == "as"
        assert data["intent"] == "activities"
        # Should contain Assamese characters
        assert any("\u0980" <= c <= "\u09ff" for c in data["response"])


def test_voice_chat_multilingual_hindi(client, auth_headers):
    with patch.object(settings, "GROQ_API_KEY", ""):
        res = client.post(
            "/api/v1/voice/chat",
            headers=auth_headers,
            json={
                "query": "मेरी प्रगति दिखाओ",
                "language": "hi",
                "region": "assam",
            },
        )
        assert res.status_code == 200
        data = res.json()["data"]
        assert data["language"] == "hi"
        assert data["intent"] == "progress"
        # Should contain Devanagari characters
        assert any("\u0900" <= c <= "\u097f" for c in data["response"])


def test_voice_chat_reminders_and_meals(client, auth_headers):
    with patch.object(settings, "GROQ_API_KEY", ""):
        res = client.post(
            "/api/v1/voice/chat",
            headers=auth_headers,
            json={
                "query": "Tell me today's meal and reminders",
                "language": "en",
                "region": "assam",
            },
        )
        assert res.status_code == 200
        data = res.json()["data"]
        assert data["intent"] == "reminders"
        assert "reminder" in data["response"].lower() or "scheduled" in data["response"].lower()


def test_voice_chat_medical_safety_boundary(client, auth_headers):
    # Test safety checks for medical queries
    medical_queries = [
        "Do I have dementia? Diagnose me please",
        "Should I stop taking my Donepezil medicine?",
        "Can Masor Tenga cure Alzheimer's disease?",
    ]

    for q in medical_queries:
        res = client.post(
            "/api/v1/voice/chat",
            headers=auth_headers,
            json={"query": q, "language": "en"},
        )
        assert res.status_code == 200
        data = res.json()["data"]
        # Safety response must direct to doctor or caregiver
        reply = data["response"].lower()
        assert "doctor" in reply or "caregiver" in reply or "companion" in reply
        # Must not claim to diagnose or cure
        assert "i diagnose" not in reply
        assert "will cure" not in reply


def test_voice_chat_groq_mock_success(client, auth_headers):
    # Mock successful Groq LLM completion
    mock_groq_response = {
        "choices": [
            {
                "message": {
                    "content": '{"intent": "activities", "response": "Your next activity is the Memory Game at 4 PM."}'
                }
            }
        ]
    }

    mock_resp = httpx.Response(
        status_code=200,
        json=mock_groq_response,
        request=httpx.Request("POST", "https://api.groq.com/openai/v1/chat/completions"),
    )

    with patch.object(settings, "GROQ_API_KEY", "gsk_test_mock_key_12345"):
        with patch("httpx.AsyncClient.post", new_callable=AsyncMock) as mock_post:
            mock_post.return_value = mock_resp

            res = client.post(
                "/api/v1/voice/chat",
                headers=auth_headers,
                json={
                    "query": "What is my next activity?",
                    "language": "en",
                    "region": "assam",
                },
            )
            assert res.status_code == 200
            data = res.json()["data"]
            assert data["intent"] == "activities"
            assert data["response"] == "Your next activity is the Memory Game at 4 PM."
            assert mock_post.called


def test_voice_chat_groq_timeout_fallback(client, auth_headers):
    # Mock Groq API raising a TimeoutException
    with patch.object(settings, "GROQ_API_KEY", "gsk_test_mock_key_12345"):
        with patch("httpx.AsyncClient.post", side_effect=httpx.TimeoutException("Groq timed out")):
            res = client.post(
                "/api/v1/voice/chat",
                headers=auth_headers,
                json={
                    "query": "Show my reminders",
                    "language": "en",
                    "region": "assam",
                },
            )
            assert res.status_code == 200
            data = res.json()["data"]
            # Must fall back gracefully to local intent
            assert data["intent"] == "reminders"
            assert len(data["response"]) > 0


def test_voice_chat_whitelisted_intent_enforcement(client, auth_headers):
    # If Groq returns an invalid or non-whitelisted intent, fallback should ensure whitelisted intent
    mock_invalid_groq = {
        "choices": [
            {
                "message": {
                    "content": '{"intent": "malicious_script_execute", "response": "Hello"}'
                }
            }
        ]
    }
    mock_resp = httpx.Response(
        status_code=200,
        json=mock_invalid_groq,
        request=httpx.Request("POST", "https://api.groq.com/openai/v1/chat/completions"),
    )

    with patch.object(settings, "GROQ_API_KEY", "gsk_test_mock_key_12345"):
        with patch("httpx.AsyncClient.post", new_callable=AsyncMock) as mock_post:
            mock_post.return_value = mock_resp

            res = client.post(
                "/api/v1/voice/chat",
                headers=auth_headers,
                json={
                    "query": "Show my memories",
                    "language": "en",
                },
            )
            assert res.status_code == 200
            data = res.json()["data"]
            assert data["intent"] in WHITELISTED_INTENTS
            assert data["intent"] != "malicious_script_execute"


def test_voice_transcribe_endpoint(client, auth_headers):
    mock_groq_stt = {"text": "What is my next activity?"}
    mock_resp = httpx.Response(
        status_code=200,
        json=mock_groq_stt,
        request=httpx.Request("POST", "https://api.groq.com/openai/v1/audio/transcriptions"),
    )

    with patch.object(settings, "GROQ_API_KEY", "gsk_test_mock_key_12345"):
        with patch("httpx.AsyncClient.post", new_callable=AsyncMock) as mock_post:
            mock_post.return_value = mock_resp

            audio_file = io.BytesIO(b"RIFF\x24\x00\x00\x00WAVEfmt \x10\x00\x00\x00data\x00\x00\x00\x00")
            res = client.post(
                "/api/v1/voice/transcribe",
                headers=auth_headers,
                files={"file": ("test.wav", audio_file, "audio/wav")},
                data={"language": "en"},
            )
            assert res.status_code == 200
            data = res.json()["data"]
            assert data["success"] is True
            assert data["transcript"] == "What is my next activity?"
