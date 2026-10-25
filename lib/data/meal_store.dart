import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../domain/food.dart';

/// Normalized transactional persistence. AI output is preserved separately.
class MealStore {
  late final DatabaseConnection connection;
  bool _opened = false;
  Future<void>? _opening;
  Future<void> open() async {
    if (_opened) return;
    return _opening ??= _initialize().catchError((Object error) {
      _opening = null;
      throw error;
    });
  }
  Future<void> _initialize() async {
    final dir=await getApplicationDocumentsDirectory();
    connection=DatabaseConnection(NativeDatabase.createInBackground(File(p.join(dir.path,'meals_v2.sqlite'))));
    await connection.executor.runCustom('PRAGMA foreign_keys = ON');
    await connection.executor.runCustom('CREATE TABLE IF NOT EXISTS meals (id TEXT PRIMARY KEY, consumed_at TEXT NOT NULL, meal_type TEXT NOT NULL, total_kcal REAL NOT NULL)');
    await connection.executor.runCustom('CREATE TABLE IF NOT EXISTS food_items (id TEXT PRIMARY KEY, meal_id TEXT NOT NULL REFERENCES meals(id) ON DELETE CASCADE, name TEXT NOT NULL, category TEXT NOT NULL, weight_g REAL, kcal_per_100g REAL, calculated_kcal REAL, source TEXT NOT NULL, confidence REAL, bbox_json TEXT, needs_review INTEGER NOT NULL)');
    await connection.executor.runCustom('CREATE TABLE IF NOT EXISTS meal_images (id TEXT PRIMARY KEY, meal_id TEXT NOT NULL REFERENCES meals(id) ON DELETE CASCADE, position INTEGER NOT NULL, relative_path TEXT NOT NULL, sha256 TEXT NOT NULL, UNIQUE(meal_id,position))');
    await connection.executor.runCustom('CREATE TABLE IF NOT EXISTS ai_analyses (id TEXT PRIMARY KEY, meal_id TEXT NOT NULL REFERENCES meals(id) ON DELETE CASCADE, model TEXT NOT NULL, raw_json TEXT NOT NULL, created_at TEXT NOT NULL)');
    await connection.executor.runCustom('CREATE INDEX IF NOT EXISTS idx_meals_date ON meals(consumed_at)');
    await connection.executor.runCustom('CREATE INDEX IF NOT EXISTS idx_food_items_meal ON food_items(meal_id)');
    // All future structural migrations must be versioned and additive.
    final versionRows = await connection.executor.runSelect('PRAGMA user_version', []);
    final version = (versionRows.first['user_version'] as num).toInt();
    if (version < 1) {
      await connection.executor.runCustom('PRAGMA user_version = 1');
    }
    if (version < 2) {
      final columns = await connection.executor.runSelect('PRAGMA table_info(food_items)', []);
      if (!columns.any((c) => c['name'] == 'nutrition_source_id')) {
        await connection.executor.runCustom('ALTER TABLE food_items ADD COLUMN nutrition_source_id TEXT');
      }
      await connection.executor.runCustom('PRAGMA user_version = 2');
    }
    if (version < 3) {
      await connection.executor.runCustom('PRAGMA user_version = 3');
    }
    _opened = true;
  }
  Future<void> save(String id,String mealType,List<Food> foods,{String? rawAnalysis,String model='gemma4:cloud',DateTime? consumedAt,List<Uint8List> images = const []}) async {
    await open();
    if(foods.isEmpty)throw ArgumentError('식사에 음식이 없습니다');
    final date=(consumedAt??DateTime.now()).toIso8601String();
    final docDir = await getApplicationDocumentsDirectory();
    final imageDir = Directory(p.join(docDir.path, 'meal_images', id));
    if (await imageDir.exists()) throw StateError('Duplicate meal ID / image directory');
    final stored = <Map<String, String>>[];
    try {
      if (images.isNotEmpty) await imageDir.create(recursive: true);
      for (var i = 0; i < images.length; i++) {
        final bytes = images[i];
        final relativePath = p.join('meal_images', id, '$i.jpg');
        final file = File(p.join(docDir.path, relativePath));
        await file.writeAsBytes(bytes, flush: true);
        stored.add({'id': '$id-image-$i', 'path': relativePath, 'hash': sha256.convert(bytes).toString()});
      }
    } catch (_) {
      if (await imageDir.exists()) await imageDir.delete(recursive: true);
      rethrow;
    }
    await connection.executor.runCustom('BEGIN IMMEDIATE');
    try {
      await connection.executor.runInsert('INSERT INTO meals (id,consumed_at,meal_type,total_kcal) VALUES (?,?,?,?)',[id,date,mealType,AnalysisValidator.total(foods)]);
      for(final food in foods){
        await connection.executor.runInsert('INSERT INTO food_items (id,meal_id,name,category,weight_g,kcal_per_100g,calculated_kcal,source,confidence,bbox_json,needs_review,nutrition_source_id) VALUES (?,?,?,?,?,?,?,?,?,?,?,?)',['$id:${food.id}',id,food.name,food.category,food.weight,food.kcalPer100g,food.calories,food.source,food.confidence,food.bbox==null?null:jsonEncode(food.bbox),food.needsReview?1:0,food.source.startsWith('PUBLIC_DB:')?food.source.substring(10):null]);
      }
      for (var i = 0; i < stored.length; i++) {
        final photo = stored[i];
        await connection.executor.runInsert('INSERT INTO meal_images(id,meal_id,position,relative_path,sha256) VALUES (?,?,?,?,?)',
          [photo['id'],id,i,photo['path'],photo['hash']]);
      }
      if(rawAnalysis!=null)await connection.executor.runInsert('INSERT INTO ai_analyses (id,meal_id,model,raw_json,created_at) VALUES (?,?,?,?,?)',['analysis-$id',id,model,rawAnalysis,date]);
      await connection.executor.runCustom('COMMIT');
    } catch (_) {
      await connection.executor.runCustom('ROLLBACK');
      if (await imageDir.exists()) await imageDir.delete(recursive: true);
      rethrow;
    }
  }
  Future<List<Map<String,dynamic>>> list() async { await open(); return connection.executor.runSelect('SELECT * FROM meals ORDER BY consumed_at DESC',[]); }
  Future<List<Map<String,dynamic>>> items(String mealId) async { await open(); return connection.executor.runSelect('SELECT * FROM food_items WHERE meal_id = ? ORDER BY rowid',[mealId]); }
  Future<List<Map<String,dynamic>>> images(String mealId) async {
    await open();
    final rows = await connection.executor.runSelect('SELECT * FROM meal_images WHERE meal_id=? ORDER BY position', [mealId]);
    final docDir = await getApplicationDocumentsDirectory();
    return rows.map((row) => {...row, 'absolute_path': p.join(docDir.path, row['relative_path'] as String)}).toList();
  }
  Future<void> deleteMeal(String mealId) async {
    await open();
    await connection.executor.runDelete('DELETE FROM meals WHERE id=?', [mealId]);
    final docDir = await getApplicationDocumentsDirectory();
    final folder = Directory(p.join(docDir.path,'meal_images', mealId));
    if (await folder.exists()) await folder.delete(recursive:true);
  }
  Future<List<Map<String,dynamic>>> dailyTotals() async { await open(); return connection.executor.runSelect('SELECT substr(consumed_at,1,10) AS day, SUM(total_kcal) AS kcal FROM meals GROUP BY substr(consumed_at,1,10) ORDER BY day DESC LIMIT 30',[]); }
  Future<void> close()=>connection.executor.close();
}
