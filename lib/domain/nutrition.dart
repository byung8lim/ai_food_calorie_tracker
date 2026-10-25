import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';

class NutritionEntry {
  final String name, source, sourceId, unit;
  final double kcal;
  final double? protein, fat, carbs;
  const NutritionEntry(this.name, this.kcal, this.protein, this.fat, this.carbs, this.source, this.sourceId, this.unit);
  factory NutritionEntry.fromJson(Map<String, dynamic> r) => NutritionEntry(
    r['name'] as String, (r['kcal'] as num).toDouble(),
    (r['protein'] as num?)?.toDouble(), (r['fat'] as num?)?.toDouble(),
    (r['carbs'] as num?)?.toDouble(), r['source'] as String,
    r['source_id'] as String, r['unit'] as String,
  );
}

class NutritionMatch {
  final NutritionEntry entry;
  final double score;
  const NutritionMatch(this.entry, this.score);
}

class NutritionCatalog {
  final List<NutritionEntry> entries;
  const NutritionCatalog(this.entries);
  static Future<NutritionCatalog> load() async {
    final bundled = await rootBundle.load('assets/nutrition/seed.json.gz');
    final compressed = bundled.buffer.asUint8List(bundled.offsetInBytes, bundled.lengthInBytes);
    final data = jsonDecode(utf8.decode(gzip.decode(compressed))) as List;
    return NutritionCatalog(data.map((v) => NutritionEntry.fromJson(Map<String, dynamic>.from(v as Map))).toList());
  }
  static String normalize(String s) => s.toLowerCase().replaceAll(RegExp(r'[^가-힣a-z0-9]'), '');
  static const _initials = [
    'ㄱ','ㄲ','ㄴ','ㄷ','ㄸ','ㄹ','ㅁ','ㅂ','ㅃ','ㅅ','ㅆ','ㅇ','ㅈ','ㅉ','ㅊ','ㅋ','ㅌ','ㅍ','ㅎ'
  ];
  static String decomposeHangul(String input) {
    final out = StringBuffer();
    for (final code in normalize(input).runes) {
      if (code >= 0xAC00 && code <= 0xD7A3) {
        final base = code - 0xAC00;
        out.write(_initials[base ~/ 588]);
        out.writeCharCode(0x1161 + (base % 588) ~/ 28);
        final tail = base % 28;
        if (tail > 0) out.writeCharCode(0x11A7 + tail);
      } else {
        out.writeCharCode(code);
      }
    }
    return out.toString();
  }
  static double jamoSimilarity(String a, String b) {
    if (a.isEmpty || b.isEmpty) return 0;
    if (a == b) return 1;
    final aa = <String, int>{}, bb = <String, int>{};
    for (var i = 0; i < a.length - 1; i++) {
      final pair = a.substring(i, i + 2);
      aa[pair] = (aa[pair] ?? 0) + 1;
    }
    for (var i = 0; i < b.length - 1; i++) {
      final pair = b.substring(i, i + 2);
      bb[pair] = (bb[pair] ?? 0) + 1;
    }
    var shared = 0;
    for (final key in aa.keys) {
      final n = bb[key] ?? 0;
      shared += aa[key]! < n ? aa[key]! : n;
    }
    final denominator = (a.length - 1) + (b.length - 1);
    return denominator <= 0 ? 0 : (2.0 * shared / denominator);
  }
  static int distance(String a, String b) {
    var previous = List<int>.generate(b.length + 1, (i) => i);
    for (var i = 1; i <= a.length; i++) {
      final row = List<int>.filled(b.length + 1, 0);
      row[0] = i;
      for (var j = 1; j <= b.length; j++) {
        final cost = a[i - 1] == b[j - 1] ? 0 : 1;
        row[j] = [row[j - 1] + 1, previous[j] + 1, previous[j - 1] + cost].reduce((v, w) => v < w ? v : w);
      }
      previous = row;
    }
    return previous.last;
  }
  List<NutritionMatch> suggest(String name, {int limit = 8}) {
    final q = normalize(name);
    if (q.isEmpty) return [];
    final found = <NutritionMatch>[];
    for (final entry in entries) {
      final e = normalize(entry.name);
      if (e.isEmpty) continue;
      final normalScore = q == e ? 1.0 : 1 - distance(q, e) / (q.length > e.length ? q.length : e.length);
      final jamoScore = jamoSimilarity(decomposeHangul(q), decomposeHangul(e));
      var score = normalScore > jamoScore ? normalScore : jamoScore;
      if (q != e && (e.contains(q) || q.contains(e))) score = score < .85 ? .85 : score;
      if (score >= .58) found.add(NutritionMatch(entry, score));
    }
    found.sort((a, b) => b.score.compareTo(a.score));
    return found.take(limit).toList();
  }
}
