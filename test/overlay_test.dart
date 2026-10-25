import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_food_calorie_tracker/ui/food_overlay.dart';

void main() {
  test('Landscape image letterboxes vertically', () {
    final rect = FoodOverlay.imageRect(const Size(300, 300), const Size(400, 200));
    expect(rect, const Rect.fromLTWH(0, 75, 300, 150));
    final box = FoodOverlay.boxRect(rect, {'x': .25, 'y': .2, 'width': .5, 'height': .5});
    expect(box, const Rect.fromLTWH(75, 105, 150, 75));
  });
  test('Portrait image letterboxes horizontally', () {
    expect(FoodOverlay.imageRect(const Size(300, 300), const Size(200, 400)),
      const Rect.fromLTWH(75, 0, 150, 300));
  });
}
