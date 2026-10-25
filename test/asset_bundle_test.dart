import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('K-FIND data is actually loadable from Flutter asset bundle', () async {
    final raw = await rootBundle.loadString('assets/nutrition/seed.json');
    final entries = jsonDecode(raw) as List;
    expect(entries.length, 13877);
    expect(entries.any((e) => e['name'].toString().contains('된장찌개')), isTrue);
  });
}
