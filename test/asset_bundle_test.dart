import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('K-FIND data is actually loadable from Flutter asset bundle', () async {
    final bundled = await rootBundle.load('assets/nutrition/seed.json.gz');
    final raw = utf8.decode(gzip.decode(bundled.buffer.asUint8List(bundled.offsetInBytes, bundled.lengthInBytes)));
    final entries = jsonDecode(raw) as List;
    expect(entries.length, 13877);
    expect(entries.any((e) => e['name'].toString().contains('된장찌개')), isTrue);
  });
}
