import 'dart:typed_data';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../domain/food.dart';

class FoodOverlay extends StatelessWidget {
  final Uint8List image;
  final Size originalSize;
  final List<Food> foods;
  final int selected;
  final ValueChanged<int> onSelect;
  const FoodOverlay({super.key, required this.image, required this.originalSize,
    required this.foods, required this.selected, required this.onSelect});

  static Rect imageRect(Size outer, Size raw) {
    final scale = math.min(outer.width / raw.width, outer.height / raw.height);
    return Rect.fromLTWH((outer.width - raw.width * scale) / 2,
      (outer.height - raw.height * scale) / 2, raw.width * scale, raw.height * scale);
  }
  static Rect boxRect(Rect display, Map<String, double> b) => Rect.fromLTWH(
    display.left + b['x']! * display.width, display.top + b['y']! * display.height,
    b['width']! * display.width, b['height']! * display.height);

  static int hitTest(Size canvas, Size raw, List<Food> foods, Offset position) {
    final rect = imageRect(canvas, raw);
    final indices = List.generate(foods.length, (i) => i)
      ..sort((a, b) {
        double area(int i) => foods[i].bbox == null ? double.infinity :
          foods[i].bbox!['width']! * foods[i].bbox!['height']!;
        return area(a).compareTo(area(b)); // smaller overlapping side dish wins
      });
    for (final i in indices) {
      final b = foods[i].bbox;
      if (b != null && boxRect(rect, b).contains(position)) return i;
    }
    return -1;
  }
  @override Widget build(BuildContext context) => LayoutBuilder(builder: (context, constraints) {
    final screenWidth = constraints.maxWidth;
    final height = screenWidth * originalSize.height / originalSize.width;
    return SizedBox(height: height, child: InteractiveViewer(
      minScale: 1, maxScale: 5, boundaryMargin: const EdgeInsets.all(16),
      child: SizedBox(width: screenWidth, height: height,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapUp: (d) {
            final index = hitTest(Size(screenWidth, height), originalSize, foods, d.localPosition);
            if (index >= 0) onSelect(index);
          },
          child: CustomPaint(
            foregroundPainter: _BoxPainter(originalSize, foods, selected),
            child: Image.memory(image, fit: BoxFit.contain),
          ),
        ),
      ),
    ));
  });
}

class _BoxPainter extends CustomPainter {
  final Size raw;
  final List<Food> foods;
  final int selected;
  const _BoxPainter(this.raw, this.foods, this.selected);
  @override void paint(Canvas canvas, Size size) {
    final display = FoodOverlay.imageRect(size, raw);
    for (var i = 0; i < foods.length; i++) {
      final b = foods[i].bbox;
      if (b == null) continue;
      final rect = FoodOverlay.boxRect(display, b);
      final active = i == selected;
      final paint = Paint()
        ..color = active ? Colors.amber : Colors.lightGreenAccent
        ..style = PaintingStyle.stroke ..strokeWidth = active ? 3 : 2;
      canvas.drawRect(rect, paint);
      final label = TextPainter(
        text: TextSpan(text: '${i + 1} ${foods[i].name}',
          style: const TextStyle(color: Colors.white, fontSize: 12,
            backgroundColor: Colors.black87)),
        textDirection: TextDirection.ltr, maxLines: 1,
      )..layout(maxWidth: rect.width);
      label.paint(canvas, rect.topLeft);
    }
  }
  @override bool shouldRepaint(_BoxPainter old) =>
    old.selected != selected || old.foods != foods || old.raw != raw;
}
