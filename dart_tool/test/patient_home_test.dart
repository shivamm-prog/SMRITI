import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smriti/core/theme/app_theme.dart';
import 'package:smriti/features/home/app_shell.dart';
import 'package:smriti/features/home/home_screen.dart';
import 'package:smriti/localization/app_language.dart';
import 'package:smriti/localization/app_localizations.dart';
import 'package:smriti/models/connectivity_state.dart';
import 'package:smriti/services/local_data_service.dart';

void main() {
  testWidgets('Test HomeScreen direct render', (WidgetTester tester) async {
    const localizations = AppLocalizations(AppLanguage.english);
    LocalDataService.instance.setAuthenticatedUser(
      role: UserRole.patient,
      fullName: 'Bhaben Borah',
      email: 'patient@mindsetu.in',
      patientId: 'MS-ASSAM-001',
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: buildSmritiTheme(),
        home: Scaffold(
          body: HomeScreen(
            localizations: localizations,
            connection: SmritiConnectionState.connected,
            onOpenActivities: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Bhaben Borah'), findsWidgets);
    expect(find.textContaining('MS-ASSAM-001'), findsWidgets);
  });

  testWidgets('Test AppShell render', (WidgetTester tester) async {
    LocalDataService.instance.setAuthenticatedUser(
      role: UserRole.patient,
      fullName: 'Bhaben Borah',
      email: 'patient@mindsetu.in',
      patientId: 'MS-ASSAM-001',
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: buildSmritiTheme(),
        home: const AppShell(language: AppLanguage.english),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Bhaben Borah'), findsWidgets);
  });
}
