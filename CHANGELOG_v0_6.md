# v0.6 수정 사항 및 검증 상태

## 실제 수정
- `pubspec.yaml`: 영양 데이터 `assets/nutrition/` 번들 포함; 앱 버전 `0.6.0+6`; `crypto` 의존성 추가
- `lib/data/meal_store.dart`: `meal_images` 정규화 테이블 및 스키마 버전 3; 식사 저장 시 분석용 JPEG를 앱 내부 문서 폴더에 영구 저장하고 SHA-256 기록; DB 기록 실패 시 새 이미지 디렉터리 삭제; 식사 이미지 조회와 식사 삭제 추가
- `lib/main.dart`: 식사 저장 때 해당 식사의 사진 여러 장을 함께 보존
- `lib/ui/meal_pages.dart`: 기록 상세에서 저장된 사진 조회 표시
- `test/asset_bundle_test.dart`: 데이터 파일을 Flutter `rootBundle`에서 여는 회귀 테스트 추가(실제 실행 미검증)

## 중요 제약 / 미완료
- 이 환경에는 Flutter, Android SDK, Xcode가 없고 공식 다운로드 호스트에 DNS 연결되지 않아 `flutter analyze`, `flutter test`, `flutter build apk`, iOS 빌드를 실행하지 **못함**. 따라서 **실행 가능한 최종 완성품으로 인증하지 않음**.
- 원본 사진과 분석용 리사이즈 이미지 분리, 사용자 동의 및 이미지 삭제 정책, DB 마이그레이션의 실기기 데이터 보존 검증, 안전한 중복 사진 통합, API 취소, 외부 영양 데이터 갱신, 통합·실기기 테스트는 추가 작업 필요.
- 현재 저장되는 사진은 모델 입력용으로 압축한 JPEG이며, 카메라가 생성한 **촬영 원본과 동일하지 않음**.
- 로컬 DB·파일 기록은 복구 가능한 단일 트랜잭션이 아니므로 기기 전원 차단 시 고아 파일 가능성 있음. 별도 정합성 복구 로직 필요.
- 영양 DB 총 13,877행 중 탄수화물 null 10,654행, 지방 null 11,076행: 영양소 전 항목 완비로 표시하면 안 됨.

## 사용자 환경 재현 검증
```
flutter pub get
flutter analyze
flutter test
flutter build apk --debug
flutter build apk --release
```
실기기에서 카메라 → 다중 사진 → Ollama Cloud 실제 분석 → 음식 검수 → 식사 저장 → 앱 강제 종료 → 재실행 → 상세 사진 및 열량 조회를 추가로 검사해야 합니다.
