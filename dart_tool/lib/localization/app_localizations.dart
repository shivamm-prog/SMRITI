import 'app_language.dart';

class AppLocalizations {
  const AppLocalizations(this.language);
  final AppLanguage language;

  // Navigation
  String get home => switch (language) {
        AppLanguage.hindi => 'होम',
        AppLanguage.assamese => 'হোম',
        AppLanguage.nepali => 'गृहपृष्ठ',
        AppLanguage.manipuri => 'য়ুম',
        AppLanguage.khasi => 'Iing',
        AppLanguage.mizo => 'In',
        AppLanguage.nagamese => 'Ghor',
        AppLanguage.kokborok => 'Nok',
        _ => 'Home',
      };

  String get games => switch (language) {
        AppLanguage.hindi => 'गतिविधियाँ',
        AppLanguage.assamese => 'কাৰ্যকলাপ',
        AppLanguage.nepali => 'गतिविधिहरू',
        AppLanguage.manipuri => 'থবকশিং',
        AppLanguage.khasi => 'Ki Kam',
        AppLanguage.mizo => 'Thiltih te',
        AppLanguage.nagamese => 'Activities',
        AppLanguage.kokborok => 'Samung',
        _ => 'Activities',
      };

  String get memories => switch (language) {
        AppLanguage.hindi => 'यादें',
        AppLanguage.assamese => 'স্মৃতি',
        AppLanguage.nepali => 'सम्झनाहरू',
        AppLanguage.manipuri => 'নীংশিংবা',
        AppLanguage.khasi => 'Ki Jingkynmaw',
        AppLanguage.mizo => 'Hriatrengna te',
        AppLanguage.nagamese => 'Memories',
        AppLanguage.kokborok => 'Uanma',
        _ => 'Memories',
      };

  String get progress => switch (language) {
        AppLanguage.hindi => 'प्रगति',
        AppLanguage.assamese => 'অগ্ৰগতি',
        AppLanguage.nepali => 'प्रगति',
        AppLanguage.manipuri => 'চাউখৎপা',
        AppLanguage.khasi => 'Ka Jingroi',
        AppLanguage.mizo => 'Hmasawnna',
        AppLanguage.nagamese => 'Progress',
        AppLanguage.kokborok => 'Tangsa',
        _ => 'Progress',
      };

  String get profile => switch (language) {
        AppLanguage.hindi => 'प्रोफ़ाइल',
        AppLanguage.assamese => 'প্ৰফাইল',
        AppLanguage.nepali => 'प्रोफाइल',
        AppLanguage.manipuri => 'প্রোফাইল',
        AppLanguage.khasi => 'Profile',
        AppLanguage.mizo => 'Profile',
        AppLanguage.nagamese => 'Profile',
        AppLanguage.kokborok => 'Profile',
        _ => 'Profile',
      };

  // Greetings & Home
  String greeting(String name) => switch (language) {
        AppLanguage.hindi => 'सुप्रभात, $name',
        AppLanguage.assamese => 'সুপ্ৰভাত, $name',
        AppLanguage.nepali => 'शुभ प्रभात, $name',
        AppLanguage.manipuri => 'য়াইফরে, $name',
        AppLanguage.khasi => 'Kumno, $name',
        AppLanguage.mizo => 'Chibai, $name',
        AppLanguage.nagamese => 'Bhal ase, $name',
        AppLanguage.kokborok => 'Khumbar, $name',
        _ => 'Good morning, $name',
      };

  String get readyForActivity => switch (language) {
        AppLanguage.english => 'Ready for a gentle cognitive activity today?',
        AppLanguage.hindi => 'क्या आप आज थोड़ा शांत अभ्यास करना चाहेंगे?',
        AppLanguage.assamese => 'আজি অলপ শান্তভাৱে মনৰ অনুশীলন কৰিবলৈ সাজু নে?',
        _ => 'Ready for a gentle cognitive activity today?',
      };

  String get todayReminders => switch (language) {
        AppLanguage.english => "Today's Reminders",
        AppLanguage.hindi => 'आज के अनुस्मारक',
        AppLanguage.assamese => 'আজিৰ সোঁৱৰণী',
        _ => "Today's Reminders",
      };

  String remindersDone(int completed, int total) => switch (language) {
        AppLanguage.english => '$completed of $total done',
        AppLanguage.hindi => '$completed में से $total पूरे हुए',
        AppLanguage.assamese => '$total টাৰ ভিতৰত $completed টা সম্পন্ন হ’ল',
        _ => '$completed of $total done',
      };

  String get todayFeaturedActivity => switch (language) {
        AppLanguage.english => "Today's Featured Activity",
        AppLanguage.hindi => 'आज की अनुशंसित गतिविधि',
        AppLanguage.assamese => 'আজিৰ বিশেষ কাৰ্যকলাপ',
        _ => "Today's Featured Activity",
      };

  String get adaptiveRecommendationBadge => switch (language) {
        AppLanguage.english => 'Adaptive Recommendation',
        AppLanguage.hindi => 'आपके अनुसार अनुशंसित',
        AppLanguage.assamese => 'উপযুক্ত পৰামৰ্শ',
        _ => 'Adaptive Recommendation',
      };

  String get rotateActivity => switch (language) {
        AppLanguage.english => 'Try another activity',
        AppLanguage.hindi => 'दूसरी गतिविधि देखें',
        AppLanguage.assamese => 'আন কাৰ্যকলাপ চাওক',
        _ => 'Try another activity',
      };

  String get quickActivities => switch (language) {
        AppLanguage.english => 'Cognitive Activities',
        AppLanguage.hindi => 'संज्ञानात्मक गतिविधियाँ',
        AppLanguage.assamese => 'মনৰ কাৰ্যকলাপসমূহ',
        _ => 'Cognitive Activities',
      };

  String get viewAll => switch (language) {
        AppLanguage.english => 'View all',
        AppLanguage.hindi => 'सभी देखें',
        AppLanguage.assamese => 'সকলো চাওক',
        _ => 'View all',
      };

  String get memoryJournal => switch (language) {
        AppLanguage.english => 'Memory Journal',
        AppLanguage.hindi => 'स्मृति पत्रिका',
        AppLanguage.assamese => 'স্মৃতিৰ দিনলিপি',
        _ => 'Memory Journal',
      };

  String get lookAtPhotos => switch (language) {
        AppLanguage.english => 'Cherished North-East memories & gentle recall prompts.',
        AppLanguage.hindi => 'पूर्वोत्तर की प्रिय यादें और सौम्य स्मरण अभ्यास।',
        AppLanguage.assamese => 'উত্তৰ-পূবৰ মনপৰশা স্মৃতি আৰু চিনাকি সোঁৱৰণ।',
        _ => 'Cherished North-East memories & gentle recall prompts.',
      };

  String get openJournal => switch (language) {
        AppLanguage.english => 'Open Memory Journal',
        AppLanguage.hindi => 'स्मृति पत्रिका खोलें',
        AppLanguage.assamese => 'স্মৃতিৰ দিনলিপি খোলক',
        _ => 'Open Memory Journal',
      };

  String get dayStreak => switch (language) {
        AppLanguage.english => 'Day Streak',
        AppLanguage.hindi => 'दिनों का सिलसिला',
        AppLanguage.assamese => 'ধাৰাবাহিক দিন',
        _ => 'Day Streak',
      };

  String get activitiesDone => switch (language) {
        AppLanguage.english => 'Activities Done',
        AppLanguage.hindi => 'पूर्ण गतिविधियाँ',
        AppLanguage.assamese => 'সম্পূৰ্ণ কাৰ্যকলাপ',
        _ => 'Activities Done',
      };

  String get averageAccuracy => switch (language) {
        AppLanguage.english => 'Avg Accuracy',
        AppLanguage.hindi => 'औसत सटीकता',
        AppLanguage.assamese => 'গড় নিখুঁততা',
        _ => 'Avg Accuracy',
      };

  String get practiceMinutes => switch (language) {
        AppLanguage.english => 'Practice Minutes',
        AppLanguage.hindi => 'अभ्यास के मिनट',
        AppLanguage.assamese => 'অনুশীলন সময়',
        _ => 'Practice Minutes',
      };

  String get startActivity => switch (language) {
        AppLanguage.english => 'Start Activity',
        AppLanguage.hindi => 'गतिविधि शुरू करें',
        AppLanguage.assamese => 'কাৰ্যকলাপ আৰম্ভ কৰক',
        _ => 'Start Activity',
      };

  // Activity Titles, Categories & Descriptions
  String get teaRoutineTitle => switch (language) {
        AppLanguage.english => 'Making Morning Assam Tea',
        AppLanguage.hindi => 'सुबह की असम चाय बनाना',
        AppLanguage.assamese => 'ৰাতিপুৱাৰ অসমীয়া চাহ তৈয়াৰ',
        _ => 'Making Morning Assam Tea',
      };

  String get teaRoutineSubtitle => switch (language) {
        AppLanguage.english => 'Morning Routine · 3–5 mins',
        AppLanguage.hindi => 'सुबह की दिनचर्या · ३–५ मिनट',
        AppLanguage.assamese => 'ৰাতিপুৱাৰ নিয়ম · ৩–৫ মিনিট',
        _ => 'Morning Routine · 3–5 mins',
      };

  String get teaRoutineDesc => switch (language) {
        AppLanguage.english => 'A gentle sequence activity to brew warm, fragrant tea step by step.',
        AppLanguage.hindi => 'गरम और सुगंधित चाय बनाने का एक शांत क्रमिक अभ्यास।',
        AppLanguage.assamese => 'এঢোক সুগন্ধি চাহ তৈয়াৰ কৰাৰ এটা শান্ত ক্ৰমিক অনুশীলন।',
        _ => 'A gentle sequence activity to brew warm, fragrant tea step by step.',
      };

  String get cardMatchTitle => switch (language) {
        AppLanguage.english => 'Cultural Pairs of the Hills',
        AppLanguage.hindi => 'पहाड़ों के सांस्कृतिक जोड़े',
        AppLanguage.assamese => 'পাহাৰৰ সাংস্কৃতিক যোৰা',
        _ => 'Cultural Pairs of the Hills',
      };

  String get cardMatchSubtitle => switch (language) {
        AppLanguage.english => 'Visual Matching · 2–4 mins',
        AppLanguage.hindi => 'दृश्य मिलान · २–४ मिनट',
        AppLanguage.assamese => 'দৃশ্যমান মিলন · ২–৪ মিনিট',
        _ => 'Visual Matching · 2–4 mins',
      };

  String get cardMatchDesc => switch (language) {
        AppLanguage.english => 'Match culturally familiar pairs of North-Eastern instruments, wildlife and textiles.',
        AppLanguage.hindi => 'पूर्वोत्तर के वाद्ययंत्रों, वन्यजीवों और वस्त्रों के जाने-पहचाने जोड़े मिलाएँ।',
        AppLanguage.assamese => 'উত্তৰ-পূবৰ বাদ্যযন্ত্ৰ, বন্যপ্ৰাণী আৰু কাপোৰৰ চিনাকি যোৰাবোৰ মিলাওক।',
        _ => 'Match culturally familiar pairs of North-Eastern instruments, wildlife and textiles.',
      };

  String get memoriesTitle => switch (language) {
        AppLanguage.english => 'Familiar Places & Memories',
        AppLanguage.hindi => 'परिचित स्थान और यादें',
        AppLanguage.assamese => 'পৰিচিত স্থান আৰু স্মৃতি',
        _ => 'Familiar Places & Memories',
      };

  String get memoriesSubtitle => switch (language) {
        AppLanguage.english => 'Memory Recall · 3–5 mins',
        AppLanguage.hindi => 'स्मृति स्मरण · ३–५ मिनट',
        AppLanguage.assamese => 'স্মৃতি সোঁৱৰণ · ৩–৫ মিনিট',
        _ => 'Memory Recall · 3–5 mins',
      };

  String get memoriesDesc => switch (language) {
        AppLanguage.english => 'Reflect on joyful moments of Rongali Bihu and Kaziranga travels.',
        AppLanguage.hindi => 'रंगाली बिहू और काज़ीरंगा यात्रा के सुखद पलों को याद करें।',
        AppLanguage.assamese => 'ৰঙালী বিহু আৰু কাজিৰঙা ভ্ৰমণৰ আনন্দময় মুহূৰ্তবোৰ মনত পেলাওক।',
        _ => 'Reflect on joyful moments of Rongali Bihu and Kaziranga travels.',
      };

  String get natureSpottingTitle => switch (language) {
        AppLanguage.english => 'Gentle Nature Spotting',
        AppLanguage.hindi => 'शांत प्रकृति दर्शन',
        AppLanguage.assamese => 'শান্ত প্ৰকৃতি নিৰীক্ষণ',
        _ => 'Gentle Nature Spotting',
      };

  String get natureSpottingSubtitle => switch (language) {
        AppLanguage.english => 'Visual Attention · 2–3 mins',
        AppLanguage.hindi => 'दृश्य ध्यान · २–३ मिनट',
        AppLanguage.assamese => 'দৃষ্টি মনোযোগ · ২–৩ মিনিট',
        _ => 'Visual Attention · 2–3 mins',
      };

  String get natureSpottingDesc => switch (language) {
        AppLanguage.english => 'Spot the one-horned rhino and vibrant birds in Assam grasslands.',
        AppLanguage.hindi => 'असम के मैदानों में एक सींग वाला गैंडा और सुंदर पक्षी देखें।',
        AppLanguage.assamese => 'অসমৰ ঘাঁহনিত এশিঙীয়া গঁড় আৰু সুন্দৰ চৰাইবোৰ বিচাৰক।',
        _ => 'Spot the one-horned rhino and vibrant birds in Assam grasslands.',
      };

  // Game Gameplay & Instructions
  String get sequenceGameTitle => switch (language) {
        AppLanguage.english => 'Making Morning Assam Tea',
        AppLanguage.hindi => 'सुबह की असम चाय बनाना',
        AppLanguage.assamese => 'ৰাতিপুৱাৰ অসমীয়া চাহ তৈয়াৰ',
        _ => 'Making Morning Assam Tea',
      };

  String get teaSequenceInstructions => switch (language) {
        AppLanguage.english => 'Tap each step card in the correct order:',
        AppLanguage.hindi => 'चाय बनाने के लिए सही क्रम में प्रत्येक चरण को छुएँ:',
        AppLanguage.assamese => 'চাহ তৈয়াৰ কৰিবলৈ সঠিক ক্ৰমত প্ৰতিটো কাৰ্ডত স্পৰ্শ কৰক:',
        _ => 'Tap each step card in the correct order:',
      };

  String get stepBoilWater => switch (language) {
        AppLanguage.english => 'Boil Fresh Water',
        AppLanguage.hindi => 'ताज़ा पानी उबालें',
        AppLanguage.assamese => 'পানী উতলাওক',
        _ => 'Boil Fresh Water',
      };

  String get stepBoilWaterDesc => switch (language) {
        AppLanguage.english => 'Heat water in the kettle until bubbling.',
        AppLanguage.hindi => 'केतली में पानी को उबलने तक गरम करें।',
        AppLanguage.assamese => 'কেটলীত পানী উতলিবলৈ দিয়ক।',
        _ => 'Heat water in the kettle until bubbling.',
      };

  String get stepTeaLeaves => switch (language) {
        AppLanguage.english => 'Add Assam Tea Leaves',
        AppLanguage.hindi => 'असम चाय की पत्ती डालें',
        AppLanguage.assamese => 'অসমীয়া চাহ পাত দিয়ক',
        _ => 'Add Assam Tea Leaves',
      };

  String get stepTeaLeavesDesc => switch (language) {
        AppLanguage.english => 'Add aromatic black tea leaves to the boiling water.',
        AppLanguage.hindi => 'उबलते पानी में सुगंधित चाय पत्ती डालें।',
        AppLanguage.assamese => 'উতলা পানীত সুগন্ধি চাহ পাত দিয়ক।',
        _ => 'Add aromatic black tea leaves to the boiling water.',
      };

  String get stepGingerMilk => switch (language) {
        AppLanguage.english => 'Add Ginger & Milk',
        AppLanguage.hindi => 'अदरक और दूध डालें',
        AppLanguage.assamese => 'আদা আৰু গাখীৰ দিয়ক',
        _ => 'Add Ginger & Milk',
      };

  String get stepGingerMilkDesc => switch (language) {
        AppLanguage.english => 'Crush fresh ginger and pour warm milk to taste.',
        AppLanguage.hindi => 'ताज़ा अदरक कूटें और स्वादानुसार दूध मिलाएँ।',
        AppLanguage.assamese => 'কেঁচা আদা খুন্দি দিয়ক আৰু সোৱাদ অনুসৰি গাখীৰ দিয়ক।',
        _ => 'Crush fresh ginger and pour warm milk to taste.',
      };

  String get stepStrainCup => switch (language) {
        AppLanguage.english => 'Strain Into Cup',
        AppLanguage.hindi => 'कप में छानें',
        AppLanguage.assamese => 'কাপত চাকি দিয়ক',
        _ => 'Strain Into Cup',
      };

  String get stepStrainCupDesc => switch (language) {
        AppLanguage.english => 'Pour the rich, warm tea through a strainer into your cup.',
        AppLanguage.hindi => 'छलनी से छानकर गरम चाय अपने कप में डालें।',
        AppLanguage.assamese => 'চাকনিৰে চাকি গৰম চাহ কাপত ঢালিব।',
        _ => 'Pour the rich, warm tea through a strainer into your cup.',
      };

  String get feedbackCorrectStep => switch (language) {
        AppLanguage.english => 'Splendid! Step completed correctly.',
        AppLanguage.hindi => 'शानदार! सही कदम पूरा हुआ।',
        AppLanguage.assamese => 'বৰ ধুনীয়া! সঠিক খোজ লোৱা হৈছে।',
        _ => 'Splendid! Step completed correctly.',
      };

  String get feedbackBoilFirst => switch (language) {
        AppLanguage.english => 'Gentle reminder: Boil the water first.',
        AppLanguage.hindi => 'कृपया ध्यान दें: पहले पानी उबालना होगा।',
        AppLanguage.assamese => 'ধীৰে মনত পেলাওক: প্ৰথমে পানী উতলাব লাগিব।',
        _ => 'Gentle reminder: Boil the water first.',
      };

  String get feedbackLeavesSecond => switch (language) {
        AppLanguage.english => 'Almost there: Add tea leaves to the boiling water next.',
        AppLanguage.hindi => 'उबलते पानी में अब चाय पत्ती डालें।',
        AppLanguage.assamese => 'প্ৰায় হ’ল: এতিয়া উতলা পানীত চাহ পাত দিয়ক।',
        _ => 'Almost there: Add tea leaves to the boiling water next.',
      };

  String get feedbackMilkThird => switch (language) {
        AppLanguage.english => 'Good thought! Add ginger and milk before straining.',
        AppLanguage.hindi => 'छानने से पहले अदरक और दूध मिलाएँ।',
        AppLanguage.assamese => 'ভাল ভাবিছে! চাকি দিয়াৰ আগতে আদা আৰু গাখীৰ দিয়ক।',
        _ => 'Good thought! Add ginger and milk before straining.',
      };

  String get feedbackStrainLast => switch (language) {
        AppLanguage.english => 'Save straining for the very last step into the cup.',
        AppLanguage.hindi => 'चाय को सबसे अंत में कप में छाना जाता है।',
        AppLanguage.assamese => 'সকলো শেষতহে কাপত চাহ চাকি দিব লাগে।',
        _ => 'Save straining for the very last step into the cup.',
      };

  String get congratulations => switch (language) {
        AppLanguage.english => 'Congratulations! Tea Is Ready',
        AppLanguage.hindi => 'बधाई हो! चाय तैयार है',
        AppLanguage.assamese => 'অভিনন্দন! চাহ প্ৰস্তুত হ’ল',
        _ => 'Congratulations! Tea Is Ready',
      };

  String get congratulationsDesc => switch (language) {
        AppLanguage.english => 'You brewed a wonderful, aromatic cup of morning Assam tea in the perfect sequence.',
        AppLanguage.hindi => 'आपने बिल्कुल सही क्रम में सुबह की स्वादिष्ट असम चाय तैयार कर ली।',
        AppLanguage.assamese => 'আপুনি সঠিক ক্ৰমত এঢোক অতি সুস্বাদু ৰাতিপুৱাৰ অসমীয়া চাহ তৈয়াৰ কৰিলে।',
        _ => 'You brewed a wonderful, aromatic cup of morning Assam tea in the perfect sequence.',
      };

  String get playAgain => switch (language) {
        AppLanguage.english => 'Play Again',
        AppLanguage.hindi => 'फिर से खेलें',
        AppLanguage.assamese => 'পুনৰ খেলক',
        _ => 'Play Again',
      };

  String get finishActivity => switch (language) {
        AppLanguage.english => 'Complete & Return Home',
        AppLanguage.hindi => 'पूरा करें और होम पर लौटें',
        AppLanguage.assamese => 'সম্পন্ন কৰি ঘৰলৈ উভতি যাওক',
        _ => 'Complete & Return Home',
      };

  String get moves => switch (language) {
        AppLanguage.english => 'Moves',
        AppLanguage.hindi => 'कदम',
        AppLanguage.assamese => 'খোজ',
        _ => 'Moves',
      };

  String get time => switch (language) {
        AppLanguage.english => 'Time',
        AppLanguage.hindi => 'समय',
        AppLanguage.assamese => 'সময়',
        _ => 'Time',
      };

  // Cultural Matching Game
  String get matchingInstructions => switch (language) {
        AppLanguage.english => 'Tap two cards to find culturally familiar matching pairs:',
        AppLanguage.hindi => 'दो कार्ड पलटकर जाने-पहचाने सांस्कृतिक जोड़े मिलाएँ:',
        AppLanguage.assamese => 'কাৰ্ড উলটাই সাংস্কৃতিকভাৱে চিনাকি যোৰাবোৰ মিলাওক:',
        _ => 'Tap two cards to find culturally familiar matching pairs:',
      };

  String get pairsFound => switch (language) {
        AppLanguage.english => 'Pairs Found',
        AppLanguage.hindi => 'जोड़े मिले',
        AppLanguage.assamese => 'যোৰা মিলিল',
        _ => 'Pairs Found',
      };

  String get greatMatch => switch (language) {
        AppLanguage.english => 'Great match!',
        AppLanguage.hindi => 'शानदार मेल!',
        AppLanguage.assamese => 'বৰ সুন্দৰ মিলিল!',
        _ => 'Great match!',
      };

  String get cardMismatchInstruction => switch (language) {
        AppLanguage.english => 'Not quite a match. Tap another card.',
        AppLanguage.hindi => 'यह मेल नहीं खाया। दूसरा कार्ड चुनें।',
        AppLanguage.assamese => 'মিলা নাই। আন এখন কাৰ্ডত স্পৰ্শ কৰক।',
        _ => 'Not quite a match. Tap another card.',
      };

  String get matchingCompleteTitle => switch (language) {
        AppLanguage.english => 'Wonderful! All Pairs Matched',
        AppLanguage.hindi => 'शानदार! सभी जोड़े मिल गए',
        AppLanguage.assamese => 'অপূৰ্ব! সকলো যোৰা মিলিল',
        _ => 'Wonderful! All Pairs Matched',
      };

  String get matchingCompleteDesc => switch (language) {
        AppLanguage.english => 'You have matched all culturally familiar North-Eastern symbols.',
        AppLanguage.hindi => 'आपने पूर्वोत्तर के सभी सांस्कृतिक प्रतीकों को सफलतापूर्वक मिला दिया।',
        AppLanguage.assamese => 'আপুনি উত্তৰ-পূবৰ সকলো চিনাকি প্ৰতীক সফলতাৰে মিলাই তুলিলে।',
        _ => 'You have matched all culturally familiar North-Eastern symbols.',
      };

  String get cardBihuPepa => switch (language) {
        AppLanguage.english => 'Bihu Pepa (Horn Pipe)',
        AppLanguage.hindi => 'बिहू पेपा (सींग की बांसुरी)',
        AppLanguage.assamese => 'বিহু পেঁপা',
        _ => 'Bihu Pepa (Horn Pipe)',
      };

  String get cardRhino => switch (language) {
        AppLanguage.english => 'Kaziranga Rhino',
        AppLanguage.hindi => 'काज़ीरंगा का गैंडा',
        AppLanguage.assamese => 'কাজিৰঙাৰ এশিঙীয়া গঁড়',
        _ => 'Kaziranga Rhino',
      };

  String get cardAssamTea => switch (language) {
        AppLanguage.english => 'Assam Tea Leaves',
        AppLanguage.hindi => 'असम चाय की पत्ती',
        AppLanguage.assamese => 'অসমীয়া চাহ পাত',
        _ => 'Assam Tea Leaves',
      };

  // Reminders Localized
  String reminderTitle(String id, String defaultTitle) => switch (id) {
        'rem_1' => switch (language) {
            AppLanguage.english => 'Morning Blood Pressure & Vitamin',
            AppLanguage.hindi => 'सुबह की बीपी और विटामिन की गोली',
            AppLanguage.assamese => 'ৰাতিপুৱাৰ ৰক্তচাপ আৰু ভিটামিনৰ ঔষধ',
        _ => 'Morning Blood Pressure & Vitamin',
          },
        'rem_2' => switch (language) {
            AppLanguage.english => 'Warm Lemongrass & Ginger Tea',
            AppLanguage.hindi => 'गरम लेमनग्रास और अदरक की चाय',
            AppLanguage.assamese => 'গৰম নেমু-ঘাঁহ আৰু আদা চাহ',
        _ => 'Warm Lemongrass & Ginger Tea',
          },
        'rem_3' => switch (language) {
            AppLanguage.english => 'Lunch with Fresh Masor Tenga',
            AppLanguage.hindi => 'दोपहर का खाना: ताज़ा माछोर टेंगा',
            AppLanguage.assamese => 'দুপৰীয়াৰ মাছৰ টেঙা আৰু ভাত',
        _ => 'Lunch with Fresh Masor Tenga',
          },
        'rem_4' => switch (language) {
            AppLanguage.english => 'Gentle Garden Stroll',
            AppLanguage.hindi => 'बगीचे में शांत चहलकदमी',
            AppLanguage.assamese => 'ফুলনিত শান্ত খোজ কঢ়া',
        _ => 'Gentle Garden Stroll',
          },
        _ => defaultTitle,
      };

  String reminderInstructions(String id, String defaultInstructions) => switch (id) {
        'rem_1' => switch (language) {
            AppLanguage.english => 'Take 1 tablet with warm water after breakfast',
            AppLanguage.hindi => 'नाश्ते के बाद गुनगुने पानी के साथ १ गोली लें',
            AppLanguage.assamese => 'ৰাতিপুৱাৰ আহাৰৰ পাছত গৰম পানীৰে ১টা টেবলেট খাব',
        _ => 'Take 1 tablet with warm water after breakfast',
          },
        'rem_2' => switch (language) {
            AppLanguage.english => 'Sip slowly and enjoy a quiet rest in the veranda',
            AppLanguage.hindi => 'बरामदे में आराम से बैठकर धीरे-धीरे पिएँ',
            AppLanguage.assamese => 'বাৰাণ্ডাত বহি জুৰ লৈ লাহে লাহে চাহ খাওক',
        _ => 'Sip slowly and enjoy a quiet rest in the veranda',
          },
        'rem_3' => switch (language) {
            AppLanguage.english => 'Wholesome rice and mild fish broth prepared fresh',
            AppLanguage.hindi => 'पौष्टिक चावल और ताज़ी मछली का पतला शोरबा',
            AppLanguage.assamese => 'পুষ্টিকৰ ভাত আৰু সতেজ মাছৰ টেঙা জোল',
        _ => 'Wholesome rice and mild fish broth prepared fresh',
          },
        'rem_4' => switch (language) {
            AppLanguage.english => '15-minute peaceful walk to admire the flowers',
            AppLanguage.hindi => 'फूलों को देखते हुए १५ मिनट शांति से टहलें',
            AppLanguage.assamese => 'ফুলবোৰ চাই ১৫ মিনিট শান্তভাৱে খোজ কাঢ়ক',
        _ => '15-minute peaceful walk to admire the flowers',
          },
        _ => defaultInstructions,
      };

  String reminderCategory(String cat) => switch (cat.toLowerCase()) {
        'medicine' => switch (language) {
            AppLanguage.english => 'Medicine',
            AppLanguage.hindi => 'दवाई',
            AppLanguage.assamese => 'ঔষধ',
        _ => 'Medicine',
          },
        'hydration' => switch (language) {
            AppLanguage.english => 'Hydration',
            AppLanguage.hindi => 'पेय',
            AppLanguage.assamese => 'পানী / চাহ',
        _ => 'Hydration',
          },
        'meal' => switch (language) {
            AppLanguage.english => 'Meal',
            AppLanguage.hindi => 'भोजन',
            AppLanguage.assamese => 'আহাৰ',
        _ => 'Meal',
          },
        'gentle walk' => switch (language) {
            AppLanguage.english => 'Gentle Walk',
            AppLanguage.hindi => 'टहलना',
            AppLanguage.assamese => 'খোজ কঢ়া',
        _ => 'Gentle Walk',
          },
        _ => cat,
      };

  String get verifiedByCaregiver => switch (language) {
        AppLanguage.english => 'Verified by Caregiver ✓',
        AppLanguage.hindi => 'देखभालकर्ता द्वारा सत्यापित ✓',
        AppLanguage.assamese => 'তত্ত্বাৱধায়কে পৰীক্ষা কৰিছে ✓',
        _ => 'Verified by Caregiver ✓',
      };

  // Memories Localized
  String memoryTitle(String id, String defaultTitle) => switch (id) {
        'mem_bihu' => switch (language) {
            AppLanguage.english => 'Rongali Bihu with Grandchildren',
            AppLanguage.hindi => 'पोते-पोतियों के साथ रंगाली बिहू',
            AppLanguage.assamese => 'নাতি-নাতিনীৰ সৈতে ৰঙালী বিহু',
        _ => 'Rongali Bihu with Grandchildren',
          },
        'mem_kaziranga' => switch (language) {
            AppLanguage.english => 'Visit to Kaziranga National Park',
            AppLanguage.hindi => 'काज़ीरंगा राष्ट्रीय उद्यान की यात्रा',
            AppLanguage.assamese => 'কাজিৰঙা ৰাষ্ট্ৰীয় উদ্যান ভ্ৰমণ',
        _ => 'Visit to Kaziranga National Park',
          },
        _ => defaultTitle,
      };

  String memoryDesc(String id, String defaultDesc) => switch (id) {
        'mem_bihu' => switch (language) {
            AppLanguage.english =>
              'We gathered on the veranda wearing our festive Muga Gamusas. Joy danced to the cheerful dhol rhythm, and we shared sweet warm Til Pitha and freshly brewed Assam tea.',
            AppLanguage.hindi =>
              'हम मुगा गमोसा पहनकर बरामदे में एकत्र हुए। पोते ने ढोल पर नृत्य किया और हमने मीठे तिल पीठा और ताज़ा बनी असम चाय का आनंद लिया।',
            AppLanguage.assamese =>
              'আমি মুগাৰ গামোচা পিন্ধি বাৰাণ্ডাত গোট খাইছিলো। নাতিয়ে ঢোলৰ তালে তালে নাচিছিল আৰু আমি তিল পিঠা আৰু গৰম চাহ খাইছিলো।',
        _ => 'We gathered on the veranda wearing our festive Muga Gamusas. Joy danced to the cheerful dhol rhythm, and we shared sweet warm Til Pitha and freshly brewed Assam tea.',
          },
        'mem_kaziranga' => switch (language) {
            AppLanguage.english =>
              'The soft golden morning mist was rising over elephant grass. We watched a majestic mother rhino and her gentle calf grazing quietly near the stream.',
            AppLanguage.hindi =>
              'सुनहरी सुबह का कोहरा और हाथी घास। हमने नाले के पास एक मां गैंडे और उसके छोटे बच्चे को शांति से चरते देखा।',
            AppLanguage.assamese =>
              'সোণালী পুৱাৰ কুঁৱলী ফালি ওলোৱা ঘাঁহনি। আমি জুৰিৰ পাৰত এজনী মাতৃ গঁড় আৰু তাইৰ পোৱালীটোক শান্তভাৱে চৰি থকা দেখিছিলো।',
        _ => 'The soft golden morning mist was rising over elephant grass. We watched a majestic mother rhino and her gentle calf grazing quietly near the stream.',
          },
        _ => defaultDesc,
      };

  String memoryQuizPrompt(String id, String defaultPrompt) => switch (id) {
        'mem_bihu' => switch (language) {
            AppLanguage.english => 'Who was dancing to the joyful Bihu drum in the courtyard?',
            AppLanguage.hindi => 'आंगन में ढोल की थाप पर कौन नाच रहा था?',
            AppLanguage.assamese => 'চোতালত ঢোলৰ তালে তালে কোনে আনন্দমনে নাচিছিল?',
        _ => 'Who was dancing to the joyful Bihu drum in the courtyard?',
          },
        'mem_kaziranga' => switch (language) {
            AppLanguage.english => 'What majestic animal did you admire grazing near the stream?',
            AppLanguage.hindi => 'नाले के पास चरते हुए आपने किस भव्य जानवर को देखा था?',
            AppLanguage.assamese => 'জুৰিৰ পাৰত শান্তভাৱে চৰি থকা কোনটো ডাঙৰ প্ৰাণী আপুনি দেখিছিল?',
        _ => 'What majestic animal did you admire grazing near the stream?',
          },
        _ => defaultPrompt,
      };

  String get recallPromptLabel => switch (language) {
        AppLanguage.english => 'Gentle Recall Question',
        AppLanguage.hindi => 'स्मरण प्रश्न',
        AppLanguage.assamese => 'মনত পেলোৱা প্ৰশ্ন',
        _ => 'Gentle Recall Question',
      };

  String get hintLabel => switch (language) {
        AppLanguage.english => 'Helpful Hint',
        AppLanguage.hindi => 'मददगार संकेत',
        AppLanguage.assamese => 'সহায়কাৰী ইংগিত',
        _ => 'Helpful Hint',
      };

  // Auth & Roles
  String get signInTitle => switch (language) {
        AppLanguage.english => 'Sign In to MindSetu',
        AppLanguage.hindi => 'माइंडसेतु में साइन इन करें',
        AppLanguage.assamese => 'মাইণ্ডসেতুত প্ৰৱেশ কৰক',
        _ => 'Sign In to MindSetu',
      };

  String get signUpTitle => switch (language) {
        AppLanguage.english => 'Create MindSetu Account',
        AppLanguage.hindi => 'नया खाता बनाएँ',
        AppLanguage.assamese => 'নতুন একাউণ্ট খোলক',
        _ => 'Create MindSetu Account',
      };

  String get selectRole => switch (language) {
        AppLanguage.english => 'Select Your Role',
        AppLanguage.hindi => 'अपनी भूमिका चुनें',
        AppLanguage.assamese => 'আপোনাৰ ভূমিকা বাছক',
        _ => 'Select Your Role',
      };

  String get patientRoleLabel => switch (language) {
        AppLanguage.english => 'Patient',
        AppLanguage.hindi => 'मरीज',
        AppLanguage.assamese => 'জ্যেষ্ঠ ৰোগী',
        _ => 'Patient',
      };

  String get caregiverRoleLabel => switch (language) {
        AppLanguage.english => 'Caregiver',
        AppLanguage.hindi => 'देखभालकर्ता',
        AppLanguage.assamese => 'তত্ত্বাৱধায়ক',
        _ => 'Caregiver',
      };

  String get doctorRoleLabel => switch (language) {
        AppLanguage.english => 'Doctor',
        AppLanguage.hindi => 'चिकित्सक',
        AppLanguage.assamese => 'চিকিৎসক',
        _ => 'Doctor',
      };

  String get emailLabel => switch (language) {
        AppLanguage.english => 'Email Address',
        AppLanguage.hindi => 'ईमेल पता',
        AppLanguage.assamese => 'ইমেইল ঠিকনা',
        _ => 'Email Address',
      };

  String get passwordLabel => switch (language) {
        AppLanguage.english => 'Password',
        AppLanguage.hindi => 'पासवर्ड',
        AppLanguage.assamese => 'পাছৱৰ্ড',
        _ => 'Password',
      };

  String get fullNameLabel => switch (language) {
        AppLanguage.english => 'Full Name',
        AppLanguage.hindi => 'पूरा नाम',
        AppLanguage.assamese => 'সম্পূৰ্ণ নাম',
        _ => 'Full Name',
      };

  String get signInButton => switch (language) {
        AppLanguage.english => 'Sign In',
        AppLanguage.hindi => 'साइन इन करें',
        AppLanguage.assamese => 'প্ৰৱেশ কৰক',
        _ => 'Sign In',
      };

  String get signUpButton => switch (language) {
        AppLanguage.english => 'Create Account',
        AppLanguage.hindi => 'खाता बनाएँ',
        AppLanguage.assamese => 'একাউণ্ট খোলক',
        _ => 'Create Account',
      };

  String get logOut => switch (language) {
        AppLanguage.english => 'Log Out',
        AppLanguage.hindi => 'लॉग आउट',
        AppLanguage.assamese => 'প্ৰস্থান কৰক',
        _ => 'Log Out',
      };

  String get demoAccountsHeader => switch (language) {
        AppLanguage.english => '1-Tap Demo Logins (Instant Demonstration)',
        AppLanguage.hindi => 'त्वरित डेमो लॉगिन (तुरंत परीक्षण करें)',
        AppLanguage.assamese => '১-স্পৰ্শত ডেমো প্ৰৱেশ (প্ৰদৰ্শনৰ বাবে)',
        _ => '1-Tap Demo Logins (Instant Demonstration)',
      };

  // Activities & Games List Screen
  String get activitiesListTitle => switch (language) {
        AppLanguage.english => 'Cognitive Activities',
        AppLanguage.hindi => 'संज्ञानात्मक गतिविधियाँ',
        AppLanguage.assamese => 'মনৰ কাৰ্যকলাপসমূহ',
        _ => 'Cognitive Activities',
      };

  String get activitiesListSubtitle => switch (language) {
        AppLanguage.english => 'Choose a gentle activity. Take all the time you need.',
        AppLanguage.hindi => 'कोई भी शांत गतिविधि चुनें। आराम से अपना समय लें।',
        AppLanguage.assamese => 'যিকোনো এটা শান্ত কাৰ্যকলাপ বাছক। আপোনাৰ সময় লওক।',
        _ => 'Choose a gentle activity. Take all the time you need.',
      };

  String get teaRoutineDetail => switch (language) {
        AppLanguage.english => 'Arrange the 4 steps of brewing Assam tea in order',
        AppLanguage.hindi => 'असम चाय बनाने के ४ चरणों को सही क्रम में सजाएँ',
        AppLanguage.assamese => 'অসমীয়া চাহ তৈয়াৰ কৰাৰ ৪টা খোজ ক্ৰমত সজাওক',
        _ => 'Arrange the 4 steps of brewing Assam tea in order',
      };

  String get cardMatchDetail => switch (language) {
        AppLanguage.english => 'Flip and match familiar North-East treasures',
        AppLanguage.hindi => 'पूर्वोत्तर की जानी-पहचानी सांस्कृतिक वस्तुएं मिलाएँ',
        AppLanguage.assamese => 'উত্তৰ-পূবৰ চিনাকি সম্পদ আৰু প্ৰতীকবোৰ মিলাওক',
        _ => 'Flip and match familiar North-East treasures',
      };

  String get pictureRecallTitle => switch (language) {
        AppLanguage.english => 'Cherished Picture Recall',
        AppLanguage.hindi => 'तस्वीरों से सुखद स्मरण',
        AppLanguage.assamese => 'মনপৰশা ছবি সোঁৱৰণ',
        _ => 'Cherished Picture Recall',
      };

  String get pictureRecallDetail => switch (language) {
        AppLanguage.english => 'Look closely at cultural scenes and remember the details',
        AppLanguage.hindi => 'सांस्कृतिक चित्रों को ध्यान से देखें और याद करें',
        AppLanguage.assamese => 'সাংস্কৃতিক ছবিবোৰ ভালদৰে চাই মনত পেলাওক',
        _ => 'Look closely at cultural scenes and remember the details',
      };

  String get householdRoutineTitle => switch (language) {
        AppLanguage.english => 'Household Morning Routine',
        AppLanguage.hindi => 'घर की सुबह की दिनचर्या',
        AppLanguage.assamese => 'ঘৰৰ ৰাতিপুৱাৰ নিয়ম',
        _ => 'Household Morning Routine',
      };

  String get householdRoutineDetail => switch (language) {
        AppLanguage.english => 'Continue familiar everyday step-by-step sequences',
        AppLanguage.hindi => 'दैनिक जीवन के परिचित क्रमिक कार्य जारी रखें',
        AppLanguage.assamese => 'দৈনন্দিন জীৱনৰ চিনাকি খোজবোৰ আগবঢ়াওক',
        _ => 'Continue familiar everyday step-by-step sequences',
      };

  String get offlineActivitiesBanner => switch (language) {
        AppLanguage.english => 'All activities run completely offline and save your progress automatically on this device.',
        AppLanguage.hindi => 'सभी गतिविधियाँ पूरी तरह से ऑफ़लाइन चलती हैं और आपकी प्रगति इस उपकरण पर सुरक्षित रहती है।',
        AppLanguage.assamese => 'সকলো কাৰ্যকলাপ সম্পূৰ্ণৰূপে অফলাইনত চলে আৰু আপোনাৰ অগ্ৰগতি এই ডিভাইচত সংৰক্ষিত হয়।',
        _ => 'All activities run completely offline and save your progress automatically on this device.',
      };

  String get startButtonLabel => switch (language) {
        AppLanguage.english => 'Start',
        AppLanguage.hindi => 'शुरू',
        AppLanguage.assamese => 'আৰম্ভ',
        _ => 'Start',
      };

  // Progress Screen Localized
  String get yourProgressTitle => switch (language) {
        AppLanguage.english => 'Your Progress',
        AppLanguage.hindi => 'आपकी प्रगति',
        AppLanguage.assamese => 'আপোনাৰ অগ্ৰগতি',
        _ => 'Your Progress',
      };

  String get progressSubtitle => switch (language) {
        AppLanguage.english => 'A gentle, supportive view of your cognitive activity practice.',
        AppLanguage.hindi => 'आपके संज्ञानात्मक अभ्यास का एक शांत और उत्साहवर्धक दृश्य।',
        AppLanguage.assamese => 'আপোনাৰ মনৰ অনুশীলনৰ এটা শান্ত আৰু সহায়ক প্ৰতিচ্ছবি।',
        _ => 'A gentle, supportive view of your cognitive activity practice.',
      };

  String get weeklyEngagementTitle => switch (language) {
        AppLanguage.english => 'Activity engagement this week',
        AppLanguage.hindi => 'इस सप्ताह की गतिविधियाँ',
        AppLanguage.assamese => 'এই সপ্তাহৰ কাৰ্যকলাপৰ পৰিসংখ্যা',
        _ => 'Activity engagement this week',
      };

  String get activitiesCompletedStat => switch (language) {
        AppLanguage.english => 'activities completed',
        AppLanguage.hindi => 'पूर्ण गतिविधियाँ',
        AppLanguage.assamese => 'সম্পূৰ্ণ কাৰ্যকলাপ',
        _ => 'activities completed',
      };

  String get currentStreakStat => switch (language) {
        AppLanguage.english => 'current streak',
        AppLanguage.hindi => 'वर्तमान निरंतरता',
        AppLanguage.assamese => 'বৰ্তমান ধাৰাবাহিকতা',
        _ => 'current streak',
      };

  String get averageAccuracyStat => switch (language) {
        AppLanguage.english => 'average accuracy',
        AppLanguage.hindi => 'औसत सटीकता',
        AppLanguage.assamese => 'গড় নিখুঁততা',
        _ => 'average accuracy',
      };

  String get practiceTimeStat => switch (language) {
        AppLanguage.english => 'practice time',
        AppLanguage.hindi => 'अभ्यास समय',
        AppLanguage.assamese => 'অনুশীলনৰ সময়',
        _ => 'practice time',
      };

  String get daysUnit => switch (language) {
        AppLanguage.english => 'days',
        AppLanguage.hindi => 'दिन',
        AppLanguage.assamese => 'দিন',
        _ => 'days',
      };

  String get minutesUnit => switch (language) {
        AppLanguage.english => 'min',
        AppLanguage.hindi => 'मिनट',
        AppLanguage.assamese => 'মিনিট',
        _ => 'min',
      };

  String get recentActivityHistoryTitle => switch (language) {
        AppLanguage.english => 'Recent Activity History',
        AppLanguage.hindi => 'हाल की गतिविधियों का इतिहास',
        AppLanguage.assamese => 'শেহতীয়া কাৰ্যকলাপৰ ইতিহাস',
        _ => 'Recent Activity History',
      };

  String get noActivitiesYetDesc => switch (language) {
        AppLanguage.english => 'Complete your first gentle activity today to see your timeline.',
        AppLanguage.hindi => 'अपनी समयरेखा देखने के लिए आज अपनी पहली गतिविधि पूरी करें।',
        AppLanguage.assamese => 'আপোনাৰ সময়ৰেখা চাবলৈ আজি প্ৰথম শান্ত কাৰ্যকলাপটো সম্পূৰ্ণ কৰক।',
        _ => 'Complete your first gentle activity today to see your timeline.',
      };

  // Voice Companion Modal Localized
  String get voiceListeningGently => switch (language) {
        AppLanguage.english => 'I am listening gently...',
        AppLanguage.hindi => 'मैं ध्यान से सुन रहा हूँ...',
        AppLanguage.assamese => 'মই মনোযোগেৰে শুনি আছো...',
        _ => 'I am listening gently...',
      };

  String get voiceProcessingCare => switch (language) {
        AppLanguage.english => 'Processing your voice with care...',
        AppLanguage.hindi => 'आपकी आवाज़ को समझा जा रहा है...',
        AppLanguage.assamese => 'আপোনাৰ কথা বুজিবলৈ যত্ন কৰিছো...',
        _ => 'Processing your voice with care...',
      };

  String get voiceErrorTitle => switch (language) {
        AppLanguage.english => 'Microphone Unavailable',
        AppLanguage.hindi => 'माइक्रोफ़ोन उपलब्ध नहीं है',
        AppLanguage.assamese => 'মাইক্ৰ’ফ’ন উপলব্ধ নহয়',
        _ => 'Microphone Unavailable',
      };

  String get voiceErrorSubtitle => switch (language) {
        AppLanguage.english => 'Microphone access is restricted or unsupported on this platform. You can still test any command below.',
        AppLanguage.hindi => 'इस प्लेटफ़ॉर्म पर माइक्रोफ़ोन अनुमति नहीं है। आप नीचे लिखकर कोई भी आदेश दे सकते हैं।',
        AppLanguage.assamese => 'এই প্লেটফৰ্মত মাইক্ৰ’ফ’নৰ সুবিধা নাই। আপুনি তলত টাইপ কৰি যিকোনো আদেশ পৰীক্ষা কৰিব পাৰে।',
        _ => 'Microphone access is restricted or unsupported on this platform. You can still test any command below.',
      };

  String get voiceTypeCommandPlaceholder => switch (language) {
        AppLanguage.english => 'Type a command (e.g. "Show my progress")...',
        AppLanguage.hindi => 'यहाँ आदेश लिखें (जैसे "प्रगति दिखाएं")...',
        AppLanguage.assamese => 'আদেশ টাইপ কৰক (যেনে "মোৰ প্ৰগতি দেখুৱাওক")...',
        _ => 'Type a command (e.g. "Show my progress")...',
      };

  String get voiceSendButton => switch (language) {
        AppLanguage.english => 'Send',
        AppLanguage.hindi => 'भेजें',
        AppLanguage.assamese => 'প্ৰেৰণ',
        _ => 'Send',
      };

  String get voiceTryAgainButton => switch (language) {
        AppLanguage.english => 'Try Listening Again',
        AppLanguage.hindi => 'दोबारा सुनें',
        AppLanguage.assamese => 'পুনৰ শুনক',
        _ => 'Try Listening Again',
      };

  String get voiceAskSomethingElse => switch (language) {
        AppLanguage.english => 'Ask Something Else',
        AppLanguage.hindi => 'कुछ और पूछें',
        AppLanguage.assamese => 'আন কিবা সোধক',
        _ => 'Ask Something Else',
      };

  String get voiceCommonQuestionsHeader => switch (language) {
        AppLanguage.english => 'Or tap a common question:',
        AppLanguage.hindi => 'या इनमें से कोई सवाल चुनें:',
        AppLanguage.assamese => 'বা তলৰ যিকোনো এটা প্ৰশ্ন বাছক:',
        _ => 'Or tap a common question:',
      };

  String get voiceSpeakingGently => switch (language) {
        AppLanguage.english => 'Speaking gently...',
        AppLanguage.hindi => 'उत्तर दिया जा रहा है...',
        AppLanguage.assamese => 'শান্তভাৱে কোৱা হৈছে...',
        _ => 'Speaking gently...',
      };

  String get voiceYouAskedLabel => switch (language) {
        AppLanguage.english => 'You asked:',
        AppLanguage.hindi => 'आपने पूछा:',
        AppLanguage.assamese => 'আপুনি সুধিলে:',
        _ => 'You asked:',
      };

  // Region & Multilingual Onboarding
  String get chooseRegion => switch (language) {
        AppLanguage.hindi => 'अपना क्षेत्र चुनें',
        AppLanguage.assamese => 'আপোনাৰ অঞ্চল বাছক',
        AppLanguage.nepali => 'आफ्नो क्षेत्र छान्नुहोस्',
        AppLanguage.manipuri => 'অদোমগী লমদম খনবীয়ু',
        AppLanguage.khasi => 'Jied ia ka thain jong phi',
        AppLanguage.mizo => 'I awmna hmun thlang rawh',
        AppLanguage.nagamese => 'Apuni laga region chuni lobi',
        AppLanguage.kokborok => 'Nini dophano rwgwi achaino',
        _ => 'Choose your region',
      };

  String get chooseRegionSubtitle => switch (language) {
        AppLanguage.hindi => 'हम आपकी स्थानीय भाषा स्वतः निर्धारित करेंगे। आप इसे बाद में प्रोफ़ाइल में बदल सकते हैं।',
        AppLanguage.assamese => 'আমি আপোনাৰ স্থানীয় ভাষা স্বয়ংক্ৰিয়ভাৱে নিৰ্ধাৰণ কৰিম। আপুনি পিছত প্ৰফাইলত সলনি কৰিব পাৰিব।',
        AppLanguage.nepali => 'हामी स्वतः तपाईंको स्थानीय भाषा तय गर्नेछौं। तपाईं पछि प्रोफाइलमा परिवर्तन गर्न सक्नुहुन्छ।',
        _ => 'We will set your default language automatically. You can always change it later in your profile.',
      };

  String languageAssignedConfirmation(String languageName) => switch (language) {
        AppLanguage.hindi => 'आपकी भाषा होगी $languageName',
        AppLanguage.assamese => 'আপোনাৰ ভাষা হ’ব $languageName',
        AppLanguage.nepali => 'तपाईंको भाषा $languageName हुनेछ',
        AppLanguage.manipuri => 'অদোমগী লোলদি $languageName ওইগনি',
        AppLanguage.khasi => 'Ka ktien jong phi kan long ka $languageName',
        AppLanguage.mizo => 'I ṭawng tur chu $languageName a ni ang',
        AppLanguage.nagamese => 'Apuni laga kotha $languageName thakibo',
        AppLanguage.kokborok => 'Nini kok wngnai $languageName',
        _ => 'Your language will be $languageName',
      };

  String get regionAndLanguage => switch (language) {
        AppLanguage.hindi => 'क्षेत्र और भाषा',
        AppLanguage.assamese => 'অঞ্চল আৰু ভাষা',
        AppLanguage.nepali => 'क्षेत्र र भाषा',
        _ => 'Region & Language',
      };

  String get region => switch (language) {
        AppLanguage.hindi => 'क्षेत्र',
        AppLanguage.assamese => 'অঞ্চল',
        AppLanguage.nepali => 'क्षेत्र',
        _ => 'Region',
      };

  String get changeRegion => switch (language) {
        AppLanguage.hindi => 'क्षेत्र बदलें',
        AppLanguage.assamese => 'অঞ্চল সলনি কৰক',
        AppLanguage.nepali => 'क्षेत्र परिवर्तन गर्नुहोस्',
        _ => 'Change Region',
      };

  String get automaticLanguageLabel => switch (language) {
        AppLanguage.hindi => 'क्षेत्र द्वारा स्वतः निर्धारित',
        AppLanguage.assamese => 'অঞ্চল অনুসৰি স্বয়ংক্ৰিয়ভাৱে নিৰ্ধাৰিত',
        AppLanguage.nepali => 'क्षेत्र अनुसार स्वतः निर्धारित',
        _ => 'Automatically set by region',
      };

  String get letsGetStarted => switch (language) {
        AppLanguage.hindi => 'शुरू करें',
        AppLanguage.assamese => 'আহক আৰম্ভ কৰোঁ',
        AppLanguage.nepali => 'सुरु गरौं',
        _ => "Let's get started",
      };

  String get continueButton => switch (language) {
        AppLanguage.hindi => 'आगे बढ़ें',
        AppLanguage.assamese => 'আগবাঢ়ক',
        AppLanguage.nepali => 'जारी राख्नुहोस्',
        _ => 'Continue',
      };

  String get loadingDailyRoutine => switch (language) {
        AppLanguage.hindi => 'दैनिक दिनचर्या लोड हो रही है...',
        AppLanguage.assamese => 'দৈনন্দিন ৰুটিন লোড হৈ আছে...',
        AppLanguage.nepali => 'दैनिक तालिका लोड हुँदैछ...',
        _ => 'Loading daily routine...',
      };

  String get preparingPersonalizedCare => switch (language) {
        AppLanguage.hindi => 'व्यक्तिगत देखभाल और गतिविधियाँ तैयार की जा रही हैं',
        AppLanguage.assamese => 'ব্যক্তিগত যত্ন আৰু কাৰ্যকলাপ প্ৰস্তুত কৰা হৈছে',
        AppLanguage.nepali => 'व्यक्तिगत हेरचाह र गतिविधिहरू तयार गरिँदैछ',
        _ => 'Preparing personalized care & activities',
      };

  // Phase 3: Regional Diet & Meal Routine
  String get todaysMeals => switch (language) {
        AppLanguage.assamese => 'আজিৰ আহাৰ',
        AppLanguage.hindi => 'आज का भोजन',
        AppLanguage.nepali => 'आजको खाना',
        _ => "Today's Meals",
      };

  String get nextMeal => switch (language) {
        AppLanguage.assamese => 'পৰৱৰ্তী আহাৰ',
        AppLanguage.hindi => 'अगला भोजन',
        AppLanguage.nepali => 'अर्को खाना',
        _ => 'Next Meal',
      };

  String get breakfast => switch (language) {
        AppLanguage.assamese => 'ৰাতিপুৱাৰ জলপান',
        AppLanguage.hindi => 'नाश्ता',
        AppLanguage.nepali => 'बिहानको खाजा',
        _ => 'Breakfast',
      };

  String get lunch => switch (language) {
        AppLanguage.assamese => 'দুপৰীয়াৰ আহাৰ',
        AppLanguage.hindi => 'दोपहर का भोजन',
        AppLanguage.nepali => 'दिउँसोको खाना',
        _ => 'Lunch',
      };

  String get eveningSnack => switch (language) {
        AppLanguage.assamese => 'গধূলিৰ জলপান',
        AppLanguage.hindi => 'शाम का नाश्ता',
        AppLanguage.nepali => 'साँझको खाजा',
        _ => 'Evening Snack',
      };

  String get dinner => switch (language) {
        AppLanguage.assamese => 'ৰাতিৰ আহাৰ',
        AppLanguage.hindi => 'रात का खाना',
        AppLanguage.nepali => 'रातको खाना',
        _ => 'Dinner',
      };

  String get markAsDone => switch (language) {
        AppLanguage.assamese => 'সম্পন্ন বুলি চিহ্নিত কৰক',
        AppLanguage.hindi => 'पूर्ण चिह्नित करें',
        AppLanguage.nepali => 'सकियो भनी चिन्ह लगाउनुहोस्',
        _ => 'Mark as Done',
      };

  String get remindMeLater => switch (language) {
        AppLanguage.assamese => 'পিছত মনত পেলাওক',
        AppLanguage.hindi => 'बाद में याद दिलाएं',
        AppLanguage.nepali => 'पछि सम्झाउनुहोस्',
        _ => 'Remind Me Later',
      };

  String get mealCompleted => switch (language) {
        AppLanguage.assamese => 'আহাৰ সম্পন্ন হৈছে',
        AppLanguage.hindi => 'भोजन पूरा हुआ',
        AppLanguage.nepali => 'खाना पूरा भयो',
        _ => 'Meal completed',
      };

  String mealCompletedPositive(String mealName) => switch (language) {
        AppLanguage.assamese => '$mealName সম্পন্ন হৈছে',
        AppLanguage.hindi => '$mealName पूरा हुआ',
        AppLanguage.nepali => '$mealName पूरा भयो',
        _ => '$mealName completed',
      };

  String get todaysMealStatus => switch (language) {
        AppLanguage.assamese => 'আজিৰ আহাৰৰ অৱস্থা',
        AppLanguage.hindi => 'आज के भोजन की स्थिति',
        AppLanguage.nepali => 'आजको भोजन स्थिति',
        _ => "Today's Meal Status",
      };

  String get remindLaterScheduled => switch (language) {
        AppLanguage.assamese => 'স্মৃতিয়ে সময়ত আপোনাক এই আহাৰৰ বিষয়ে সোঁৱৰাই দিব।',
        AppLanguage.hindi => 'स्मृति समय पर आपको इस भोजन की याद दिलाएगी।',
        AppLanguage.nepali => 'स्मृतिले समयमा तपाईंलाई यो खानाको बारेमा सम्झाउनेछ।',
        _ => 'SMRITI will remind you gently about this meal.',
      };

  String get dietDisclaimer => switch (language) {
        AppLanguage.assamese => 'শান্ত পৰিপুষ্টিৰ বাবে পৰিচিত আঞ্চলিক আহাৰ। কোনো চিকিৎসা নিদান বা খাদ্য প্ৰেচক্ৰিপচন নহয়।',
        AppLanguage.hindi => 'शांत पोषण के लिए परिचित क्षेत्रीय भोजन दिनचर्या। यह कोई चिकित्सीय आहार नुस्खा नहीं है।',
        AppLanguage.nepali => 'शान्त पोषणको लागि परिचित क्षेत्रीय खाना दिनचर्या। यो कुनै मेडिकल डाइट प्रिस्क्रिप्शन होइन।',
        _ => 'Culturally familiar regional food routine for gentle nourishment. Not a medical diet prescription.',
      };

  // Game Feedback & Hints
  String get wonderfulRecall => switch (language) {
        AppLanguage.assamese => 'সুন্দৰ সোঁৱৰণ!',
        AppLanguage.hindi => 'अद्भुत स्मरण!',
        AppLanguage.nepali => 'उत्कृष्ट स्मरण!',
        AppLanguage.manipuri => 'য়াম্না ফরে!',
        _ => 'Wonderful recall!',
      };

  String get notQuite => switch (language) {
        AppLanguage.assamese => 'সম্পূৰ্ণ শুদ্ধ হোৱা নাই। পুনৰ চেষ্টা কৰোঁ আহক।',
        AppLanguage.hindi => 'पूरी तरह सही नहीं। चलिए फिर से प्रयास करते हैं।',
        AppLanguage.nepali => 'पूरै सही भएन। फेरि प्रयास गरौं।',
        AppLanguage.manipuri => 'হন্না হোৎনসি।',
        _ => "Not quite. Let's try again.",
      };

  String get notQuiteShort => switch (language) {
        AppLanguage.assamese => 'সম্পূৰ্ণ শুদ্ধ হোৱা নাই।',
        AppLanguage.hindi => 'पूरी तरह सही नहीं।',
        AppLanguage.nepali => 'पूरै सही भएन।',
        _ => 'Not quite.',
      };

  String get tryAgain => switch (language) {
        AppLanguage.assamese => 'পুনৰ চেষ্টা কৰক',
        AppLanguage.hindi => 'फिर से प्रयास करें',
        AppLanguage.nepali => 'फेरि प्रयास गर्नुहोस्',
        _ => 'Try again',
      };

  String get hint => switch (language) {
        AppLanguage.assamese => 'সংকেত',
        AppLanguage.hindi => 'संकेत',
        AppLanguage.nepali => 'संकेत',
        _ => 'Hint',
      };

  String get orderWasDifferent => switch (language) {
        AppLanguage.assamese => 'ক্ৰমটো বেলেগ আছিল।',
        AppLanguage.hindi => 'क्रम अलग था।',
        AppLanguage.nepali => 'क्रम फरक थियो।',
        _ => 'The order was different.',
      };

  String get notAMatch => switch (language) {
        AppLanguage.assamese => 'মিল খোৱা নাই',
        AppLanguage.hindi => 'मेल नहीं खाया',
        AppLanguage.nepali => 'मिलेन',
        _ => 'Not a match',
      };

  String get memoryMatchHint => switch (language) {
        AppLanguage.assamese => 'কাৰ্ডবোৰ লুটিওৱাৰ সময়ত প্ৰতিখন কাৰ্ডৰ স্থান মনত ৰাখিবলৈ চেষ্টা কৰক।',
        AppLanguage.hindi => 'कार्ड पलटने पर उनके स्थान को याद रखने का प्रयास करें।',
        AppLanguage.nepali => 'कार्डहरू पल्टिंदा तिनीहरूको स्थान सम्झने प्रयास गर्नुहोस्।',
        _ => 'Try to remember the location of each card as they flip.',
      };

  String get objectsHint => switch (language) {
        AppLanguage.assamese => 'কাৰ্ডবোৰ অন্তৰ্ধান হোৱাৰ আগতে দেখা বস্তুবোৰ মনত পেলাওক।',
        AppLanguage.hindi => 'कार्ड गायब होने से पहले देखी गई वस्तुओं पर ध्यान दें।',
        AppLanguage.nepali => 'कार्डहरू हराउनु अघि तपाईंले देख्नुभएका वस्तुहरू खोज्नुहोस्।',
        _ => 'Look for the objects you saw before the cards disappeared.',
      };

  String get sequenceHint => switch (language) {
        AppLanguage.assamese => 'বাকীবোৰৰ আগতে প্ৰথম দুটা সংখ্যা মনত ৰাখিবলৈ চেষ্টা কৰক।',
        AppLanguage.hindi => 'बाकी संख्याओं से पहले पहली दो संख्याओं को याद करने का प्रयास करें।',
        AppLanguage.nepali => 'बाँकी संख्याहरू भन्दा पहिले पहिलो दुई संख्या सम्झने प्रयास गर्नुहोस्।',
        _ => 'Try remembering the first two numbers before the rest.',
      };

  String get wordRecallHint => switch (language) {
        AppLanguage.assamese => 'আজিৰ স্মৃতি দৃশ্যৰ সৈতে জড়িত শব্দবোৰৰ বিষয়ে ভাবক।',
        AppLanguage.hindi => 'आज के स्मृति दृश्य से जुड़े शब्दों के बारे में सोचें।',
        AppLanguage.nepali => 'आजको स्मृति दृश्यसँग जोडिएका शब्दहरूको बारेमा सोच्नुहोस्।',
        _ => "Think about the words connected to today's memory scene.",
      };
}

