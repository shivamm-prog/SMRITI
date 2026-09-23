from datetime import datetime, timezone, timedelta
from typing import Dict, Any, List

# North Eastern Region (NER) 8 States Cultural & Linguistic Configuration
NER_REGIONS_DATA: Dict[str, Dict[str, Any]] = {
    "assam": {
        "name": "Assam",
        "capital": "Dispur",
        "languages": ["Assamese", "Bodo", "Bengali", "English", "Hindi"],
        "default_language": "Assamese",
        "greeting": "নমস্কাৰ (Nomoskar)",
        "symbol": "🦏",
        "landmarks": ["Kaziranga National Park", "Majuli River Island", "Kamakhya Temple"],
        "foods": ["Masor Tenga", "Khaar", "Pitha"],
        "festivals": ["Rongali Bihu", "Bhogali Bihu", "Kongali Bihu"],
        "proverb": "লাহে লাহে সকলো ঠিক হ’ব (Slowly, everything will be well)",
    },
    "meghalaya": {
        "name": "Meghalaya",
        "capital": "Shillong",
        "languages": ["Khasi", "Garo", "Pnar", "English"],
        "default_language": "Khasi",
        "greeting": "Khublei Shibun",
        "symbol": "🌿",
        "landmarks": ["Living Root Bridges of Cherrapunji", "Nohkalikai Falls", "Umiam Lake"],
        "foods": ["Jadoh", "Dohneiiong", "Pukhlein"],
        "festivals": ["Wangala 100 Drums Festival", "Shad Suk Mynsiem"],
        "proverb": "U Blei un don ryngkat bad phi (Peace and safety be with you)",
    },
    "manipur": {
        "name": "Manipur",
        "capital": "Imphal",
        "languages": ["Meitei (Manipuri)", "Tangkhul", "Thadou", "English"],
        "default_language": "Meitei (Manipuri)",
        "greeting": "Khurumjari",
        "symbol": "🌸",
        "landmarks": ["Loktak Lake & Floating Phumdis", "Kangla Fort", "Ima Keithel"],
        "foods": ["Kangshoi", "Eromba", "Chak-hao Black Rice Kheer"],
        "festivals": ["Yaoshang", "Lai Haraoba", "Ningol Chakouba"],
        "proverb": "Thamoina henna chetna leiyu (Keep your heart calm and steady)",
    },
    "nagaland": {
        "name": "Nagaland",
        "capital": "Kohima",
        "languages": ["Nagamese", "Ao", "Angami", "Sumi", "Lotha", "English"],
        "default_language": "Nagamese",
        "greeting": "Aayao / Khwelie",
        "symbol": "⛰️",
        "landmarks": ["Dzukou Valley", "Kohima War Cemetery", "Khonoma Village"],
        "foods": ["Galho Rice Broth", "Axone stew", "Smoked Bamboo Greens"],
        "festivals": ["Hornbill Festival", "Moatsu", "Sekrenyi"],
        "proverb": "Kini kemo (Peace and calmness be with you)",
    },
    "mizoram": {
        "name": "Mizoram",
        "capital": "Aizawl",
        "languages": ["Mizo", "English"],
        "default_language": "Mizo",
        "greeting": "Chibai",
        "symbol": "🎋",
        "landmarks": ["Durtlang Hills", "Vantawng Falls", "Reiek Mountain"],
        "foods": ["Bai", "Sawhchiar", "Chhangban"],
        "festivals": ["Chapchar Kut", "Mim Kut", "Pawl Kut"],
        "proverb": "Dam takin le (Live gently and in peace)",
    },
    "arunachal": {
        "name": "Arunachal Pradesh",
        "capital": "Itanagar",
        "languages": ["Nyishi", "Monpa", "Adi", "Hindi", "English"],
        "default_language": "English",
        "greeting": "Tashi Delek / Mingkeng",
        "symbol": "🏔️",
        "landmarks": ["Tawang Monastery", "Sela Pass", "Ziro Valley"],
        "foods": ["Thukpa", "Momos", "Pika Pila"],
        "festivals": ["Losar", "Dree Festival", "Nyokum"],
        "proverb": "Om Mani Padme Hum (May peace fill every corner of your mind)",
    },
    "tripura": {
        "name": "Tripura",
        "capital": "Agartala",
        "languages": ["Kokborok", "Bengali", "English"],
        "default_language": "Bengali",
        "greeting": "নমস্কার / Khulumkha",
        "symbol": "🏰",
        "landmarks": ["Ujjayanta Palace", "Unakoti Rock Carvings", "Neermahal"],
        "foods": ["Mui Borok", "Chakhwi", "Muya Awandru"],
        "festivals": ["Kharchi Puja", "Garia Puja", "Ker Puja"],
        "proverb": "Kaham tongdi (Stay happy and at tranquil ease)",
    },
    "sikkim": {
        "name": "Sikkim",
        "capital": "Gangtok",
        "languages": ["Nepali", "Bhutia", "Lepcha", "English", "Hindi"],
        "default_language": "Nepali",
        "greeting": "नमस्ते (Namaste) / Kuzuzangpo",
        "symbol": "❄️",
        "landmarks": ["Mount Kanchenjunga", "Rumtek Monastery", "Tsomgo Lake"],
        "foods": ["Momos", "Sel Roti", "Gundruk", "Thukpa"],
        "festivals": ["Losoong", "Pang Lhabsol", "Saga Dawa"],
        "proverb": "सधैं शान्त रहनुहोस् (May you always remain in gentle serenity)",
    },
}

ALL_SUPPORTED_LANGUAGES = [
    "Assamese",
    "Bengali",
    "Bodo",
    "Meitei (Manipuri)",
    "Khasi",
    "Garo",
    "Mizo",
    "Nagamese",
    "Nepali",
    "Kokborok",
    "Hindi",
    "English",
]


def get_time_greeting() -> str:
    """Returns a calming, time-sensitive greeting."""
    hour = datetime.now().hour
    if hour < 12:
        return "Good morning"
    elif hour < 17:
        return "Good afternoon"
    return "Good evening"


def check_two_day_sync_overdue(last_synced_at: datetime) -> bool:
    """Returns True if the patient has not synchronized for more than 48 hours."""
    if not last_synced_at:
        return True
    if last_synced_at.tzinfo is None:
        last_synced_at = last_synced_at.replace(tzinfo=timezone.utc)
    return datetime.now(timezone.utc) - last_synced_at > timedelta(hours=48)
