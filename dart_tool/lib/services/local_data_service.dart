import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../localization/app_language.dart';
import '../localization/app_localizations.dart';
import '../localization/app_region.dart';
import '../models/diet_item.dart';
import 'api_service.dart';
import 'diet_service.dart';

enum UserRole { patient, caregiver, doctor }

class RecommendedActivity {
  const RecommendedActivity({
    required this.id,
    required this.category,
    required this.title,
    required this.durationStr,
    required this.description,
    required this.iconStr,
  });

  final String id;
  final String category;
  final String title;
  final String durationStr;
  final String description;
  final String iconStr;
}

class DailyReminder {
  DailyReminder({
    required this.id,
    required this.title,
    required this.category,
    required this.timeStr,
    required this.instructions,
    this.completed = false,
    this.verifiedByCaregiver = false,
  });

  final String id;
  final String title;
  final String category;
  final String timeStr;
  final String instructions;
  bool completed;
  bool verifiedByCaregiver;
}

class MemoryItem {
  const MemoryItem({
    required this.id,
    required this.title,
    required this.place,
    required this.date,
    required this.description,
    required this.photoIcon,
    required this.recallPrompt,
    required this.options,
    required this.correctIndex,
    required this.hint,
  });

  final String id;
  final String title;
  final String place;
  final String date;
  final String description;
  final String photoIcon;
  final String recallPrompt;
  final List<String> options;
  final int correctIndex;
  final String hint;
}

class ActivityHistoryItem {
  const ActivityHistoryItem({
    required this.id,
    required this.title,
    required this.category,
    required this.timeAgo,
    required this.score,
    required this.accuracy,
    required this.icon,
  });

  final String id;
  final String title;
  final String category;
  final String timeAgo;
  final int score;
  final int accuracy;
  final IconData icon;
}

class CaregiverObservation {
  const CaregiverObservation({
    required this.id,
    required this.timestampStr,
    required this.mood,
    required this.sleepHours,
    required this.appetite,
    required this.notes,
  });

  final String id;
  final String timestampStr;
  final String mood; // 'Happy', 'Calm', 'Low', 'Concerned'
  final double sleepHours;
  final String appetite; // 'Good', 'Average', 'Poor'
  final String notes;
}

class DoctorPatientProfile {
  const DoctorPatientProfile({
    required this.id,
    required this.name,
    required this.age,
    required this.region,
    required this.language,
    required this.caregiverName,
    required this.caregiverPhone,
    required this.adherenceRate,
    required this.avgAccuracy,
    required this.activeStreak,
    required this.statusSummary,
    this.patientCode = 'MS-ASSAM-001',
  });

  final String id;
  final String patientCode;
  final String name;
  final int age;
  final String region;
  final String language;
  final String caregiverName;
  final String caregiverPhone;
  final int adherenceRate;
  final int avgAccuracy;
  final int activeStreak;
  final String statusSummary;
}

class DailyActivity {
  DailyActivity({
    required this.id,
    required this.title,
    required this.detail,
    this.done = false,
  });
  final String id;
  final String title;
  final String detail;
  bool done;

  DailyActivity copyWith({
    String? id,
    String? title,
    String? detail,
    bool? done,
  }) {
    return DailyActivity(
      id: id ?? this.id,
      title: title ?? this.title,
      detail: detail ?? this.detail,
      done: done ?? this.done,
    );
  }
}

class CareCircleMember {
  CareCircleMember({
    required this.name,
    required this.relation,
    required this.contact,
  });
  final String name;
  final String relation;
  final String contact;
}

class UpcomingAppointment {
  UpcomingAppointment({
    required this.id,
    required this.title,
    required this.dateTimeStr,
    required this.location,
  });
  final String id;
  final String title;
  final String dateTimeStr;
  final String location;
}


/// Offline-first central repository for local patient, caregiver, and doctor state,
/// integrated with the FastAPI Backend (http://127.0.0.1:8000).
class LocalDataService extends ChangeNotifier {
  static const String _keySelectedRegion = 'smriti_selected_region';
  static const String _keySelectedLanguage = 'smriti_selected_language';
  static const String _keyHasCompletedOnboarding = 'smriti_has_completed_onboarding';

  LocalDataService._internal() {
    _initDefaults();
    initPrefs();
    // Attempt initial background sync check
    syncWithBackend();
  }

  static final LocalDataService instance = LocalDataService._internal();

  UserRole _currentRole = UserRole.patient;

  // Region State
  AppRegion _currentRegion = AppRegion.assam;
  AppRegion get currentRegion => _currentRegion;
  String get regionLabel => _currentRegion.name;

  // Language State
  AppLanguage _currentLanguage = AppLanguage.english;
  AppLanguage get currentLanguage => _currentLanguage;
  AppLocalizations get localizations => AppLocalizations(_currentLanguage);

  // Onboarding State
  bool _hasCompletedOnboarding = false;
  bool get hasCompletedOnboarding => _hasCompletedOnboarding;

  Future<SharedPreferences?> _getSafePrefs() async {
    try {
      return await SharedPreferences.getInstance();
    } catch (_) {
      return null;
    }
  }

  /// Asynchronously loads persisted region and language settings from SharedPreferences
  Future<void> initPrefs() async {
    try {
      final prefs = await _getSafePrefs();
      if (prefs == null) return;
      final savedRegionStr = prefs.getString(_keySelectedRegion);
      final savedLangStr = prefs.getString(_keySelectedLanguage);
      final savedOnboarding = prefs.getBool(_keyHasCompletedOnboarding);

      if (savedOnboarding != null) {
        _hasCompletedOnboarding = savedOnboarding;
      }
      if (savedRegionStr != null) {
        _currentRegion = AppRegionX.fromString(savedRegionStr);
        _hasCompletedOnboarding = true;
      }
      if (savedLangStr != null) {
        _currentLanguage = AppLanguageX.fromCode(savedLangStr);
      } else if (savedRegionStr != null) {
        _currentLanguage = _currentRegion.defaultLanguage;
      }
      notifyListeners();
    } catch (_) {
      // Graceful fallback for environments where SharedPreferences is unavailable
    }
  }

  /// Sets language, saves to persistence, and notifies listeners so MaterialApp rebuilds
  void setLanguage(AppLanguage lang) {
    _getSafePrefs().then((prefs) {
      prefs?.setString(_keySelectedLanguage, lang.code);
    }).catchError((_) {});

    if (_currentLanguage != lang) {
      _currentLanguage = lang;
      notifyListeners();

      if (_isOnline && ApiService.instance.isAuthenticated && _currentRole == UserRole.patient) {
        _syncRegionAndLanguageToBackend();
      }
    }
  }

  /// Sets region, saves to persistence, determines default language, updates language,
  /// notifies listeners, and synchronizes with the backend.
  Future<void> setRegion(AppRegion region, {bool syncToBackend = true}) async {
    _currentRegion = region;
    _connectedPatientRegion = region.name;
    final defaultLang = region.defaultLanguage;

    // Immediately update language and meals in-memory
    setLanguage(defaultLang);
    _updateMealsForRegion(region);

    final prefs = await _getSafePrefs();
    await prefs?.setString(_keySelectedRegion, region.code);
    await prefs?.setString(_keySelectedLanguage, defaultLang.code);

    if (syncToBackend && _isOnline && ApiService.instance.isAuthenticated && _currentRole == UserRole.patient) {
      _syncRegionAndLanguageToBackend();
    }
  }

  /// Mark onboarding as completed and persist
  void completeOnboarding({AppRegion? region}) {
    _hasCompletedOnboarding = true;
    if (region != null) {
      setRegion(region);
    }
    _getSafePrefs().then((prefs) {
      prefs?.setBool(_keyHasCompletedOnboarding, true);
    }).catchError((_) {});
    notifyListeners();
  }

  /// Reset onboarding state (useful for tests or re-running tour)
  void resetOnboarding() {
    _hasCompletedOnboarding = false;
    _getSafePrefs().then((prefs) {
      prefs?.remove(_keyHasCompletedOnboarding);
      prefs?.remove(_keySelectedRegion);
      prefs?.remove(_keySelectedLanguage);
    }).catchError((_) {});
    notifyListeners();
  }

  Future<void> _syncRegionAndLanguageToBackend() async {
    if (!_isOnline || !ApiService.instance.isAuthenticated || _currentRole != UserRole.patient) {
      return;
    }
    try {
      await ApiService.instance.updatePatientMe({
        'region': _currentRegion.name,
        'preferred_language': _currentLanguage.label,
      });
    } catch (_) {
      // Graceful offline fallback
    }
  }

  // Authentication & Patient-Linking State
  bool _isAuthenticated = false;
  String? _authFullName;
  String? _authEmail;
  String? _patientId = 'MS-ASSAM-001';

  // Connected Patient (for Caregiver and Doctor)
  String _connectedPatientId = 'MS-ASSAM-001';
  String _connectedPatientName = 'Bhaben Borah';
  int _connectedPatientAge = 72;
  String _connectedPatientRegion = 'Tezpur, Assam';

  bool get isAuthenticated => _isAuthenticated;
  String? get authFullName => _authFullName;
  String? get authEmail => _authEmail;
  String get patientId => _patientId ?? 'MS-ASSAM-001';

  String get connectedPatientId => _connectedPatientId;
  String get connectedPatientName => _connectedPatientName;
  int get connectedPatientAge => _connectedPatientAge;
  String get connectedPatientRegion => _connectedPatientRegion;

  void notify() => notifyListeners();

  void setAuthenticatedUser({
    required UserRole role,
    required String fullName,
    required String email,
    String? token,
    String? patientId,
  }) {
    _isAuthenticated = true;
    _currentRole = role;
    _authFullName = fullName;
    _authEmail = email;
    _hasCompletedOnboarding = true;
    _getSafePrefs().then((prefs) {
      prefs?.setBool(_keyHasCompletedOnboarding, true);
    }).catchError((_) {});
    if (patientId != null && patientId.isNotEmpty) {
      _patientId = patientId;
      _connectedPatientId = patientId;
    } else if (role == UserRole.patient) {
      _patientId = 'MS-ASSAM-001';
      _connectedPatientId = 'MS-ASSAM-001';
    }
    if (token != null) {
      ApiService.instance.setToken(token, role: role.name.toUpperCase(), userId: email, patientId: _patientId);
    }
    notifyListeners();
    syncWithBackend();
  }

  void setConnectedPatient({
    required String patientId,
    required String patientName,
    int? age,
    String? region,
  }) {
    _connectedPatientId = patientId;
    _connectedPatientName = patientName;
    if (age != null) _connectedPatientAge = age;
    if (region != null) _connectedPatientRegion = region;
    notifyListeners();
  }

  void logout() {
    _isAuthenticated = false;
    _authFullName = null;
    _authEmail = null;
    ApiService.instance.clearAuth();
    notifyListeners();
  }

  // Adaptive Activity Rotation Pool
  static const List<RecommendedActivity> _activitiesPool = [
    RecommendedActivity(
      id: 'act-sequence',
      category: 'Morning Routine',
      title: 'Making Morning Assam Tea',
      durationStr: '3–5 mins',
      description: 'A gentle sequence activity to brew warm, fragrant tea step by step.',
      iconStr: '☕',
    ),
    RecommendedActivity(
      id: 'act-matching',
      category: 'Visual Matching',
      title: 'Cultural Pairs of the Hills',
      durationStr: '2–4 mins',
      description: 'Match culturally familiar pairs of North-Eastern instruments, wildlife and textiles.',
      iconStr: '🪕',
    ),
    RecommendedActivity(
      id: 'act-memory-recall',
      category: 'Memory Recall',
      title: 'Familiar Places & Memories',
      durationStr: '3–5 mins',
      description: 'Reflect on joyful moments of Rongali Bihu and Kaziranga travels.',
      iconStr: '🌾',
    ),
    RecommendedActivity(
      id: 'act-attention',
      category: 'Visual Attention',
      title: 'Gentle Nature Spotting',
      durationStr: '2–3 mins',
      description: 'Spot the one-horned rhino and vibrant birds in Assam grasslands.',
      iconStr: '🦏',
    ),
  ];

  int _recommendationIndex = 0;

  List<RecommendedActivity> get availableActivities => _activitiesPool;
  RecommendedActivity get currentRecommendation => _activitiesPool[_recommendationIndex % _activitiesPool.length];

  void rotateRecommendation() {
    _recommendationIndex = (_recommendationIndex + 1) % _activitiesPool.length;
    notifyListeners();
  }

  void updateAdaptiveRecommendation() {
    if (_history.isNotEmpty) {
      final lastCategory = _history.first.category.toLowerCase();
      final lastActId = lastCategory.contains('match')
          ? 'act-matching'
          : (lastCategory.contains('recall') ? 'act-memory-recall' : 'act-sequence');

      int nextIdx = (_recommendationIndex + 1) % _activitiesPool.length;
      if (_activitiesPool[nextIdx].id == lastActId) {
        nextIdx = (nextIdx + 1) % _activitiesPool.length;
      }
      _recommendationIndex = nextIdx;
    } else {
      _recommendationIndex = (_recommendationIndex + 1) % _activitiesPool.length;
    }
    notifyListeners();
  }

  final List<DailyReminder> _reminders = [];
  final List<MemoryItem> _memories = [];
  final List<ActivityHistoryItem> _history = [];
  final List<CaregiverObservation> _observations = [];
  final List<DoctorPatientProfile> _patients = [];

  // Teammate Extended State
  int _hydrationCount = 5;
  bool _isLargeText = false;
  bool _voiceAssistanceEnabled = true;
  bool _reminderNotificationsEnabled = true;

  String _userDistrict = 'Kamrup Metropolitan';
  String _userHometown = 'Guwahati';
  String _userState = 'Assam';

  final List<DailyActivity> _activities = [];
  final List<CareCircleMember> _careCircle = [];
  final List<UpcomingAppointment> _appointments = [];
  final Map<String, int> _gameScores = {
    'match': 2,
    'objects': 1,
    'sequence': 3,
    'words': 1,
  };

  // Offline Sync Queue
  final List<Map<String, dynamic>> _pendingSyncQueue = [];

  int _completedActivitiesCount = 2;
  int _currentStreakDays = 3;
  int _practiceMinutes = 12;
  int _averageAccuracy = 88;

  bool _isOnline = false;
  bool _isSyncing = false;
  String? _syncStatusMessage;
  bool _isLoadingPatientProfile = false;
  String? _patientProfileError;

  // Pre-seed last sync to 52 hours ago to demonstrate the 2-day sync alert
  DateTime _lastSyncedAt = DateTime.now().subtract(const Duration(hours: 52));

  UserRole get currentRole => _currentRole;
  List<DailyReminder> get reminders => List.unmodifiable(_reminders);
  List<MemoryItem> get memories => List.unmodifiable(_memories);
  List<ActivityHistoryItem> get history => List.unmodifiable(_history);
  List<CaregiverObservation> get observations => List.unmodifiable(_observations);
  List<DoctorPatientProfile> get patients => List.unmodifiable(_patients);

  // Teammate Getters
  int get hydrationCount => _hydrationCount;
  bool get isLargeText => _isLargeText;
  bool get voiceAssistanceEnabled => _voiceAssistanceEnabled;
  bool get reminderNotificationsEnabled => _reminderNotificationsEnabled;
  String get userDistrict => _userDistrict;
  String get userHometown => _userHometown;
  String get userState => _userState;
  List<DailyActivity> get activities => List.unmodifiable(_activities);
  List<CareCircleMember> get careCircle => List.unmodifiable(_careCircle);
  List<UpcomingAppointment> get appointments => List.unmodifiable(_appointments);
  Map<String, int> get gameScores => Map.unmodifiable(_gameScores);

  int get completedActivitiesCount => _completedActivitiesCount;
  int get currentStreakDays => _currentStreakDays;
  int get practiceMinutes => _practiceMinutes;
  int get averageAccuracy => _averageAccuracy;

  bool get isOnline => _isOnline;
  bool get isSyncing => _isSyncing;
  bool get isLoadingPatientProfile => _isLoadingPatientProfile;
  String? get patientProfileError => _patientProfileError;
  String? get syncStatusMessage => _syncStatusMessage;
  int get pendingSyncCount => _pendingSyncQueue.length;

  DateTime get lastSyncedAt => _lastSyncedAt;
  bool get isSyncOverdue => DateTime.now().difference(_lastSyncedAt).inHours >= 48;
  int get authAge => _connectedPatientAge;
  String get textSizeLabel => _isLargeText ? 'Large' : 'Standard';

  // Teammate Feature Methods
  void addWaterGlass() {
    if (_hydrationCount < 8) {
      _hydrationCount++;
      notifyListeners();
    }
  }

  void toggleLargeText() {
    _isLargeText = !_isLargeText;
    notifyListeners();
  }

  void toggleVoiceAssistance() {
    _voiceAssistanceEnabled = !_voiceAssistanceEnabled;
    notifyListeners();
  }

  void toggleReminderNotifications() {
    _reminderNotificationsEnabled = !_reminderNotificationsEnabled;
    notifyListeners();
  }

  void updateProfile({String? name, String? district, String? hometown, String? state, int? age}) {
    if (name != null && name.trim().isNotEmpty) _authFullName = name.trim();
    if (district != null) _userDistrict = district;
    if (hometown != null) _userHometown = hometown;
    if (state != null) _userState = state;
    if (age != null) _connectedPatientAge = age;
    notifyListeners();
  }

  void addCustomActivity(String title, String detail) {
    if (title.trim().isEmpty) return;
    _activities.add(DailyActivity(
      id: 'act_${DateTime.now().millisecondsSinceEpoch}',
      title: title.trim(),
      detail: detail.trim().isEmpty ? 'Personal activity' : detail.trim(),
      done: false,
    ));
    notifyListeners();
  }

  void toggleActivity(int index) {
    if (index >= 0 && index < _activities.length) {
      final act = _activities[index];
      _activities[index] = act.copyWith(done: !act.done);
      notifyListeners();
    }
  }

  void removeActivity(int index) {
    if (index >= 0 && index < _activities.length) {
      _activities.removeAt(index);
      notifyListeners();
    }
  }

  void addCareCircleMember(String name, String relation, String contact) {
    if (name.trim().isEmpty) return;
    _careCircle.add(CareCircleMember(
      name: name.trim(),
      relation: relation.trim(),
      contact: contact.trim().isEmpty ? 'Contact saved' : contact.trim(),
    ));
    notifyListeners();
  }

  void addAppointment(String title, String dateTimeStr, String location) {
    if (title.trim().isEmpty) return;
    _appointments.add(UpcomingAppointment(
      id: 'appt_${DateTime.now().millisecondsSinceEpoch}',
      title: title.trim(),
      dateTimeStr: dateTimeStr.trim(),
      location: location.trim(),
    ));
    notifyListeners();
  }

  void recordGameScore(String gameKey) {
    _gameScores[gameKey] = (_gameScores[gameKey] ?? 0) + 1;
    _completedActivitiesCount++;
    notifyListeners();
  }

  void addMemory({
    required String title,
    required String category,
    required String date,
    required String text,
    String memoryIcon = '🌸',
    String? icon,
  }) {
    final effectiveIcon = icon ?? memoryIcon;
    _memories.insert(
      0,
      MemoryItem(
        id: 'mem_${DateTime.now().millisecondsSinceEpoch}',
        title: title,
        place: _userHometown.isNotEmpty ? _userHometown : category,
        date: date.isEmpty ? 'A treasured time' : date,
        description: text,
        photoIcon: effectiveIcon,
        recallPrompt: 'What do you remember most about this moment?',
        options: [title, 'Family gathering', 'A special day'],
        correctIndex: 0,
        hint: 'A special personal story kept close.',
      ),
    );
    notifyListeners();

    if (_isOnline && ApiService.instance.isAuthenticated) {
      ApiService.instance.createMemory(
        title: title,
        description: text,
        location: _userHometown,
        dateEra: date,
        tags: [category],
      );
    }
  }

  void addReminder({
    required String title,
    required String category,
    required String timeStr,
    String instructions = '',
  }) {
    final newRem = DailyReminder(
      id: 'rem_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      category: category,
      timeStr: timeStr,
      instructions: instructions.isEmpty ? 'Gentle reminder' : instructions,
      completed: false,
      verifiedByCaregiver: false,
    );
    _reminders.add(newRem);
    notifyListeners();

    if (_isOnline && ApiService.instance.isAuthenticated) {
      ApiService.instance.createReminder({
        'title': title,
        'category': category,
        'time_str': timeStr,
        'instructions': instructions,
      });
    }
  }

  void deleteReminder(String id) {
    _reminders.removeWhere((r) => r.id == id);
    notifyListeners();

    if (_isOnline && ApiService.instance.isAuthenticated) {
      ApiService.instance.deleteReminder(id);
    }
  }
  int get hoursSinceLastSync => DateTime.now().difference(_lastSyncedAt).inHours;

  CaregiverObservation? get latestObservation =>
      _observations.isNotEmpty ? _observations.first : null;

  // Phase 3: Regional Meal Routines
  List<DietItem> get regionalMeals => DietService.getMealsForRegion(_currentRegion, _reminders);
  DietItem get nextMeal => DietService.getNextMeal(_currentRegion, _reminders);

  void completeMeal(String id) {
    if (_reminders.any((r) => r.id == id)) {
      toggleReminder(id);
      return;
    }
    final meal = regionalMeals.where((m) => m.id == id).firstOrNull;
    if (meal != null && meal.reminderId != null) {
      toggleReminder(meal.reminderId!);
      return;
    }
    toggleReminder(id);
  }

  void _updateMealsForRegion(AppRegion region) {
    final meals = DietService.getMealsForRegion(region, _reminders);
    for (final meal in meals) {
      final idx = _reminders.indexWhere((r) => r.id == meal.reminderId);
      if (idx != -1) {
        _reminders[idx] = DailyReminder(
          id: _reminders[idx].id,
          title: meal.title,
          category: 'Meal',
          timeStr: meal.time,
          instructions: meal.description,
          completed: _reminders[idx].completed,
          verifiedByCaregiver: _reminders[idx].verifiedByCaregiver,
        );
      }
    }
    notifyListeners();
  }

  void setRole(UserRole role) {
    if (_currentRole != role) {
      _currentRole = role;
      notifyListeners();
      // Sync fresh role data from backend in background
      syncWithBackend();
    }
  }

  void resetToDefaults() {
    _reminders.clear();
    _currentRegion = AppRegion.assam;
    _currentLanguage = AppLanguage.assamese;
    _initDefaults();
    notifyListeners();
  }

  void _initDefaults() {
    // 1. Pre-seeded Reminders (Medicine, Hydration, Regional Meals, Walk)
    _reminders.addAll([
      DailyReminder(
        id: 'rem_1',
        title: 'Morning Blood Pressure & Vitamin',
        category: 'Medicine',
        timeStr: '08:30 AM',
        instructions: 'Take 1 tablet with warm water after breakfast',
        completed: true,
        verifiedByCaregiver: true,
      ),
      DailyReminder(
        id: 'rem_meal_breakfast',
        title: 'Til Pitha & Warm Assam Tea',
        category: 'Meal',
        timeStr: '08:30 AM',
        instructions: 'Traditional rice pitha with soothing tea for a gentle morning start',
        completed: true,
        verifiedByCaregiver: true,
      ),
      DailyReminder(
        id: 'rem_2',
        title: 'Warm Lemongrass & Ginger Tea',
        category: 'Hydration',
        timeStr: '11:00 AM',
        instructions: 'Sip slowly and enjoy a quiet rest in the veranda',
        completed: true,
        verifiedByCaregiver: false,
      ),
      DailyReminder(
        id: 'rem_3',
        title: 'Lunch with Fresh Masor Tenga',
        category: 'Meal',
        timeStr: '01:15 PM',
        instructions: 'Wholesome rice and mild fish broth prepared fresh',
        completed: false,
        verifiedByCaregiver: false,
      ),
      DailyReminder(
        id: 'rem_meal_snack',
        title: 'Pitha & Roasted Chira',
        category: 'Meal',
        timeStr: '04:30 PM',
        instructions: 'Light festive rice snacks and warm water or herbal tea',
        completed: false,
        verifiedByCaregiver: false,
      ),
      DailyReminder(
        id: 'rem_4',
        title: 'Gentle Garden Stroll',
        category: 'Gentle Walk',
        timeStr: '04:45 PM',
        instructions: '15-minute peaceful walk to admire the flowers',
        completed: false,
        verifiedByCaregiver: false,
      ),
      DailyReminder(
        id: 'rem_meal_dinner',
        title: 'Rice with Gentle Khaar & Dal',
        category: 'Meal',
        timeStr: '08:00 PM',
        instructions: 'Comforting traditional alkaline broth with tender vegetables and rice',
        completed: false,
        verifiedByCaregiver: false,
      ),
    ]);

    // 2. Pre-seeded Cultural Memories
    _memories.addAll([
      const MemoryItem(
        id: 'mem_bihu',
        title: 'Rongali Bihu with Grandchildren',
        place: 'Tezpur Family Courtyard, Assam',
        date: 'April 14, 2024',
        description:
            'We gathered on the veranda wearing our festive Muga Gamusas. Joy danced to the cheerful dhol rhythm, and we shared sweet warm Til Pitha and freshly brewed Assam tea.',
        photoIcon: '🌾 🪕 👨‍👩‍👧‍👦',
        recallPrompt: 'Who was playing the small Bihu drum in the sunny courtyard?',
        options: ['Joy (Your Grandson)', 'Uncle Biren', 'Neighbor Arun'],
        correctIndex: 0,
        hint: 'Your cheerful 10-year-old grandson wearing a silk waistcoat.',
      ),
      const MemoryItem(
        id: 'mem_kaziranga',
        title: 'Visit to Kaziranga National Park',
        place: 'Kohora Range, Kaziranga',
        date: 'November 2022',
        description:
            'The soft golden morning mist was rising over elephant grass. We watched a majestic mother rhino and her gentle calf grazing quietly near the stream.',
        photoIcon: '🦏 🌄 🌿',
        recallPrompt: 'What majestic animal did you admire grazing near the morning stream?',
        options: ['One-horned Rhinoceros', 'Wild Water Buffalo', 'Golden Langur'],
        correctIndex: 0,
        hint: 'The world-famous guardian of the Assam floodplains.',
      ),
    ]);

    // 3. Initial Progress History
    _history.addAll([
      const ActivityHistoryItem(
        id: 'hist_1',
        title: 'Memory Match',
        category: 'Matching',
        timeAgo: 'Today',
        score: 100,
        accuracy: 100,
        icon: Icons.grid_view_rounded,
      ),
      const ActivityHistoryItem(
        id: 'hist_2',
        title: 'Tea Brewing Routine',
        category: 'Sequence',
        timeAgo: 'Yesterday',
        score: 95,
        accuracy: 95,
        icon: Icons.coffee_rounded,
      ),
    ]);

    // 4. Pre-seeded Caregiver Observations
    _observations.addAll([
      const CaregiverObservation(
        id: 'obs_1',
        timestampStr: 'Today, 10:30 AM',
        mood: 'Calm',
        sleepHours: 7.5,
        appetite: 'Good',
        notes:
            'Father was in high spirits this morning. Enjoyed looking at the Bihu family memory and drank tea independently.',
      ),
      const CaregiverObservation(
        id: 'obs_2',
        timestampStr: 'Yesterday, 08:00 PM',
        mood: 'Happy',
        sleepHours: 8.0,
        appetite: 'Good',
        notes:
            'Walked in the courtyard for 15 minutes. Completed morning medication on time without confusion.',
      ),
    ]);

    // 5. Pre-seeded Patients for Doctor View
    _patients.addAll([
      const DoctorPatientProfile(
        id: 'pat_bhaben',
        name: 'Bhaben Borah',
        age: 72,
        region: 'Tezpur, Assam',
        language: 'Assamese (অসমীয়া)',
        caregiverName: 'Anamika Borah (Daughter)',
        caregiverPhone: '+91 94350 12345',
        adherenceRate: 85,
        avgAccuracy: 92,
        activeStreak: 3,
        statusSummary: 'Consistent daily routine; strong engagement with cultural games.',
      ),
      const DoctorPatientProfile(
        id: 'pat_hemoprabha',
        name: 'Hemoprabha Devi',
        age: 68,
        region: 'Jorhat, Assam',
        language: 'Assamese (অসমীয়া)',
        caregiverName: 'Pranab Devi (Son)',
        caregiverPhone: '+91 98640 54321',
        adherenceRate: 78,
        avgAccuracy: 84,
        activeStreak: 5,
        statusSummary: 'Active sequence practice; moderate afternoon reminder adherence.',
      ),
      const DoctorPatientProfile(
        id: 'pat_taba',
        name: 'Taba Robin',
        age: 75,
        region: 'Itanagar, Arunachal Pradesh',
        language: 'English / Hindi',
        caregiverName: 'Taba Meena (Spouse)',
        caregiverPhone: '+91 94360 98765',
        adherenceRate: 70,
        avgAccuracy: 79,
        activeStreak: 2,
        statusSummary: 'Gentle attention games ongoing; sync completed yesterday.',
      ),
    ]);

    // 6. Teammate Memories
    _memories.addAll([
      const MemoryItem(
        id: 'mem_rain',
        title: 'Rainy afternoons at home',
        place: 'Guwahati, Assam',
        date: '1968',
        description: 'The sound of rain on our tin roof and tea with my mother.',
        photoIcon: '☔',
        recallPrompt: 'What peaceful sound do you remember on the roof?',
        options: ['Rain on tin roof', 'Bird song', 'Wind in trees'],
        correctIndex: 0,
        hint: 'A comforting sound of raindrops during monsoon tea time.',
      ),
      const MemoryItem(
        id: 'mem_bihu_courtyard',
        title: 'Bihu with the family',
        place: 'Guwahati, Assam',
        date: '1991',
        description: 'Everyone gathered around the courtyard after the dance.',
        photoIcon: '🎶',
        recallPrompt: 'Where did everyone gather after the festive dance?',
        options: ['Around the courtyard', 'In the kitchen', 'Under the mango tree'],
        correctIndex: 0,
        hint: 'The central open space of the family home.',
      ),
      const MemoryItem(
        id: 'mem_tenga',
        title: 'Grandmother’s tenga',
        place: 'Guwahati, Assam',
        date: 'Family recipe',
        description: 'Her gentle fish curry always brought us home.',
        photoIcon: '🍲',
        recallPrompt: 'What gentle family curry always brought everyone home?',
        options: ['Masor tenga', 'Khaar', 'Dal'],
        correctIndex: 0,
        hint: 'A traditional tangy Assamese fish broth.',
      ),
    ]);

    // 7. Teammate Daily Activities
    _activities.addAll([
      DailyActivity(id: 'act_1', title: 'Morning walk', detail: '20 minutes', done: true),
      DailyActivity(id: 'act_2', title: 'Gentle stretching', detail: '10 minutes', done: false),
      DailyActivity(id: 'act_3', title: 'Listen to a favourite song', detail: 'A moment for you', done: false),
      DailyActivity(id: 'act_4', title: 'Call Ananya', detail: 'Family connection', done: false),
    ]);

    // 8. Teammate Care Circle
    _careCircle.addAll([
      CareCircleMember(name: 'Ananya Das', relation: 'Daughter', contact: '98765 43210'),
      CareCircleMember(name: 'Ritwik Das', relation: 'Son', contact: '98765 43211'),
    ]);

    // 9. Teammate Upcoming Appointments
    _appointments.addAll([
      UpcomingAppointment(
        id: 'appt_1',
        title: 'Eye check-up',
        dateTimeStr: '24 September · 10:30 AM',
        location: 'City Clinic',
      ),
    ]);
  }

  // ==========================================
  // FASTAPI BACKEND SYNCHRONIZATION
  // ==========================================

  Future<void> syncWithBackend() async {
    _isSyncing = true;
    notifyListeners();

    try {
      final isHealthy = await ApiService.instance.checkHealth();
      if (!isHealthy) {
        _isOnline = false;
        _isSyncing = false;
        _syncStatusMessage = 'Offline mode active (FastAPI server unreachable)';
        notifyListeners();
        return;
      }

      _isOnline = true;

      // 1. If not yet authenticated, authenticate with pre-seeded demo account
      if (!ApiService.instance.isAuthenticated) {
        String email = 'patient@mindsetu.in';
        if (_currentRole == UserRole.caregiver) {
          email = 'caregiver@mindsetu.in';
        } else if (_currentRole == UserRole.doctor) {
          email = 'doctor@mindsetu.in';
        }

        final loginRes = await ApiService.instance.login(email: email, password: 'MindSetu@2026');

        if (!loginRes.isSuccess) {
          _isSyncing = false;
          _syncStatusMessage = 'Authentication error; working offline';
          notifyListeners();
          return;
        }
      }

      // 2. Push any queued offline items
      if (_pendingSyncQueue.isNotEmpty) {
        final pushRes = await ApiService.instance.pushSync(items: List.from(_pendingSyncQueue));
        if (pushRes.isSuccess) {
          _pendingSyncQueue.clear();
        }
      }

      // 3. Pull role-specific data
      if (_currentRole == UserRole.patient) {
        _isLoadingPatientProfile = true;
        _patientProfileError = null;

        try {
          // A. Pull authenticated user details (GET /api/v1/auth/me)
          final meRes = await ApiService.instance.getMe();
          if (meRes.isSuccess && meRes.data != null) {
            final meData = meRes.data!;
            final name = meData['full_name'] as String?;
            if (name != null && name.isNotEmpty) {
              _authFullName = name;
            }
          }

          // B. Pull patient profile (GET /api/v1/patients/me)
          final patRes = await ApiService.instance.getPatientMe();
          if (patRes.isSuccess && patRes.data != null) {
            final p = patRes.data!;
            final name = p['name'] as String?;
            if (name != null && name.isNotEmpty) {
              _authFullName = name;
            }
            final code = (p['patient_id'] as String?) ?? (p['patient_code'] as String?);
            if (code != null && code.isNotEmpty) {
              _patientId = code;
              _connectedPatientId = code;
            }
            final age = p['age'] as int?;
            if (age != null) {
              _connectedPatientAge = age;
            }
            final reg = p['region'] as String?;
            if (reg != null && reg.isNotEmpty) {
              _connectedPatientRegion = reg;
              _currentRegion = AppRegionX.fromString(reg);
            }
            final prefLang = p['preferred_language'] as String?;
            if (prefLang != null && prefLang.isNotEmpty) {
              _currentLanguage = AppLanguageX.fromCode(prefLang);
            }
          }

          // C. Pull patient dashboard (GET /api/v1/patients/me/dashboard)
          final dashRes = await ApiService.instance.getPatientDashboard();
          if (dashRes.isSuccess && dashRes.data != null) {
            final d = dashRes.data!;
            if (d['progress_summary'] is Map) {
              final ps = d['progress_summary'] as Map<String, dynamic>;
              if (ps['total_activities_completed'] is int) {
                _completedActivitiesCount = ps['total_activities_completed'] as int;
              }
              if (ps['active_day_streak'] is int) {
                _currentStreakDays = ps['active_day_streak'] as int;
              }
              if (ps['overall_accuracy_percentage'] is num) {
                _averageAccuracy = (ps['overall_accuracy_percentage'] as num).round();
              }
            }
            if (d['reminders'] is List) {
              final serverReminders = d['reminders'] as List;
              for (final r in serverReminders) {
                if (r is Map<String, dynamic> && r['id'] != null) {
                  final idx = _reminders.indexWhere((x) => x.id == r['id']);
                  if (idx != -1) {
                    _reminders[idx].completed = r['is_completed'] == true;
                  }
                }
              }
            }
          }
        } catch (e) {
          _patientProfileError = e.toString();
        } finally {
          _isLoadingPatientProfile = false;
        }
      } else if (_currentRole == UserRole.caregiver) {
        final notesRes = await ApiService.instance.getNotes();
        if (notesRes.isSuccess && notesRes.data != null) {
          final serverNotes = notesRes.data!;
          for (final n in serverNotes) {
            if (n is Map<String, dynamic> && n['id'] != null) {
              final exists = _observations.any((o) => o.id == n['id']);
              if (!exists) {
                _observations.add(CaregiverObservation(
                  id: n['id'].toString(),
                  timestampStr: n['timestamp']?.toString().substring(0, 16).replaceAll('T', ' ') ?? 'Recent',
                  mood: n['mood']?.toString() ?? 'Calm',
                  sleepHours: (n['sleep_hours'] as num?)?.toDouble() ?? 7.5,
                  appetite: n['appetite']?.toString() ?? 'Good',
                  notes: n['behavior_notes']?.toString() ?? 'Routine check',
                ));
              }
            }
          }
        }
      }

      // 4. Update sync timestamp and clear overdue alert
      _lastSyncedAt = DateTime.now();
      _syncStatusMessage = 'All data synced with FastAPI server';
    } catch (e) {
      _isOnline = false;
      _syncStatusMessage = 'Offline resilient mode';
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  /// Toggle reminder completion status immediately & sync with backend
  void toggleReminder(String id) {
    final index = _reminders.indexWhere((r) => r.id == id);
    if (index != -1) {
      _reminders[index].completed = !_reminders[index].completed;
      final newStatus = _reminders[index].completed;
      notifyListeners();

      // Dispatch to FastAPI backend in background if online, otherwise queue
      if (_isOnline && ApiService.instance.isAuthenticated) {
        ApiService.instance.updateReminder(id, isCompleted: newStatus).then((res) {
          if (!res.isSuccess) {
            _pendingSyncQueue.add({
              'entity_type': 'reminder',
              'entity_id': id,
              'operation': 'update',
              'payload': {
                'is_completed': newStatus,
              },
            });
          }
        });
      } else {
        _pendingSyncQueue.add({
          'entity_type': 'reminder',
          'entity_id': id,
          'operation': 'update',
          'payload': {
            'is_completed': newStatus,
          },
        });
      }
    }
  }

  /// Caregiver marks/verifies reminder completion & syncs with backend
  void verifyReminder(String id) {
    final index = _reminders.indexWhere((r) => r.id == id);
    if (index != -1) {
      _reminders[index].completed = true;
      _reminders[index].verifiedByCaregiver = true;
      notifyListeners();

      if (_isOnline && ApiService.instance.isAuthenticated) {
        ApiService.instance.updateReminder(id, isCompleted: true, verifiedByCaregiver: true);
      } else {
        _pendingSyncQueue.add({
          'entity_type': 'reminder',
          'entity_id': id,
          'operation': 'update',
          'payload': {
            'is_completed': true,
            'verified_by_caregiver': true,
          },
        });
      }
    }
  }

  /// Save new caregiver daily observation locally & send to FastAPI /api/v1/notes
  void saveObservation({
    required String mood,
    required double sleepHours,
    required String appetite,
    required String notes,
  }) {
    final noteText = notes.trim().isNotEmpty ? notes.trim() : 'No additional notes entered.';
    final newObs = CaregiverObservation(
      id: 'obs_${DateTime.now().millisecondsSinceEpoch}',
      timestampStr: 'Just now',
      mood: mood,
      sleepHours: sleepHours,
      appetite: appetite,
      notes: noteText,
    );
    _observations.insert(0, newObs);
    notifyListeners();

    // Send to backend /api/v1/notes
    if (_isOnline && ApiService.instance.isAuthenticated) {
      ApiService.instance.createNote(
        mood: mood,
        sleepHours: sleepHours,
        appetite: appetite,
        notes: noteText,
      ).then((res) {
        if (!res.isSuccess) {
          _pendingSyncQueue.add({
            'entity_type': 'note',
            'entity_id': newObs.id,
            'operation': 'create',
            'payload': {
              'mood': mood,
              'sleep_hours': sleepHours,
              'appetite': appetite,
              'behavior_notes': noteText,
            },
          });
        }
      });
    } else {
      _pendingSyncQueue.add({
        'entity_type': 'note',
        'entity_id': newObs.id,
        'operation': 'create',
        'payload': {
          'mood': mood,
          'sleep_hours': sleepHours,
          'appetite': appetite,
          'behavior_notes': noteText,
        },
      });
    }
  }

  /// Manual synchronization action (connects to FastAPI or simulates)
  void simulateSyncNow() {
    _lastSyncedAt = DateTime.now();
    notifyListeners();
    syncWithBackend();
  }

  /// Record completed cognitive game result, update local progress, and submit to FastAPI /api/v1/activities/results
  void recordGameCompletion({
    required String title,
    required String category,
    required int score,
    required int accuracy,
    required int durationSeconds,
    required IconData icon,
  }) {
    _completedActivitiesCount++;
    _practiceMinutes += (durationSeconds / 60).ceil();
    if (_practiceMinutes < 1) _practiceMinutes = 1;

    _averageAccuracy =
        ((_averageAccuracy * (_history.length) + accuracy) / (_history.length + 1)).round();

    _history.insert(
      0,
      ActivityHistoryItem(
        id: 'hist_${DateTime.now().millisecondsSinceEpoch}',
        title: title,
        category: category,
        timeAgo: 'Just now',
        score: score,
        accuracy: accuracy,
        icon: icon,
      ),
    );

    updateAdaptiveRecommendation();
    notifyListeners();

    // Map title to backend activity_id
    String activityId = 'act-sequence';
    if (title.toLowerCase().contains('match') || category.toLowerCase().contains('match')) {
      activityId = 'act-matching';
    } else if (title.toLowerCase().contains('recall')) {
      activityId = 'act-memory-recall';
    }

    if (_isOnline && ApiService.instance.isAuthenticated) {
      ApiService.instance.submitActivityResult(
        activityId: activityId,
        score: score,
        accuracy: accuracy.toDouble(),
        completionTimeSeconds: durationSeconds > 0 ? durationSeconds : 60,
      ).then((res) {
        if (!res.isSuccess) {
          _pendingSyncQueue.add({
            'entity_type': 'activity_result',
            'entity_id': 'res_${DateTime.now().millisecondsSinceEpoch}',
            'operation': 'create',
            'payload': {
              'activity_id': activityId,
              'score': score,
              'accuracy': accuracy.toDouble(),
              'completion_time_seconds': durationSeconds > 0 ? durationSeconds : 60,
              'moves_count': 4,
              'difficulty_level': 'gentle',
            },
          });
        }
      });
    } else {
      _pendingSyncQueue.add({
        'entity_type': 'activity_result',
        'entity_id': 'res_${DateTime.now().millisecondsSinceEpoch}',
        'operation': 'create',
        'payload': {
          'activity_id': activityId,
          'score': score,
          'accuracy': accuracy.toDouble(),
          'completion_time_seconds': durationSeconds > 0 ? durationSeconds : 60,
          'moves_count': 4,
          'difficulty_level': 'gentle',
        },
      });
    }
  }
}
