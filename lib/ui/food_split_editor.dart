import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../domain/food.dart';

class FoodSplitResult {
  final String firstName, secondName;
  final double firstWeight, secondWeight;
  final Map<String, double> leftBox, rightBox;
  const FoodSplitResult(this.firstName, this.secondName, this.firstWeight,
    this.secondWeight, this.leftBox, this.rightBox);
}

/// A real geometric split: the user drags the dividing line within a
/// confirmed bounding region and names/weighs each resulting region.
class FoodSplitEditor extends StatefulWidget {
  final Uint8List image;
  final Size rawSize;
  final Food food;
  const FoodSplitEditor({super.key, required this.image, required this.rawSize, required this.food});
  @override State<FoodSplitEditor> createState() => _FoodSplitEditorState();
}
class _FoodSplitEditorState extends State<FoodSplitEditor> {
  double fraction = .5;
  final firstName = TextEditingController();
  final secondName = TextEditingController();
  final firstWeight = TextEditingController();
  final secondWeight = TextEditingController();
  @override void initState() {
    super.initState();
    firstName.text = widget.food.name;
    secondName.text = '';
  }
  @override void dispose() {
    firstName.dispose(); secondName.dispose(); firstWeight.dispose(); secondWeight.dispose();
    super.dispose();
  }
  @override Widget build(BuildContext context) {
    final box = widget.food.bbox;
    if (box == null) {
      return Scaffold(appBar: AppBar(title: const Text('영역 분리')),
        body: const Center(child: Text('위치 미확인: 영역을 먼저 지정해야 분리할 수 있습니다.')));
    }
    return Scaffold(appBar: AppBar(title: const Text('드래그하여 음식 영역 분리')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        const Text('선택한 음식 박스 내부의 세로선을 좌우로 끌어 분할하세요.'),
        LayoutBuilder(builder: (context, constraints) {
          final w = constraints.maxWidth, h = w * widget.rawSize.height / widget.rawSize.width;
          final x = box['x']! * w, y = box['y']! * h;
          final bw = box['width']! * w, bh = box['height']! * h;
          return SizedBox(width: w, height: h, child: Stack(children: [
            Positioned.fill(child: Image.memory(widget.image, fit: BoxFit.fill)),
            Positioned(left: x, top: y, width: bw, height: bh,
              child: GestureDetector(behavior: HitTestBehavior.opaque,
                onPanUpdate: (details) => setState(() =>
                  fraction = (fraction + details.delta.dx / bw).clamp(.1, .9)),
                child: CustomPaint(painter: _SplitPainter(fraction)))),
          ]));
        }),
        TextField(controller: firstName, decoration: const InputDecoration(labelText: '왼쪽 음식명')),
        TextField(controller: firstWeight, keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: '왼쪽 섭취량(g)')),
        TextField(controller: secondName, decoration: const InputDecoration(labelText: '오른쪽 음식명')),
        TextField(controller: secondWeight, keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: '오른쪽 섭취량(g)')),
        const Text('두 항목은 별도로 영양 DB를 선택해야 합니다. 임의로 기존 열량을 복제하지 않습니다.'),
        FilledButton(onPressed: () {
          final a = double.tryParse(firstWeight.text), b = double.tryParse(secondWeight.text);
          if (firstName.text.trim().isEmpty || secondName.text.trim().isEmpty ||
              a == null || b == null || !a.isFinite || !b.isFinite ||
              a <= 0 || b <= 0 || a > 10000 || b > 10000) {
            return;
          }
          final left = <String, double>{
            'x': box['x']!, 'y': box['y']!,
            'width': box['width']! * fraction, 'height': box['height']!,
          };
          final right = <String, double>{
            'x': box['x']! + box['width']! * fraction, 'y': box['y']!,
            'width': box['width']! * (1 - fraction), 'height': box['height']!,
          };
          Navigator.pop(context, FoodSplitResult(firstName.text.trim(), secondName.text.trim(),
            a, b, left, right));
        }, child: const Text('두 개의 독립 음식으로 확정')),
      ]));
  }
}
class _SplitPainter extends CustomPainter {
  final double fraction;
  const _SplitPainter(this.fraction);
  @override void paint(Canvas canvas, Size size) {
    final border = Paint()..color = Colors.amber ..style = PaintingStyle.stroke ..strokeWidth = 3;
    canvas.drawRect(Offset.zero & size, border);
    canvas.drawLine(Offset(size.width * fraction, 0),
      Offset(size.width * fraction, size.height), border);
  }
  @override bool shouldRepaint(_SplitPainter old) => old.fraction != fraction;
}
