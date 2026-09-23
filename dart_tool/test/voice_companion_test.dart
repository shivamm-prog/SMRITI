import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smriti/core/theme/app_theme.dart';
import 'package:smriti/localization/app_language.dart';
import 'package:smriti/services/api_service.dart';
import 'package:smriti/services/local_data_service.dart';
import 'package:smriti/services/voice_service.dart';
import 'package:smriti/widgets/voice_companion_modal.dart';

class _AvailableTestVoiceService extends MindSetuVoiceService {
  final Completer<VoiceResult> _completer = Completer<VoiceResult>();

  @override
  Future<bool> isAvailable() async => true;

  @override
  Future<VoiceResult> listen({
    Duration timeout = const Duration(seconds: 8),
    AppLanguage? language,
  }) {
    return _completer.future;
  }
}

class _UnavailableTestVoiceService extends MindSetuVoiceService {
  @override
  Future<bool> isAvailable() async => false;
}

void main() {
  setUp(() {
    LocalDataService.instance.setAuthenticatedUser(
      role: UserRole.patient,
      fullName: 'Bhaben Borah',
      email: 'bhaben@mindsetu.in',
      patientId: 'MS-ASSAM-001',
    );
    LocalDataService.instance.setLanguage(AppLanguage.english);
  });

  group('MindSetuVoiceService Tests', () {
    final service = MindSetuVoiceService();

    test('Activities intent: "Start today\'s activity" navigates to Activities tab', () async {
      final resEn = await service.processCommand(
        "Start today's activity",
        data: LocalDataService.instance,
        language: AppLanguage.english,
      );
      expect(resEn.intent, VoiceIntentType.activities);
      expect(resEn.targetTabIndex, 1);
      expect(resEn.actionLabel, 'Go to Activities');
      expect(resEn.responseText, contains('Starting your gentle cognitive activity'));

      final resAs = await service.processCommand(
        "আজিৰ কাৰ্যকলাপ আৰম্ভ কৰক",
        data: LocalDataService.instance,
        language: AppLanguage.assamese,
      );
      expect(resAs.intent, VoiceIntentType.activities);
      expect(resAs.targetTabIndex, 1);
    });

    test('Progress intent: "Show my progress" navigates to Progress tab', () async {
      final res = await service.processCommand(
        "Show my progress",
        data: LocalDataService.instance,
        language: AppLanguage.english,
      );
      expect(res.intent, VoiceIntentType.progress);
      expect(res.targetTabIndex, 3);
      expect(res.actionLabel, 'View Progress');
      expect(res.responseText, contains('streak'));
    });

    test('Language switching intent: "Change language to Hindi" updates AppLanguage', () async {
      final res = await service.processCommand(
        "Change language to Hindi",
        data: LocalDataService.instance,
        language: AppLanguage.english,
      );
      expect(res.intent, VoiceIntentType.changeLanguage);
      expect(LocalDataService.instance.currentLanguage, AppLanguage.hindi);
      expect(res.responseText, contains('हिन्दी'));
    });

    test('Language switching intent: "Change language to Assamese" updates AppLanguage', () async {
      final res = await service.processCommand(
        "Change language to Assamese",
        data: LocalDataService.instance,
        language: AppLanguage.hindi,
      );
      expect(res.intent, VoiceIntentType.changeLanguage);
      expect(LocalDataService.instance.currentLanguage, AppLanguage.assamese);
      expect(res.responseText, contains('অসমীয়াত'));
    });

    test('Reminders intent recognized with live data count', () async {
      final res = await service.processCommand(
        "Show my reminders and medicine",
        data: LocalDataService.instance,
        language: AppLanguage.english,
      );
      expect(res.intent, VoiceIntentType.reminders);
      expect(res.targetTabIndex, 0);
      expect(res.responseText, contains('reminders'));
    });

    test('Memories intent recognized', () async {
      final res = await service.processCommand(
        "Start a memory game with Kaziranga photos",
        data: LocalDataService.instance,
        language: AppLanguage.english,
      );
      expect(res.intent, VoiceIntentType.memories);
      expect(res.targetTabIndex, 2);
      expect(res.actionLabel, 'Open Memories');
    });

    test('Patient info and ID intent provides verified patient details', () async {
      final res = await service.processCommand(
        "What is my patient ID and who am I?",
        data: LocalDataService.instance,
        language: AppLanguage.english,
      );
      expect(res.intent, VoiceIntentType.patientInfo);
      expect(res.targetTabIndex, 4);
      expect(res.responseText, contains('MS-ASSAM-001'));
      expect(res.responseText, contains('Bhaben Borah'));
    });

    test('Offline fallback when ApiService is unauthenticated or network unreachable', () async {
      ApiService.instance.clearAuth();
      final offlineService = MindSetuVoiceService();

      final res = await offlineService.processCommand(
        "Show my reminders",
        data: LocalDataService.instance,
        language: AppLanguage.english,
      );
      expect(res.intent, VoiceIntentType.reminders);
      expect(res.targetTabIndex, 0);
      expect(res.responseText, contains('reminders'));
    });

    test('Online voice command graceful handling when authenticated', () async {
      ApiService.instance.setToken('mock-jwt-token', role: 'PATIENT', patientId: 'MS-ASSAM-001');
      final onlineService = MindSetuVoiceService();

      final res = await onlineService.processCommand(
        "What is my next activity?",
        data: LocalDataService.instance,
        language: AppLanguage.english,
      );
      // Either backend returns response or falls back cleanly
      expect(res.intent, VoiceIntentType.activities);
      expect(res.targetTabIndex, 1);
      expect(res.responseText, isNotEmpty);

      ApiService.instance.clearAuth();
    });
  });

  group('VoiceCompanionModal Widget Tests', () {
    testWidgets('Renders VoiceCompanionModal with listening UI and chips when mic available', (tester) async {
      int? navigatedIndex;

      await tester.pumpWidget(
        MaterialApp(
          theme: buildSmritiTheme(),
          home: Scaffold(
            body: VoiceCompanionModal(
              voiceService: _AvailableTestVoiceService(),
              onNavigateTab: (index) => navigatedIndex = index,
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.textContaining('MindSetu Voice Companion'), findsOneWidget);
      expect(find.textContaining('I am listening gently...'), findsOneWidget);
      expect(find.text('"Show my progress"'), findsOneWidget);
      expect(find.text('"Start today\'s activity"'), findsOneWidget);

      // Tap on "Start today's activity" chip
      await tester.ensureVisible(find.text('"Start today\'s activity"'));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.tap(find.text('"Start today\'s activity"'));
      await tester.pump(); // Enter processing
      await tester.pump(const Duration(milliseconds: 600)); // Process command
      await tester.pump(const Duration(milliseconds: 200)); // Transition to response

      expect(find.textContaining('Go to Activities'), findsOneWidget);

      // Tap the action button to navigate
      await tester.ensureVisible(find.text('Go to Activities'));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.tap(find.text('Go to Activities'));
      await tester.pump();

      expect(navigatedIndex, 1);
    });

    testWidgets('Gracefully renders Error state card when mic is unavailable', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildSmritiTheme(),
          home: Scaffold(
            body: VoiceCompanionModal(
              voiceService: _UnavailableTestVoiceService(),
              onNavigateTab: (_) {},
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Verifies Error state is displayed cleanly instead of hanging in listening
      expect(find.text('Microphone Unavailable'), findsOneWidget);
      expect(find.textContaining('Microphone access is'), findsOneWidget);
      expect(find.text('Try Listening Again'), findsOneWidget);
    });

    testWidgets('Fallback text field executes typed voice commands', (tester) async {
      int? navigatedIndex;

      await tester.pumpWidget(
        MaterialApp(
          theme: buildSmritiTheme(),
          home: Scaffold(
            body: VoiceCompanionModal(
              onNavigateTab: (index) => navigatedIndex = index,
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Enter command into fallback text field
      final textField = find.byType(TextField);
      expect(textField, findsOneWidget);

      await tester.enterText(textField, "Show my progress");
      await tester.tap(find.byIcon(Icons.send_rounded));

      await tester.pump(); // Enter processing
      await tester.pump(const Duration(milliseconds: 600)); // Process command
      await tester.pump(const Duration(milliseconds: 200)); // Transition to response

      expect(find.textContaining('View Progress'), findsOneWidget);

      await tester.tap(find.text('View Progress'));
      await tester.pump();

      expect(navigatedIndex, 3);
    });

    testWidgets('Voice modal displays transcript and SMRITI response visibly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildSmritiTheme(),
          home: const Scaffold(
            body: VoiceCompanionModal(
              onNavigateTab: _dummyNav,
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      final textField = find.byType(TextField);
      await tester.enterText(textField, "Tell me today's gentle routine");
      await tester.tap(find.byIcon(Icons.send_rounded));

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('You said:'), findsOneWidget);
      expect(find.text('"Tell me today\'s gentle routine"'), findsOneWidget);
      expect(find.text('SMRITI:'), findsOneWidget);
    });
  });
}

void _dummyNav(int _) {}
