# Gemini 2026-10-25 품질감리 대응 추적서

기준: reports_DEPLOYMENT_QUALITY_AUDIT_REPORT.md (사용자 제공 문서).
이 문서는 실제 코드와 비교한 결과이며 앱 빌드/실기기 테스트 통과 증명이 아닙니다.

| 번호 | Gemini 지적 | 소스 검토 결과 | 조치 |
|---|---|---|---|
| B-01 | Ollama API 키 직접 호출 | 확인. `lib/data/ollama_client.dart`에서 사용자 개인 API 키로 직접 호출 | **미해결**: 운영용 서버 BFF, 인증, 호출량 제한, 비용 제한, 앱-서버 API 전환이 필요 |
| B-02 | BBox 드래그/분할 미구현 | **지적 부정확**: `lib/ui/food_split_editor.dart`는 사용자가 분할선을 드래그하여 좌우 각각 서로 다른 bbox를 계산하고 독립 중량을 입력하게 함 | 기존 구현 유지. 자유형 마스크 분할·정확도 실기기 검증은 별개 미완료 |
| B-03 | 이미지 파일 및 DB 원자성 미확보 | 확인. SQLite 트랜잭션만으로 파일시스템까지 원자성 보장 불가 | **부분 조치**: `MealStore.open()`에서 DB에 기록이 없는 이미지 폴더를 정리하여 중단된 저장의 고아 파일을 복구. 강제종료/디스크 장애 테스트와 저장 프로토콜 보강은 미완료 |
| B-04 | 공공 영양 DB 결측값 표시 | 부분 확인. `NutritionEntry`는 nullable 값을 보존하지만 식사 기록은 열량 위주 | **부분 조치**: 식사 상세 UI에서 영양소는 '데이터 없음 (0g 아님)'으로 표기. 정확한 영양소별 스냅샷·합계 구현은 미완료 |
| QA | 빌드 및 테스트 미실시 | 확인 | CI 정의는 존재하지만 통과 로그를 확인하지 못함 |

## 실증 전 절대 배포 금지
- GitHub에 `assets/nutrition/seed.json` 파일이 실제 존재하는지 검사: 없으면 앱 에셋 로딩 실패
- `flutter pub get`, `flutter analyze`, `flutter test`, `flutter build apk --release` 결과 확인
- 디바이스에서 카메라, AI API 실제 연결, SQLite 마이그레이션, 앱 재시작, 파일 유실/복구 테스트
- JWT BFF 인증과 요금/쿼터 제어 구현 및 모의 침투 테스트

## 유의 사항
Gemini 보고서의 '임시 디렉터리 → DB commit → atomic rename'만으로도 DB와 파일 간 단일 원자적 트랜잭션이 만들어지지는 않습니다. commit 뒤 rename 전 크래시에 대한 복구 프로토콜 또는 재시도 설계가 반드시 추가되어야 합니다.
