import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_food_calorie_tracker/domain/nutrition.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('Official Korean nutrition asset is nonempty and traceable', () async {
    // Flutter unit tests do not install the app's PlatformAssetBundle.
    // Parse the exact bundled JSON file independently of platform channels.
    final records = jsonDecode(await File('assets/nutrition/seed.json').readAsString()) as List;
    final catalog = NutritionCatalog(records.map((row) =>
      NutritionEntry.fromJson(Map<String, dynamic>.from(row as Map))).toList());
    expect(catalog.entries.length, greaterThan(10000));
    expect(catalog.entries.every((e) => e.unit == '100g' && e.sourceId.isNotEmpty), isTrue);
    final match = catalog.suggest('된장찌개').first;
    expect(match.entry.name, '된장찌개');
    expect(match.entry.source, isNotEmpty);
  });
  test('Korean spacing is normalized', () {
    expect(NutritionCatalog.normalize('김치 찌개'), '김치찌개');
  });
  test('Typographic differences are ranked', () {
    const catalog = NutritionCatalog([
      NutritionEntry('김치찌개', 50, 3, 2, 4, 'MFDS', 'A1', '100g'),
      NutritionEntry('볶음밥', 180, 5, 5, 28, 'MFDS', 'A2', '100g'),
    ]);
    expect(catalog.suggest('김치 찌개').first.entry.sourceId, 'A1');
    expect(catalog.suggest('김치찌게').first.entry.sourceId, 'A1');
  });
}
