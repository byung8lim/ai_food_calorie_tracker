import 'package:flutter/material.dart';
import 'dart:io';
import 'package:fl_chart/fl_chart.dart';
import '../data/meal_store.dart';

class MealsPage extends StatelessWidget {
  final MealStore store;
  const MealsPage({super.key,required this.store});
  @override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:const Text('식사 기록')),body:FutureBuilder<List<Map<String,dynamic>>>(future:store.list(),builder:(context,snapshot){
    if(snapshot.hasError)return Center(child:Text('기록 조회 실패: ${snapshot.error}'));
    if(!snapshot.hasData)return const Center(child:CircularProgressIndicator());
    final rows=snapshot.data!;
    if(rows.isEmpty)return const Center(child:Text('저장된 식사가 없습니다'));
    return ListView(children:[for(final row in rows)ListTile(title:Text('${row['meal_type']} · ${(row['total_kcal'] as num).toStringAsFixed(1)} kcal'),subtitle:Text(row['consumed_at'].toString()),onTap:()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>MealDetailPage(store:store,id:row['id'].toString()))))]);
  }));
}
class MealDetailPage extends StatelessWidget {
  final MealStore store;
  final String id;
  const MealDetailPage({super.key,required this.store,required this.id});
  @override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:const Text('식사 상세')),body:FutureBuilder<List<dynamic>>(future:Future.wait<dynamic>([store.items(id),store.images(id)]),builder:(context,snapshot){
    if(snapshot.hasError)return Center(child:Text('조회 실패: ${snapshot.error}'));
    if(!snapshot.hasData)return const Center(child:CircularProgressIndicator());
    final items = snapshot.data![0] as List<Map<String,dynamic>>;
    final photos = snapshot.data![1] as List<File>;
    return ListView(children:[
      for(final photo in photos) Padding(padding:const EdgeInsets.all(8),child:Image.file(photo,height:220,fit:BoxFit.contain)),
      for(final row in items)ListTile(title:Text(row['name'].toString()),subtitle:Text('${row['weight_g']??'?'} g · 출처: ${row['source']}'),trailing:Text('${row['calculated_kcal']??'?'} kcal'))]);
  }));
}
class StatsPage extends StatelessWidget {
  final MealStore store;
  const StatsPage({super.key,required this.store});
  @override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:const Text('최근 30일 통계')),body:FutureBuilder<List<Map<String,dynamic>>>(future:store.dailyTotals(),builder:(context,snapshot){
    if(snapshot.hasError)return Center(child:Text('통계 조회 실패: ${snapshot.error}'));
    if(!snapshot.hasData)return const Center(child:CircularProgressIndicator());
    final rows=snapshot.data!.reversed.toList();
    if(rows.isEmpty)return const Center(child:Text('표시할 데이터가 없습니다'));
    final values=[for(final r in rows)(r['kcal'] as num).toDouble()];
    return Padding(padding:const EdgeInsets.all(22),child:Column(children:[const Text('기록이 있는 날짜별 칼로리 총합'),SizedBox(height:260,child:BarChart(BarChartData(maxY:values.reduce((a,b)=>a>b?a:b)*1.2+1,barGroups:[for(var i=0;i<rows.length;i++)BarChartGroupData(x:i,barRods:[BarChartRodData(toY:values[i])])],titlesData:const FlTitlesData(topTitles:AxisTitles(sideTitles:SideTitles(showTitles:false)),rightTitles:AxisTitles(sideTitles:SideTitles(showTitles:false)),bottomTitles:AxisTitles(sideTitles:SideTitles(showTitles:false)))))),const SizedBox(height:12),Expanded(child:ListView(children:[for(var i=rows.length-1;i>=0;i--)ListTile(title:Text(rows[i]['day'].toString()),trailing:Text('${values[i].toStringAsFixed(1)} kcal'))]))]));
  }));
}
