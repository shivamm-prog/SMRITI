from datetime import datetime, timezone, timedelta
from sqlalchemy.orm import Session
from app.models.user import User, UserRole
from app.models.patient import Patient
from app.models.caregiver import Caregiver
from app.models.doctor import Doctor
from app.models.activity import Activity
from app.models.activity_result import ActivityResult
from app.models.memory import Memory
from app.models.reminder import Reminder
from app.models.daily_note import DailyNote
from app.models.cultural_content import CulturalContent
from app.models.sync import ClientSyncState
from app.core.security import get_password_hash


def seed_database(db: Session):
    """Seed initial development data safely if empty."""
    # 1. Seed Activities
    if db.query(Activity).count() == 0:
        activities_data = [
            Activity(
                id="act-memory-recall",
                type="Memory Recall",
                title="Familiar Places & Memories",
                category="Memory Recall",
                difficulty="Gentle & Calming",
                estimated_minutes="3–5 mins",
                icon="Brain",
                color="#2563EB",
                description="Look at peaceful pictures of our beautiful North East and remember their stories.",
                instructions="Look closely at the picture. Take all the time you need. Then tap the answer that feels right.",
                config_data={
                    "total_questions": 3,
                    "landmarks": ["Kaziranga National Park", "Living Root Bridge", "Ujjayanta Palace"],
                },
            ),
            Activity(
                id="act-matching",
                type="Matching",
                title="Cultural Pairs of the Hills",
                category="Matching",
                difficulty="Relaxed & Pleasant",
                estimated_minutes="4 mins",
                icon="Sparkles",
                color="#0D9488",
                description="Match familiar traditional objects and cultural treasures with their pairs.",
                instructions="Tap two cards to reveal them. Find the pairs that belong together.",
                config_data={"total_pairs": 6},
            ),
            Activity(
                id="act-sequence",
                type="Sequence",
                title="Making Morning Assam Tea",
                category="Sequence",
                difficulty="Very Gentle",
                estimated_minutes="3 mins",
                icon="ListOrdered",
                color="#7C3AED",
                description="Arrange the daily steps of brewing a comforting, warm cup of morning tea.",
                instructions="Tap the steps in the order you would do them in your kitchen.",
                config_data={"steps_count": 4},
            ),
            Activity(
                id="act-attention",
                type="Attention",
                title="Gentle Nature Spotting",
                category="Attention",
                difficulty="Gentle Focus",
                estimated_minutes="3 mins",
                icon="Eye",
                color="#0284C7",
                description="Gently look across a soothing garden scene and spot peaceful nature items.",
                instructions="Look for the target item shown at the top. Tap it gently when spotted.",
                config_data={"rounds_count": 3},
            ),
            Activity(
                id="act-recognition",
                type="Recognition",
                title="Instruments of the North East",
                category="Recognition",
                difficulty="Comforting & Musical",
                estimated_minutes="3 mins",
                icon="Music",
                color="#D97706",
                description="Listen to the memory of traditional melodies and identify the traditional instrument.",
                instructions="Read the gentle clue and tap the musical instrument you recognise.",
                config_data={"instruments_count": 3},
            ),
            Activity(
                id="act-language",
                type="Language",
                title="Familiar Words & Proverbs",
                category="Language",
                difficulty="Gentle Word Fun",
                estimated_minutes="3 mins",
                icon="BookOpen",
                color="#059669",
                description="Connect comforting everyday words and positive proverbs with their meanings.",
                instructions="Read the greeting or word and select the gentle meaning that matches.",
                config_data={"words_count": 3},
            ),
        ]
        db.add_all(activities_data)
        db.commit()

    # 2. Seed Cultural Content (8 NER States)
    if db.query(CulturalContent).count() == 0:
        cultural_data = [
            CulturalContent(
                region="assam",
                language="Assamese",
                category="food",
                title="Masor Tenga (Sour Fish Curry)",
                content="A soothing, light sour fish stew made with fresh garden tomatoes, elephant apple (ou tenga), and fresh herbs.",
                difficulty="Gentle",
                tags=["Food", "Assam", "Comfort"],
            ),
            CulturalContent(
                region="assam",
                language="Assamese",
                category="festival",
                title="Rongali Bihu",
                content="The joyful spring festival celebrating the Assamese New Year, marked by dhol beats, pepa melodies, and weaving new Gamusas.",
                difficulty="Gentle",
                tags=["Festival", "Spring", "Assam"],
            ),
            CulturalContent(
                region="meghalaya",
                language="Khasi",
                category="landmark",
                title="Living Root Bridges of Cherrapunji",
                content="Ancient bio-engineering marvels hand-woven across generations from living Ficus elastica tree roots over pristine rivers.",
                difficulty="Gentle",
                tags=["Landmark", "Meghalaya", "Nature"],
            ),
            CulturalContent(
                region="manipur",
                language="Meitei (Manipuri)",
                category="landmark",
                title="Loktak Lake & Floating Phumdis",
                content="The largest freshwater lake in the North East, famous for circular floating biomass islands and the endangered Sangai deer.",
                difficulty="Gentle",
                tags=["Landmark", "Manipur", "Lake"],
            ),
            CulturalContent(
                region="nagaland",
                language="Nagamese",
                category="festival",
                title="Hornbill Festival",
                content="The grand Festival of Festivals held in Kisama heritage village, showcasing the unity, music, and traditions of all 16 Naga tribes.",
                difficulty="Gentle",
                tags=["Festival", "Nagaland", "Heritage"],
            ),
            CulturalContent(
                region="mizoram",
                language="Mizo",
                category="music",
                title="Cheraw Bamboo Dance",
                content="A graceful traditional rhythm where dancers step in and out of rhythmic clapping bamboo poles to celebrate harvest seasons.",
                difficulty="Gentle",
                tags=["Music", "Mizoram", "Dance"],
            ),
            CulturalContent(
                region="arunachal",
                language="English",
                category="landmark",
                title="Tawang Monastery",
                content="The second-largest monastery in the world, founded in the 17th century among snow-clad Himalayan mountain peaks.",
                difficulty="Gentle",
                tags=["Landmark", "Arunachal", "Spiritual"],
            ),
            CulturalContent(
                region="tripura",
                language="Bengali",
                category="landmark",
                title="Ujjayanta Palace",
                content="A neoclassical white royal palace set beside twin lakes in Agartala, named by poet Rabindranath Tagore.",
                difficulty="Gentle",
                tags=["Landmark", "Tripura", "History"],
            ),
            CulturalContent(
                region="sikkim",
                language="Nepali",
                category="food",
                title="Steamed Momos & Sel Roti",
                content="Comforting hot steamed dumplings served with herbal soup, paired with traditional golden ring-shaped sweet rice bread.",
                difficulty="Gentle",
                tags=["Food", "Sikkim", "Comfort"],
            ),
        ]
        db.add_all(cultural_data)
        db.commit()

    # 3. Seed Users (Doctor, Caregiver, Patient)
    if db.query(User).count() == 0:
        default_pwd_hash = get_password_hash("MindSetu@2026")

        # Doctor
        doc_user = User(
            email="doctor@mindsetu.in",
            hashed_password=default_pwd_hash,
            full_name="Dr. Debabrata Sarma",
            role=UserRole.DOCTOR,
        )
        db.add(doc_user)
        db.flush()

        doctor = Doctor(
            user_id=doc_user.id,
            name="Dr. Debabrata Sarma",
            qualification="MD, Geriatric Medicine & Cognitive Health",
            hospital="Guwahati Neurological & Senior Wellness Institute",
            license_number="NMC-NER-44821",
        )
        db.add(doctor)
        db.flush()

        # Caregiver
        cg_user = User(
            email="caregiver@mindsetu.in",
            hashed_password=default_pwd_hash,
            full_name="Anamika Borah",
            role=UserRole.CAREGIVER,
        )
        db.add(cg_user)
        db.flush()

        caregiver = Caregiver(
            user_id=cg_user.id,
            name="Anamika Borah",
            phone="+91 94350 12345",
            relationship="Daughter & Primary Caregiver",
        )
        db.add(caregiver)
        db.flush()

        # Patient
        pat_user = User(
            email="patient@mindsetu.in",
            hashed_password=default_pwd_hash,
            full_name="Bhaben Borah",
            role=UserRole.PATIENT,
        )
        db.add(pat_user)
        db.flush()

        patient = Patient(
            user_id=pat_user.id,
            patient_code="MS-ASSAM-001",
            name="Bhaben Borah",
            age=72,
            dob="1954-04-14",
            gender="Male",
            region="assam",
            preferred_language="Assamese",
            cultural_preferences={
                "activities": ["Morning tea on the veranda", "Gardening & caring for plants"],
                "foods": ["Fresh Masor Tenga", "Soft Pitha with jaggery"],
                "music": ["Gentle Bihu songs & Pepa"],
            },
            cognitive_stage="Mild Memory Support",
            emergency_contact_name="Anamika Borah (Daughter)",
            emergency_contact_phone="+91 94350 12345",
            emergency_contact_relation="Daughter",
            primary_caregiver_id=caregiver.id,
            primary_doctor_id=doctor.id,
            last_synced_at=datetime.now(timezone.utc),
            sync_attention_required=False,
        )
        db.add(patient)
        db.flush()

        # Update caregiver assigned patient
        caregiver.assigned_patient_id = patient.id

        # Seed Reminders for Bhaben
        rems = [
            Reminder(
                patient_id=patient.id,
                title="Morning Blood Pressure & Memory Vitamin",
                category="Medicine",
                time_str="08:30 AM",
                instructions="Take 1 tablet with warm water after light breakfast.",
                completed=True,
                completed_at=datetime.now(timezone.utc) - timedelta(hours=2),
                verified_by_caregiver=True,
            ),
            Reminder(
                patient_id=patient.id,
                title="Warm Ginger & Lemongrass Tea",
                category="Hydration",
                time_str="11:00 AM",
                instructions="Sip a warm cup of herbal tea and rest in the veranda.",
                completed=False,
                verified_by_caregiver=False,
            ),
            Reminder(
                patient_id=patient.id,
                title="Wholesome Lunch with Masor Tenga",
                category="Meal",
                time_str="01:15 PM",
                instructions="Fresh steamed rice and gentle fish broth prepared by Anamika.",
                completed=False,
                verified_by_caregiver=False,
            ),
            Reminder(
                patient_id=patient.id,
                title="Gentle Garden Stroll with Family",
                category="Daily Activity",
                time_str="04:45 PM",
                instructions="15-minute peaceful stroll on the lawn to admire the marigolds.",
                completed=False,
                verified_by_caregiver=False,
            ),
        ]
        db.add_all(rems)

        # Seed Memories
        mems = [
            Memory(
                patient_id=patient.id,
                title="Rongali Bihu with Grandchildren",
                memory_date="April 14, 2024",
                place="Tezpur Family Courtyard, Assam",
                people="Anamika (Daughter), Joy (Grandson), Parishmita (Granddaughter)",
                description="We sat in the courtyard wearing our festive Muga Gamusa. Joy danced the Bihu steps with the dhol beat, and we enjoyed freshly baked Til Pitha and warm tea together.",
                photo_url="🌾 🪕 👨‍👩‍👧‍👦",
                tags=["Family", "Bihu", "Festive"],
                recall_question="Who was playing the small Bihu drum in the courtyard?",
                recall_answer="Joy (Your grandson)",
                recall_hint="Your cheerful 10-year-old grandson wearing a silk waistcoat.",
            ),
            Memory(
                patient_id=patient.id,
                title="Visit to Kaziranga National Park",
                memory_date="November 2022",
                place="Kohora Range, Kaziranga",
                people="Late Wife (Nirmala) and Bhaben",
                description="The golden morning mist was rising over the elephant grass. We spotted a mother rhino and her gentle calf grazing near the quiet stream. Nirmala held my hand and smiled.",
                photo_url="🦏 🌄 🌿",
                tags=["Nature", "Kaziranga", "Peaceful"],
                recall_question="What beautiful animal did you and Nirmala watch near the quiet stream?",
                recall_answer="A mother one-horned rhinoceros and her gentle calf",
                recall_hint="The majestic animal Assam is known for across the world.",
            ),
        ]
        db.add_all(mems)

        # Seed Daily Notes
        notes = [
            DailyNote(
                patient_id=patient.id,
                caregiver_id=caregiver.id,
                author_name="Anamika Borah (Caregiver)",
                mood="Calm & Happy",
                mood_emoji="😊",
                sleep_quality="Good (7.5 hours uninterrupted)",
                appetite="Normal — enjoyed soft pitha & warm tea",
                behavioral_notes="Pleasant and conversational. Talked about old Tezpur memories.",
                clinical_observations="Smiled warmly during morning tea. Completed his BP pill without reluctance.",
                note_date="Today, 8:40 AM",
            ),
            DailyNote(
                patient_id=patient.id,
                caregiver_id=caregiver.id,
                author_name="Anamika Borah (Caregiver)",
                mood="Slightly Tired in Evening",
                mood_emoji="😌",
                sleep_quality="Mild afternoon nap (40 mins)",
                appetite="Finished full dinner of steamed rice and dal",
                behavioral_notes="Needed gentle encouragement around 5 PM to recall where his spectacles were.",
                clinical_observations="Played the Nature Spotting activity happily.",
                note_date="Yesterday, 8:15 PM",
            ),
        ]
        db.add_all(notes)

        # Seed Activity Results
        results = [
            ActivityResult(
                patient_id=patient.id,
                activity_id="act-memory-recall",
                score=100,
                accuracy=1.0,
                duration_seconds=142,
                difficulty="Gentle",
                completed_at=datetime.now(timezone.utc) - timedelta(hours=3),
                feedback="Splendid memory! You recognised all serene landmarks effortlessly.",
            ),
            ActivityResult(
                patient_id=patient.id,
                activity_id="act-matching",
                score=85,
                accuracy=0.85,
                duration_seconds=180,
                difficulty="Gentle",
                completed_at=datetime.now(timezone.utc) - timedelta(days=1),
                feedback="Warm effort! Matched traditional treasures with steady focus.",
            ),
            ActivityResult(
                patient_id=patient.id,
                activity_id="act-sequence",
                score=100,
                accuracy=1.0,
                duration_seconds=110,
                difficulty="Gentle",
                completed_at=datetime.now(timezone.utc) - timedelta(days=2),
                feedback="Perfect daily routine sequencing! Remembered all tea brewing steps.",
            ),
        ]
        db.add_all(results)

        # Seed ClientSyncState
        sync_state = ClientSyncState(
            patient_id=patient.id,
            last_synced_at=datetime.now(timezone.utc),
            sync_attention_required=False,
        )
        db.add(sync_state)

        db.commit()
