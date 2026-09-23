import 'dart:async';
import '../localization/app_language.dart';
import '../models/diet_item.dart';
import 'api_service.dart';
import 'local_data_service.dart';
import 'voice_transport.dart';

enum VoiceIntentType {
  activities,
  reminders,
  memories,
  progress,
  patientInfo,
  changeLanguage,
  greeting,
  sos,
  unknown,
}

class VoiceResult {
  const VoiceResult.unavailable([this.errorMessage])
      : text = null,
        isAvailable = false;
  const VoiceResult.transcript(this.text)
      : isAvailable = true,
        errorMessage = null;

  final String? text;
  final bool isAvailable;
  final String? errorMessage;
}

class VoiceResponse {
  const VoiceResponse({
    required this.query,
    required this.intent,
    required this.responseText,
    this.targetTabIndex,
    this.actionLabel,
  });

  final String query;
  final VoiceIntentType intent;
  final String responseText;
  final int? targetTabIndex;
  final String? actionLabel;
}

abstract interface class VoiceService {
  Future<VoiceResult> listen({
    Duration timeout = const Duration(seconds: 8),
    AppLanguage? language,
  });
  Future<bool> isAvailable();
  Future<VoiceResponse> processCommand(
    String text, {
    required LocalDataService data,
    AppLanguage? language,
  });
  Future<void> speak(String text, {AppLanguage? language});
  Future<void> stopSpeaking();
}

class DemoVoiceService implements VoiceService {
  @override
  Future<VoiceResult> listen({
    Duration timeout = const Duration(seconds: 8),
    AppLanguage? language,
  }) async =>
      const VoiceResult.unavailable('Demo voice service does not listen.');

  @override
  Future<bool> isAvailable() async => false;

  @override
  Future<VoiceResponse> processCommand(
    String text, {
    required LocalDataService data,
    AppLanguage? language,
  }) async {
    return VoiceResponse(
      query: text,
      intent: VoiceIntentType.unknown,
      responseText: 'I am here with you. How can I help you today?',
    );
  }

  @override
  Future<void> speak(String text, {AppLanguage? language}) async {}

  @override
  Future<void> stopSpeaking() async {}
}

class MindSetuVoiceService implements VoiceService {
  MindSetuVoiceService({VoiceTransport? transport, ApiService? apiService})
      : _transport = transport ?? defaultVoiceTransport,
        _apiService = apiService ?? ApiService.instance;

  final VoiceTransport _transport;
  final ApiService _apiService;

  static final MindSetuVoiceService instance = MindSetuVoiceService();

  @override
  Future<bool> isAvailable() async {
    return await _transport.isRecognitionSupported();
  }

  @override
  Future<VoiceResult> listen({
    Duration timeout = const Duration(seconds: 8),
    AppLanguage? language,
  }) async {
    final supported = await _transport.isRecognitionSupported();
    if (!supported) {
      return const VoiceResult.unavailable(
        'Microphone access is unavailable. You can type your request instead.',
      );
    }

    try {
      final langTag = switch (language ?? AppLanguage.english) {
        AppLanguage.assamese => 'as-IN',
        AppLanguage.hindi => 'hi-IN',
        AppLanguage.nepali => 'ne-NP',
        _ => 'en-US',
      };

      final transcript = await _transport.listenOnce(lang: langTag, timeout: timeout);
      if (transcript != null && transcript.trim().isNotEmpty) {
        return VoiceResult.transcript(transcript.trim());
      }
      return const VoiceResult.unavailable(
        'No speech detected. Please speak clearly or choose a prompt below.',
      );
    } catch (e) {
      return VoiceResult.unavailable('Microphone error: $e');
    }
  }

  @override
  Future<VoiceResponse> processCommand(
    String text, {
    required LocalDataService data,
    AppLanguage? language,
  }) async {
    final currentLang = language ?? data.currentLanguage;
    final clean = text.toLowerCase().trim();
    final patientName = data.authFullName ?? 'Bhaben';

    // 0. AI SAFETY CHECK (Diet & medical boundaries: food does not cure/prevent dementia)
    if (_isDietSafetyQuery(clean)) {
      final safeReply = switch (currentLang) {
        AppLanguage.assamese => 'এই আহাৰ আপোনাৰ দৈনিক খাদ্য পৰিকল্পনাৰ অংশ। আপোনাৰ স্বাস্থ্যৰ বাবে বিশেষ চিকিৎসা বা পথ্যৰ পৰামৰ্শ ল’বলৈ অনুগ্ৰহ কৰি আপোনাৰ চিকিৎসক বা শুশ্ৰূষাকাৰীৰ সৈতে কথা পাতক।',
        AppLanguage.hindi => 'यह भोजन आपकी दैनिक भोजन दिनचर्या का हिस्सा है। अपने स्वास्थ्य के लिए विशिष्ट चिकित्सीय आहार सलाह हेतु कृपया अपने डॉक्टर या देखभालकर्ता से परामर्श लें।',
        AppLanguage.nepali => 'यो खाना तपाईंको नियमित भोजन तालिकाको अंश हो। स्वास्थ्य सम्बन्धी चिकित्सकीय सल्लाहको लागि कृपया आफ्नो डाक्टर वा हेरचाहकर्तासँग परामर्श लिनुहोस्।',
        _ => 'This meal is part of your planned food routine. For medical dietary advice specific to your health, please check with your caregiver or doctor.',
      };
      return VoiceResponse(
        query: text,
        intent: VoiceIntentType.reminders,
        responseText: safeReply,
        targetTabIndex: 0,
        actionLabel: 'View Meals',
      );
    }

    // 0.1 APPLICATION MEAL QUERIES (Uses actual application data instead of asking Groq to invent food)
    final mealResponse = _resolveMealQuery(clean, text, data, currentLang);
    if (mealResponse != null) {
      return mealResponse;
    }

    // 1. ONLINE GROQ BACKEND INTEGRATION (When authenticated & connected)
    if (_apiService.isAuthenticated) {
      try {
        final regionName = data.currentRegion.name.toLowerCase();
        final res = await _apiService.sendVoiceChat(
          query: text,
          language: currentLang.code,
          region: regionName,
          context: {
            'patient_name': patientName,
            'reminders_count': data.reminders.length,
            'streak_days': data.currentStreakDays,
          },
        );

        if (res.isSuccess && res.data != null) {
          final dataMap = res.data!;
          final aiResponse = (dataMap['response'] as String?)?.trim() ?? '';
          final intentStr = (dataMap['intent'] as String?)?.trim().toLowerCase() ?? 'unknown';

          if (aiResponse.isNotEmpty) {
            final mappedIntent = switch (intentStr) {
              'activities' => VoiceIntentType.activities,
              'reminders' => VoiceIntentType.reminders,
              'memories' => VoiceIntentType.memories,
              'progress' => VoiceIntentType.progress,
              'patientinfo' || 'patient_info' => VoiceIntentType.patientInfo,
              'changelanguage' || 'change_language' => VoiceIntentType.changeLanguage,
              'greeting' => VoiceIntentType.greeting,
              'sos' => VoiceIntentType.sos,
              _ => VoiceIntentType.unknown,
            };

            // Handle language change side-effect if requested
            if (mappedIntent == VoiceIntentType.changeLanguage) {
              if (clean.contains('hindi') || clean.contains('हिन्दी') || clean.contains('हिंदी')) {
                data.setLanguage(AppLanguage.hindi);
              } else if (clean.contains('assamese') || clean.contains('অসমীয়া')) {
                data.setLanguage(AppLanguage.assamese);
              } else if (clean.contains('english') || clean.contains('ইংরেজি') || clean.contains('अंग्रेजी')) {
                data.setLanguage(AppLanguage.english);
              } else if (clean.contains('nepali') || clean.contains('नेपाली')) {
                data.setLanguage(AppLanguage.nepali);
              }
            }

            final nav = _resolveNavigation(mappedIntent, currentLang);
            return VoiceResponse(
              query: text,
              intent: mappedIntent,
              responseText: aiResponse,
              targetTabIndex: nav.$1,
              actionLabel: nav.$2,
            );
          }
        }
      } catch (_) {
        // Backend / network error -> gracefully falls back to local parser
      }
    }

    // 2. LOCAL INTENT & KEYWORD PARSER (Offline-first fallback)

    // 0. LANGUAGE SWITCHING COMMANDS
    if (_matches(clean, ['hindi', 'हिन्दी', 'हिंदी']) &&
        (_matches(clean, ['change', 'switch', 'language', 'to', 'बदलो', 'करो', 'कৰক', 'भाषा']) ||
            clean == 'hindi' ||
            clean == 'change to hindi' ||
            clean == 'switch to hindi' ||
            clean == 'हिन्दी')) {
      data.setLanguage(AppLanguage.hindi);
      return VoiceResponse(
        query: text,
        intent: VoiceIntentType.changeLanguage,
        responseText: 'भाषा बदलकर हिन्दी कर दी गई है। सभी गतिविधियाँ और स्क्रीन अब हिन्दी में हैं।',
        targetTabIndex: null,
        actionLabel: null,
      );
    }

    if (_matches(clean, ['assamese', 'অসমীয়া', 'asomiya']) &&
        (_matches(clean, ['change', 'switch', 'language', 'to', 'সলনি', 'কৰক', 'बदलो', 'ভাষা']) ||
            clean == 'assamese' ||
            clean == 'change to assamese' ||
            clean == 'switch to assamese' ||
            clean == 'অসমীয়া')) {
      data.setLanguage(AppLanguage.assamese);
      return VoiceResponse(
        query: text,
        intent: VoiceIntentType.changeLanguage,
        responseText: 'ভাষা অসমীয়ালৈ সলনি কৰা হ’ল। সকলো কাৰ্যকলাপ আৰু স্ক্ৰীন এতিয়া অসমীয়াত উপলব্ধ।',
        targetTabIndex: null,
        actionLabel: null,
      );
    }

    if (_matches(clean, ['english', 'अंग्रेजी', 'ইংৰাজী']) &&
        (_matches(clean, ['change', 'switch', 'language', 'to', 'बदलो', 'সলনি', 'কৰক']) ||
            clean == 'english' ||
            clean == 'change to english' ||
            clean == 'switch to english' ||
            clean == 'अंग्रेजी')) {
      data.setLanguage(AppLanguage.english);
      return VoiceResponse(
        query: text,
        intent: VoiceIntentType.changeLanguage,
        responseText: 'Language switched to English. All screens and cognitive activities are now in English.',
        targetTabIndex: null,
        actionLabel: null,
      );
    }

    // 1. CHERISHED MEMORIES / PHOTOS (Checked before general activities)
    if (_matches(clean, [
      'memory',
      'memories',
      'photo',
      'photos',
      'picture',
      'pictures',
      'kaziranga',
      'cherrapunji',
      'album',
      'স্মৃতি',
      'ছবি',
      'ফটোগ্রাফ',
      'কাজিৰঙা',
      'এলবাম',
      'यादें',
      'तस्वीरें',
      'फोटो',
      'काज़ीरंगा',
    ])) {
      final reply = switch (currentLang) {
        AppLanguage.assamese => 'আপোনাৰ মৰমৰ পুৰণি স্মৃতি আৰু কাজিৰঙাৰ ফটোবোৰ উলিয়াইছো। আহক একেলগে মনত পেলাওঁ।',
        AppLanguage.hindi => 'आपकी प्रिय पुरानी यादें और तस्वीरें खोल रहे हैं। आइए साथ मिलकर काज़ीरंगा को याद करें।',
        _ => 'Opening your cherished memories album. Let us look at Kaziranga and familiar places together.',
      };

      return VoiceResponse(
        query: text,
        intent: VoiceIntentType.memories,
        responseText: reply,
        targetTabIndex: 2,
        actionLabel: switch (currentLang) {
          AppLanguage.assamese => 'স্মৃতিলৈ যাওক',
          AppLanguage.hindi => 'यादें देखें',
          _ => 'Open Memories',
        },
      );
    }

    // 2. ACTIVITIES / COGNITIVE GAMES / "Start today's activity"
    if (_matches(clean, [
      'start today\'s activity',
      'start todays activity',
      'start today activity',
      'start activity',
      'today\'s activity',
      'todays activity',
      'activity',
      'activities',
      'game',
      'games',
      'sequence',
      'matching',
      'exercise',
      'play',
      'routine',
      'কাৰ্যকলাপ',
      'কাৰ্য্যকলাপ',
      'খেল',
      'অনুশীলন',
      'আজিৰ কাৰ্যকলাপ',
      'কাৰ্যকলাপ আৰম্ভ',
      'গতিविधि',
      'गतिविधियाँ',
      'आज की गतिविधि',
      'गतिविधि शुरू',
      'खेल',
      'अभ्यास',
    ])) {
      final isStartExplicit = clean.contains('start') || clean.contains('शुरू') || clean.contains('আৰম্ভ');
      final reply = switch (currentLang) {
        AppLanguage.assamese => isStartExplicit
            ? 'আজিৰ শান্ত কাৰ্যকলাপ আৰম্ভ কৰিছো। আহক ৰাতিপুৱাৰ অসমীয়া চাহ তৈয়াৰ কৰাৰ খোজবোৰ মিলাওঁ!'
            : 'নিশ্চয়! আজিৰ বাবে শান্ত কাৰ্যকলাপবোৰ খুলিছো। আহক মন সতেজ কৰি ৰাখোঁ।',
        AppLanguage.hindi => isStartExplicit
            ? 'आज की गतिविधि शुरू कर रहे हैं। चलिए सुबह की असम चाय बनाने का क्रम पूरा करते हैं!'
            : 'ज़रूर! आज के शांत और मनोरंजक अभ्यास खोल रहे हैं। चलिए दिमाग को सक्रिय रखें।',
        _ => isStartExplicit
            ? 'Starting your gentle cognitive activity for today. Let us brew morning Assam tea step by step!'
            : 'Certainly! Opening your gentle activities for today. Let us keep your mind active and refreshed.',
      };
      return VoiceResponse(
        query: text,
        intent: VoiceIntentType.activities,
        responseText: reply,
        targetTabIndex: 1,
        actionLabel: switch (currentLang) {
          AppLanguage.assamese => 'কাৰ্যকলাপলৈ যাওক',
          AppLanguage.hindi => 'गतिविधियों पर जाएं',
          _ => 'Go to Activities',
        },
      );
    }

    // 3. DAILY REMINDERS / MEDICINE
    if (_matches(clean, [
      'reminder',
      'reminders',
      'medicine',
      'pill',
      'tea',
      'walk',
      'সোঁৱৰণী',
      'ঔষধ',
      'দৰব',
      'চাহ',
      'খোজে',
      'याद',
      'दवाई',
      'गोली',
      'चाय',
      'दवा',
    ])) {
      final total = data.reminders.length;
      final done = data.reminders.where((r) => r.completed).length;
      final pending = total - done;

      final reply = switch (currentLang) {
        AppLanguage.assamese => total == 0
            ? 'আজি আপোনাৰ কোনো বাকী সোঁৱৰণী নাই।'
            : 'আপোনাৰ আজিৰ সোঁৱৰণীসমূহ: $total টাৰ ভিতৰত $done টা সম্পন্ন হৈছে, বাকী আছে $pending টা। ঔষধ আৰু চাহৰ সময় মনত ৰাখিব।',
        AppLanguage.hindi => total == 0
            ? 'आज आपके लिए कोई लंबित अनुस्मारक नहीं है।'
            : 'आज के अनुस्मारक: $total में से $done पूरे हो चुके हैं, $pending बाकी हैं। समय पर दवाई और चाय अवश्य लें।',
        _ => total == 0
            ? 'You have no pending reminders for today.'
            : 'Opening your reminders. You have completed $done of $total daily reminders today. Remember your upcoming routine!',
      };

      return VoiceResponse(
        query: text,
        intent: VoiceIntentType.reminders,
        responseText: reply,
        targetTabIndex: 0,
        actionLabel: switch (currentLang) {
          AppLanguage.assamese => 'সোঁৱৰণীলৈ যাওক',
          AppLanguage.hindi => 'अनुस्मारक देखें',
          _ => 'View Reminders',
        },
      );
    }

    // 4. PROGRESS & STREAK / "Show my progress"
    if (_matches(clean, [
      'show my progress',
      'show progress',
      'my progress',
      'progress',
      'score',
      'streak',
      'accuracy',
      'how am i',
      'performance',
      'প্ৰগতি',
      'অগ্ৰগতি',
      'মোৰ প্ৰগতি',
      'স্কোৰ',
      'দিনৰ ধাৰাবাহিকতা',
      'प्रगति',
      'मेरी प्रगति',
      'प्रगति दिखाओ',
      'प्रगति दिखाएं',
      'स्कोर',
      'दिन',
    ])) {
      final streak = data.currentStreakDays;
      final acc = data.averageAccuracy;

      final reply = switch (currentLang) {
        AppLanguage.assamese => 'আপুনি বৰ সুন্দৰভাৱে আগবাঢ়িছে, $patientName! আপোনাৰ অভ্যাসৰ ধাৰাবাহিকতা $streak দিন আৰু শুদ্ধতা $acc%।',
        AppLanguage.hindi => 'बहुत बढ़िया, $patientName! आपकी निरंतरता $streak दिनों की है और औसत सटीकता $acc% है।',
        _ => 'You are doing wonderfully, $patientName! You have a $streak-day practice streak and $acc% average accuracy.',
      };

      return VoiceResponse(
        query: text,
        intent: VoiceIntentType.progress,
        responseText: reply,
        targetTabIndex: 3,
        actionLabel: switch (currentLang) {
          AppLanguage.assamese => 'প্ৰগতিলৈ যাওক',
          AppLanguage.hindi => 'प्रगति देखें',
          _ => 'View Progress',
        },
      );
    }

    // 5. PATIENT IDENTIFIER & CAREGIVER/DOCTOR INFO
    if (_matches(clean, [
      'who am i',
      'my name',
      'patient id',
      'my id',
      'doctor',
      'caregiver',
      'anamika',
      'sarma',
      'নাম',
      'পৰিচয়',
      'ৰোগী নম্বৰ',
      'ডাটা',
      'नाम',
      'पहचान',
      'डॉक्टर',
      'मरीज',
    ])) {
      final pid = data.patientId;
      final reply = switch (currentLang) {
        AppLanguage.assamese => 'আপুনি শ্ৰীযুত $patientName। আপোনাৰ মাইণ্ডসেতু ৰোগী নম্বৰ হ’ল $pid। আপোনাৰ শুশ্ৰূষাকাৰী আৰু চিকিৎসক সংযুক্ত হৈ আছে।',
        AppLanguage.hindi => 'आप $patientName हैं। आपका माइंडसेतु पेशेंट आईडी $pid है। आपकी देखभाल टीम जुड़ी हुई है।',
        _ => 'You are $patientName, and your MindSetu Patient ID is $pid. Your caregiver and doctor are connected to your profile.',
      };

      return VoiceResponse(
        query: text,
        intent: VoiceIntentType.patientInfo,
        responseText: reply,
        targetTabIndex: 4,
        actionLabel: switch (currentLang) {
          AppLanguage.assamese => 'প্ৰফাইল চাওক',
          AppLanguage.hindi => 'प्रोफ़ाइल देखें',
          _ => 'View Profile',
        },
      );
    }

    // 6. GREETING & WHAT DO I HAVE TODAY
    if (_matches(clean, [
      'today',
      'what do i have',
      'schedule',
      'good morning',
      'hello',
      'hi',
      'নমস্কাৰ',
      'সুপ্ৰভাত',
      'আজি কি',
      'नमस्ते',
      'सुप्रभात',
      'आज क्या',
    ])) {
      final remCount = data.reminders.length;
      final reply = switch (currentLang) {
        AppLanguage.assamese => 'সুপ্ৰভাত, $patientName ডাঙৰীয়া! আজি আপোনাৰ $remCount টা দৈনিক কাম, পুৱাৰ খোজ আৰু মন শান্ত কৰা কাৰ্যকলাপ আছে।',
        AppLanguage.hindi => 'सुप्रभात, $patientName जी! आज आपके $remCount दैनिक कार्य, सुबह की सैर और शांत संज्ञानात्मक गतिविधियाँ हैं।',
        _ => 'Good day, $patientName! Today you have $remCount gentle daily routines, refreshing walks, and engaging activities scheduled.',
      };

      return VoiceResponse(
        query: text,
        intent: VoiceIntentType.greeting,
        responseText: reply,
        targetTabIndex: 0,
        actionLabel: switch (currentLang) {
          AppLanguage.assamese => 'হোমলৈ যাওক',
          AppLanguage.hindi => 'होम पर जाएं',
          _ => 'Go to Home',
        },
      );
    }

    // 7. SOS / EMERGENCY HELP
    if (_matches(clean, [
      'help',
      'emergency',
      'sos',
      'alert',
      'danger',
      'সহায়',
      'বিপদ',
      'জৰুৰী',
      'मदद',
      'आपातकालीन',
      'खतरा',
    ])) {
      final reply = switch (currentLang) {
        AppLanguage.assamese => 'শান্ত হওক। আমি তৎক্ষণাৎ আপোনাৰ শুশ্ৰূষাকাৰী আৰু জৰুৰীকালীন সহায়ক অৱগত কৰি আছো।',
        AppLanguage.hindi => 'शांत रहें। हम तुरंत आपकी देखभालकर्ता और आपातकालीन संपर्कों को सूचित कर रहे हैं।',
        _ => 'Stay calm. We are alerting your caregiver and emergency support immediately for assistance.',
      };

      return VoiceResponse(
        query: text,
        intent: VoiceIntentType.sos,
        responseText: reply,
        targetTabIndex: 0,
        actionLabel: 'SOS',
      );
    }

    // Default friendly response
    final defaultReply = switch (currentLang) {
      AppLanguage.assamese => 'মই আপোনাৰ কথা শুনিলোঁ: "$text"। আপুনি আজিৰ কাৰ্যকলাপ, সোঁৱৰণী বা পুৰণি স্মৃতিৰ বিষয়ে মোক ক’ব পাৰে।',
      AppLanguage.hindi => 'मैंने सुना: "$text"। आप मुझसे आज की गतिविधियों, दवाइयों या पुरानी यादों के बारे में पूछ सकते हैं।',
      _ => 'I heard: "$text". You can ask me to show your activities, daily reminders, or cherished memory photos.',
    };

    return VoiceResponse(
      query: text,
      intent: VoiceIntentType.unknown,
      responseText: defaultReply,
      targetTabIndex: null,
      actionLabel: null,
    );
  }

  @override
  Future<void> speak(String text, {AppLanguage? language}) async {
    try {
      final supported = await _transport.isSynthesisSupported();
      if (!supported) return;

      final langTag = switch (language ?? AppLanguage.english) {
        AppLanguage.assamese => 'as-IN',
        AppLanguage.hindi => 'hi-IN',
        AppLanguage.nepali => 'ne-NP',
        _ => 'en-US',
      };
      await _transport.speak(text, lang: langTag);
    } catch (_) {
      // Speech synthesis unavailability should never break the voice interaction
    }
  }

  @override
  Future<void> stopSpeaking() async {
    await _transport.stopSpeaking();
  }

  (int?, String?) _resolveNavigation(VoiceIntentType intent, AppLanguage currentLang) {
    return switch (intent) {
      VoiceIntentType.activities => (
        1,
        switch (currentLang) {
          AppLanguage.assamese => 'কাৰ্যকলাপলৈ যাওক',
          AppLanguage.hindi => 'गतिविधियों पर जाएं',
          _ => 'Go to Activities',
        }
      ),
      VoiceIntentType.reminders => (
        0,
        switch (currentLang) {
          AppLanguage.assamese => 'সোঁৱৰণীলৈ যাওক',
          AppLanguage.hindi => 'अनुस्मारक देखें',
          _ => 'View Reminders',
        }
      ),
      VoiceIntentType.memories => (
        2,
        switch (currentLang) {
          AppLanguage.assamese => 'স্মৃতিলৈ যাওক',
          AppLanguage.hindi => 'यादें देखें',
          _ => 'Open Memories',
        }
      ),
      VoiceIntentType.progress => (
        3,
        switch (currentLang) {
          AppLanguage.assamese => 'প্ৰগতিলৈ যাওক',
          AppLanguage.hindi => 'प्रगति देखें',
          _ => 'View Progress',
        }
      ),
      VoiceIntentType.patientInfo => (
        4,
        switch (currentLang) {
          AppLanguage.assamese => 'প্ৰফাইল চাওক',
          AppLanguage.hindi => 'प्रोफ़ाइल देखें',
          _ => 'View Profile',
        }
      ),
      VoiceIntentType.greeting => (
        0,
        switch (currentLang) {
          AppLanguage.assamese => 'হোমলৈ যাওক',
          AppLanguage.hindi => 'होम पर जाएं',
          _ => 'Go to Home',
        }
      ),
      VoiceIntentType.sos => (0, 'SOS'),
      _ => (null, null),
    };
  }

  bool _matches(String input, List<String> keywords) {
    for (final kw in keywords) {
      if (input.contains(kw.toLowerCase())) return true;
    }
    return false;
  }

  bool _isDietSafetyQuery(String clean) {
    return _matches(clean, [
      'good for dementia',
      'cure dementia',
      'prevent dementia',
      'reverse dementia',
      'dementia diet',
      'cure with food',
      'food cure',
      'medical diet',
      'চিকিৎসা খাদ্য',
      'খাদ্যই ডিমেনচিয়া নিৰাময়',
      'खाना डिमेंशिया ठीक',
    ]);
  }

  VoiceResponse? _resolveMealQuery(String clean, String rawText, LocalDataService data, AppLanguage currentLang) {
    // 1. "What is my next meal?" / Next meal query
    if (_matches(clean, [
      'next meal',
      'what is my next meal',
      'next to eat',
      'upcoming meal',
      'পৰৱৰ্তী আহাৰ',
      'अगला भोजन',
      'अगला खाना',
    ])) {
      final next = data.nextMeal;
      final typeName = _mealTypeLabel(next.mealType, currentLang);
        final reply = switch (currentLang) {
          AppLanguage.assamese => 'আপোনাৰ পৰৱৰ্তী আহাৰ হ’ল $typeName: ${next.title}, সময় ${next.time}।',
          AppLanguage.hindi => 'आपका अगला भोजन $typeName है: ${next.title}, समय ${next.time}।',
          AppLanguage.nepali => 'तपाईंको अर्को खाना $typeName हो: ${next.title}, समय ${next.time}।',
          _ => 'Your next meal is $typeName: ${next.title} at ${next.time}.',
        };
        return VoiceResponse(
          query: rawText,
          intent: VoiceIntentType.reminders,
          responseText: reply,
          targetTabIndex: 0,
          actionLabel: 'View Meals',
        );
    }

    // 2. Lunch query: "What's for lunch?" / "What am I having for lunch?"
    if (_matches(clean, [
      'lunch',
      'দুপৰীয়াৰ আহাৰ',
      'दोपहर का खाना',
      'लंच',
    ])) {
      final lunch = data.regionalMeals.where((m) => m.mealType == MealType.lunch).firstOrNull;
      if (lunch != null) {
        if (_matches(clean, ['did i', 'completed', 'finished', 'done', 'হৈছে', 'खत्म', 'खाया'])) {
          final reply = lunch.completed
              ? switch (currentLang) {
                  AppLanguage.assamese => 'হয়, আপোনাৰ দুপৰীয়াৰ আহাৰ সম্পন্ন হৈছে।',
                  AppLanguage.hindi => 'हाँ, आपने आज का दोपहर का भोजन पूरा कर लिया है।',
                  _ => 'Yes, you have completed lunch today.',
                }
              : switch (currentLang) {
                  AppLanguage.assamese => 'নাই, দুপৰীয়াৰ আহাৰৰ সময় ${lunch.time} আৰু এতিয়াও সম্পূৰ্ণ হোৱা নাই।',
                  AppLanguage.hindi => 'नहीं, दोपहर का भोजन ${lunch.time} बजे है और अभी पूरा नहीं हुआ है।',
                  _ => 'No, lunch is scheduled for ${lunch.time} and is not marked done yet.',
                };
          return VoiceResponse(
            query: rawText,
            intent: VoiceIntentType.reminders,
            responseText: reply,
            targetTabIndex: 0,
            actionLabel: 'View Meals',
          );
        }
        final reply = switch (currentLang) {
          AppLanguage.assamese => 'আজি দুপৰীয়াৰ আহাৰ হ’ল ${lunch.title}, সময় ${lunch.time}।',
          AppLanguage.hindi => 'आज दोपहर का भोजन ${lunch.title} है, समय ${lunch.time}।',
          AppLanguage.nepali => 'आज दिउँसोको खानामा ${lunch.title} छ, समय ${lunch.time}।',
          _ => 'Your lunch today is ${lunch.title} at ${lunch.time}.',
        };
        return VoiceResponse(
          query: rawText,
          intent: VoiceIntentType.reminders,
          responseText: reply,
          targetTabIndex: 0,
          actionLabel: 'View Meals',
        );
      }
    }

    // 3. Breakfast query: "What's for breakfast?" / "Did I complete breakfast?"
    if (_matches(clean, [
      'breakfast',
      'ৰাতিপুৱাৰ আহাৰ',
      'नाश्ता',
      'ब्रेकफास्ट',
    ])) {
      final bfast = data.regionalMeals.where((m) => m.mealType == MealType.breakfast).firstOrNull;
      if (bfast != null) {
        if (_matches(clean, ['did i', 'completed', 'finished', 'done', 'হৈছে', 'खत्म', 'खाया'])) {
          final reply = bfast.completed
              ? switch (currentLang) {
                  AppLanguage.assamese => 'হয়, আপুনি আজি ৰাতিপুৱাৰ আহাৰ সম্পন্ন কৰিছে।',
                  AppLanguage.hindi => 'हाँ, आपने आज नाश्ता पूरा कर लिया है।',
                  _ => 'Yes, you have completed breakfast today.',
                }
              : switch (currentLang) {
                  AppLanguage.assamese => 'নাই, ৰাতিপুৱাৰ আহাৰৰ সময় ${bfast.time} আৰু এতিয়াও সম্পূৰ্ণ হোৱা নাই।',
                  AppLanguage.hindi => 'नहीं, नाश्ता ${bfast.time} बजे निर्धारित है और अभी पूरा नहीं हुआ है।',
                  _ => 'No, breakfast is scheduled for ${bfast.time} and is not marked done yet.',
                };
          return VoiceResponse(
            query: rawText,
            intent: VoiceIntentType.reminders,
            responseText: reply,
            targetTabIndex: 0,
            actionLabel: 'View Meals',
          );
        }
        final reply = switch (currentLang) {
          AppLanguage.assamese => 'আজি ৰাতিপুৱাৰ আহাৰ হ’ল ${bfast.title}, সময় ${bfast.time}।',
          AppLanguage.hindi => 'आज नाश्ते में ${bfast.title} है, समय ${bfast.time}।',
          AppLanguage.nepali => 'आज बिहानको खाजामा ${bfast.title} छ, समय ${bfast.time}।',
          _ => 'Your breakfast today is ${bfast.title} at ${bfast.time}.',
        };
        return VoiceResponse(
          query: rawText,
          intent: VoiceIntentType.reminders,
          responseText: reply,
          targetTabIndex: 0,
          actionLabel: 'View Meals',
        );
      }
    }

    // 4. Dinner query: "What's for dinner?"
    if (_matches(clean, [
      'dinner',
      'ৰাতিৰ আহাৰ',
      'रात का खाना',
      'डिनर',
    ])) {
      final dinner = data.regionalMeals.where((m) => m.mealType == MealType.dinner).firstOrNull;
      if (dinner != null) {
        final reply = switch (currentLang) {
          AppLanguage.assamese => 'আজি ৰাতিৰ আহাৰ হ’ল ${dinner.title}, সময় ${dinner.time}।',
          AppLanguage.hindi => 'आज रात का भोजन ${dinner.title} है, समय ${dinner.time}।',
          AppLanguage.nepali => 'आज रातिको खानामा ${dinner.title} छ, समय ${dinner.time}।',
          _ => 'Your dinner today is ${dinner.title} at ${dinner.time}.',
        };
        return VoiceResponse(
          query: rawText,
          intent: VoiceIntentType.reminders,
          responseText: reply,
          targetTabIndex: 0,
          actionLabel: 'View Meals',
        );
      }
    }

    // 5. Evening Snack query
    if (_matches(clean, [
      'snack',
      'evening snack',
      'গধূলিৰ',
      'शाम का नाश्ता',
    ])) {
      final snack = data.regionalMeals.where((m) => m.mealType == MealType.snack).firstOrNull;
      if (snack != null) {
        final reply = switch (currentLang) {
          AppLanguage.assamese => 'আজি গধূলিৰ চাহ-জলপান হ’ল ${snack.title}, সময় ${snack.time}।',
          AppLanguage.hindi => 'आज शाम का नाश्ता ${snack.title} है, समय ${snack.time}।',
          _ => 'Your evening snack today is ${snack.title} at ${snack.time}.',
        };
        return VoiceResponse(
          query: rawText,
          intent: VoiceIntentType.reminders,
          responseText: reply,
          targetTabIndex: 0,
          actionLabel: 'View Meals',
        );
      }
    }

    // 6. "Tell me today's meals" / List all meals
    if (_matches(clean, [
      'today\'s meals',
      'todays meals',
      'today meals',
      'tell me today\'s meals',
      'tell me todays meals',
      'what are my meals',
      'all meals',
      'meal routine',
      'food routine',
      'আজিৰ আহাৰ',
      'आज का खाना',
      'आज के भोजन',
    ])) {
      final meals = data.regionalMeals;
      final b = meals.where((m) => m.mealType == MealType.breakfast).firstOrNull?.title ?? 'Breakfast';
      final l = meals.where((m) => m.mealType == MealType.lunch).firstOrNull?.title ?? 'Lunch';
      final s = meals.where((m) => m.mealType == MealType.snack).firstOrNull?.title ?? 'Evening Snack';
      final d = meals.where((m) => m.mealType == MealType.dinner).firstOrNull?.title ?? 'Dinner';
      final reply = switch (currentLang) {
        AppLanguage.assamese => 'আজিৰ আহাৰসমূহ হ’ল: ৰাতিপুৱা $b, দুপৰীয়া $l, গধূলি $s, আৰু ৰাতি $d।',
        AppLanguage.hindi => 'आज का भोजन: नाश्ते में $b, दोपहर में $l, शाम में $s, और रात में $d।',
        _ => "Today's meals are: Breakfast - $b, Lunch - $l, Evening Snack - $s, and Dinner - $d.",
      };
      return VoiceResponse(
        query: rawText,
        intent: VoiceIntentType.reminders,
        responseText: reply,
        targetTabIndex: 0,
        actionLabel: 'View Meals',
      );
    }

    return null;
  }

  static String _mealTypeLabel(MealType type, AppLanguage lang) {
    switch (type) {
      case MealType.breakfast:
        return switch (lang) {
          AppLanguage.assamese => 'ৰাতিপুৱাৰ আহাৰ',
          AppLanguage.hindi => 'नाश्ता',
          AppLanguage.nepali => 'बिहानको खाजा',
          _ => 'Breakfast',
        };
      case MealType.lunch:
        return switch (lang) {
          AppLanguage.assamese => 'দুপৰীয়াৰ আহাৰ',
          AppLanguage.hindi => 'दोपहर का भोजन',
          AppLanguage.nepali => 'दिउँसोको खाना',
          _ => 'Lunch',
        };
      case MealType.snack:
        return switch (lang) {
          AppLanguage.assamese => 'গধূলিৰ জলপান',
          AppLanguage.hindi => 'शाम का नाश्ता',
          AppLanguage.nepali => 'खाजा',
          _ => 'Evening Snack',
        };
      case MealType.dinner:
        return switch (lang) {
          AppLanguage.assamese => 'ৰাতিৰ আহাৰ',
          AppLanguage.hindi => 'रात का भोजन',
          AppLanguage.nepali => 'रातिको खाना',
          _ => 'Dinner',
        };
    }
  }
}
