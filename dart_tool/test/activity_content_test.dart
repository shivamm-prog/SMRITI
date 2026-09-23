import 'package:flutter_test/flutter_test.dart';
import 'package:smriti/models/activity_content.dart';

void main() {
  test('local content has a unique id and covers the core activity categories', () {
    final ids = localActivityContent.map((item) => item.id).toSet();
    final categories = localActivityContent.map((item) => item.category).toSet();
    expect(ids.length, localActivityContent.length);
    expect(categories, containsAll(ActivityCategory.values));
  });
}
