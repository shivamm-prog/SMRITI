import json
import logging
import re
from typing import Optional, Dict, Any, Tuple
import httpx
from sqlalchemy.orm import Session

from app.core.config import settings
from app.models.patient import Patient
from app.schemas.voice import VoiceChatRequest, VoiceChatResponse, VoiceTranscriptionResponse

logger = logging.getLogger("mindsetu.voice")

WHITELISTED_INTENTS = {
    "activities",
    "reminders",
    "memories",
    "progress",
    "patientInfo",
    "changeLanguage",
    "greeting",
    "sos",
    "unknown",
}

LANGUAGE_NAMES = {
    "en": "English",
    "as": "Assamese",
    "hi": "Hindi",
    "ne": "Nepali",
    "mni": "Meitei (Manipuri)",
    "kha": "Khasi",
    "lus": "Mizo",
    "nag": "Nagamese",
    "brx": "Kokborok",
}

# Medical safety terms requiring redirection to healthcare professionals
MEDICAL_SAFETY_PATTERNS = [
    r"(do i have dementia|diagnos|alzheimer'?s test)",
    r"(prescribe|prescription|change medication|change medicine)",
    r"stop\s+(?:taking\s+)?(?:[a-z0-9\-_']+\s+)*(?:medicine|medication|pills|drugs|tablets)",
    r"cure\s+(?:[a-z0-9\-_']+\s+)*(?:dementia|alzheimer|memory loss)",
    r"(dosage|increase dose|decrease dose|overdose)",
    r"(heart attack|stroke|chest pain|paralysis|blood pressure emergency)",
]

# Diet & food safety terms ensuring non-medical claims
DIET_SAFETY_PATTERNS = [
    r"(cure|prevent|reverse)\s+(?:dementia|alzheimer)",
    r"(good for dementia|healthy for dementia|cure dementia with food|cure dementia with diet|can food cure|food cure)",
    r"(medical diet|prescribed diet|dementia diet)",
]


class VoiceService:
    @staticmethod
    def is_medical_question(text: str) -> bool:
        lower = text.lower()
        for pat in MEDICAL_SAFETY_PATTERNS:
            if re.search(pat, lower):
                return True
        return False

    @staticmethod
    def is_diet_safety_question(text: str) -> bool:
        lower = text.lower()
        for pat in DIET_SAFETY_PATTERNS:
            if re.search(pat, lower):
                return True
        return False

    @staticmethod
    def get_safe_diet_response(language: str) -> str:
        lang = (language or "en").lower()
        if lang.startswith("as"):
            return "এই আহাৰ আপোনাৰ দৈনিক খাদ্য পৰিকল্পনাৰ অংশ। আপোনাৰ স্বাস্থ্যৰ বাবে বিশেষ চিকিৎসা বা পথ্যৰ পৰামৰ্শ ল’বলৈ অনুগ্ৰহ কৰি আপোনাৰ চিকিৎসক বা শুশ্ৰূষাকাৰীৰ সৈতে কথা পাতক।"
        elif lang.startswith("hi"):
            return "यह भोजन आपकी दैनिक भोजन दिनचर्या का हिस्सा है। अपने स्वास्थ्य के लिए विशिष्ट चिकित्सीय आहार सलाह हेतु कृपया अपने डॉक्टर या देखभालकर्ता से परामर्श लें।"
        elif lang.startswith("ne"):
            return "यो खाना तपाईंको नियमित भोजन तालिकाको अंश हो। स्वास्थ्य सम्बन्धी चिकित्सकीय सल्लाहको लागि कृपया आफ्नो डाक्टर वा हेरचाहकर्तासँग परामर्श लिनुहोस्।"
        return "This meal is part of your planned food routine. For medical dietary advice specific to your health, please check with your caregiver or doctor."

    @staticmethod
    def get_safe_medical_response(language: str) -> str:
        lang = (language or "en").lower()
        if lang.startswith("as"):
            return "মই মাইণ্ডসেতুৰ দৈনিক সংগী, কোনো চিকিৎসক নহয়। ঔষধ সলনি কৰা বা কোনো ৰোগ নিৰ্ণয়ৰ বাবে অনুগ্ৰহ কৰি আপোনাৰ চিকিৎসক বা শুশ্ৰূষাকাৰীৰ সৈতে যোগাযোগ কৰক।"
        elif lang.startswith("hi"):
            return "मैं आपका दैनिक संज्ञानात्मक साथी हूँ, डॉक्टर नहीं। दवाइयों में बदलाव या चिकित्सा जांच के लिए कृपया अपने डॉक्टर या देखभालकर्ता से तुरंत परामर्श लें।"
        elif lang.startswith("ne"):
            return "म तपाईंको दैनिक साथी हुँ, डाक्टर होइन। कुनै पनि औषधि परिवर्तन वा स्वास्थ्य जाँचको लागि कृपया आफ्नो डाक्टर वा हेरचाहकर्तासँग परामर्श गर्नुहोस्।"
        return "I am your daily cognitive companion, not a doctor. For medical diagnoses, medication changes, or health advice, please consult your doctor or caregiver directly."

    @staticmethod
    def build_patient_context(db: Session, patient: Optional[Patient]) -> str:
        if not patient:
            return "Patient profile: Guest user."

        lines = [
            f"Patient name: {patient.name}",
            f"Region: {patient.region or 'Assam'}",
            f"Preferred language: {patient.preferred_language or 'Assamese'}",
        ]

        # Add reminders summary (titles, categories, times)
        try:
            if patient.reminders:
                rems = []
                for r in patient.reminders[:5]:
                    status_str = "Completed" if r.completed else "Pending"
                    rems.append(f"{r.title} ({r.category}, {r.time_str}, {status_str})")
                lines.append(f"Scheduled Reminders: {'; '.join(rems)}")
        except Exception:
            pass

        # Add recent cognitive streak/performance summary if available
        try:
            if patient.activity_results:
                total_results = len(patient.activity_results)
                recent = patient.activity_results[-3:]
                avg_acc = sum((r.accuracy or 0) for r in recent) / max(len(recent), 1)
                lines.append(f"Cognitive Activity: {total_results} total sessions completed, recent accuracy {avg_acc:.0f}%.")
        except Exception:
            pass

        return "\n".join(lines)

    @staticmethod
    def classify_local_intent(query: str) -> Tuple[str, str, Optional[int]]:
        """
        Fast, offline-safe keyword intent classifier aligned with MindSetu voice specs.
        Returns: (intent, default_reply_template_key, target_tab_index)
        """
        clean = query.lower().strip()

        # SOS
        if any(k in clean for k in ["help", "sos", "emergency", "danger", "সহায়", "বিপদ", "জৰুৰী", "मदद", "खतरा"]):
            return "sos", "sos", 0

        # Change language
        if any(k in clean for k in ["hindi", "assamese", "english", "nepali", "language", "भाषा", "बदलो", "সলনি"]):
            return "changeLanguage", "changeLanguage", None

        # Memories
        if any(k in clean for k in ["memory", "memories", "photo", "photos", "picture", "album", "স্মৃতি", "ছবি", "यादें", "तस्वीर"]):
            return "memories", "memories", 2

        # Activities / Games
        if any(k in clean for k in ["activity", "activities", "game", "games", "puzzle", "match", "exercise", "কাৰ্যকলাপ", "খেল", "गतिविधि", "खेल"]):
            return "activities", "activities", 1

        # Reminders / Medicine / Meals
        if any(k in clean for k in ["reminder", "reminders", "medicine", "pill", "tea", "walk", "meal", "food", "diet", "ঔষধ", "দৰব", "চাহ", "আহাৰ", "दवाई", "भोजन", "खाना"]):
            return "reminders", "reminders", 0

        # Progress / Score
        if any(k in clean for k in ["progress", "score", "streak", "accuracy", "performance", "প্ৰগতি", "স্কোৰ", "प्रगति", "स्कोर"]):
            return "progress", "progress", 3

        # Patient Info / Identity
        if any(k in clean for k in ["who am i", "my name", "patient id", "doctor", "caregiver", "নাম", "পৰিচয়", "पहचान", "मरीज"]):
            return "patientInfo", "patientInfo", 4

        # Greeting / Today's Schedule
        if any(k in clean for k in ["today", "schedule", "hello", "hi", "good morning", "নমস্কাৰ", "সুপ্ৰভাত", "नमस्ते", "सुप्रभात"]):
            return "greeting", "greeting", 0

        return "unknown", "unknown", None

    @staticmethod
    def generate_local_response(query: str, language: str, intent: str, patient: Optional[Patient] = None) -> str:
        lang = (language or "en").lower()
        name = patient.name if patient else "Bhaben"

        # Reminders context if available
        rem_count = len(patient.reminders) if patient and patient.reminders else 0
        rem_done = len([r for r in patient.reminders if r.completed]) if patient and patient.reminders else 0

        if intent == "activities":
            if lang.startswith("as"):
                return f"নিশ্চয় {name} ডাঙৰীয়া! আজিৰ শান্ত কাৰ্যকলাপবোৰ খুলিছো। আহক মন সতেজ কৰি ৰাখোঁ।"
            elif lang.startswith("hi"):
                return f"ज़रूर {name} जी! आज की शांत और मनोरंजक गतिविधियाँ खोल रहे हैं।"
            return f"Opening your gentle cognitive activities for today, {name}. Let us keep your mind active."

        elif intent == "reminders":
            clean_q = query.lower()
            if patient and patient.reminders:
                meal_rems = [r for r in patient.reminders if (r.category or "").lower() == "meal"]
                if any(k in clean_q for k in ["lunch", "দুপৰীয়া", "दोपहर"]):
                    lunch = next((r for r in meal_rems if "lunch" in (r.title or "").lower() or "1:15" in (r.time_str or "")), None)
                    if lunch:
                        if lang.startswith("as"):
                            return f"আজি আপোনাৰ দুপৰীয়াৰ আহাৰ হ’ল {lunch.title}, সময় {lunch.time_str}।"
                        elif lang.startswith("hi"):
                            return f"आज दोपहर का भोजन {lunch.title} है, समय {lunch.time_str}।"
                        return f"Your lunch today is {lunch.title} at {lunch.time_str}."
                if any(k in clean_q for k in ["next meal", "পৰৱৰ্তী আহাৰ", "अगला भोजन", "अगला खाना"]):
                    pending_meal = next((r for r in meal_rems if not r.completed), meal_rems[0] if meal_rems else None)
                    if pending_meal:
                        if lang.startswith("as"):
                            return f"আপোনাৰ পৰৱৰ্তী আহাৰ হ’ল {pending_meal.title}, সময় {pending_meal.time_str}।"
                        elif lang.startswith("hi"):
                            return f"आपका अगला भोजन {pending_meal.title} है, समय {pending_meal.time_str}।"
                        return f"Your next meal is {pending_meal.title} at {pending_meal.time_str}."

            if lang.startswith("as"):
                return f"আপোনাৰ আজিৰ সোঁৱৰণীসমূহ: {rem_count} টাৰ ভিতৰত {rem_done} টা সম্পন্ন হৈছে। ঔষধ আৰু চাহৰ সময় মনত ৰাখিব।"
            elif lang.startswith("hi"):
                return f"आज के अनुस्मारक: {rem_count} में से {rem_done} पूरे हो चुके हैं। समय पर दवाई और भोजन लें।"
            return f"Viewing your reminders, {name}. You have {rem_count - rem_done} pending reminders scheduled for today."

        elif intent == "memories":
            if lang.startswith("as"):
                return f"আপোনাৰ মৰমৰ পুৰণি স্মৃতি আৰু কাজিৰঙাৰ ফটোবোৰ উলিয়াইছো। আহক একেলগে মনত পেলাওঁ।"
            elif lang.startswith("hi"):
                return "आपकी प्रिय पुरानी यादें और तस्वीरें खोल रहे हैं। आइए साथ मिलकर यादें ताज़ा करें।"
            return "Opening your cherished memories album. Let us look at your family and travel moments together."

        elif intent == "progress":
            if lang.startswith("as"):
                return f"আপুনি বৰ সুন্দৰভাৱে আগবাঢ়িছে, {name}! আপোনাৰ স্মৃতিৰ অনুশীলন অব্যাহত ৰাখক।"
            elif lang.startswith("hi"):
                return f"बहुत बढ़िया, {name} जी! आपकी नियमित प्रगति बहुत अच्छी है।"
            return f"You are doing wonderfully, {name}! Your regular practice is keeping your mind sharp."

        elif intent == "patientInfo":
            pid = patient.patient_code if (patient and patient.patient_code) else "MS-ASSAM-001"
            if lang.startswith("as"):
                return f"আপুনি শ্ৰীযুত {name}। আপোনাৰ মাইণ্ডসেতু ৰোগী নম্বৰ হ’ল {pid}। আপোনাৰ শুশ্ৰূষাকাৰী সংযুক্ত হৈ আছে।"
            elif lang.startswith("hi"):
                return f"आप {name} हैं। आपका माइंडसेतु पेशेंट आईडी {pid} है।"
            return f"You are {name}, and your MindSetu ID is {pid}. Your caregiver is connected."

        elif intent == "greeting":
            if lang.startswith("as"):
                return f"সুপ্ৰভাত {name} ডাঙৰীয়া! আজি আপোনাৰ দৈনিক কাম আৰু মন শান্ত কৰা কাৰ্যকলাপ সাজু হৈ আছে।"
            elif lang.startswith("hi"):
                return f"सुप्रभात {name} जी! आज के आपके दैनिक कार्य और गतिविधियाँ तैयार हैं।"
            return f"Good day, {name}! You have gentle routines and engaging activities scheduled for today."

        elif intent == "sos":
            if lang.startswith("as"):
                return "শান্ত হওক। আমি তৎক্ষণাৎ আপোনাৰ শুশ্ৰূষাকাৰী আৰু জৰুৰীকালীন সহায়ক অৱগত কৰি আছো।"
            elif lang.startswith("hi"):
                return "शांत रहें। हम तुरंत आपकी देखभालकर्ता और आपातकालीन संपर्कों को सूचित कर रहे हैं।"
            return "Stay calm. We are alerting your caregiver and emergency contacts immediately."

        elif intent == "changeLanguage":
            if lang.startswith("as"):
                return "ভাষা অসমীয়ালৈ সলনি কৰা হৈছে।"
            elif lang.startswith("hi"):
                return "भाषा बदलकर हिन्दी कर दी गई है।"
            return "Language preference updated."

        # Default fallback
        if lang.startswith("as"):
            return f"মই আপোনাৰ কথা শুনিলোঁ: \"{query}\"। আপুনি আজিৰ কাৰ্যকলাপ, সোঁৱৰণী বা পুৰণি স্মৃতিৰ বিষয়ে মোক সুধিব পাৰে।"
        elif lang.startswith("hi"):
            return f"मैंने सुना: \"{query}\"। आप मुझसे आज की गतिविधियों, दवाइयों या पुरानी यादों के बारे में पूछ सकते हैं।"
        return f"I heard: \"{query}\". You can ask about your activities, reminders, meals, or memory photos."

    @classmethod
    async def chat(
        cls,
        db: Session,
        request: VoiceChatRequest,
        patient: Optional[Patient] = None,
    ) -> VoiceChatResponse:
        query = request.query.strip()
        lang_code = (request.language or "en").lower().split("-")[0]
        region = request.region or (patient.region if patient else "Assam")
        lang_name = LANGUAGE_NAMES.get(lang_code, "English")

        # 1. First line of defense: Check medical and diet safety boundaries
        if cls.is_medical_question(query):
            logger.info("Voice query triggered medical safety boundary")
            return VoiceChatResponse(
                transcript=query,
                response=cls.get_safe_medical_response(lang_code),
                language=lang_code,
                intent="reminders",
                success=True,
            )

        if cls.is_diet_safety_question(query):
            logger.info("Voice query triggered diet safety boundary")
            return VoiceChatResponse(
                transcript=query,
                response=cls.get_safe_diet_response(lang_code),
                language=lang_code,
                intent="reminders",
                success=True,
            )

        # 2. Local fallback if GROQ_API_KEY is not configured
        if not settings.GROQ_API_KEY or settings.GROQ_API_KEY.strip() == "":
            logger.info("GROQ_API_KEY is not configured. Using intelligent local fallback.")
            intent, _, _ = cls.classify_local_intent(query)
            local_reply = cls.generate_local_response(query, lang_code, intent, patient)
            return VoiceChatResponse(
                transcript=query,
                response=local_reply,
                language=lang_code,
                intent=intent,
                success=True,
            )

        # 3. Call Groq API via httpx
        patient_context = cls.build_patient_context(db, patient)
        system_prompt = (
            "You are SMRITI, an elderly cognitive assistance companion for the MindSetu platform.\n"
            "You communicate respectfully, gently, and simply with an elderly user.\n\n"
            f"Patient language: {lang_name} ({lang_code})\n"
            f"Patient region: {region}\n"
            f"Context:\n{patient_context}\n\n"
            f"IMPORTANT RULES:\n"
            f"1. Use short, simple, easy-to-understand sentences.\n"
            f"2. Your response MUST be in {lang_name} ({lang_code}) whenever appropriate.\n"
            f"3. Help the patient with: daily activities, reminders, meals/diet info already in context, memories, progress, and gentle reassurance.\n"
            f"4. SMRITI is an elderly cognitive companion, NOT a doctor or diagnostic system. NEVER diagnose dementia or illnesses, NEVER prescribe or change medications, and NEVER claim activities or diet cure dementia. For medical advice beyond scheduled app reminders, advise contacting caregiver or doctor.\n"
            f"5. OUTPUT FORMAT: Respond ONLY with a valid JSON object with keys 'intent' and 'response'.\n"
            f"Valid intents are strictly: activities, reminders, memories, progress, patientInfo, changeLanguage, greeting, sos, unknown.\n"
            "Example format: {\"intent\": \"activities\", \"response\": \"Your next activity is the gentle memory game.\"}\n"
            "Do not add any Markdown fences or backticks."
        )

        groq_url = f"{settings.GROQ_BASE_URL.rstrip('/')}/chat/completions"
        headers = {
            "Authorization": f"Bearer {settings.GROQ_API_KEY}",
            "Content-Type": "application/json",
        }
        payload = {
            "model": settings.GROQ_CHAT_MODEL,
            "messages": [
                {"role": "system", "content": system_prompt},
                {"role": "user", "content": query},
            ],
            "temperature": 0.3,
            "max_tokens": 250,
        }

        try:
            async with httpx.AsyncClient(timeout=10.0) as client:
                res = await client.post(groq_url, headers=headers, json=payload)
                if res.status_code == 200:
                    data = res.json()
                    raw_content = data["choices"][0]["message"]["content"].strip()

                    # Strip possible ```json ``` fences
                    clean_content = raw_content
                    if clean_content.startswith("```"):
                        clean_content = re.sub(r"^```(?:json)?\s*", "", clean_content)
                        clean_content = re.sub(r"\s*```$", "", clean_content).strip()

                    parsed_intent = "unknown"
                    parsed_response = clean_content

                    try:
                        parsed_json = json.loads(clean_content)
                        if isinstance(parsed_json, dict):
                            intent_candidate = str(parsed_json.get("intent", "unknown")).strip()
                            if intent_candidate in WHITELISTED_INTENTS:
                                parsed_intent = intent_candidate
                            else:
                                parsed_intent, _, _ = cls.classify_local_intent(query)
                            parsed_response = str(parsed_json.get("response", "")).strip() or clean_content
                    except Exception:
                        parsed_intent, _, _ = cls.classify_local_intent(query)

                    return VoiceChatResponse(
                        transcript=query,
                        response=parsed_response,
                        language=lang_code,
                        intent=parsed_intent,
                        success=True,
                    )
                else:
                    logger.warning("Groq Chat API returned status %s: fallback to local", res.status_code)
        except Exception as e:
            logger.warning("Groq API error or timeout: %s. Falling back to local response.", str(e))

        # 4. Fallback on Groq error/timeout
        intent, _, _ = cls.classify_local_intent(query)
        local_reply = cls.generate_local_response(query, lang_code, intent, patient)
        return VoiceChatResponse(
            transcript=query,
            response=local_reply,
            language=lang_code,
            intent=intent,
            success=True,
        )

    @classmethod
    async def transcribe(
        cls,
        audio_bytes: bytes,
        filename: str = "audio.wav",
        content_type: str = "audio/wav",
        language: Optional[str] = None,
    ) -> VoiceTranscriptionResponse:
        if not audio_bytes or len(audio_bytes) == 0:
            return VoiceTranscriptionResponse(
                transcript="",
                detected_language=language,
                success=False,
            )

        # Enforce maximum audio length / size (e.g. 10MB)
        if len(audio_bytes) > 10 * 1024 * 1024:
            raise ValueError("Audio recording exceeds size limit of 10MB")

        if not settings.GROQ_API_KEY or settings.GROQ_API_KEY.strip() == "":
            logger.warning("GROQ_API_KEY is not configured for transcription.")
            return VoiceTranscriptionResponse(
                transcript="",
                detected_language=language,
                success=False,
            )

        groq_url = f"{settings.GROQ_BASE_URL.rstrip('/')}/audio/transcriptions"
        headers = {
            "Authorization": f"Bearer {settings.GROQ_API_KEY}",
        }

        files = {
            "file": (filename, audio_bytes, content_type),
        }
        data: Dict[str, Any] = {
            "model": settings.GROQ_STT_MODEL,
        }
        if language:
            lang_code = language.lower().split("-")[0]
            data["language"] = lang_code

        try:
            async with httpx.AsyncClient(timeout=15.0) as client:
                res = await client.post(groq_url, headers=headers, files=files, data=data)
                if res.status_code == 200:
                    resp_json = res.json()
                    transcript = resp_json.get("text", "").strip()
                    return VoiceTranscriptionResponse(
                        transcript=transcript,
                        detected_language=language,
                        success=True,
                    )
                else:
                    logger.warning("Groq STT returned status %s", res.status_code)
                    return VoiceTranscriptionResponse(
                        transcript="",
                        detected_language=language,
                        success=False,
                    )
        except Exception as e:
            logger.warning("Groq STT transcription error: %s", str(e))
            return VoiceTranscriptionResponse(
                transcript="",
                detected_language=language,
                success=False,
            )
