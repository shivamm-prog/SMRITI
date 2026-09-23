import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smriti/core/theme/app_theme.dart';
import 'package:smriti/features/onboarding/onboarding_screen.dart';
import 'package:smriti/features/profile/profile_screen.dart';
import 'package:smriti/localization/app_language.dart';
import 'package:smriti/localization/app_localizations.dart';
import 'package:smriti/localization/app_region.dart';
import 'package:smriti/services/local_data_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Phase 1: Region-Based Multilingual Support Tests', () {
    test('Prototype default mapping covers all 8 NER states', () {
      expect(AppRegion.assam.defaultLanguage, AppLanguage.assamese);
      expect(AppRegion.arunachalPradesh.defaultLanguage, AppLanguage.hindi);
      expect(AppRegion.manipur.defaultLanguage, AppLanguage.manipuri);
      expect(AppRegion.meghalaya.defaultLanguage, AppLanguage.khasi);
      expect(AppRegion.mizoram.defaultLanguage, AppLanguage.mizo);
      expect(AppRegion.nagaland.defaultLanguage, AppLanguage.nagamese);
      expect(AppRegion.sikkim.defaultLanguage, AppLanguage.nepali);
      expect(AppRegion.tripura.defaultLanguage, AppLanguage.kokborok);
    });

    test('Test A: Select Assam -> Assamese automatically enabled -> restart -> Assamese remains', () async {
      SharedPreferences.setMockInitialValues({});
      final service = LocalDataService.instance;

      // 1. Select Assam
      await service.setRegion(AppRegion.assam);
      expect(service.currentRegion, AppRegion.assam);
      expect(service.currentLanguage, AppLanguage.assamese);

      // Verify persistence saved
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('smriti_selected_region'), 'assam');
      expect(prefs.getString('smriti_selected_language'), 'as');

      // 2. Simulate app restart: prefs restore previously selected region and language
      SharedPreferences.setMockInitialValues({
        'smriti_selected_region': 'assam',
        'smriti_selected_language': 'as',
        'smriti_has_completed_onboarding': true,
      });
      await service.initPrefs();

      expect(service.currentRegion, AppRegion.assam);
      expect(service.currentLanguage, AppLanguage.assamese);
      expect(service.hasCompletedOnboarding, true);
    });

    test('Test B: Select Sikkim -> Nepali automatically enabled -> restart -> Nepali remains', () async {
      SharedPreferences.setMockInitialValues({});
      final service = LocalDataService.instance;

      // 1. Select Sikkim
      await service.setRegion(AppRegion.sikkim);
      expect(service.currentRegion, AppRegion.sikkim);
      expect(service.currentLanguage, AppLanguage.nepali);

      // Verify persistence saved
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('smriti_selected_region'), 'sikkim');
      expect(prefs.getString('smriti_selected_language'), 'ne');

      // 2. Simulate app restart: prefs restore previously selected region and language
      SharedPreferences.setMockInitialValues({
        'smriti_selected_region': 'sikkim',
        'smriti_selected_language': 'ne',
        'smriti_has_completed_onboarding': true,
      });
      await service.initPrefs();

      expect(service.currentRegion, AppRegion.sikkim);
      expect(service.currentLanguage, AppLanguage.nepali);
      expect(service.hasCompletedOnboarding, true);
    });

    test('Test C: Select Mizoram -> Mizo automatically enabled', () async {
      final service = LocalDataService.instance;

      await service.setRegion(AppRegion.mizoram);
      expect(service.currentRegion, AppRegion.mizoram);
      expect(service.currentLanguage, AppLanguage.mizo);
    });

    test('Test E: Existing English, Hindi, Assamese functionality continues working', () {
      final service = LocalDataService.instance;

      // 1. English
      service.setLanguage(AppLanguage.english);
      expect(service.currentLanguage, AppLanguage.english);
      expect(service.localizations.home, 'Home');
      expect(service.localizations.greeting('Bhaben'), 'Good morning, Bhaben');

      // 2. Hindi
      service.setLanguage(AppLanguage.hindi);
      expect(service.currentLanguage, AppLanguage.hindi);
      expect(service.localizations.home, 'होम');
      expect(service.localizations.greeting('Bhaben'), 'सुप्रभात, Bhaben');

      // 3. Assamese
      service.setLanguage(AppLanguage.assamese);
      expect(service.currentLanguage, AppLanguage.assamese);
      expect(service.localizations.home, 'হোম');
      expect(service.localizations.greeting('Bhaben'), 'সুপ্ৰভাত, Bhaben');
    });

    test('Fallback safety: Every language returns non-empty strings and never crashes', () {
      for (final language in AppLanguage.values) {
        final l = AppLocalizations(language);
        expect(l.home, isNotEmpty);
        expect(l.games, isNotEmpty);
        expect(l.memories, isNotEmpty);
        expect(l.progress, isNotEmpty);
        expect(l.profile, isNotEmpty);
        expect(l.greeting('Elder'), isNotEmpty);
        expect(l.chooseRegion, isNotEmpty);
        expect(l.chooseRegionSubtitle, isNotEmpty);
        expect(l.languageAssignedConfirmation('Language'), isNotEmpty);
        expect(l.regionAndLanguage, isNotEmpty);
        expect(l.region, isNotEmpty);
        expect(l.changeRegion, isNotEmpty);
        expect(l.automaticLanguageLabel, isNotEmpty);
        expect(l.letsGetStarted, isNotEmpty);
        expect(l.continueButton, isNotEmpty);
        expect(l.teaRoutineTitle, isNotEmpty);
        expect(l.cardMatchTitle, isNotEmpty);
        expect(l.memoriesTitle, isNotEmpty);
      }
    });

    testWidgets('Onboarding Region Selection UI test', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      AppRegion? completedRegion;

      await tester.pumpWidget(
        MaterialApp(
          theme: buildSmritiTheme(),
          home: OnboardingScreen(
            onComplete: (region) {
              completedRegion = region;
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify branding is present
      expect(find.textContaining('Smriti'), findsWidgets);

      // Navigate pages using Continue button
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // Verify Region selection header is visible
      expect(find.textContaining('region'), findsWidgets);

      // Verify all 8 NER states are displayed as cards
      for (final region in AppRegion.values) {
        expect(find.text(region.name), findsAtLeastNWidgets(1));
      }

      // Tap on 'Sikkim'
      await tester.tap(find.text('Sikkim'));
      await tester.pumpAndSettle();

      // Verify confirmation banner shows 'Nepali'
      expect(find.textContaining('Nepali'), findsWidgets);

      // Tap 'Let\'s get started'
      await tester.tap(find.text("Let's get started"));
      await tester.pumpAndSettle();

      expect(completedRegion, AppRegion.sikkim);
    });

    testWidgets('Test D: Change region from Profile updates language globally', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final service = LocalDataService.instance;
      await service.setRegion(AppRegion.assam);
      expect(service.currentRegion, AppRegion.assam);
      expect(service.currentLanguage, AppLanguage.assamese);

      AppLanguage? changedLang;

      await tester.pumpWidget(
        MaterialApp(
          theme: buildSmritiTheme(),
          home: Scaffold(
            body: ProfileScreen(
              language: service.currentLanguage,
              onLanguageChanged: (lang) {
                changedLang = lang;
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap Region tile (shows 'Assam') to open region sheet
      final regionTileFinder = find.widgetWithText(ListTile, 'Assam');
      expect(regionTileFinder, findsOneWidget);

      await tester.tap(regionTileFinder);
      await tester.pumpAndSettle();

      // Sheet displays NER regions
      expect(find.text('Choose your region'), findsOneWidget);
      expect(find.text('Nagaland'), findsOneWidget);

      await tester.tap(find.text('Nagaland'));
      await tester.pumpAndSettle();

      // Region should be Nagaland and language should automatically be Nagamese
      expect(service.currentRegion, AppRegion.nagaland);
      expect(service.currentLanguage, AppLanguage.nagamese);
      expect(changedLang, AppLanguage.nagamese);
    });
  });
}
