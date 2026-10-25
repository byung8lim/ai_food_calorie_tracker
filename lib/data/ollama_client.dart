import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../domain/food.dart';
class OllamaClient {
 final Dio dio;
 final FlutterSecureStorage storage;
 OllamaClient({Dio? dio,FlutterSecureStorage? storage}):dio=dio??Dio(BaseOptions(connectTimeout:const Duration(seconds:20),receiveTimeout:const Duration(seconds:120))),storage=storage??const FlutterSecureStorage();
 Future<void> saveKey(String key)=>storage.write(key:'ollama_api_key',value:key);
 Future<List<Food>> analyze(Uint8List image,{String model='gemma4:cloud',String? prompt})async{
  final key=await storage.read(key:'ollama_api_key');
  if(key==null || key.isEmpty)throw StateError('설정에서 Ollama API 키를 입력하세요');
  final response=await dio.post('https://ollama.com/api/chat',options:Options(headers:{'Authorization':'Bearer $key','Content-Type':'application/json'}),data:{'model':model,'stream':false,'format':'json','messages':[{'role':'user','content':prompt??'사진 속 음식을 접시별로 구분하여 foods JSON 배열로 반환하세요.','images':[base64Encode(image)]}]});
  final content=response.data['message']?['content'];
  if(content is! String || content.trim().isEmpty)throw const FormatException('AI 응답이 비어 있습니다');
  return AnalysisValidator.parse(content);
 }
}
