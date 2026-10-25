import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'data/meal_store.dart';
import 'data/ollama_client.dart';
import 'domain/food.dart';
import 'domain/nutrition.dart';
import 'ui/food_overlay.dart';
import 'ui/food_split_editor.dart';
import 'ui/meal_pages.dart';

final storeProvider = Provider((ref) => MealStore());
final clientProvider = Provider((ref) => OllamaClient());
void main() => runApp(const ProviderScope(child: FoodApp()));

class FoodApp extends ConsumerWidget {
  const FoodApp({super.key});
  @override Widget build(BuildContext context, WidgetRef ref) {
    final router = GoRouter(routes: [
      GoRoute(path: '/', builder: (_, __) => const Dashboard()),
      GoRoute(path: '/capture', builder: (_, __) => const CapturePage()),
      GoRoute(path: '/history', builder: (_, __) => MealsPage(store: ref.read(storeProvider))),
      GoRoute(path: '/stats', builder: (_, __) => StatsPage(store: ref.read(storeProvider))),
      GoRoute(path: '/settings', builder: (_, __) => const SettingsPage()),
    ]);
    return MaterialApp.router(title: '한상 칼로리', routerConfig: router,
      theme: ThemeData(colorSchemeSeed: Colors.green, useMaterial3: true));
  }
}

class Dashboard extends ConsumerStatefulWidget {
  const Dashboard({super.key});
  @override ConsumerState<Dashboard> createState() => _DashboardState();
}
class _DashboardState extends ConsumerState<Dashboard> {
  String? error;
  @override void initState() {
    super.initState();
    Future<void>(() async {
      try { await ref.read(storeProvider).open(); }
      catch (e) { if (mounted) setState(() => error = '$e'); }
    });
  }
  @override Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('AI 한상 칼로리')),
    body: ListView(padding: const EdgeInsets.all(20), children: [
      Text('한식 한 상을 음식별로 분석합니다', style: Theme.of(context).textTheme.headlineSmall),
      const Text('음식명과 중량은 AI 추정치이며 사용자의 검수가 필요합니다.'),
      if (error != null) Text('DB 오류: $error'),
      const SizedBox(height: 20),
      FilledButton.icon(onPressed: () => context.push('/capture'),
        icon: const Icon(Icons.camera_alt), label: const Text('사진 촬영 · 분석')),
      OutlinedButton(onPressed: () => context.push('/history'), child: const Text('식사 기록 · 상세')),
      OutlinedButton(onPressed: () => context.push('/stats'), child: const Text('일별 통계')),
      OutlinedButton(onPressed: () => context.push('/settings'), child: const Text('설정')),
    ]),
  );
}

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});
  @override ConsumerState<SettingsPage> createState() => _SettingsPageState();
}
class _SettingsPageState extends ConsumerState<SettingsPage> {
  final keyInput = TextEditingController();
  @override void dispose() { keyInput.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('API 설정')),
    body: Padding(padding: const EdgeInsets.all(16), child: Column(children: [
      TextField(controller: keyInput, obscureText: true,
        decoration: const InputDecoration(labelText: 'Ollama Cloud API 키')),
      FilledButton(onPressed: () async {
        await ref.read(clientProvider).saveKey(keyInput.text);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('OS 보안 저장소에 저장했습니다')));
        }
      }, child: const Text('키 저장')),
      const Text('개인용 API 직접 연결입니다. 서비스 배포 시 서버 프록시가 필요합니다.'),
    ])));
}

class CapturePage extends ConsumerStatefulWidget {
  const CapturePage({super.key});
  @override ConsumerState<CapturePage> createState() => _CapturePageState();
}
class _CapturePageState extends ConsumerState<CapturePage> {
  final picker = ImagePicker();
  final photos = <Uint8List>[];
  final sizes = <Size>[];
  final foods = <Food>[];
  NutritionCatalog? catalog;
  String mealType = '점심', status = '사진을 추가하세요';
  int active = 0, selected = -1;
  bool busy = false;
  @override void initState() {
    super.initState();
    NutritionCatalog.load().then((v) {
      if (mounted) setState(() => catalog = v);
    }).catchError((Object e) { if (mounted) setState(() => status = '영양 DB 읽기 오류: $e'); });
  }
  Future<void> pick(ImageSource source) async {
    final f = await picker.pickImage(source: source, maxWidth: 2000, maxHeight: 1500, imageQuality: 84);
    if (f == null) return;
    final bytes = await f.readAsBytes();
    final decoded = img.decodeImage(bytes);
    if (decoded == null) { setState(() => status = '이미지 손상: 읽을 수 없음'); return; }
    // EXIF orientation is normalized before coordinates are sent to the model.
    final fixed = img.bakeOrientation(decoded);
    final encoded = Uint8List.fromList(img.encodeJpg(fixed, quality: 84));
    setState(() {
      photos.add(encoded);
      sizes.add(Size(fixed.width.toDouble(), fixed.height.toDouble()));
      active = photos.length - 1;
      status = '${photos.length}장 추가됨';
    });
  }
  Future<void> analyze() async {
    if (photos.isEmpty) return;
    setState(() { busy = true; status = '사진별 분석 중'; foods.clear(); });
    try {
      final merged = <Food>[];
      for (var photoIndex = 0; photoIndex < photos.length; photoIndex++) {
        final result = await ref.read(clientProvider).analyze(photos[photoIndex]);
        // IDs from different photos can collide, so namespace by photo.
        for (final food in result) {
          merged.add(Food(id: 'p$photoIndex-${food.id}', name: food.name,
            category: food.category, weight: food.weight, estimatedKcal: food.estimatedKcal,
            confidence: food.confidence, bbox: food.bbox, needsReview: true,
            source: 'AI_ESTIMATE'));
        }
      }
      if (mounted) {
        setState(() {
          foods.addAll(merged);
          status = '${foods.length}개 후보. 사진 간 중복 항목을 검수·병합하세요.';
        });
      }
    } catch (e) {
      if (mounted) setState(() => status = '분석 실패 (재시도 가능): $e');
    } finally { if (mounted) setState(() => busy = false); }
  }
  Future<void> edit(int index) async {
    final original = foods[index];
    final name = TextEditingController(text: original.name);
    final weight = TextEditingController(text: '${original.weight ?? 100}');
    final rate = TextEditingController(text: original.kcalPer100g?.toString() ?? '');
    final candidates = catalog?.suggest(original.name) ?? <NutritionMatch>[];
    NutritionEntry? chosen;
    await showDialog<void>(context: context, builder: (ctx) => StatefulBuilder(
      builder: (ctx, update) => AlertDialog(title: const Text('음식 검수 및 영양정보'),
        content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: name, decoration: const InputDecoration(labelText: '음식명')),
          TextField(controller: weight, keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: '섭취 중량 g')),
          TextField(controller: rate, keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: '100g당 kcal (사용자 입력)')),
          const SizedBox(height: 8),
          const Text('공공 DB 후보: 선택 후 출처를 확인하세요'),
          RadioGroup<String>(groupValue: chosen?.sourceId,
            onChanged: (id) => update(() {
              for (final match in candidates) {
                if (match.entry.sourceId == id) {
                  chosen = match.entry;
                  rate.text = '${match.entry.kcal}';
                  break;
                }
              }
            }),
            child: Column(children: [
              for (final m in candidates) RadioListTile<String>(
                title: Text('${m.entry.name} · ${m.entry.kcal} kcal/100g'),
                subtitle: Text('${m.entry.source} · ${m.entry.sourceId} · 일치도 ${m.score.toStringAsFixed(2)}'),
                value: m.entry.sourceId),
            ])),
        ])), actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('취소')),
          FilledButton(onPressed: () {
            final w = double.tryParse(weight.text), r = double.tryParse(rate.text);
            if (w == null || !w.isFinite || w < 0 || w > 10000 ||
                (rate.text.isNotEmpty && (r == null || !r.isFinite || r < 0))) {
              return;
            }
            setState(() => foods[index] = Food(
              id: original.id, name: name.text.trim(), category: original.category,
              weight: w, estimatedKcal: original.estimatedKcal,
              confidence: original.confidence, kcalPer100g: r,
              bbox: original.bbox, needsReview: false,
              source: chosen != null ? 'PUBLIC_DB:${chosen!.sourceId}' :
                r != null ? 'USER_INPUT' : 'AI_ESTIMATE'));
            Navigator.pop(ctx);
          }, child: const Text('적용')),
        ])));
    name.dispose(); weight.dispose(); rate.dispose();
  }
  void merge(int index) {
    if (selected < 0 || selected == index || selected >= foods.length) {
      setState(() => selected = index); return;
    }
    final a = foods[selected], b = foods[index];
    setState(() {
      foods[selected] = Food(id: a.id, name: a.name, category: a.category,
        weight: (a.weight ?? 0) + (b.weight ?? 0), bbox: a.bbox,
        source: 'UNVERIFIED', needsReview: true);
      foods.removeAt(index);
      selected = -1;
      status = '두 항목의 중량을 합쳤습니다. 중복 열량 여부를 다시 검수하세요.';
    });
  }
  Future<void> split(int index) async {
    if (photos.isEmpty || foods[index].bbox == null) {
      setState(() => status = '영역이 없는 음식은 먼저 위치를 지정해야 분리할 수 있습니다.');
      return;
    }
    final food = foods[index];
    final imageIndex = RegExp(r'^p(\d+)-').firstMatch(food.id);
    final p = int.tryParse(imageIndex?.group(1) ?? '') ?? active;
    if (p >= photos.length) return;
    final result = await Navigator.push<FoodSplitResult>(context, MaterialPageRoute(
      builder: (_) => FoodSplitEditor(image: photos[p], rawSize: sizes[p], food: food)));
    if (result == null || !mounted) return;
    final idPrefix = 'p$p-';
    setState(() {
      foods.removeAt(index);
      foods.insertAll(index, [
        Food(id: '$idPrefix${const Uuid().v4()}', name: result.firstName,
          category: food.category, weight: result.firstWeight, bbox: result.leftBox,
          source: 'UNVERIFIED', needsReview: true),
        Food(id: '$idPrefix${const Uuid().v4()}', name: result.secondName,
          category: food.category, weight: result.secondWeight, bbox: result.rightBox,
          source: 'UNVERIFIED', needsReview: true),
      ]);
      status = '실제 이미지 영역을 두 개로 분할했습니다. 두 음식의 영양 DB를 각각 검수하세요.';
    });
  }
  Future<void> save() async {
    if (foods.isEmpty) return;
    if (foods.any((f) => f.needsReview)) {
      setState(() => status = '확인되지 않은 음식 항목이 있습니다. 각 항목을 검수하세요.');
      return;
    }
    try {
      await ref.read(storeProvider).save(const Uuid().v4(), mealType, foods, images: photos);
      if (mounted) setState(() => status = '저장 완료');
    } catch (e) { if (mounted) setState(() => status = '저장 실패: $e'); }
  }
  @override Widget build(BuildContext context) {
    final visible = <Food>[];
    final indices = <int>[];
    if (photos.isNotEmpty) {
      for (var i = 0; i < foods.length; i++) {
        if (foods[i].id.startsWith('p$active-')) { visible.add(foods[i]); indices.add(i); }
      }
    }
    return Scaffold(appBar: AppBar(title: const Text('식사 촬영 · 검수')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        DropdownButton<String>(value: mealType,
          items: ['아침', '점심', '저녁', '간식', '야식'].map((x) =>
            DropdownMenuItem(value: x, child: Text(x))).toList(),
          onChanged: (v) => setState(() => mealType = v!)),
        Wrap(spacing: 8, children: [
          OutlinedButton(onPressed: () => pick(ImageSource.camera), child: const Text('촬영')),
          OutlinedButton(onPressed: () => pick(ImageSource.gallery), child: const Text('사진 추가')),
          if (photos.isNotEmpty) OutlinedButton(onPressed: () => setState(() {
            photos.removeAt(active); sizes.removeAt(active);
            foods.clear(); active = 0; status = '사진 변경: 기존 분석을 초기화했습니다';
          }), child: const Text('현재 사진 삭제')),
        ]),
        if (photos.isNotEmpty) ...[
          Wrap(children: [for (var i = 0; i < photos.length; i++)
            ChoiceChip(label: Text('사진 ${i + 1}'), selected: active == i,
              onSelected: (_) => setState(() => active = i))]),
          FoodOverlay(image: photos[active], originalSize: sizes[active],
            foods: visible, selected: indices.indexOf(selected),
            onSelect: (i) => setState(() => selected = indices[i])),
        ],
        FilledButton(onPressed: busy || photos.isEmpty ? null : analyze,
          child: Text(busy ? '분석 중' : '전체 사진 AI 분석 / 재시도')),
        Text(status),
        Text('음식 ${foods.length}개 · ${AnalysisValidator.total(foods).toStringAsFixed(1)} kcal',
          style: Theme.of(context).textTheme.titleLarge),
        for (var i = 0; i < foods.length; i++) Card(child: Column(children: [
          ListTile(selected: selected == i, title: Text(foods[i].name),
            subtitle: Text('${foods[i].weight ?? '?'}g · ${foods[i].source}${foods[i].needsReview ? ' · 검수 필요' : ''}'),
            trailing: Text('${foods[i].calories?.toStringAsFixed(1) ?? '?'} kcal'),
            onTap: () => edit(i)),
          Wrap(spacing: 8, children: [
            TextButton(onPressed: () => merge(i), child: const Text('선택/병합')),
            TextButton(onPressed: () => setState(() => foods.removeAt(i)), child: const Text('삭제')),
            TextButton(onPressed: () => split(i), child: const Text('영역 드래그 분리')),
          ]),
        ])),
        OutlinedButton(onPressed: () => setState(() => foods.add(
          Food(id: const Uuid().v4(), name: '새 음식', category: 'unknown',
            weight: 100, needsReview: true))), child: const Text('음식 직접 추가')),
        FilledButton(onPressed: foods.isEmpty ? null : save, child: const Text('검수 완료 · 식사 저장')),
      ]));
  }
}
