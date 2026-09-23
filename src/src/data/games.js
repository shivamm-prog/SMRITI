// SMRITI - 6 Scientifically Grounded Cognitive & Reminiscence Activities (100% Offline)
export const GAMES_DATA = {
  memory_match: {
    id: "game_001_memory_match",
    type: "memory_match",
    domain: "memory",
    icon: "tea_cup",
    title: {
      en: "Memory Match",
      hi: "स्मृति मिलान (Memory Match)",
      as: "স্মৃতি মিলোৱা খেল"
    },
    description: {
      en: "Display 4–8 familiar cards, remember their positions, and tap the matching pairs.",
      hi: "परिचित चित्रों को ध्यान से देखें, उनके स्थान याद रखें और जोड़े मिलाएँ।",
      as: "চিনাকি ছবিবোৰ মনোযোগেৰে চাওক আৰু একে জোৰা ছবিবোৰ মিলাওক।"
    },
    audioPrompt: {
      en: "Look carefully at these familiar pictures. Remember where each one is.",
      hi: "इन परिचित चित्रों को ध्यान से देखें। याद रखें कि कौन सा चित्र कहाँ है।",
      as: "এই চিনাকি ছবিবোৰ মনোযোগেৰে চাওক। কোনখন ক’ত আছে মনত ৰাখক।"
    },
    subtitleEn: "Look carefully at these familiar pictures. Remember where each one is.",
    levels: [
      {
        level: 1,
        name: "Level 1 (Very Easy)",
        cardsCount: 4, // 2 pairs
        pairs: ["tea_cup", "marigold"],
        labels: {
          tea_cup: { en: "Assam Tea", hi: "असम की चाय", as: "অসমৰ চাহ" },
          marigold: { en: "Marigold Flower", hi: "गेंदे का फूल", as: "নাৰ্জী ফুল" }
        }
      },
      {
        level: 2,
        name: "Level 2 (Easy)",
        cardsCount: 6, // 3 pairs
        pairs: ["tea_cup", "marigold", "bihu_dhol"],
        labels: {
          tea_cup: { en: "Assam Tea", hi: "असम की चाय", as: "অসমৰ চাহ" },
          marigold: { en: "Marigold", hi: "गेंदा", as: "নাৰ্জী ফুল" },
          bihu_dhol: { en: "Bihu Dhol", hi: "बिहू ढोल", as: "বিহু ঢোল" }
        }
      },
      {
        level: 3,
        name: "Level 3 (Moderate)",
        cardsCount: 8, // 4 pairs
        pairs: ["tea_cup", "marigold", "bihu_dhol", "kamakhya"],
        labels: {
          tea_cup: { en: "Assam Tea", hi: "असम की चाय", as: "অসমৰ চাহ" },
          marigold: { en: "Marigold", hi: "गेंदा", as: "নাৰ্জী ফুল" },
          bihu_dhol: { en: "Bihu Dhol", hi: "बिहू ढोल", as: "বিহু ঢোল" },
          kamakhya: { en: "Kamakhya Temple", hi: "कामाख्या मंदिर", as: "কামাখ্যা মন্দিৰ" }
        }
      },
      {
        level: 4,
        name: "Level 4 (Challenging)",
        cardsCount: 8, // 4 pairs with varied objects
        pairs: ["gamosa", "rhino", "brass_bell", "diya_lamp"],
        labels: {
          gamosa: { en: "Assamese Gamosa", hi: "असमिया गमोसा", as: "অসমীয়া গামোচা" },
          rhino: { en: "Kaziranga Rhino", hi: "काजीरंगा गैंडा", as: "কাজিৰঙাৰ গঁড়" },
          brass_bell: { en: "Prayer Bell", hi: "पूजा की घंटी", as: "কাঁহৰ ঘণ্টা" },
          diya_lamp: { en: "Diya Lamp", hi: "मिट्टी का दीया", as: "মাটিৰ চাকি" }
        }
      }
    ]
  },

  remember_objects: {
    id: "game_002_remember_objects",
    type: "remember_objects",
    domain: "attention_memory",
    icon: "spectacles",
    title: {
      en: "Remember the Objects",
      hi: "वस्तुएं याद रखें (Remember the Objects)",
      as: "বস্তুবোৰ মনত ৰখা খেল"
    },
    description: {
      en: "Look at the familiar objects, remember them, and tap the ones you saw.",
      hi: "दिखाई गई परिचित वस्तुओं को याद रखें और फिर पूछी गई वस्तुओं को पहचानें।",
      as: "বস্তুবোৰ মনোযোগেৰে চাওক, মনত ৰাখক আৰু তাৰ পাছত চিনি উলিয়াওক।"
    },
    audioPrompt: {
      en: "Look at these objects and remember them. When you are ready, tap Continue.",
      hi: "इन वस्तुओं को ध्यान से देखें और याद रखें। तैयार होने पर आगे बढ़ें।",
      as: "এই বস্তুবোৰ মনোযোগেৰে চাওক আৰু মনত ৰাখক। সাজু হ’লে আগবাঢ়ক।"
    },
    subtitleEn: "Look at these objects and remember them. When you are ready, tap Continue.",
    questionPrompt: {
      en: "Which objects did you see?",
      hi: "आपने कौन सी वस्तुएँ देखी थीं?",
      as: "আপুনি কোনবোৰ বস্তু দেখিছিল?"
    },
    questionSubtitleEn: "Which objects did you see? Tap all the items that were shown.",
    sets: [
      {
        id: "set_1_easy",
        level: 1,
        targets: [
          { key: "apple", label: { en: "Apple", hi: "सेब", as: "আপেল" } },
          { key: "tea_cup", label: { en: "Tea Cup", hi: "चाय का कप", as: "চাহৰ কাপ" } },
          { key: "key", label: { en: "Key", hi: "चाबी", as: "চাবি" } }
        ],
        options: [
          { key: "apple", label: { en: "Apple", hi: "सेब", as: "আপেল" }, isTarget: true },
          { key: "book", label: { en: "Book", hi: "किताब", as: "কিতাপ" }, isTarget: false },
          { key: "key", label: { en: "Key", hi: "चाबी", as: "চাবি" }, isTarget: true },
          { key: "ball", label: { en: "Ball", hi: "गेंद", as: "বল" }, isTarget: false },
          { key: "tea_cup", label: { en: "Tea Cup", hi: "चाय का कप", as: "চাহৰ কাপ" }, isTarget: true },
          { key: "chair", label: { en: "Chair", hi: "कुर्सी", as: "চকী" }, isTarget: false }
        ]
      },
      {
        id: "set_2_moderate",
        level: 2,
        targets: [
          { key: "mango", label: { en: "Mango", hi: "आम", as: "আম" } },
          { key: "spectacles", label: { en: "Glasses", hi: "चश्मा", as: "চছমা" } },
          { key: "marigold", label: { en: "Marigold", hi: "गेंदा फूल", as: "নাৰ্জী ফুল" } },
          { key: "diya_lamp", label: { en: "Diya", hi: "दीया", as: "চাকি" } }
        ],
        options: [
          { key: "mango", label: { en: "Mango", hi: "आम", as: "আম" }, isTarget: true },
          { key: "banana", label: { en: "Banana", hi: "केला", as: "কল" }, isTarget: false },
          { key: "spectacles", label: { en: "Glasses", hi: "चश्मा", as: "চছমা" }, isTarget: true },
          { key: "umbrella", label: { en: "Umbrella", hi: "छाता", as: "ছাতি" }, isTarget: false },
          { key: "marigold", label: { en: "Marigold", hi: "गेंदा फूल", as: "নাৰ্জী ফুল" }, isTarget: true },
          { key: "diya_lamp", label: { en: "Diya", hi: "दीया", as: "চাকি" }, isTarget: true },
          { key: "table", label: { en: "Table", hi: "मेज", as: "মেজ" }, isTarget: false }
        ]
      },
      {
        id: "set_3_challenging",
        level: 3,
        targets: [
          { key: "gamosa", label: { en: "Gamosa", hi: "गमोसा", as: "গামোচা" } },
          { key: "bihu_dhol", label: { en: "Bihu Dhol", hi: "बिहू ढोल", as: "বিহু ঢোল" } },
          { key: "tulsi_plant", label: { en: "Tulsi", hi: "तुलसी", as: "তুলসী" } },
          { key: "rhino", label: { en: "Rhino", hi: "गैंडा", as: "গঁড়" } },
          { key: "brass_bell", label: { en: "Brass Bell", hi: "घंटी", as: "ঘণ্টা" } }
        ],
        options: [
          { key: "gamosa", label: { en: "Gamosa", hi: "गमोसा", as: "গামোচা" }, isTarget: true },
          { key: "tea_cup", label: { en: "Tea Cup", hi: "चाय का कप", as: "চাহৰ কাপ" }, isTarget: false },
          { key: "bihu_dhol", label: { en: "Bihu Dhol", hi: "बिहू ढोल", as: "বিহু ঢোল" }, isTarget: true },
          { key: "tulsi_plant", label: { en: "Tulsi", hi: "तुलसी", as: "তুলসী" }, isTarget: true },
          { key: "elephant", label: { en: "Elephant", hi: "हाथी", as: "হাতী" }, isTarget: false },
          { key: "rhino", label: { en: "Rhino", hi: "गैंडा", as: "গঁড়" }, isTarget: true },
          { key: "brass_bell", label: { en: "Brass Bell", hi: "घंटी", as: "ঘণ্টা" }, isTarget: true },
          { key: "ball", label: { en: "Ball", hi: "गेंद", as: "বল" }, isTarget: false }
        ]
      }
    ]
  },

  daily_life_sequencing: {
    id: "game_003_daily_life_sequencing",
    type: "daily_life_sequencing",
    domain: "sequencing_planning",
    icon: "morning_walk",
    title: {
      en: "Daily Life Sequence",
      hi: "दैनिक जीवन क्रम (Daily Life Sequence)",
      as: "দৈনন্দিন কামৰ ক্ৰম"
    },
    description: {
      en: "Arrange the familiar everyday steps in the correct order.",
      hi: "दैनिक दिनचर्या के कार्यों को सही क्रम में व्यवस्थित करें।",
      as: "দৈনন্দিন জীৱনৰ চিনাকি কামবোৰৰ খোজবোৰ সঠিক ক্ৰমত সজাওক।"
    },
    routines: [
      {
        id: "routine_tea",
        title: {
          en: "Making Assam Tea",
          hi: "असम चाय बनाना (Making Tea)",
          as: "চাহ বনোৱা"
        },
        audioPrompt: {
          en: "Put the steps of making a warm cup of tea in the correct order.",
          hi: "गरमा-गरम चाय बनाने के चरणों को सही क्रम में लगाएं।",
          as: "চাহ বনোৱাৰ নিয়মবোৰ সঠিক ক্ৰমত সজাওক।"
        },
        subtitleEn: "Put the steps of making a warm cup of tea in the correct order.",
        steps: [
          {
            stepNumber: 1,
            label: { en: "1. Boil fresh water in kettle", hi: "1. केतली में ताजा पानी उबालें", as: "১. কেটলীত পানী উতলাওক" },
            iconKey: "tea_cup"
          },
          {
            stepNumber: 2,
            label: { en: "2. Add fragrant tea leaves & milk", hi: "2. चाय पत्ती और दूध डालें", as: "২. চাহ পাত আৰু গাখীৰ দিয়ক" },
            iconKey: "tea_garden"
          },
          {
            stepNumber: 3,
            label: { en: "3. Strain into cup & enjoy", hi: "3. कप में छानकर आनंद लें", as: "৩. কাপত চাকি পৰিবেশন কৰক" },
            iconKey: "tea_cup"
          }
        ]
      },
      {
        id: "routine_walk",
        title: {
          en: "Getting Ready for a Walk",
          hi: "सुबह की सैर पर जाना",
          as: "ৰাতিপুৱা খোজ কাঢ়িবলৈ যোৱা"
        },
        audioPrompt: {
          en: "Arrange the steps for going on a peaceful morning walk.",
          hi: "सुबह की सैर पर जाने के चरणों को सही क्रम में लगाएं।",
          as: "ৰাতিপুৱা খোজ কাঢ়িবলৈ যোৱাৰ খোজবোৰ সজাওক।"
        },
        subtitleEn: "Arrange the steps for going on a peaceful morning walk.",
        steps: [
          {
            stepNumber: 1,
            label: { en: "1. Put on comfortable walking shoes", hi: "1. चलने वाले जूते या चप्पल पहनें", as: "১. খোজ কঢ়া জোতা বা চেণ্ডেল পিন্ধক" },
            iconKey: "morning_walk"
          },
          {
            stepNumber: 2,
            label: { en: "2. Take walking stick and spectacles", hi: "2. चश्मा और छड़ी साथ लें", as: "২. চছমা আৰু লাঠিডাল লওক" },
            iconKey: "spectacles"
          },
          {
            stepNumber: 3,
            label: { en: "3. Step outside for fresh morning air", hi: "3. खुली ताजी हवा में टहलें", as: "৩. মুকলি বতাহত খোজ কাঢ়ক" },
            iconKey: "tea_garden"
          }
        ]
      },
      {
        id: "routine_breakfast",
        title: {
          en: "Preparing Morning Breakfast",
          hi: "सुबह का नाश्ता तैयार करना",
          as: "ৰাতিপুৱাৰ জলপান খোৱা"
        },
        audioPrompt: {
          en: "Put the steps of preparing morning breakfast in order.",
          hi: "सुबह का नाश्ता करने के चरणों को सही क्रम में व्यवस्थित करें।",
          as: "ৰাতিপুৱাৰ জলপান খোৱাৰ খোজবোৰ ক্ৰমত সজাওক।"
        },
        subtitleEn: "Put the steps of preparing morning breakfast in order.",
        steps: [
          {
            stepNumber: 1,
            label: { en: "1. Wash hands with clean water", hi: "1. हाथों को साफ पानी से धोएं", as: "১. হাত দুখন ভালদৰে ধুবক" },
            iconKey: "soap_water"
          },
          {
            stepNumber: 2,
            label: { en: "2. Warm the fresh roti or pitha", hi: "2. ताजा रोटी या पीठा गर्म करें", as: "২. সতেজ ৰুটী বা পিঠা গৰম কৰক" },
            iconKey: "banana"
          },
          {
            stepNumber: 3,
            label: { en: "3. Sit comfortably and eat with family", hi: "3. परिवार के साथ बैठकर भोजन करें", as: "৩. পৰিয়ালৰ সৈতে আৰামেৰে ভোজন কৰক" },
            iconKey: "grandkids"
          }
        ]
      },
      {
        id: "routine_temple",
        title: {
          en: "Going to Community Prayer / Temple",
          hi: "प्रार्थना या मंदिर जाना",
          as: "নামঘৰ বা মন্দিৰলৈ যোৱা"
        },
        audioPrompt: {
          en: "Arrange the steps for visiting the local prayer hall.",
          hi: "प्रार्थना स्थल या मंदिर जाने के चरणों को क्रम में लगाएं।",
          as: "নামঘৰ বা মন্দিৰলৈ যোৱাৰ খোজবোৰ সজাওক।"
        },
        subtitleEn: "Arrange the steps for visiting the local prayer hall.",
        steps: [
          {
            stepNumber: 1,
            label: { en: "1. Bathe and wear clean clothes", hi: "1. स्नान कर स्वच्छ वस्त्र पहनें", as: "১. স্নান কৰি পৰিষ্কাৰ কাপোৰ পিন্ধক" },
            iconKey: "gamosa"
          },
          {
            stepNumber: 2,
            label: { en: "2. Pick fresh marigold flowers", hi: "2. पूजा के लिए ताजे गेंदे के फूल लें", as: "২. পূজাৰ বাবে নাৰ্জী ফুল সংগ্ৰহ কৰক" },
            iconKey: "marigold"
          },
          {
            stepNumber: 3,
            label: { en: "3. Walk peacefully to prayer hall", hi: "3. शांति से प्रार्थना स्थल जाएं", as: "৩. শান্ত মনেৰে নামঘৰলৈ যাওক" },
            iconKey: "kamakhya"
          }
        ]
      },
      {
        id: "routine_wash_hands",
        title: {
          en: "Washing Hands Thoroughly",
          hi: "हाथ अच्छी तरह धोना",
          as: "হাত ভালদৰে ধোৱা"
        },
        audioPrompt: {
          en: "Arrange the simple steps for washing hands cleanly.",
          hi: "हाथ धोने के सही चरणों को क्रम में लगाएं।",
          as: "হাত ধোৱাৰ সহজ খোজবোৰ ক্ৰমত সজাওক।"
        },
        subtitleEn: "Arrange the simple steps for washing hands cleanly.",
        steps: [
          {
            stepNumber: 1,
            label: { en: "1. Wet hands with clean running water", hi: "1. हाथों को साफ पानी से गीला करें", as: "১. হাত দুখন পৰিষ্কাৰ পানীৰে তিয়াওক" },
            iconKey: "soap_water"
          },
          {
            stepNumber: 2,
            label: { en: "2. Apply soap and gently rub palms", hi: "2. साबुन लगाकर हथेलियों को मलें", as: "২. চাবোন ঘঁহি হাত দুখন ফেনাওক" },
            iconKey: "soap_water"
          },
          {
            stepNumber: 3,
            label: { en: "3. Rinse with water and dry with towel", hi: "3. पानी से धोकर तौलिए से पोंछें", as: "৩. পানীৰে ধুই গামোচাৰে মচক" },
            iconKey: "gamosa"
          }
        ]
      },
      {
        id: "routine_bedtime",
        title: {
          en: "Getting Ready for Bed",
          hi: "सोने की तैयारी करना",
          as: "শোৱাৰ প্ৰস্তুতি কৰা"
        },
        audioPrompt: {
          en: "Put the peaceful bedtime steps in the right order.",
          hi: "रात को सोने की तैयारी के चरणों को क्रम में लगाएं।",
          as: "ৰাতি শোৱাৰ আগৰ নিয়মবোৰ ক্ৰমত সজাওক।"
        },
        subtitleEn: "Put the peaceful bedtime steps in the right order.",
        steps: [
          {
            stepNumber: 1,
            label: { en: "1. Drink a glass of warm water", hi: "1. एक गिलास गुनगुना पानी पिएं", as: "১. এগিলাচ কুহুমীয়া পানী খাওক" },
            iconKey: "tea_cup"
          },
          {
            stepNumber: 2,
            label: { en: "2. Change into comfortable night clothes", hi: "2. आरामदायक ढीले वस्त्र पहनें", as: "২. ঢিলা আৰু আৰামদায়ক কাপোৰ পিন্ধক" },
            iconKey: "gamosa"
          },
          {
            stepNumber: 3,
            label: { en: "3. Lie down peacefully on soft bed", hi: "3. बिस्तर पर आराम से लेटें", as: "৩. বিছনাত আৰামেৰে জিৰণি লওক" },
            iconKey: "ancestral_home"
          }
        ]
      }
    ]
  },

  word_category_game: {
    id: "game_004_word_category_game",
    type: "word_category_game",
    domain: "language_semantic",
    icon: "banana",
    title: {
      en: "Word & Category Game",
      hi: "शब्द और श्रेणी खेल (Word & Category)",
      as: "শব্দ আৰু শ্ৰেণী খেল"
    },
    description: {
      en: "Stimulate language and semantic memory with category and word tasks.",
      hi: "श्रेणी और शब्द कार्यों के साथ भाषा और स्मृति को बढ़ावा दें।",
      as: "শ্ৰেণী আৰু শব্দৰ চিনাকি খেলৰ জৰিয়তে স্মৃতি সজীৱ কৰক।"
    },
    categories: [
      {
        id: "cat_fruits",
        type: "category_select",
        categoryName: {
          en: "FRUITS",
          hi: "फल (FRUITS)",
          as: "ফলসমূহ (FRUITS)"
        },
        audioPrompt: {
          en: "Select all the fruits from the options below.",
          hi: "नीचे दिए गए विकल्पों में से सभी फलों को चुनें।",
          as: "তলৰ ছবিবোৰৰ পৰা সকলো ফল বাছি উলিয়াওক।"
        },
        subtitleEn: "Select all the fruits from the options below.",
        items: [
          { id: "c_apple", iconKey: "apple", name: { en: "Apple", hi: "सेब", as: "আপেল" }, isBelonging: true },
          { id: "c_mango", iconKey: "mango", name: { en: "Mango", hi: "आम", as: "আম" }, isBelonging: true },
          { id: "c_banana", iconKey: "banana", name: { en: "Banana", hi: "केला", as: "কল" }, isBelonging: true },
          { id: "c_chair", iconKey: "chair", name: { en: "Chair", hi: "कुर्सी", as: "চকী" }, isBelonging: false },
          { id: "c_orange", iconKey: "orange", name: { en: "Orange", hi: "संतरा", as: "কমলা" }, isBelonging: true },
          { id: "c_table", iconKey: "table", name: { en: "Table", hi: "मेज", as: "মেজ" }, isBelonging: false }
        ]
      },
      {
        id: "cat_animals",
        type: "category_select",
        categoryName: {
          en: "ANIMALS & BIRDS",
          hi: "पशु और पक्षी (ANIMALS)",
          as: "পশু আৰু চৰাই (ANIMALS)"
        },
        audioPrompt: {
          en: "Select all the animals and birds.",
          hi: "सभी पशु और पक्षियों को चुनें।",
          as: "সকলো জীৱ-জন্তু আৰু চৰাই বাছি উলিয়াওক।"
        },
        subtitleEn: "Select all the animals and birds.",
        items: [
          { id: "c_eleph", iconKey: "elephant", name: { en: "Elephant", hi: "हाथी", as: "হাতী" }, isBelonging: true },
          { id: "c_pea", iconKey: "peacock", name: { en: "Peacock", hi: "मोर", as: "ম’ৰা চৰাই" }, isBelonging: true },
          { id: "c_rhino", iconKey: "rhino", name: { en: "Rhino", hi: "गैंडा", as: "গঁড়" }, isBelonging: true },
          { id: "c_tea", iconKey: "tea_cup", name: { en: "Tea Cup", hi: "चाय का कप", as: "চাহৰ কাপ" }, isBelonging: false },
          { id: "c_bell", iconKey: "brass_bell", name: { en: "Bell", hi: "घंटी", as: "ঘণ্টা" }, isBelonging: false }
        ]
      },
      {
        id: "word_gen_m_fruit",
        type: "word_generation",
        promptLetter: "M",
        promptText: {
          en: "Name a fruit beginning with 'M'",
          hi: "'M' से शुरू होने वाले फल का नाम बताएं",
          as: "'M' আখৰেৰে আৰম্ভ হোৱা ফলবিধৰ নাম কি?"
        },
        audioPrompt: {
          en: "Name a delicious fruit that begins with the letter M.",
          hi: "'M' अक्षर से शुरू होने वाले फल का नाम चुनें।",
          as: "'M' আখৰেৰে আৰম্ভ হোৱা ফলবিধ চিনাক্ত কৰক।"
        },
        subtitleEn: "Name a fruit beginning with 'M'",
        options: [
          { id: "w_mango", text: { en: "Mango (আম / आम)", hi: "आम (Mango)", as: "আম (Mango)" }, iconKey: "mango", isCorrect: true },
          { id: "w_milk", text: { en: "Milk", hi: "दूध", as: "গাখীৰ" }, iconKey: "tea_cup", isCorrect: false },
          { id: "w_mat", text: { en: "Mat", hi: "चटाई", as: "ঢাৰি" }, iconKey: "chair", isCorrect: false }
        ]
      },
      {
        id: "word_gen_m_flower",
        type: "word_generation",
        promptLetter: "M",
        promptText: {
          en: "Name a flower beginning with 'M'",
          hi: "'M' से शुरू होने वाले फूल का नाम बताएं",
          as: "'M' আখৰেৰে আৰম্ভ হোৱা ফুলবিধৰ নাম কি?"
        },
        audioPrompt: {
          en: "Name a bright orange flower that begins with M.",
          hi: "'M' अक्षर से शुरू होने वाले सुंदर फूल को चुनें।",
          as: "'M' আখৰেৰে আৰম্ভ হোৱা ফুলবিধ বাছক।"
        },
        subtitleEn: "Name a flower beginning with 'M'",
        options: [
          { id: "w_marigold", text: { en: "Marigold (गेंदा / নাৰ্জী)", hi: "गेंदा (Marigold)", as: "নাৰ্জী ফুল (Marigold)" }, iconKey: "marigold", isCorrect: true },
          { id: "w_mango_flower", text: { en: "Mango", hi: "आम", as: "আম" }, iconKey: "mango", isCorrect: false },
          { id: "w_moon", text: { en: "Moon", hi: "चांद", as: "জোনবাই" }, iconKey: "diya_lamp", isCorrect: false }
        ]
      }
    ]
  },

  reminiscence_album: {
    id: "game_005_reminiscence_album",
    type: "reminiscence_album",
    domain: "reminiscence_personal",
    icon: "grandkids",
    title: {
      en: "Reminiscence Album",
      hi: "संस्मरण एल्बम (Reminiscence Album)",
      as: "স্মৃতিৰ এলবাম"
    },
    description: {
      en: "Cherish personal memories, family photographs, places, and cultural celebrations.",
      hi: "पारिवारिक तस्वीरों, स्थानों, त्योहारों और सुखद पुरानी यादों का आनंद लें।",
      as: "পৰিয়ালৰ পুৰণি ছবি, চিনাকি ঠাই, বিহু-পূজা আৰু আনন্দৰ স্মৃতিসমূহ স্মৰণ কৰক।"
    },
    memories: [
      {
        id: "mem_bihu_grandkids",
        title: {
          en: "Rongali Bihu with Grandchildren",
          hi: "बच्चों के साथ रोंगाली बिहू",
          as: "নাতি-নাতিনীৰ সৈতে ৰঙালী বিহু"
        },
        category: "festival",
        personName: "Rahul & Meera (Grandchildren)",
        relation: "Family (Grandchildren)",
        place: "Guwahati Home",
        iconKey: "bihu_dhol",
        audioPrompt: {
          en: "Look at this joyful Rongali Bihu memory with your family. Who is in this memory?",
          hi: "परिवार के साथ रोंगाली बिहू की इस मधुर याद को देखें। इस तस्वीर में कौन हैं?",
          as: "পৰিয়ালৰ সৈতে ৰঙালী বিহুৰ এই আনন্দৰ ছবিখন চাওক। এই ছবিখনত কোন আছে?"
        },
        subtitleEn: "Look at this joyful Rongali Bihu memory with your family. Who is in this memory?",
        question1: {
          prompt: { en: "Who is this in the photo?", hi: "इस तस्वीर में कौन हैं?", as: "এই ছবিখনত কোন আছে?" },
          options: [
            { text: { en: "Family Members (Grandchildren)", hi: "परिवार के सदस्य (पोते-पोती)", as: "পৰিয়ালৰ সদস্য (নাতি-নাতিনী)" }, isCorrect: true },
            { text: { en: "Neighbor", hi: "पड़ोसी", as: "চুবুৰীয়া" }, isCorrect: false },
            { text: { en: "Other", hi: "अन्य", as: "অন্যান্য" }, isCorrect: false }
          ]
        },
        question2: {
          prompt: { en: "What relation do they have with you?", hi: "इनका आपके साथ क्या संबंध है?", as: "এওঁলোকৰ আপোনাৰ সৈতে কি সম্পৰ্ক?" },
          options: [
            { text: { en: "Beloved Grandchildren", hi: "प्यारे पोते-पोती", as: "মৰমৰ নাতি-নাতিনী" }, isCorrect: true },
            { text: { en: "School Teacher", hi: "शिक्षक", as: "শিক্ষক" }, isCorrect: false },
            { text: { en: "Old Colleague", hi: "सहकर्मी", as: "সহকৰ্মী" }, isCorrect: false }
          ]
        },
        question3: {
          prompt: { en: "What special celebration is this?", hi: "यह कौन सा पावन अवसर है?", as: "এইটো কোনটো উৎসৱৰ সময়?" },
          options: [
            { text: { en: "Rongali Bihu & Gamosa Giving", hi: "रोंगाली बिहू", as: "ৰঙালী বিহু আৰু বিহুৱান" }, isCorrect: true },
            { text: { en: "Birthday Party", hi: "जन्मदिन", as: "জন্মদিন" }, isCorrect: false },
            { text: { en: "Market Trip", hi: "बाजार", as: "বজাৰ" }, isCorrect: false }
          ]
        },
        story: {
          en: "Every spring during Rongali Bihu, the grandchildren tie the new red-embroidered Gamosa and play the rhythmic Dhol in the front courtyard.",
          hi: "हर साल रोंगाली बिहू पर बच्चे आंगन में बिहू ढोल बजाते हैं और आप उन्हें नया गमोसा भेंट करते हैं।",
          as: "প্ৰতি বছৰে ৰঙালী বিহুত চোতালত নাতি-নাতিনীয়ে বিহু ঢোল বজায় আৰু আপুনি মৰমেৰে নতুন গামোচা প্ৰদান কৰে।"
        }
      },
      {
        id: "mem_kamakhya_visit",
        title: {
          en: "Kamakhya Temple on Nilachal Hill",
          hi: "नीलाचल पहाड़ी पर कामाख्या मंदिर",
          as: "নীলাচল পাহাৰৰ কামাখ্যা মন্দিৰ"
        },
        category: "place",
        personName: "Family Pilgrimage",
        relation: "Sacred Heritage",
        place: "Nilachal Hill, Guwahati",
        iconKey: "kamakhya",
        audioPrompt: {
          en: "Do you remember visiting the sacred Kamakhya Temple overlooking the Brahmaputra?",
          hi: "क्या आपको ब्रह्मपुत्र नदी के पास नीलाचल पहाड़ी के कामाख्या मंदिर की याद है?",
          as: "ব্ৰহ্মপুত্ৰৰ কাষৰ নীলাচল পাহাৰৰ পবিত্ৰ কামাখ্যা মন্দিৰলৈ যোৱাৰ কথা মনত আছেনে?"
        },
        subtitleEn: "Do you remember visiting the sacred Kamakhya Temple overlooking the Brahmaputra?",
        question1: {
          prompt: { en: "What place is this?", hi: "यह कौन सा स्थान है?", as: "এইখন কোনখন পবিত্ৰ ঠাই?" },
          options: [
            { text: { en: "Kamakhya Temple, Guwahati", hi: "कामाख्या मंदिर, गुवाहाटी", as: "কামাখ্যা মন্দিৰ, গুৱাহাটী" }, isCorrect: true },
            { text: { en: "Railway Station", hi: "रेलवे स्टेशन", as: "ৰে’ল ষ্টেচন" }, isCorrect: false },
            { text: { en: "Marketplace", hi: "बाजार", as: "বজাৰ" }, isCorrect: false }
          ]
        },
        question2: {
          prompt: { en: "Who used to accompany you here?", hi: "यहाँ आपके साथ कौन जाते थे?", as: "ইয়াত আপোনাৰ লগত কোন গৈছিল?" },
          options: [
            { text: { en: "Family & Loved Ones", hi: "परिवार और प्रियजन", as: "পৰিয়াল আৰু মৰমৰ মানুহ" }, isCorrect: true },
            { text: { en: "Alone", hi: "अकेले", as: "অকলশৰে" }, isCorrect: false }
          ]
        },
        story: {
          en: "You often walked up Nilachal Hill during early morning prayers, feeling the peaceful breeze and hearing the temple bells ring.",
          hi: "आप सुबह-सुबह नीलाचल पहाड़ी पर जाते थे, जहाँ ठंडी हवा और मंदिर की घंटियाँ मन को शांति देती थीं।",
          as: "আপুনি ৰাতিপুৱা নীলাচল পাহাৰত বতাহৰ সুবাস আৰু মন্দিৰৰ ঘণ্টাৰ ধ্বনি শুনি বৰ আনন্দ পাইছিল।"
        }
      },
      {
        id: "mem_tea_garden_dibrugarh",
        title: {
          en: "Lush Tea Gardens of Upper Assam",
          hi: "असम के हरे-भरे चाय बागान",
          as: "উজনি অসমৰ সেউজীয়া চাহ বাগিচা"
        },
        category: "nature",
        personName: "Morning Tea Routine",
        relation: "Cherished Routine",
        place: "Dibrugarh / Jorhat",
        iconKey: "tea_garden",
        audioPrompt: {
          en: "Look at the beautiful green tea gardens. What place does this remind you of?",
          hi: "इन सुंदर हरे चाय बागानों को देखें। यह आपको किस स्थान की याद दिलाता है?",
          as: "এই সেউজীয়া চাহ বাগিচাবোৰ চাওক। এই দৃশ্যই আপোনাক ক’লৈ মনত পেলায়?"
        },
        subtitleEn: "Look at the beautiful green tea gardens. What place does this remind you of?",
        question1: {
          prompt: { en: "What place is this?", hi: "यह कौन सी जगह है?", as: "এইখন কিহৰ বাগিচা?" },
          options: [
            { text: { en: "Assam Tea Garden", hi: "असम चाय बागान", as: "অসমৰ চাহ বাগিচা" }, isCorrect: true },
            { text: { en: "Crowded City", hi: "भीड़भाड़ वाला शहर", as: "নগৰৰ ভিৰ" }, isCorrect: false }
          ]
        },
        story: {
          en: "Fresh morning tea made with leaves harvested from these lush green estates has been a comfort every single morning.",
          hi: "इन बागानों की ताजी चाय की पत्तियों से बनी सुबह की चाय हमेशा आपकी पसंदीदा रही है।",
          as: "এই সেউজ বাগিচাৰ সতেজ চাহ পাতেৰে বনোৱা ৰাতিপুৱাৰ লাল চাহ আপোনাৰ চিৰপ্ৰিয়।"
        }
      }
    ]
  },

  orientation_game: {
    id: "game_006_orientation_game",
    type: "orientation_game",
    domain: "orientation_environment",
    icon: "calendar",
    title: {
      en: "Orientation Activity",
      hi: "दिशा और समय ज्ञान (Orientation Activity)",
      as: "দিশ আৰু সময়ৰ খেল"
    },
    description: {
      en: "Gentle stimulation for time, day, season, and environment awareness.",
      hi: "दिन, महीना, मौसम और अपने परिवेश के सरल और सहज सवाल।",
      as: "আজিৰ দিন, মাহ, বতৰ আৰু আপোনাৰ চৌপাশৰ সহজ কথাৰ খেল।"
    },
    questions: [
      {
        id: "ori_day",
        type: "day_of_week",
        prompt: {
          en: "What day is today?",
          hi: "आज कौन सा दिन है?",
          as: "আজি বাৰ কি?"
        },
        audioPrompt: {
          en: "Can you tell what day of the week today is?",
          hi: "क्या आप बता सकते हैं कि आज कौन सा दिन है?",
          as: "আজি সপ্তাহৰ কি বাৰ আপুনি ক’ব পাৰিবনে?"
        },
        subtitleEn: "What day is today?",
        options: [
          { key: "Sun", text: { en: "Sunday", hi: "रविवार (Sunday)", as: "দেওবাৰ (Sunday)" }, dayNum: 0 },
          { key: "Mon", text: { en: "Monday", hi: "सोमवार (Monday)", as: "সোমবাৰ (Monday)" }, dayNum: 1 },
          { key: "Tue", text: { en: "Tuesday", hi: "मंगलवार (Tuesday)", as: "মঙলবাৰ (Tuesday)" }, dayNum: 2 },
          { key: "Wed", text: { en: "Wednesday", hi: "बुधवार (Wednesday)", as: "বুধবাৰ (Wednesday)" }, dayNum: 3 },
          { key: "Thu", text: { en: "Thursday", hi: "गुरुवार (Thursday)", as: "বৃহস্পতিবাৰ (Thursday)" }, dayNum: 4 },
          { key: "Fri", text: { en: "Friday", hi: "शुक्रवार (Friday)", as: "শুক্ৰবাৰ (Friday)" }, dayNum: 5 },
          { key: "Sat", text: { en: "Saturday", hi: "शनिवार (Saturday)", as: "শনিবাৰ (Saturday)" }, dayNum: 6 }
        ]
      },
      {
        id: "ori_month",
        type: "month_of_year",
        prompt: {
          en: "What month is it currently?",
          hi: "अभी कौन सा महीना चल रहा है?",
          as: "এতিয়া কোনটো মাহ চলি আছে?"
        },
        audioPrompt: {
          en: "What month of the year is it right now?",
          hi: "अभी वर्ष का कौन सा महीना है?",
          as: "বছৰটোৰ এতিয়া কোনটো মাহ চলিছে?"
        },
        subtitleEn: "What month is it currently?",
        options: [
          { key: "Jan", text: { en: "January (মাঘ)", hi: "जनवरी", as: "জানুৱাৰী (মাঘ)" }, monthNum: 0 },
          { key: "Apr", text: { en: "April (ব’হাগ)", hi: "अप्रैल (बिहू)", as: "এপ্ৰিল (ব’হাগ)" }, monthNum: 3 },
          { key: "Sep", text: { en: "September (আহিন)", hi: "सितंबर", as: "ছেপ্টেম্বৰ (আহিন)" }, monthNum: 8 },
          { key: "Dec", text: { en: "December (পোহ)", hi: "दिसंबर", as: "ডিচেম্বৰ (পোহ)" }, monthNum: 11 }
        ]
      },
      {
        id: "ori_season",
        type: "season",
        prompt: {
          en: "What season is it right now?",
          hi: "अभी कौन सा मौसम (ऋतु) है?",
          as: "এতিয়া কোনটো ঋতু চলি আছে?"
        },
        audioPrompt: {
          en: "Look outside the window. What season is it?",
          hi: "खिड़की के बाहर देखें। अभी कौन सा मौसम है?",
          as: "খিৰিকীৰে বাহিৰলৈ চাওক। এতিয়া কোনটো ঋতু চলিছে?"
        },
        subtitleEn: "What season is it right now?",
        options: [
          { key: "spring", text: { en: "Spring (বসন্ত ঋতু / Spring)", hi: "वसंत ऋतु (Spring)", as: "বসন্ত ঋতু (Spring)" }, isCorrect: true },
          { key: "monsoon", text: { en: "Monsoon (বৰ্ষাকাল / Rainy)", hi: "वर्षा ऋतु (Monsoon)", as: "বৰ্ষাকাল (Monsoon)" }, isCorrect: true },
          { key: "autumn", text: { en: "Autumn (শৰৎকাল / Autumn)", hi: "शरद ऋतु (Autumn)", as: "শৰৎকাল (Autumn)" }, isCorrect: true },
          { key: "winter", text: { en: "Winter (শীতকাল / Winter)", hi: "शीत ऋतु (Winter)", as: "শীতকাল (Winter)" }, isCorrect: true }
        ]
      },
      {
        id: "ori_place",
        type: "place",
        prompt: {
          en: "Where are you right now?",
          hi: "अभी आप कहाँ पर हैं?",
          as: "এতিয়া আপুনি ক’ত আছে?"
        },
        audioPrompt: {
          en: "Where are you spending your time today?",
          hi: "आज आप कहाँ पर हैं?",
          as: "আজি আপুনি ক’ত সময় কটাইছে?"
        },
        subtitleEn: "Where are you right now?",
        options: [
          { key: "home", text: { en: "At Home with Family", hi: "परिवार के साथ घर पर", as: "পৰিয়ালৰ সৈতে আপোন ঘৰত" }, isCorrect: true },
          { key: "center", text: { en: "At Community Center", hi: "सामुदायिक केंद्र में", as: "সমাজঘৰ বা নামঘৰত" }, isCorrect: true },
          { key: "visit", text: { en: "Visiting Loved Ones", hi: "रिश्तेदारों के यहाँ", as: "আত্মীয়ৰ ঘৰত" }, isCorrect: true }
        ]
      },
      {
        id: "ori_weather",
        type: "weather",
        prompt: {
          en: "What is the weather like today?",
          hi: "आज मौसम कैसा है?",
          as: "আজিৰ বতৰটো কেনেকুৱা?"
        },
        audioPrompt: {
          en: "How does the weather feel today?",
          hi: "आज का मौसम कैसा महसूस हो रहा है?",
          as: "আজিৰ বতৰটো কেনেকুৱা অনুভৱ হৈছে?"
        },
        subtitleEn: "What is the weather like today?",
        options: [
          { key: "sunny", text: { en: "Sunny & Bright ☀️", hi: "धूप खिली हुई ☀️", as: "ৰ’দঘাই আৰু উজ্জ্বল ☀️" }, isCorrect: true },
          { key: "pleasant", text: { en: "Pleasant & Breezy 🍃", hi: "सुहावना और शीतल 🍃", as: "মনোৰম আৰু মৃদু বতাহ 🍃" }, isCorrect: true },
          { key: "rainy", text: { en: "Gentle Rain 🌧️", hi: "रिमझिम बारिश 🌧️", as: "বৰষুণৰ বতৰ 🌧️" }, isCorrect: true }
        ]
      },
      {
        id: "ori_helper",
        type: "helper",
        prompt: {
          en: "Who is supporting and helping you today?",
          hi: "आज आपकी देखभाल और मदद कौन कर रहे हैं?",
          as: "আজি আপোনাক কোনে সহায় কৰিছে?"
        },
        audioPrompt: {
          en: "Who is by your side helping you today?",
          hi: "आज आपके साथ कौन हैं?",
          as: "আজি আপোনাৰ কাষত থাকি কোনে মৰমেৰে সহায় কৰিছে?"
        },
        subtitleEn: "Who is supporting and helping you today?",
        options: [
          { key: "caregiver", text: { en: "Rahul (Caregiver / Son)", hi: "राहुल (बेटा / देखभालकर्ता)", as: "ৰাহুল (পুত্ৰ / শুশ্ৰূষাকাৰী)" }, isCorrect: true },
          { key: "daughter", text: { en: "Family Member / Daughter", hi: "परिवार / बेटी", as: "পৰিয়ালৰ সদস্য / জীয়ৰী" }, isCorrect: true },
          { key: "doctor", text: { en: "Visiting Doctor / Nurse", hi: "चिकित्सक / नर्स", as: "চিকিৎসক / নাৰ্ছ" }, isCorrect: true }
        ]
      }
    ]
  }
};