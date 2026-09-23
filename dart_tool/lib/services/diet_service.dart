import '../localization/app_region.dart';
import '../models/diet_item.dart';
import 'local_data_service.dart';

class DietService {
  DietService._();

  static const Map<AppRegion, Map<MealType, ({String title, String time, String desc, String icon, String reminderId})>>
      _regionalPlans = {
    AppRegion.assam: {
      MealType.breakfast: (
        title: 'Til Pitha & Warm Assam Tea',
        time: '08:30 AM',
        desc: 'Traditional rice pitha with soothing tea for a gentle morning start',
        icon: '🫖',
        reminderId: 'rem_meal_breakfast',
      ),
      MealType.lunch: (
        title: 'Masor Tenga & Steamed Rice',
        time: '01:15 PM',
        desc: 'Tangy mild river fish broth with seasonal tomatoes and fresh herbs',
        icon: '🍲',
        reminderId: 'rem_3',
      ),
      MealType.snack: (
        title: 'Pitha & Roasted Chira',
        time: '04:30 PM',
        desc: 'Light festive rice snacks and warm water or herbal tea',
        icon: '🌾',
        reminderId: 'rem_meal_snack',
      ),
      MealType.dinner: (
        title: 'Rice with Gentle Khaar & Dal',
        time: '08:00 PM',
        desc: 'Comforting traditional alkaline broth with tender vegetables and rice',
        icon: '🥣',
        reminderId: 'rem_meal_dinner',
      ),
    },
    AppRegion.meghalaya: {
      MealType.breakfast: (
        title: 'Pukhlein & Red Tea',
        time: '08:30 AM',
        desc: 'Sweet golden jaggery rice bread paired with warm Khasi red tea',
        icon: '🫖',
        reminderId: 'rem_meal_breakfast',
      ),
      MealType.lunch: (
        title: 'Jadoh with Fresh Herbs',
        time: '01:15 PM',
        desc: 'Fragrant mild turmeric rice cooked gently with mountain herbs',
        icon: '🍲',
        reminderId: 'rem_3',
      ),
      MealType.snack: (
        title: 'Pukhlein Rice Cake',
        time: '04:30 PM',
        desc: 'Tender evening rice treat enjoyed with quiet rest',
        icon: '🌾',
        reminderId: 'rem_meal_snack',
      ),
      MealType.dinner: (
        title: 'Dohneiiong Stew & Warm Rice',
        time: '08:00 PM',
        desc: 'Comforting broth infused with aromatic black sesame seeds',
        icon: '🥣',
        reminderId: 'rem_meal_dinner',
      ),
    },
    AppRegion.manipur: {
      MealType.breakfast: (
        title: 'Tan Flatbread & Fragrant Tea',
        time: '08:30 AM',
        desc: 'Soft pan-baked flour flatbread served with warm spiced tea',
        icon: '🫖',
        reminderId: 'rem_meal_breakfast',
      ),
      MealType.lunch: (
        title: 'Kangshoi & Steamed Rice',
        time: '01:15 PM',
        desc: 'Delicate clear vegetable and herb broth, soothing and light',
        icon: '🍲',
        reminderId: 'rem_3',
      ),
      MealType.snack: (
        title: 'Chak-hao Black Rice Kheer',
        time: '04:30 PM',
        desc: 'Naturally purple sweet scented rice pudding with subtle cardamom',
        icon: '🌾',
        reminderId: 'rem_meal_snack',
      ),
      MealType.dinner: (
        title: 'Eromba & Boiled Mountain Greens',
        time: '08:00 PM',
        desc: 'Mashed local vegetables and steamed leafy greens with soft rice',
        icon: '🥣',
        reminderId: 'rem_meal_dinner',
      ),
    },
    AppRegion.nagaland: {
      MealType.breakfast: (
        title: 'Warm Galho Rice Broth',
        time: '08:30 AM',
        desc: 'Nutritious soupy rice with fresh garden greens and ginger',
        icon: '🫖',
        reminderId: 'rem_meal_breakfast',
      ),
      MealType.lunch: (
        title: 'Smoked Bamboo Greens & Rice',
        time: '01:15 PM',
        desc: 'Tender garden vegetables cooked with aromatic bamboo essence',
        icon: '🍲',
        reminderId: 'rem_3',
      ),
      MealType.snack: (
        title: 'Steamed Sweet Corn & Tea',
        time: '04:30 PM',
        desc: 'Freshly harvested tender corn with warm comforting tea',
        icon: '🌾',
        reminderId: 'rem_meal_snack',
      ),
      MealType.dinner: (
        title: 'Axone Gentle Stew & Broth',
        time: '08:00 PM',
        desc: 'Warm fermented bean and garden vegetable soup with soft rice',
        icon: '🥣',
        reminderId: 'rem_meal_dinner',
      ),
    },
    AppRegion.mizoram: {
      MealType.breakfast: (
        title: 'Chhangban & Herbal Tea',
        time: '08:30 AM',
        desc: 'Steamed sticky rice cake in banana leaf with fresh morning tea',
        icon: '🫖',
        reminderId: 'rem_meal_breakfast',
      ),
      MealType.lunch: (
        title: 'Bai Vegetable Stew & Rice',
        time: '01:15 PM',
        desc: 'Light steamed seasonal vegetables and mustard greens in vegetable broth',
        icon: '🍲',
        reminderId: 'rem_3',
      ),
      MealType.snack: (
        title: 'Chhangban Sweets',
        time: '04:30 PM',
        desc: 'Gentle traditional rice snack to enjoy in the afternoon',
        icon: '🌾',
        reminderId: 'rem_meal_snack',
      ),
      MealType.dinner: (
        title: 'Sawhchiar Rice Porridge',
        time: '08:00 PM',
        desc: 'Comforting, easily digestible rice porridge seasoned with herbs',
        icon: '🥣',
        reminderId: 'rem_meal_dinner',
      ),
    },
    AppRegion.arunachalPradesh: {
      MealType.breakfast: (
        title: 'Khura Bread & Warm Tea',
        time: '08:30 AM',
        desc: 'Hearty buckwheat pancake served with soothing morning tea',
        icon: '🫖',
        reminderId: 'rem_meal_breakfast',
      ),
      MealType.lunch: (
        title: 'Thukpa Warm Noodle Soup',
        time: '01:15 PM',
        desc: 'Comforting Himalayan soup with soft noodles, vegetables, and ginger',
        icon: '🍲',
        reminderId: 'rem_3',
      ),
      MealType.snack: (
        title: 'Pika Pila & Warm Broth',
        time: '04:30 PM',
        desc: 'Tangy mild bamboo accompaniment with gentle soothing broth',
        icon: '🌾',
        reminderId: 'rem_meal_snack',
      ),
      MealType.dinner: (
        title: 'Steamed Momos & Clear Broth',
        time: '08:00 PM',
        desc: 'Soft vegetable dumplings served with light, calming soup',
        icon: '🥣',
        reminderId: 'rem_meal_dinner',
      ),
    },
    AppRegion.tripura: {
      MealType.breakfast: (
        title: 'Muya Awandru Warm Broth',
        time: '08:30 AM',
        desc: 'Gentle rice flour and tender bamboo shoot soup with tea',
        icon: '🫖',
        reminderId: 'rem_meal_breakfast',
      ),
      MealType.lunch: (
        title: 'Mui Borok & Steamed Rice',
        time: '01:15 PM',
        desc: 'Traditional comforting dish cooked with fresh vegetables and mild spices',
        icon: '🍲',
        reminderId: 'rem_3',
      ),
      MealType.snack: (
        title: 'Muya Awandru Light Soup',
        time: '04:30 PM',
        desc: 'Soothing afternoon warmth with fresh garden ingredients',
        icon: '🌾',
        reminderId: 'rem_meal_snack',
      ),
      MealType.dinner: (
        title: 'Chakhwi & Seasonal Greens',
        time: '08:00 PM',
        desc: 'Classic alkaline broth cooked with bamboo shoots and green leaves',
        icon: '🥣',
        reminderId: 'rem_meal_dinner',
      ),
    },
    AppRegion.sikkim: {
      MealType.breakfast: (
        title: 'Sel Roti & Cardamom Tea',
        time: '08:30 AM',
        desc: 'Crisp, sweet homemade ring bread served with warm cardamom tea',
        icon: '🫖',
        reminderId: 'rem_meal_breakfast',
      ),
      MealType.lunch: (
        title: 'Gundruk Jhol & Steamed Rice',
        time: '01:15 PM',
        desc: 'Traditional fermented leafy green soup, gentle and comforting',
        icon: '🍲',
        reminderId: 'rem_3',
      ),
      MealType.snack: (
        title: 'Thukpa Broth',
        time: '04:30 PM',
        desc: 'Light spiced noodles in vegetable broth for a refreshing evening',
        icon: '🌾',
        reminderId: 'rem_meal_snack',
      ),
      MealType.dinner: (
        title: 'Steamed Momos & Clear Soup',
        time: '08:00 PM',
        desc: 'Tender steamed vegetable dumplings with a comforting warm broth',
        icon: '🥣',
        reminderId: 'rem_meal_dinner',
      ),
    },
  };

  /// Returns the 4 structured daily meals for the active region,
  /// linked with the live completion status from the patient reminders.
  static List<DietItem> getMealsForRegion(AppRegion region, List<DailyReminder> reminders) {
    final plan = _regionalPlans[region] ?? _regionalPlans[AppRegion.assam]!;

    return MealType.values.map((type) {
      final info = plan[type]!;
      // Find matching reminder by specific reminderId or fallback category 'Meal'
      DailyReminder? matchingReminder;
      for (final r in reminders) {
        if (r.id == info.reminderId) {
          matchingReminder = r;
          break;
        }
      }
      if (matchingReminder == null) {
        for (final r in reminders) {
          if (r.category.toLowerCase() == 'meal' && r.title.toLowerCase().contains(info.title.toLowerCase().split(' ').first)) {
            matchingReminder = r;
            break;
          }
        }
      }

      final isCompleted = matchingReminder?.completed ?? false;

      return DietItem(
        id: 'diet_${region.code}_${type.name}',
        region: region,
        mealType: type,
        title: info.title,
        time: info.time,
        description: info.desc,
        icon: info.icon,
        completed: isCompleted,
        reminderId: matchingReminder?.id ?? info.reminderId,
      );
    }).toList();
  }

  /// Returns the upcoming meal based on the current time or pending completion status.
  static DietItem getNextMeal(AppRegion region, List<DailyReminder> reminders) {
    final meals = getMealsForRegion(region, reminders);

    // 1. First preference: First pending meal of the day
    for (final meal in meals) {
      if (!meal.completed) {
        return meal;
      }
    }

    // 2. If all completed, return lunch or the first meal
    final now = DateTime.now();
    if (now.hour < 10) return meals[0];
    if (now.hour < 14) return meals[1];
    if (now.hour < 17) return meals[2];
    return meals[3];
  }

  /// Generates the 4 DailyReminder instances for meals for a given region.
  static List<DailyReminder> createMealRemindersForRegion(AppRegion region) {
    final plan = _regionalPlans[region] ?? _regionalPlans[AppRegion.assam]!;
    return MealType.values.map((type) {
      final info = plan[type]!;
      return DailyReminder(
        id: info.reminderId,
        title: info.title,
        category: 'Meal',
        timeStr: info.time,
        instructions: info.desc,
        completed: false,
        verifiedByCaregiver: false,
      );
    }).toList();
  }
}
