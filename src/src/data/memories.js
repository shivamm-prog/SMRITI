// SMRITI - Seed Personal Memories, Activity History, and Caregiver Observations (100% Offline)
export const SEED_MEMORIES = [
  {
    id: "mem_001",
    patientId: "pat_anita_001",
    title: {
      en: "Ancestral Home in Tezpur",
      hi: "तेजपुर का पैतृक घर",
      as: "তেজপুৰৰ পুৰণি ঘৰখন"
    },
    category: "places",
    yearApprox: "1968-1995",
    iconKey: "ancestral_home",
    caption: {
      en: "The beautiful old courtyard where family gathered during Magh Bihu feasts.",
      hi: "वह पुराना आँगन जहाँ माघ बिहू के दौरान परिवार इकट्ठा होता था।",
      as: "মাঘ বিহুৰ মেজি আৰু উৰুকাৰ ভোজ খোৱা আমাৰ পুৰণি চোতালখন।"
    },
    audioPrompt: {
      en: "This is your ancestral courtyard in Tezpur.",
      hi: "यह तेजपुर का आपका पैतृक आँगन है।",
      as: "এইখন তেজপুৰৰ আপোনালোকৰ পুৰণি ঘৰৰ চোতালখন।"
    },
    subtitleEn: "This is your ancestral courtyard in Tezpur."
  },
  {
    id: "mem_002",
    patientId: "pat_anita_001",
    title: {
      en: "Granddaughter Priyam's 5th Birthday",
      hi: "पोती प्रियम का जन्मदिन",
      as: "নাতিনী প্রিয়মৰ জন্মদিন"
    },
    category: "family",
    yearApprox: "2018",
    iconKey: "grandkids",
    caption: {
      en: "Priyam wearing her yellow silk dress and laughing with Grandma Anita.",
      hi: "प्रियम पीली रेशमी पोशाक में दादी अनीता के साथ मुस्कुराते हुए।",
      as: "প্ৰিয়মে হালধীয়া পাটৰ ফ্ৰক পিন্ধি আইতা অনিতাৰ লগত হাঁহি থকা মুহূৰ্ত।"
    },
    audioPrompt: {
      en: "Look at Priyam's bright smile on her special day.",
      hi: "प्रियम की प्यारी मुस्कान देखिए।",
      as: "চোৱাচোন প্ৰিয়মৰ কিমান মিঠা হাঁহি।"
    },
    subtitleEn: "Look at Priyam's bright smile on her special day."
  },
  {
    id: "mem_003",
    patientId: "pat_anita_001",
    title: {
      en: "Favorite Assam CTC Tea Garden",
      hi: "मनपसंद असम चाय बागान",
      as: "প্ৰিয় চাহ বাগিচাৰ স্মৃতি"
    },
    category: "places",
    yearApprox: "2015",
    iconKey: "tea_garden",
    caption: {
      en: "Morning tea tasting trip to Sonitpur tea estate with school colleagues.",
      hi: "सहकर्मियों के साथ शोणितपुर चाय बागान की सैर।",
      as: "শোণিতপুৰ চাহ বাগিচাত সহকৰ্মী শিক্ষকসকলৰ সৈতে এক সুন্দৰ পুৱা।"
    },
    audioPrompt: {
      en: "The fresh green tea leaves of Sonitpur.",
      hi: "शोणितपुर की ताजी हरी चाय पत्तियाँ।",
      as: "শোণিতপুৰৰ সজীৱ সেউজীয়া চাহ পাত।"
    },
    subtitleEn: "The fresh green tea leaves of Sonitpur."
  },
  {
    id: "mem_004",
    patientId: "pat_anita_001",
    title: {
      en: "Fresh Ripe Mangoes from Backyard",
      hi: "घर के आँगन के मीठे आम",
      as: "বাৰীৰ মিঠা মালভোগ আম"
    },
    category: "food",
    yearApprox: "Every Summer",
    iconKey: "mango",
    caption: {
      en: "Sweet summer mangoes picked together with Rahul and enjoyed in the afternoon breeze.",
      hi: "गर्मियों में राहुल के साथ तोड़े गए मीठे आम और दोपहर की ठंडी हवा।",
      as: "ৰাহুলৰ লগত বাৰীৰ পৰা চিঙা সুস্বাদু আম আৰু দুপৰীয়াৰ জুৰ বতাহ।"
    },
    audioPrompt: {
      en: "Do you remember the sweet ripe mangoes from our backyard tree?",
      hi: "क्या आपको हमारे घर के मीठे रसीले आम याद हैं?",
      as: "আমাৰ বাৰীৰ গছৰ মিঠা পকা আমবোৰ মনত আছেনে?"
    },
    subtitleEn: "Do you remember the sweet ripe mangoes from our backyard tree?"
  }
];

export const SEED_ACTIVITY_RESULTS = [
  {
    id: "smriti_act_101",
    patientId: "pat_anita_001",
    activityType: "memory_match",
    activityTitle: "Memory Match",
    timestamp: "2026-08-30T10:15:00Z",
    difficultyLevel: "Level 1 (Very Easy)",
    accuracy: 100,
    responseTimeMs: 3800,
    attempts: 2,
    correctMatches: 2,
    incorrectMatches: 0,
    hintsUsed: 0,
    completionStatus: "completed",
    language: "as",
    syncStatus: "synced",
    syncedAt: "2026-08-30T10:20:00Z"
  },
  {
    id: "smriti_act_102",
    patientId: "pat_anita_001",
    activityType: "word_category_game",
    activityTitle: "Word & Category Game",
    timestamp: "2026-08-30T10:25:00Z",
    difficultyLevel: "Level 1 (Very Easy)",
    accuracy: 100,
    responseTimeMs: 4100,
    attempts: 1,
    correctMatches: 4,
    incorrectMatches: 0,
    hintsUsed: 0,
    completionStatus: "completed",
    language: "as",
    syncStatus: "synced",
    syncedAt: "2026-08-30T10:30:00Z"
  },
  {
    id: "smriti_act_103",
    patientId: "pat_anita_001",
    activityType: "remember_objects",
    activityTitle: "Remember the Objects",
    timestamp: "2026-08-31T09:40:00Z",
    difficultyLevel: "Level 1 (Very Easy)",
    accuracy: 100,
    responseTimeMs: 5200,
    attempts: 1,
    correctMatches: 3,
    incorrectMatches: 0,
    hintsUsed: 0,
    completionStatus: "completed",
    language: "as",
    syncStatus: "synced",
    syncedAt: "2026-08-31T10:00:00Z"
  },
  {
    id: "smriti_act_104",
    patientId: "pat_anita_001",
    activityType: "daily_life_sequencing",
    activityTitle: "Daily Life Sequence - Assam Tea",
    timestamp: "2026-09-01T09:10:00Z",
    difficultyLevel: "Level 1 (Very Easy)",
    accuracy: 100,
    responseTimeMs: 5500,
    attempts: 1,
    correctMatches: 3,
    incorrectMatches: 0,
    hintsUsed: 0,
    completionStatus: "completed",
    language: "as",
    syncStatus: "synced",
    syncedAt: "2026-09-01T09:30:00Z"
  },
  {
    id: "smriti_act_105",
    patientId: "pat_anita_001",
    activityType: "orientation_game",
    activityTitle: "Orientation Activity",
    timestamp: "2026-09-01T09:25:00Z",
    difficultyLevel: "Level 1 (Very Easy)",
    accuracy: 100,
    responseTimeMs: 4200,
    attempts: 1,
    correctMatches: 1,
    incorrectMatches: 0,
    hintsUsed: 0,
    completionStatus: "completed",
    language: "as",
    syncStatus: "synced",
    syncedAt: "2026-09-01T09:30:00Z"
  }
];

export const SEED_CAREGIVER_OBSERVATIONS = [
  {
    id: "obs_001",
    patientId: "pat_anita_001",
    caregiverId: "cg_rahul_001",
    date: "2026-08-30",
    mood: "Happy",
    sleep: "Good",
    appetite: "Good",
    dailyActivity: "Active",
    memoryConcerns: "None",
    notes: "Maa smiled warmly when looking at the Tezpur home picture. She recognized Priyam instantly and had afternoon tea comfortably.",
    syncStatus: "synced",
    syncedAt: "2026-08-30T11:00:00Z"
  },
  {
    id: "obs_002",
    patientId: "pat_anita_001",
    caregiverId: "cg_rahul_001",
    date: "2026-08-31",
    mood: "Neutral",
    sleep: "Average",
    appetite: "Good",
    dailyActivity: "Moderate",
    memoryConcerns: "Mild",
    notes: "Participated nicely in the morning tea sequencing game. Enjoyed Assamese voice prompts and took a short garden walk.",
    syncStatus: "synced",
    syncedAt: "2026-08-31T11:00:00Z"
  },
  {
    id: "obs_003",
    patientId: "pat_anita_001",
    caregiverId: "cg_rahul_001",
    date: "2026-09-01",
    mood: "Happy",
    sleep: "Good",
    appetite: "Good",
    dailyActivity: "Active",
    memoryConcerns: "None",
    notes: "Calm morning. Enjoyed the Bihu dhol reminiscence activity with Rahul and sang along with the folk tune.",
    syncStatus: "synced",
    syncedAt: "2026-09-01T10:00:00Z"
  }
];