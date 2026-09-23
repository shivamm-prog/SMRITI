import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/auth_screen.dart';
import 'features/auth/welcome_screen.dart';
import 'features/caregiver/caregiver_dashboard.dart';
import 'features/doctor/doctor_dashboard.dart';
import 'features/home/app_shell.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'localization/app_language.dart';
import 'services/local_data_service.dart';

/// Fallback delegate so Flutter Material doesn't crash on regional language codes
/// like 'nag', 'kha', 'lus', 'brx', 'mni'
class FallbackMaterialLocalizationsDelegate extends LocalizationsDelegate<MaterialLocalizations> {
  const FallbackMaterialLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<MaterialLocalizations> load(Locale locale) async {
    return const DefaultMaterialLocalizations();
  }

  @override
  bool shouldReload(FallbackMaterialLocalizationsDelegate old) => false;
}

class FallbackCupertinoLocalizationsDelegate extends LocalizationsDelegate<CupertinoLocalizations> {
  const FallbackCupertinoLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<CupertinoLocalizations> load(Locale locale) async {
    return const DefaultCupertinoLocalizations();
  }

  @override
  bool shouldReload(FallbackCupertinoLocalizationsDelegate old) => false;
}

class FallbackWidgetsLocalizationsDelegate extends LocalizationsDelegate<WidgetsLocalizations> {
  const FallbackWidgetsLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<WidgetsLocalizations> load(Locale locale) async {
    return const DefaultWidgetsLocalizations();
  }

  @override
  bool shouldReload(FallbackWidgetsLocalizationsDelegate old) => false;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalDataService.instance.initPrefs();

  // Global error boundary to prevent any blank white screen
  ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.sentiment_satisfied_alt_rounded, size: 56, color: AppColors.blue),
                const SizedBox(height: 16),
                const Text(
                  'SMRITI — Cognitive Care',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.ink),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Returning to your personalized view...',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, color: AppColors.muted),
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.blue,
                  ),
                  onPressed: () {
                    LocalDataService.instance.notify();
                  },
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Reload View'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  };
  runApp(const SmritiApp());
}

class SmritiApp extends StatelessWidget {
  const SmritiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: LocalDataService.instance,
      builder: (context, _) {
        final data = LocalDataService.instance;
        final currentLang = data.currentLanguage;

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'SMRITI — Remember. Engage. Connect.',
          theme: buildSmritiTheme(isLargeText: data.isLargeText),
          locale: Locale(currentLang.code),
          supportedLocales: const [
            Locale('en'),
            Locale('hi'),
            Locale('as'),
            Locale('mni'),
            Locale('kha'),
            Locale('lus'),
            Locale('nag'),
            Locale('ne'),
            Locale('brx'),
          ],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            FallbackMaterialLocalizationsDelegate(),
            FallbackCupertinoLocalizationsDelegate(),
            FallbackWidgetsLocalizationsDelegate(),
          ],
          localeResolutionCallback: (locale, supportedLocales) {
            if (locale != null) {
              for (final supported in supportedLocales) {
                if (supported.languageCode == locale.languageCode) {
                  return supported;
                }
              }
            }
            return const Locale('en');
          },
          home: const AppRootRouter(),
        );
      },
    );
  }
}

class AppRootRouter extends StatelessWidget {
  const AppRootRouter({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: LocalDataService.instance,
      builder: (context, _) {
        final data = LocalDataService.instance;
        final currentRole = data.currentRole;
        final isAuth = data.isAuthenticated;
        final currentLanguage = data.currentLanguage;

        // 1. If authenticated, route directly to the appropriate role dashboard
        if (isAuth) {
          switch (currentRole) {
            case UserRole.caregiver:
              return const CaregiverDashboard();
            case UserRole.doctor:
              return const DoctorDashboard();
            case UserRole.patient:
              return AppShell(language: currentLanguage);
          }
        }

        // 2. Unauthenticated: If onboarding is not completed, show teammate Welcome landing screen
        if (!data.hasCompletedOnboarding) {
          return WelcomeScreen(
            onGetStarted: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (ctx) => OnboardingScreen(
                    onComplete: (region) {
                      data.completeOnboarding(region: region);
                      if (Navigator.of(ctx).canPop()) {
                        Navigator.of(ctx).pop();
                      }
                    },
                  ),
                ),
              );
            },
            onLogIn: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const AuthScreen(initialIsSignUp: false),
                ),
              );
            },
          );
        }

        // 3. Unauthenticated and completed onboarding (e.g. after logout or tour): show AuthScreen
        return const AuthScreen();
      },
    );
  }
}

