import '../localization/app_region.dart';

enum MealType {
  breakfast,
  lunch,
  snack,
  dinner,
}

class DietItem {
  const DietItem({
    required this.id,
    required this.region,
    required this.mealType,
    required this.title,
    required this.time,
    required this.description,
    required this.icon,
    this.completed = false,
    this.reminderId,
  });

  final String id;
  final AppRegion region;
  final MealType mealType;
  final String title;
  final String time;
  final String description;
  final String icon;
  final bool completed;
  final String? reminderId;

  DietItem copyWith({
    bool? completed,
    String? title,
    String? description,
    String? time,
  }) {
    return DietItem(
      id: id,
      region: region,
      mealType: mealType,
      title: title ?? this.title,
      time: time ?? this.time,
      description: description ?? this.description,
      icon: icon,
      completed: completed ?? this.completed,
      reminderId: reminderId,
    );
  }
}
