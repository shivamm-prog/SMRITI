import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:smriti/localization/app_language.dart';
import 'package:smriti/main.dart';
import 'package:smriti/services/api_config.dart';
import 'package:smriti/services/api_service.dart';
import 'package:smriti/services/local_data_service.dart';
import 'package:smriti/services/pdf_report_service.dart';

void main() {
  testWidgets('SmritiApp launch shows AuthScreen', (WidgetTester tester) async {
    // Build SmritiApp and trigger a frame.
    await tester.pumpWidget(const SmritiApp());
    await tester.pumpAndSettle();

    // Verify AuthScreen branding is present on entry
    expect(find.textContaining('Smriti'), findsWidgets);
  });

  test('LocalDataService language switching test (English -> Assamese -> Hindi -> English)', () {
    final service = LocalDataService.instance;

    // 1. English
    service.setLanguage(AppLanguage.english);
    expect(service.currentLanguage, AppLanguage.english);
    expect(service.localizations.teaRoutineTitle, 'Making Morning Assam Tea');
    expect(service.localizations.stepBoilWater, 'Boil Fresh Water');

    // 2. Assamese
    service.setLanguage(AppLanguage.assamese);
    expect(service.currentLanguage, AppLanguage.assamese);
    expect(service.localizations.teaRoutineTitle, 'ৰাতিপুৱাৰ অসমীয়া চাহ তৈয়াৰ');
    expect(service.localizations.stepBoilWater, 'পানী উতলাওক');

    // 3. Hindi
    service.setLanguage(AppLanguage.hindi);
    expect(service.currentLanguage, AppLanguage.hindi);
    expect(service.localizations.teaRoutineTitle, 'सुबह की असम चाय बनाना');
    expect(service.localizations.stepBoilWater, 'ताज़ा पानी उबालें');

    // 4. Return to English
    service.setLanguage(AppLanguage.english);
    expect(service.currentLanguage, AppLanguage.english);
    expect(service.localizations.teaRoutineTitle, 'Making Morning Assam Tea');
  });

  test('LocalDataService adaptive activity rotation test', () {
    final service = LocalDataService.instance;
    final initialActivity = service.currentRecommendation;

    // Simulate completion of initial activity
    service.recordGameCompletion(
      title: initialActivity.title,
      category: initialActivity.category,
      score: 100,
      accuracy: 100,
      durationSeconds: 180,
      icon: service.history.first.icon,
    );

    // Verify recommendation rotated adaptively away from just-completed activity
    final nextActivity = service.currentRecommendation;
    expect(nextActivity.id, isNot(initialActivity.id));

    // Manual rotation test
    final manualNext = service.currentRecommendation;
    service.rotateRecommendation();
    expect(service.currentRecommendation.id, isNot(manualNext.id));
  });

  test('LocalDataService authentication and logout test', () {
    final service = LocalDataService.instance;

    // Login as Patient
    service.setAuthenticatedUser(
      role: UserRole.patient,
      fullName: 'Bhaben Borah',
      email: 'patient@mindsetu.in',
      token: 'jwt_mock_token_xyz',
    );

    expect(service.isAuthenticated, true);
    expect(service.currentRole, UserRole.patient);
    expect(service.authFullName, 'Bhaben Borah');

    // Logout
    service.logout();
    expect(service.isAuthenticated, false);
    expect(service.authFullName, null);
  });

  test('LocalDataService reminder toggle & verification test', () {
    final service = LocalDataService.instance;
    final firstId = service.reminders.first.id;
    final initialCompleted = service.reminders.first.completed;

    // Test toggle
    service.toggleReminder(firstId);
    expect(service.reminders.first.completed, !initialCompleted);

    // Test caregiver verification
    service.verifyReminder(firstId);
    expect(service.reminders.first.completed, true);
    expect(service.reminders.first.verifiedByCaregiver, true);
  });

  test('LocalDataService observation logging test', () {
    final service = LocalDataService.instance;
    final initialCount = service.observations.length;

    service.saveObservation(
      mood: 'Happy',
      sleepHours: 8.0,
      appetite: 'Good',
      notes: 'Father enjoyed morning tea and smiled warmly.',
    );

    expect(service.observations.length, initialCount + 1);
    expect(service.latestObservation?.mood, 'Happy');
    expect(service.latestObservation?.sleepHours, 8.0);
    expect(service.latestObservation?.appetite, 'Good');
  });

  test('LocalDataService sync overdue and manual sync test', () {
    final service = LocalDataService.instance;

    // Pre-seeded to >48 hours ago
    expect(service.hoursSinceLastSync, greaterThanOrEqualTo(48));
    expect(service.isSyncOverdue, true);

    // Simulate sync
    service.simulateSyncNow();
    expect(service.hoursSinceLastSync, lessThan(1));
    expect(service.isSyncOverdue, false);
  });

  test('LocalDataService role switching test', () {
    final service = LocalDataService.instance;

    service.setRole(UserRole.caregiver);
    expect(service.currentRole, UserRole.caregiver);

    service.setRole(UserRole.doctor);
    expect(service.currentRole, UserRole.doctor);

    service.setRole(UserRole.patient);
    expect(service.currentRole, UserRole.patient);
  });

  test('ApiService client configuration and offline resilience test', () async {
    final api = ApiService.instance;

    // Test URL configuration
    api.setBaseUrl('http://127.0.0.1:8000/');
    expect(api.baseUrl, 'http://127.0.0.1:8000');

    // Test token management
    api.setToken('test_token_123', role: 'PATIENT', userId: 'usr_1', patientId: 'pat_1');
    expect(api.isAuthenticated, true);
    expect(api.accessToken, 'test_token_123');
    expect(api.currentRole, 'PATIENT');
    expect(api.patientId, 'pat_1');

    api.clearAuth();
    expect(api.isAuthenticated, false);
    expect(api.accessToken, null);
  });

  test('PdfReportService patient report PDF generation test', () {
    final pdfBytes = PdfReportService.instance.generateReport(
      patient: {
        'id': 'ba58751e-7213-4f6c-883b-d547d69663cd',
        'name': 'Bhaben Borah',
        'age': 72,
        'region': 'Tezpur, Assam',
        'preferred_language': 'Assamese (অসমীয়া)',
      },
      activityHistory: [
        {'activity_id': 'act-sequence', 'score': 100, 'accuracy': 100.0, 'date': '2026-09-02 13:54'},
        {'activity_id': 'act-matching', 'score': 95, 'accuracy': 95.0, 'date': '2026-09-02 10:15'},
      ],
      caregiverObservations: [
        {'date': 'Today, 10:30 AM', 'mood': 'Calm', 'sleep': '7.5 hrs', 'appetite': 'Good', 'observations': 'Father in good spirits.'},
      ],
      domainTrends: {
        'Routine Sequencing': '100%',
        'Memory Recall': '96%',
        'Matching': '90%',
      },
      adherenceData: {
        'adherence_percentage': '85%',
      },
      preliminaryInsights: [
        {'title': 'Consistent Routine Sequencing', 'desc': 'Preserved procedural memory.'},
      ],
      doctorName: 'Dr. Debabrata Sarma, MD (Geriatric Medicine)',
    );

    expect(pdfBytes.length, greaterThan(1000));
    final header = String.fromCharCodes(pdfBytes.take(8));
    expect(header.startsWith('%PDF-1.4'), true);
  });

  test('ApiConfig and FileSaver web compatibility test', () async {
    expect(ApiConfig.defaultLocalUrl, 'http://127.0.0.1:8000');
    expect(ApiConfig.isLocalDevelopment, true);

    ApiConfig.setCustomBaseUrl('https://mindsetu-backend.onrender.com');
    expect(ApiConfig.baseUrl, 'https://mindsetu-backend.onrender.com');
    expect(ApiConfig.isLocalDevelopment, false);

    ApiConfig.resetToDefault();
    expect(ApiConfig.baseUrl, 'http://127.0.0.1:8000');

    // Test savePdfFile runs safely without dart:io / Platform.environment errors
    final result = await PdfReportService.instance.savePdfFile(
      bytes: Uint8List.fromList([1, 2, 3]),
      patientName: 'Test Patient',
    );
    expect(result, isNotEmpty);
  });
}
