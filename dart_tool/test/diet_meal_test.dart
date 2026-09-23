import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smriti/core/theme/app_theme.dart';
import 'package:smriti/features/caregiver/caregiver_dashboard.dart';
import 'package:smriti/features/home/home_screen.dart';
import 'package:smriti/localization/app_language.dart';
import 'package:smriti/localization/app_localizations.dart';
import 'package:smriti/localization/app_region.dart';
import 'package:smriti/models/connectivity_state.dart';
import 'package:smriti/models/diet_item.dart';
import 'package:smriti/services/local_data_service.dart';
import 'package:smriti/services/voice_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    LocalDataService.instance.resetToDefaults();
  });

  group('Phase 3 Regional Diet & Meal Support', () {
    test('TEST A: Region = Assam returns Assamese meals (Masor Tenga, Khaar, Pitha)', () {
      final service = LocalDataService.instance;
      service.setRegion(AppRegion.assam);

      final meals = service.regionalMeals;
      expect(meals.length, 4);

      final titles = meals.map((m) => m.title).join(' ');
      expect(titles.contains('Masor Tenga') || titles.contains('Tenga'), isTrue);
      expect(titles.contains('Khaar') || titles.contains('Khar'), isTrue);
      expect(titles.contains('Pitha'), isTrue);
    });

    test('TEST B: Region = Sikkim returns Sikkim regional meals (Momos, Sel Roti, Gundruk, Thukpa)', () {
      final service = LocalDataService.instance;
      service.setRegion(AppRegion.sikkim);

      final meals = service.regionalMeals;
      expect(meals.length, 4);

      final titles = meals.map((m) => m.title).join(' ');
      expect(titles.contains('Momos') || titles.contains('Momo'), isTrue);
      expect(titles.contains('Sel Roti'), isTrue);
      expect(titles.contains('Gundruk') || titles.contains('Thukpa'), isTrue);
    });

    test('TEST C: Changing region updates meal suggestions for all 8 NER states', () {
      final service = LocalDataService.instance;

      for (final region in AppRegion.values) {
        service.setRegion(region);
        final meals = service.regionalMeals;
        expect(meals.length, 4, reason: 'Region ${region.name} should have 4 daily meals');
        expect(meals.every((m) => m.region == region), isTrue);
      }

      // Check specific states from prompt
      service.setRegion(AppRegion.meghalaya);
      expect(service.regionalMeals.any((m) => m.title.contains('Jadoh')), isTrue);

      service.setRegion(AppRegion.manipur);
      expect(service.regionalMeals.any((m) => m.title.contains('Kangshoi') || m.title.contains('Chak-hao')), isTrue);

      service.setRegion(AppRegion.nagaland);
      expect(service.regionalMeals.any((m) => m.title.contains('Galho') || m.title.contains('Axone')), isTrue);

      service.setRegion(AppRegion.mizoram);
      expect(service.regionalMeals.any((m) => m.title.contains('Bai') || m.title.contains('Sawhchiar')), isTrue);

      service.setRegion(AppRegion.arunachalPradesh);
      expect(service.regionalMeals.any((m) => m.title.contains('Thukpa') || m.title.contains('Momos')), isTrue);

      service.setRegion(AppRegion.tripura);
      expect(service.regionalMeals.any((m) => m.title.contains('Mui Borok') || m.title.contains('Chakhwi')), isTrue);
    });

    test('TEST D: Mark meal as Done updates status in regionalMeals and reminders', () {
      final service = LocalDataService.instance;
      service.setRegion(AppRegion.assam);

      final lunch = service.regionalMeals.firstWhere((m) => m.mealType == MealType.lunch);
      final initialStatus = lunch.completed;

      service.completeMeal(lunch.id);

      final updatedLunch = service.regionalMeals.firstWhere((m) => m.id == lunch.id);
      expect(updatedLunch.completed, !initialStatus);

      // Verify underlying reminder was also updated
      final lunchReminder = service.reminders.firstWhere((r) => r.id == lunch.reminderId);
      expect(lunchReminder.completed, !initialStatus);
    });

    test('TEST E: Next meal determination tracks incomplete meals', () {
      final service = LocalDataService.instance;
      service.setRegion(AppRegion.assam);

      // Reset all meals to pending
      for (final meal in service.regionalMeals) {
        if (meal.completed && meal.reminderId != null) {
          service.toggleReminder(meal.reminderId!);
        }
      }

      // Initially, breakfast is first pending
      expect(service.nextMeal.mealType, MealType.breakfast);

      // Complete breakfast
      final bfast = service.regionalMeals.firstWhere((m) => m.mealType == MealType.breakfast);
      service.completeMeal(bfast.id);

      // Next meal should now be Lunch
      expect(service.nextMeal.mealType, MealType.lunch);

      // Complete lunch
      final lunch = service.regionalMeals.firstWhere((m) => m.mealType == MealType.lunch);
      service.completeMeal(lunch.id);

      // Next meal should now be Snack
      expect(service.nextMeal.mealType, MealType.snack);
    });

    test('TEST F & I & J: Existing reminders (medicine, hydration, walk) persist and work alongside meals', () {
      final service = LocalDataService.instance;

      final reminders = service.reminders;
      expect(reminders.any((r) => r.category == 'Medicine'), isTrue);
      expect(reminders.any((r) => r.category == 'Hydration'), isTrue);
      expect(reminders.any((r) => r.category == 'Gentle Walk'), isTrue);
      expect(reminders.any((r) => r.category == 'Meal'), isTrue);

      // Toggle medicine reminder
      final med = reminders.firstWhere((r) => r.category == 'Medicine');
      final prevCompleted = med.completed;
      service.toggleReminder(med.id);
      expect(med.completed, !prevCompleted);
    });

    test('TEST H: Voice AI safety rejects dementia curing/prevention food claims', () async {
      final service = LocalDataService.instance;
      final voice = MindSetuVoiceService.instance;

      final res1 = await voice.processCommand(
        'Is this food good for dementia?',
        data: service,
        language: AppLanguage.english,
      );

      expect(res1.responseText.contains('planned food routine'), isTrue);
      expect(res1.responseText.contains('check with your caregiver or doctor'), isTrue);

      final res2 = await voice.processCommand(
        'Can this diet cure dementia?',
        data: service,
        language: AppLanguage.english,
      );
      expect(res2.responseText.contains('planned food routine'), isTrue);
    });

    test('TEST G: Voice returns actual application meal data without hallucinating', () async {
      final service = LocalDataService.instance;
      service.setRegion(AppRegion.assam);
      service.setLanguage(AppLanguage.english);
      final voice = MindSetuVoiceService.instance;

      // 1. Ask what's for lunch
      final lunchRes = await voice.processCommand(
        "What's for lunch?",
        data: service,
        language: AppLanguage.english,
      );
      expect(lunchRes.responseText.contains('Masor Tenga') || lunchRes.responseText.contains('Tenga'), isTrue);
      expect(lunchRes.responseText.contains('1:15 PM'), isTrue);

      // 2. Ask next meal
      final nextRes = await voice.processCommand(
        'What is my next meal?',
        data: service,
        language: AppLanguage.english,
      );
      expect(nextRes.responseText.contains('Lunch') || nextRes.responseText.contains('Breakfast') || nextRes.responseText.contains('Masor Tenga'), isTrue);

      // 3. Ask today's meals
      final allRes = await voice.processCommand(
        "Tell me today's meals.",
        data: service,
        language: AppLanguage.english,
      );
      expect(allRes.responseText.contains('Breakfast'), isTrue);
      expect(allRes.responseText.contains('Lunch'), isTrue);
      expect(allRes.responseText.contains('Dinner'), isTrue);
    });

    testWidgets('UI Widget Test: HomeScreen displays Next Meal and Today Meals', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final service = LocalDataService.instance;
      service.setRegion(AppRegion.assam);
      service.setLanguage(AppLanguage.english);
      const l = AppLocalizations(AppLanguage.english);

      await tester.pumpWidget(
        MaterialApp(
          theme: buildSmritiTheme(),
          home: Scaffold(
            body: HomeScreen(
              localizations: l,
              connection: SmritiConnectionState.connected,
              onOpenActivities: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Should display Next Meal banner
      expect(find.textContaining('NEXT MEAL'), findsWidgets);
      // Should display Today's Meals section
      expect(find.textContaining(l.todaysMeals.toUpperCase()), findsOneWidget);
      // Should display Assamese items
      expect(find.textContaining('Masor Tenga'), findsWidgets);
      // Should display non-medical disclaimer
      expect(find.textContaining('Culturally familiar regional food routine'), findsOneWidget);
    });

    testWidgets('UI Widget Test: Caregiver Dashboard displays Meal Status', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final service = LocalDataService.instance;
      service.setRegion(AppRegion.assam);

      await tester.pumpWidget(
        MaterialApp(
          theme: buildSmritiTheme(),
          home: const Scaffold(
            body: CaregiverDashboard(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text("Today's Meal Status"), findsOneWidget);
      expect(find.textContaining('Breakfast'), findsWidgets);
      expect(find.textContaining('Lunch'), findsWidgets);
      expect(find.textContaining('Dinner'), findsWidgets);
    });
  });
}
