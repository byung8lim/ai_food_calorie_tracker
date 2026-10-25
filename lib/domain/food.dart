import 'dart:convert';
class Food {
  final String id, name, category;
  final double? weight, estimatedKcal, confidence, kcalPer100g;
  final Map<String, double>? bbox;
  final bool needsReview;
  final String source;
  const Food({required this.id,required this.name,required this.category,this.weight,this.estimatedKcal,this.confidence,this.kcalPer100g,this.bbox,this.needsReview=false,this.source='AI_ESTIMATE'});
  double? get calories => kcalPer100g != null && weight != null ? weight! * kcalPer100g! / 100 : estimatedKcal;
  Food copyWith({String? name,double? weight,double? kcalPer100g,String? source})=>Food(id:id,name:name??this.name,category:category,weight:weight??this.weight,estimatedKcal:estimatedKcal,confidence:confidence,kcalPer100g:kcalPer100g??this.kcalPer100g,bbox:bbox,needsReview:needsReview,source:source??this.source);
  Map<String,dynamic> toJson()=>{'item_id':id,'name':name,'category':category,'estimated_weight_g':weight,'estimated_calories_kcal':estimatedKcal,'confidence':confidence,'bbox':bbox,'needs_review':needsReview,'calories_per_100g':kcalPer100g,'source':source};
}
class AnalysisValidator {
 static List<Food> parse(String raw) {
  final decoded=jsonDecode(raw);
  if(decoded is! Map || decoded['foods'] is! List) throw const FormatException('foods 배열이 없습니다');
  final seen=<String>{}; final result=<Food>[];
  for(final value in decoded['foods']) {
   if(value is! Map) throw const FormatException('음식 항목 형식 오류');
   final id=value['item_id'],name=value['name'],category=value['category'];
   if(id is! String || id.isEmpty || !seen.add(id) || name is! String || name.trim().isEmpty || category is! String) throw const FormatException('필수 필드 또는 ID 중복');
   double? number(dynamic x,{double max=100000}) {if(x==null)return null; if(x is! num || !x.isFinite || x<0 || x>max)throw const FormatException('숫자 범위 오류');return x.toDouble();}
   final weight=number(value['estimated_weight_g'],max:10000),kcal=number(value['estimated_calories_kcal']);
   final confidence=number(value['confidence'],max:1);
   Map<String,double>? bbox;
   final b=value['bbox'];
   if(b!=null){if(b is! Map)throw const FormatException('bbox 형식 오류');bbox={};for(final k in ['x','y','width','height']){final n=number(b[k],max:1);if(n==null)throw const FormatException('bbox 필드 누락');bbox[k]=n;}
    if(bbox['width']!<=0 || bbox['height']!<=0 || bbox['x']!+bbox['width']!>1.000001 || bbox['y']!+bbox['height']!>1.000001)throw const FormatException('bbox 범위 오류');}
   result.add(Food(id:id,name:name,category:category,weight:weight,estimatedKcal:kcal,confidence:confidence,bbox:bbox,needsReview:value['needs_review']==true || bbox==null || (confidence??0)<0.8));
  }
  if(result.isEmpty)throw const FormatException('인식된 음식 없음');
  return result;
 }
 static double total(Iterable<Food> foods)=>foods.fold(0,(sum,food)=>sum+(food.calories??0));
}
