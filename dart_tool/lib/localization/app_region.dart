import 'app_language.dart';

/// The 8 North Eastern Region (NER) states of India
enum AppRegion {
  assam,
  arunachalPradesh,
  manipur,
  meghalaya,
  mizoram,
  nagaland,
  sikkim,
  tripura,
}

extension AppRegionX on AppRegion {
  /// Display name of the state
  String get name => switch (this) {
        AppRegion.assam => 'Assam',
        AppRegion.arunachalPradesh => 'Arunachal Pradesh',
        AppRegion.manipur => 'Manipur',
        AppRegion.meghalaya => 'Meghalaya',
        AppRegion.mizoram => 'Mizoram',
        AppRegion.nagaland => 'Nagaland',
        AppRegion.sikkim => 'Sikkim',
        AppRegion.tripura => 'Tripura',
      };

  /// Storage and API identifier code
  String get code => switch (this) {
        AppRegion.assam => 'assam',
        AppRegion.arunachalPradesh => 'arunachal_pradesh',
        AppRegion.manipur => 'manipur',
        AppRegion.meghalaya => 'meghalaya',
        AppRegion.mizoram => 'mizoram',
        AppRegion.nagaland => 'nagaland',
        AppRegion.sikkim => 'sikkim',
        AppRegion.tripura => 'tripura',
      };

  /// Prototype default language mapping for the NER state.
  /// Note: These are prototype defaults and not exclusive languages.
  AppLanguage get defaultLanguage => switch (this) {
        AppRegion.assam => AppLanguage.assamese,
        AppRegion.arunachalPradesh => AppLanguage.hindi,
        AppRegion.manipur => AppLanguage.manipuri,
        AppRegion.meghalaya => AppLanguage.khasi,
        AppRegion.mizoram => AppLanguage.mizo,
        AppRegion.nagaland => AppLanguage.nagamese,
        AppRegion.sikkim => AppLanguage.nepali,
        AppRegion.tripura => AppLanguage.kokborok,
      };

  /// Subtitle / Capital / Notable info for elderly-friendly selection cards
  String get detail => switch (this) {
        AppRegion.assam => 'Guwahati / Dispur · অসম',
        AppRegion.arunachalPradesh => 'Itanagar · Land of Dawn-Lit Mountains',
        AppRegion.manipur => 'Imphal · Jewel of India',
        AppRegion.meghalaya => 'Shillong · Abode of Clouds',
        AppRegion.mizoram => 'Aizawl · Land of the Hill People',
        AppRegion.nagaland => 'Kohima · Land of Festivals',
        AppRegion.sikkim => 'Gangtok · Himalayan Valley',
        AppRegion.tripura => 'Agartala · Cultural Heritage',
      };

  /// Helper to parse AppRegion from stored code or string name safely
  static AppRegion fromString(String? value) {
    if (value == null || value.trim().isEmpty) return AppRegion.assam;
    final clean = value.toLowerCase().trim();
    for (final region in AppRegion.values) {
      if (region.code == clean ||
          region.name.toLowerCase() == clean ||
          clean.contains(region.code) ||
          clean.contains(region.name.toLowerCase())) {
        return region;
      }
    }
    return AppRegion.assam;
  }
}
