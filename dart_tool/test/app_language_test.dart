import 'package:flutter_test/flutter_test.dart';
import 'package:smriti/localization/app_language.dart';
import 'package:smriti/localization/app_localizations.dart';

void main() {
  test('language labels cover the initial supported languages', () {
    expect(AppLanguage.values.map((language) => language.code), containsAll(<String>['en', 'hi', 'as']));
  });

  test('localized patient greeting is available in each language', () {
    for (final language in AppLanguage.values) {
      expect(AppLocalizations(language).greeting('Bhaben'), isNotEmpty);
    }
  });
}
