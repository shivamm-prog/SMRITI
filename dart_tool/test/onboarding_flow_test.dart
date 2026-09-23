import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smriti/features/auth/auth_screen.dart';
import 'package:smriti/features/auth/welcome_screen.dart';
import 'package:smriti/features/onboarding/onboarding_screen.dart';
import 'package:smriti/localization/app_language.dart';
import 'package:smriti/localization/app_region.dart';
import 'package:smriti/main.dart';
import 'package:smriti/services/local_data_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Onboarding Navigation Flow Tests', () {
    testWidgets('Fresh launch -> Get Started -> Reach Region -> Select Assam -> Confirm Assamese -> Tap Let\'s get started -> Navigates to AuthScreen', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final data = LocalDataService.instance;
      data.resetOnboarding();
      data.logout();

      expect(data.hasCompletedOnboarding, isFalse);
      expect(data.isAuthenticated, isFalse);

      // 1. Fresh launch
      await tester.pumpWidget(const SmritiApp());
      await tester.pumpAndSettle();

      // Welcome screen is shown
      expect(find.byType(WelcomeScreen), findsOneWidget);
      expect(find.text('Get started'), findsOneWidget);

      // Tap 'Get started'
      await tester.tap(find.text('Get started'));
      await tester.pumpAndSettle();

      // 2. Reach Region Selection
      expect(find.byType(OnboardingScreen), findsOneWidget);

      // Step 1 -> Continue
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // Step 2 -> Continue
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // Step 3 -> Continue
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // Step 4: Region Selection
      expect(find.textContaining('Choose your region'), findsWidgets);

      // 3. Select Assam
      await tester.tap(find.text('Assam').first);
      await tester.pumpAndSettle();

      // 4. Confirm Assamese
      expect(find.textContaining('Assamese'), findsWidgets);

      // 5. Tap "Let's get started"
      final startBtn = find.text("Let's get started");
      expect(startBtn, findsOneWidget);
      await tester.tap(startBtn);
      await tester.pumpAndSettle();

      // 6. Verify navigation succeeds: OnboardingScreen is gone, AuthScreen is displayed
      expect(find.byType(OnboardingScreen), findsNothing);
      expect(find.byType(AuthScreen), findsOneWidget);
      expect(data.hasCompletedOnboarding, isTrue);
      expect(data.currentRegion, AppRegion.assam);
      expect(data.currentLanguage, AppLanguage.assamese);
    });

    testWidgets('Sikkim -> Nepali onboarding flow and persistence', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final data = LocalDataService.instance;
      data.resetOnboarding();
      data.logout();

      await tester.pumpWidget(const SmritiApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Get started'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // Select Sikkim
      await tester.tap(find.text('Sikkim'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Nepali'), findsWidgets);

      await tester.tap(find.text("Let's get started"));
      await tester.pumpAndSettle();

      expect(find.byType(OnboardingScreen), findsNothing);
      expect(find.byType(AuthScreen), findsOneWidget);
      expect(data.hasCompletedOnboarding, isTrue);
      expect(data.currentRegion, AppRegion.sikkim);
      expect(data.currentLanguage, AppLanguage.nepali);
    });

    testWidgets('Mizoram -> Mizo onboarding flow and persistence', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final data = LocalDataService.instance;
      data.resetOnboarding();
      data.logout();

      await tester.pumpWidget(const SmritiApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Get started'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // Select Mizoram
      await tester.tap(find.text('Mizoram'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Mizo'), findsWidgets);

      await tester.tap(find.text("Let's get started"));
      await tester.pumpAndSettle();

      expect(find.byType(OnboardingScreen), findsNothing);
      expect(find.byType(AuthScreen), findsOneWidget);
      expect(data.hasCompletedOnboarding, isTrue);
      expect(data.currentRegion, AppRegion.mizoram);
      expect(data.currentLanguage, AppLanguage.mizo);
    });
  });
}
