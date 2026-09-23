import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smriti/features/auth/auth_screen.dart';
import 'package:smriti/features/auth/welcome_screen.dart';
import 'package:smriti/features/caregiver/caregiver_dashboard.dart';
import 'package:smriti/features/doctor/doctor_dashboard.dart';
import 'package:smriti/features/home/app_shell.dart';
import 'package:smriti/localization/app_language.dart';
import 'package:smriti/localization/app_region.dart';
import 'package:smriti/main.dart';
import 'package:smriti/services/api_service.dart';
import 'package:smriti/services/api_transport.dart';
import 'package:smriti/services/local_data_service.dart';

/// Test mock transport that accurately reproduces FastAPI authentication endpoints
class MockAuthTransport implements ApiTransport {
  MockAuthTransport({this.shouldFailAuth = false, this.isOffline = false});

  bool shouldFailAuth;
  bool isOffline;

  @override
  Future<TransportResponse> sendRequest({
    required String method,
    required String url,
    Map<String, String>? headers,
    String? body,
    int timeoutSeconds = 5,
  }) async {
    if (isOffline) {
      return const TransportResponse(statusCode: 0, body: 'Connection refused', isOffline: true);
    }

    if (url.endsWith('/health')) {
      return const TransportResponse(
        statusCode: 200,
        body: '{"status":"ok","database":"connected"}',
      );
    }

    if (url.endsWith('/api/v1/auth/login')) {
      if (body != null) {
        final decoded = jsonDecode(body) as Map<String, dynamic>;
        final email = decoded['email'] as String?;
        final password = decoded['password'] as String?;

        if (shouldFailAuth || password != 'MindSetu@2026') {
          return const TransportResponse(
            statusCode: 401,
            body: '{"success":false,"data":null,"message":"Incorrect email or password."}',
          );
        }

        String role = 'PATIENT';
        String fullName = 'Bhaben Borah';
        String? patientId = 'MS-ASSAM-001';

        if (email == 'caregiver@mindsetu.in') {
          role = 'CAREGIVER';
          fullName = 'Anamika Borah';
          patientId = null;
        } else if (email == 'doctor@mindsetu.in') {
          role = 'DOCTOR';
          fullName = 'Dr. Debabrata Sarma';
          patientId = null;
        }

        return TransportResponse(
          statusCode: 200,
          body: jsonEncode({
            'success': true,
            'data': {
              'access_token': 'mock_jwt_token_${role.toLowerCase()}',
              'token_type': 'bearer',
              'user_id': 'usr_${role.toLowerCase()}',
              'email': email,
              'full_name': fullName,
              'role': role,
              'patient_id': patientId,
              'patient_code': patientId,
            },
            'message': 'Login successful.',
          }),
        );
      }
    }

    if (url.endsWith('/api/v1/patients/me')) {
      return TransportResponse(
        statusCode: 200,
        body: jsonEncode({
          'success': true,
          'data': {
            'patient_id': 'MS-ASSAM-001',
            'name': 'Bhaben Borah',
            'age': 72,
            'region': 'assam',
            'preferred_language': 'Assamese',
          },
          'message': 'Patient profile retrieved.',
        }),
      );
    }

    return const TransportResponse(
      statusCode: 200,
      body: '{"success":true,"data":{}}',
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late MockAuthTransport mockTransport;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    mockTransport = MockAuthTransport();
    ApiService.instance.setTransport(mockTransport);
    LocalDataService.instance.resetOnboarding();
    LocalDataService.instance.logout();
    LocalDataService.instance.setLanguage(AppLanguage.english);
  });

  tearDown(() {
    ApiService.instance.resetTransport();
  });

  group('Authentication & Login Flow End-to-End Tests', () {
    testWidgets('Test A & B & C: Patient demo login -> AppShell opens -> Logout -> AuthScreen -> Login again', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final data = LocalDataService.instance;

      // 1. Launch on Welcome
      await tester.pumpWidget(const SmritiApp());
      await tester.pumpAndSettle();

      expect(find.byType(WelcomeScreen), findsOneWidget);

      // 2. Direct Log in from Welcome
      await tester.tap(find.text('Log in'));
      await tester.pumpAndSettle();

      expect(find.byType(AuthScreen), findsOneWidget);

      // 3. Submit Patient demo credentials
      final signInButton = find.widgetWithText(FilledButton, data.localizations.signInButton);
      expect(signInButton, findsOneWidget);

      await tester.tap(signInButton);
      await tester.pumpAndSettle();

      // Test A: Verify Patient AppShell opened
      expect(data.isAuthenticated, isTrue);
      expect(data.currentRole, UserRole.patient);
      expect(find.byType(AuthScreen), findsNothing);
      expect(find.byType(AppShell), findsOneWidget);

      // Test B: Logout returns to AuthScreen
      data.logout();
      await tester.pumpAndSettle();

      expect(data.isAuthenticated, isFalse);
      expect(find.byType(AppShell), findsNothing);
      expect(find.byType(AuthScreen), findsOneWidget);

      // Test C: Login again opens AppShell
      final signInButtonAgain = find.widgetWithText(FilledButton, data.localizations.signInButton);
      await tester.tap(signInButtonAgain);
      await tester.pumpAndSettle();

      expect(data.isAuthenticated, isTrue);
      expect(find.byType(AppShell), findsOneWidget);
    });

    testWidgets('Test D: Wrong password -> friendly error -> remain on login screen', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final data = LocalDataService.instance;
      mockTransport.shouldFailAuth = true;

      await tester.pumpWidget(const SmritiApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Log in'));
      await tester.pumpAndSettle();

      expect(find.byType(AuthScreen), findsOneWidget);

      final signInButton = find.widgetWithText(FilledButton, data.localizations.signInButton);
      await tester.tap(signInButton);
      await tester.pumpAndSettle();

      // Verify authentication failed, user stays on login screen, error shown
      expect(data.isAuthenticated, isFalse);
      expect(find.byType(AuthScreen), findsOneWidget);
      expect(find.byType(AppShell), findsNothing);
      expect(find.textContaining('Incorrect email or password'), findsOneWidget);
    });

    testWidgets('Test E: Patient role login -> patient AppShell', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final data = LocalDataService.instance;
      data.completeOnboarding(region: AppRegion.assam);

      await tester.pumpWidget(const SmritiApp());
      await tester.pumpAndSettle();

      // Already onboarded -> AuthScreen is root
      expect(find.byType(AuthScreen), findsOneWidget);

      await tester.tap(find.widgetWithText(FilledButton, data.localizations.signInButton));
      await tester.pumpAndSettle();

      expect(data.isAuthenticated, isTrue);
      expect(data.currentRole, UserRole.patient);
      expect(find.byType(AppShell), findsOneWidget);
    });

    testWidgets('Test F: Caregiver role login -> CaregiverDashboard', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final data = LocalDataService.instance;
      data.completeOnboarding(region: AppRegion.assam);

      await tester.pumpWidget(const SmritiApp());
      await tester.pumpAndSettle();

      expect(find.byType(AuthScreen), findsOneWidget);

      // Tap Caregiver quick demo button or role chip
      await tester.tap(find.text(data.localizations.caregiverRoleLabel).first);
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(FilledButton, data.localizations.signInButton));
      await tester.pumpAndSettle();

      expect(data.isAuthenticated, isTrue);
      expect(data.currentRole, UserRole.caregiver);
      expect(find.byType(CaregiverDashboard), findsOneWidget);
      expect(find.byType(AppShell), findsNothing);
    });

    testWidgets('Test G: Doctor role login -> DoctorDashboard', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final data = LocalDataService.instance;
      data.completeOnboarding(region: AppRegion.assam);

      await tester.pumpWidget(const SmritiApp());
      await tester.pumpAndSettle();

      expect(find.byType(AuthScreen), findsOneWidget);

      // Tap Doctor role chip
      await tester.tap(find.text(data.localizations.doctorRoleLabel).first);
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(FilledButton, data.localizations.signInButton));
      await tester.pumpAndSettle();

      expect(data.isAuthenticated, isTrue);
      expect(data.currentRole, UserRole.doctor);
      expect(find.byType(DoctorDashboard), findsOneWidget);
      expect(find.byType(AppShell), findsNothing);
    });

    testWidgets('Test H: Assam/Assamese selected before login -> selection remains after login', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final data = LocalDataService.instance;

      await tester.pumpWidget(const SmritiApp());
      await tester.pumpAndSettle();

      // Go through onboarding tour
      await tester.tap(find.text('Get started'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // Select Assam & Assamese
      await tester.tap(find.text('Assam').first);
      await tester.pumpAndSettle();

      await tester.tap(find.text("Let's get started"));
      await tester.pumpAndSettle();

      expect(data.currentRegion, AppRegion.assam);
      expect(data.currentLanguage, AppLanguage.assamese);
      expect(find.byType(AuthScreen), findsOneWidget);

      // Log in
      await tester.tap(find.widgetWithText(FilledButton, data.localizations.signInButton));
      await tester.pumpAndSettle();

      expect(data.isAuthenticated, isTrue);
      expect(find.byType(AppShell), findsOneWidget);
      // Region and language remain preserved
      expect(data.currentRegion, AppRegion.assam);
      expect(data.currentLanguage, AppLanguage.assamese);
    });
  });
}
