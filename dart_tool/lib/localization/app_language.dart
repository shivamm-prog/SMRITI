enum AppLanguage {
  english,
  hindi,
  assamese,
  manipuri,
  khasi,
  mizo,
  nagamese,
  nepali,
  kokborok,
}

extension AppLanguageX on AppLanguage {
  /// Native / display label for the language
  String get label => switch (this) {
        AppLanguage.english => 'English',
        AppLanguage.hindi => 'हिन्दी',
        AppLanguage.assamese => 'অসমীয়া',
        AppLanguage.manipuri => 'মৈতৈলোন্ (Manipuri)',
        AppLanguage.khasi => 'Khasi',
        AppLanguage.mizo => 'Mizo',
        AppLanguage.nagamese => 'Nagamese',
        AppLanguage.nepali => 'नेपाली (Nepali)',
        AppLanguage.kokborok => 'Kokborok',
      };

  /// English readable name
  String get englishLabel => switch (this) {
        AppLanguage.english => 'English',
        AppLanguage.hindi => 'Hindi',
        AppLanguage.assamese => 'Assamese',
        AppLanguage.manipuri => 'Manipuri',
        AppLanguage.khasi => 'Khasi',
        AppLanguage.mizo => 'Mizo',
        AppLanguage.nagamese => 'Nagamese',
        AppLanguage.nepali => 'Nepali',
        AppLanguage.kokborok => 'Kokborok',
      };

  /// ISO language code
  String get code => switch (this) {
        AppLanguage.english => 'en',
        AppLanguage.hindi => 'hi',
        AppLanguage.assamese => 'as',
        AppLanguage.manipuri => 'mni',
        AppLanguage.khasi => 'kha',
        AppLanguage.mizo => 'lus',
        AppLanguage.nagamese => 'nag',
        AppLanguage.nepali => 'ne',
        AppLanguage.kokborok => 'brx',
      };

  /// Safe parser from code or label
  static AppLanguage fromCode(String? value) {
    if (value == null || value.trim().isEmpty) return AppLanguage.english;
    final clean = value.toLowerCase().trim();
    for (final lang in AppLanguage.values) {
      if (lang.code == clean ||
          lang.name.toLowerCase() == clean ||
          lang.englishLabel.toLowerCase() == clean ||
          clean.contains(lang.code) ||
          clean.contains(lang.name.toLowerCase())) {
        return lang;
      }
    }
    return AppLanguage.english;
  }
}
