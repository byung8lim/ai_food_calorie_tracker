# AI Food Calorie Tracker v0.6 (검증 미완료 소스)

한식 다중 음식 인식·검수·칼로리 기록 Flutter 애플리케이션. `assets/nutrition/seed.json`에 100g 기준 공공 영양 데이터 13,877행이 포함되어 있습니다. 값이 없는 영양소는 null이며, 확정된 영양값으로 간주하지 않습니다.

## 설치 / 실행
Flutter SDK, Android Studio/SDK, Android 라이선스, 인터넷이 필요합니다. 프로젝트 루트에서 `flutter pub get`, `flutter analyze`, `flutter test`, `flutter run`을 실행하세요. Android APK는 `flutter build apk --release`로 별도 생성해야 합니다. 이 패키지에는 검증된 APK가 **포함되지 않습니다**.

## 인증 및 프라이버시
설정 화면에 본인이 직접 입력한 Ollama Cloud 키를 OS 보안 저장소에 보관합니다. 이미지는 클라우드 AI 분석 과정에서 외부로 전송됩니다. 상용 서비스 배포 시 인증·호출 제한 프록시가 필요하며 현재 제공되지 않습니다.

## 실증 상태
이 응답에서 프로젝트가 빌드됐거나 Android/iOS 실기기에서 동작했다고 주장하지 않습니다. 수정 내역과 미완료 범위는 `CHANGELOG_v0_6.md`를 참조하세요.
