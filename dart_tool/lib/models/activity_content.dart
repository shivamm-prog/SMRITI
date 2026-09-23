enum ActivityCategory { memory, attention, recall, sequence }

class ActivityContent {
  const ActivityContent({required this.id, required this.category, required this.title, required this.description, required this.icon});
  final String id;
  final ActivityCategory category;
  final String title;
  final String description;
  final String icon;
}

/// Local, configurable content catalogue. NER-specific familiar items can be
/// added here without changing activity mechanics.
const localActivityContent = <ActivityContent>[
  ActivityContent(id: 'cup', category: ActivityCategory.memory, title: 'Cup', description: 'A familiar household object', icon: '☕'),
  ActivityContent(id: 'book', category: ActivityCategory.recall, title: 'Book', description: 'A familiar everyday object', icon: '📖'),
  ActivityContent(id: 'key', category: ActivityCategory.attention, title: 'Key', description: 'A familiar household object', icon: '🔑'),
  ActivityContent(id: 'fruit', category: ActivityCategory.sequence, title: 'Fruit', description: 'A familiar food object', icon: '🍎'),
];
