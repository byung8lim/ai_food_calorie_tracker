# 개발 구현 요청서: AI Food Calorie Tracker

프로젝트명: AI Food Calorie Tracker — Flutter 멀티모달 AI 기반 음식 인식 및 식사별 칼로리 자동 계산 플랫폼

## 1. 프로젝트 개요

스마트폰 카메라로 식사 사진을 촬영하면 멀티모달 모델인 Gemma 4에 이미지를 전달하여 음식의 종류, 개별 음식의 위치, 추정 섭취량, 칼로리를 분석하고 식사 한 끼의 총열량을 자동 계산하는 Flutter 애플리케이션을 개발한다.

핵심은 한 장의 사진에 여러 음식이 함께 담기는 한식 식사 구조를 처리하는 것이다. 밥, 국, 김치, 나물, 볶음, 구이, 각종 반찬을 하나의 음식으로 뭉뚱그리지 않고 개별 항목으로 분리해 인식해야 한다.

예를 들어 제육볶음, 공깃밥, 된장찌개, 김치, 시금치나물이 한 상에 놓여 있다면 각 음식을 독립적으로 분석한 뒤 개별 칼로리와 식사 전체의 합계를 산출한다.

[구래동 작은밥상 한국가정식 | 경기도 김포시 구래동 | 한식 | 당근 동네 업체](https://images.openai.com/static-rsc-4/teThTsdNS5Gjr7IaT8_2QgrR2VnphYXMEk_4u60dzH22lI5nGDAe6jzvbxWJl57MyoKNKwKw-SmxfmNJ89kDiXEkZpLCK_JrVNZyr5dJZ_-qYcT9l3wKxI20gs1CUyaAjRVBgWRAgJw5mvOYu8Xer5iiMXQ9V7m7X6_mH8A8Xuk?purpose=inline)

입력: 한식 식사 사진

한 프레임에 밥, 국, 메인 요리, 다수의 반찬이 함께 포함된 사진을 촬영하거나 갤러리에서 불러온다.

[\[대전 현충원 맛집\] 대전 현충원 근처 맛집. 동가마 숯불갈비. 제육 한상 차림 점심 식사 추천. 대전 유성구 맛집.](https://images.openai.com/static-rsc-4/zmyj1lH9DD5C4rNnuOHYRiNDf7JsyMly3NRUD9WGmjbOK2XaykYVZp9n4_J9cauS3kf-hw_9L1Lme6Qe5J_YcMF6PHqDl1fnukm20d2US8g08U5Qf-LNxSVb5ge3Wm17TaKq7qDSnWYup3lVGAtESjJjxCnQ9ICHuFsa4xGOvYw?purpose=inline)

분석: 음식별 분리 및 영양 추정

Gemma 4가 음식 후보를 식별하고, 사용자가 각 항목을 확인할 수 있도록 음식명과 추정 중량을 구조화한다.

["부모님댁에 앱을 놓아드렸다"…혈당관리 서비스 '파스타' - 뉴스1](https://images.openai.com/static-rsc-4/EqjkMqJvfvncuVDlsDBGX-cyWQz67qh0RRC4_C4usiA9JLCxZnyfraECNT_mEi8VtQHqWe-f-lzDqwv1hyN9bdG8GnTfMlxa-tJ6wbCIAiKq3TZG18hiTmZEw3gCt9RMYX7iNZ5jls1eqixoOuv5MJsCbfttcc1J06MhmlEfXAQ?purpose=inline)

결과: 식사별 칼로리 대시보드

음식별 열량, 식사 총열량, 일일 섭취량을 기록하고 수정한 뒤 날짜별 통계와 추이를 확인한다.

## 2. 개발 목표 및 기본 원칙

- Flutter 기반 Android 및 iOS 네이티브 앱을 구현한다.
- 음식 이미지 분석에는 Ollama Cloud API와 멀티모달 Gemma 4 모델을 사용한다.
- 한국 음식과 여러 반찬이 동시에 등장하는 식사 사진을 우선 지원한다.
- 음식 인식, 음식별 중량 추정, 영양 정보 조회, 칼로리 합산을 별도 단계로 설계한다.
- AI 추정값과 검증된 영양 데이터베이스 값을 구분해 표시한다.
- 사용자가 음식명, 섭취량, 칼로리를 수정할 수 있어야 한다.
- 사진과 분석 결과를 식사 기록으로 저장하고 날짜별로 조회한다.
- 실제 운영을 고려해 API 키 관리, 요청 제한, 실패 복구, 개인정보 보호, 테스트 자동화를 구현한다.

## 3. 기술 스택

| 영역        | 기술                                         |
| --------- | ------------------------------------------ |
| 모바일 앱     | Flutter, Dart                              |
| 상태 관리     | Riverpod                                   |
| 화면 이동     | GoRouter                                   |
| 로컬 데이터베이스 | Drift + SQLite                             |
| 이미지 처리    | Flutter 이미지 라이브러리, EXIF 회전 보정, 리사이즈 및 압축   |
| AI 추론     | Ollama Cloud API                           |
| 비전 모델     | Gemma 4 멀티모달 지원 모델                         |
| API 통신    | Dio, HTTPS, 타임아웃 및 재시도 정책                  |
| 차트        | fl_chart                                   |
| 로컬 알림     | flutter_local_notifications                |
| 비밀정보 보호   | flutter_secure_storage, OS 보안 저장소          |
| 테스트       | flutter_test, integration_test, mocktail   |
| CI/CD     | Flutter analyze, 자동 테스트, Android/iOS 빌드 검증 |

구현 기준: 앱은 핵심 기능을 로컬에서 실행할 수 있도록 설계한다. AI 분석 요청은 인터넷 연결이 필요하다. 로컬 저장 및 기존 식사 기록 조회는 AI 서버 연결과 독립적으로 동작하도록 한다.

서버 없이 앱에서 Ollama Cloud를 직접 호출하는 구성은 개인용 테스트에 적합하다. 실제 배포에서는 앱에 포함된 API 키를 추출할 수 있으므로, 사용자별 인증·요청 제한·키 보호가 필요한 서비스라면 별도 API 중계 서버를 추가할 수 있도록 통신 계층을 분리한다.

## 4. 핵심 기능 요구사항

### 4.1 음식 촬영 및 이미지 관리

- 카메라 촬영과 갤러리 이미지 불러오기 지원
- 촬영 직후 이미지 미리보기, 재촬영, 회전, 자르기
- 초점 흐림, 과도한 어두움, 이미지 손상 여부 검사
- EXIF 회전 정보 보정 및 이미지 압축
- 한 끼에 여러 장의 사진 등록 지원
- 식사 유형 선택: 아침, 점심, 저녁, 간식, 야식
- 촬영 시각 자동 입력 및 사용자 수정
- 원본 이미지와 분석용 이미지의 별도 관리
- 이미지 분석 동의 및 원본 이미지 삭제 기능
- 분석 중 취소, 네트워크 오류 시 재시도

사진 한 장에서 음식이 겹치거나 그릇에 가려진 경우, 인식되지 않은 음식을 자동으로 만들어 내기보다 사용자 확인이 필요한 항목으로 분류한다.

### 4.2 한식 음식별 분리 인식

이 기능은 프로젝트의 핵심이다.

[Korean Food Culture Vocabulary | KWL](https://images.openai.com/static-rsc-4/GJisIJre8jFI3bWTZVv4rNyQSc58YLdmhHKTHcE3ACdQQ4X5HslYwhS5kTuxVcjxpUrTX21YChBc_RnWBQ4AbwRLPLksa2d10B40IFYvSvL3RuG4OzNYqbhu6cvB4uKC-wrjTHdXgF8kxsd0HHqmMcsW38fgsXQKjY4U4eR2_j0?purpose=inline)

[Làm cơm trộn Hàn Quốc ngon hơn ngoài quán với công thức đơn giản](https://images.openai.com/static-rsc-4/Mlt--lzh3_TBDNI16sL8BK6y0SGCEsGnL9Y1pwtEpNtccpCPHfsmcoL5eAt6c-GfS1Ly6WYLZfDOfjQ0chdzvN81VhP39QSD1z03lb6ktwoRs0NTrSpnXayC6nk26HYbssHBWCAWdYWtZASEmMQjlKrbbUpaqDUZWS6nXAdhNEM?purpose=inline)

[Nurmi Dao Oriental Food](https://images.openai.com/static-rsc-4/u-hBZhsEfSnpKISW6HMn4Ck1FGcZr-C7LB_myStwPsEyBoF01TdGzzy1PohNuDALkO-FVaA8RQkD5risU_XDcFaJ4zFC1Ri8bL2zQlzUnnYTpznVyO4rkY6LJ9mFA_ZSwy6z4IihcQjoMxV3kgOZsP2oOlfikkeaF5b77tyNcIk?purpose=inline)

10

AI는 이미지 전체를 하나의 음식으로 판정하는 대신, 시각적으로 구분되는 음식 항목을 각각 추출한다.

인식 대상 예시는 다음과 같다.

| 분류     | 음식 예시                  |
| ------ | ---------------------- |
| 밥·곡류   | 흰쌀밥, 현미밥, 잡곡밥, 볶음밥     |
| 국·탕·찌개 | 된장찌개, 김치찌개, 미역국, 순두부찌개 |
| 육류     | 제육볶음, 불고기, 삼겹살, 갈비찜    |
| 생선·해산물 | 고등어구이, 갈치조림, 멸치볶음      |
| 채소·나물  | 시금치나물, 콩나물무침, 도라지무침    |
| 김치·절임  | 배추김치, 깍두기, 오이소박이       |
| 전·튀김   | 김치전, 파전, 돈가스, 각종 튀김    |
| 면·분식   | 비빔국수, 냉면, 떡볶이, 김밥      |
| 음료·후식  | 커피, 주스, 과일, 떡, 빵       |

필수 처리 규칙:

1. 사진에서 식별 가능한 음식마다 고유한 항목 ID를 부여한다.
2. 음식명, 음식 분류, 이미지 내 위치, 추정 중량을 개별적으로 반환한다.
3. 한 그릇 안에 여러 재료가 섞인 비빔밥이나 볶음밥은 음식 하나로 처리하고, 별도 재료 분해는 사용자가 요청하거나 분석 목적상 필요할 때 수행한다.
4. 김치와 반찬이 여러 접시에 담겨 있으면 시각적으로 분리된 접시를 개별 항목으로 취급한다.
5. 같은 접시의 음식을 중복 인식한 경우 후보 항목의 위치와 이름을 비교해 중복을 제거한다.
6. 음식의 일부만 보이는 경우 추정 신뢰도를 낮추고 사용자 확인을 요청한다.
7. 메뉴 이름이 불확실하면 확정 음식명 대신 후보와 불확실성을 반환한다.
8. 이미지 인식과 칼로리 계산을 별도 단계로 처리한다.

중요한 설계 원칙: Gemma 4는 사진에서 음식의 종류와 대략적인 양을 추정하는 역할을 담당한다. 픽셀만으로 음식의 실제 무게, 조리법, 기름 함량을 정확히 측정할 수는 없다. 따라서 결과는 추정값으로 표시하고, 사용자가 중량이나 음식 구성을 수정할 수 있게 한다.

### 4.3 음식 위치 표시 및 검수

AI가 반환한 각 음식의 위치 정보를 사진 위에 오버레이로 표시한다.

- 위치 표현은 정규화된 바운딩 박스 또는 중심 좌표로 구성한다.
- 각 박스에는 음식명과 항목 번호를 표시한다.
- 음식 항목을 선택하면 사진의 해당 위치와 편집 화면을 연결한다.
- 음식별 표시·숨김, 이름 변경, 항목 병합, 분리, 삭제를 지원한다.
- 박스가 겹치는 경우 색상과 번호로 항목을 구별한다.
- AI가 위치를 신뢰성 있게 특정하지 못한 항목은 위치 미확인으로 처리한다.

Gemma 4의 응답이 유효한 바운딩 박스를 제공하지 못하면 해당 좌표를 임의로 생성하지 않는다. 사용자가 직접 영역을 지정하거나 음식 목록만으로 검수할 수 있도록 한다.

### 4.4 음식별 중량 및 칼로리 계산

음식의 칼로리를 산출하기 위해 다음 데이터를 관리한다.

| 데이터    | 설명                       |
| ------ | ------------------------ |
| 음식명    | AI가 인식한 음식명              |
| 표준 음식명 | 영양 데이터베이스와 매칭된 명칭        |
| 섭취 중량  | g 또는 ml 단위의 추정·입력값       |
| 기준 열량  | 100g 또는 100ml당 kcal      |
| 계산 열량  | 섭취량을 기준으로 계산한 kcal       |
| 추정 신뢰도 | AI 인식 및 중량 추정의 불확실성      |
| 데이터 출처 | AI 추정, 영양 데이터베이스, 사용자 입력 |
| 조리 방식  | 생것, 삶음, 볶음, 튀김, 구이 등     |

기본 계산식:

\\[ \text{음식 열량(kcal)} = \frac{\text{섭취 중량(g)}}{100} \times \text{100g당 열량(kcal)} \\]

예를 들어 밥 210g의 기준 열량을 100g당 150kcal로 적용하면 315kcal다. 이 값은 계산 방식의 예시이며, 실제 앱에서는 선택한 영양 데이터 항목의 값을 사용한다.

음식별 계산 결과를 합산해 식사 총열량을 계산한다.

\\[ \text{식사 총열량} = \sum\_{i=1}^{n}\text{음식}\_i\text{의 계산 열량} \\]

중량을 직접 입력하거나 0.5인분, 1인분, 1.5인분 등의 배율로 조정할 수 있어야 한다. 국물 섭취량, 소스, 추가 기름 등 열량에 영향을 미치는 요소도 별도로 반영할 수 있도록 한다.

### 4.5 영양 데이터베이스

AI의 응답에 포함된 칼로리 숫자를 그대로 확정값으로 저장하는 구조는 피한다.

다음 순서로 영양 정보를 결정한다.

1. 표준 음식명과 조리법을 기준으로 영양 데이터베이스 검색
2. 정확한 일치 항목이 없으면 유사 음식 후보 제시
3. 사용자가 적절한 항목을 선택하거나 AI 추정값 사용
4. 중량과 100g당 열량을 이용해 계산
5. 출처 및 추정 여부를 식사 기록에 저장

국내 식품 영양성분 데이터와 식품의약품안전처 등 공공 데이터의 이용 가능 여부, 제공 조건, 갱신 주기를 확인한 뒤 데이터 어댑터를 구현한다. 공공 데이터 API를 사용하는 경우 API 키와 요청 제한을 고려한다.

영양 정보가 확인되지 않은 음식은 임의의 표준값으로 확정하지 않는다. 이 경우 AI 추정 열량과 추정 근거를 별도로 표시한다.

### 4.6 AI 분석 결과 편집

분석 결과 화면에서 음식 항목을 직접 편집할 수 있어야 한다.

- 음식명 변경 및 다른 음식으로 교체
- 음식 추가 및 삭제
- 섭취 중량 수정
- 기준 영양 정보 변경
- 칼로리 재계산
- 식사 유형 및 식사 시간 변경
- 분석 결과 재요청
- 사용자 수정 전후 값 비교
- 편집 취소 및 다시 실행
- 최종 확정 후 식사 기록 저장

사용자가 수정한 결과를 AI가 생성한 원본 결과와 분리해서 보관한다. 이를 통해 추정값의 변경 이력과 최종 확정값을 추적할 수 있다.

## 5. AI 분석 아키텍처

Ollama Cloud는 이미지 입력을 지원하는 Gemma 4 모델과 통신하는 데 사용한다. Ollama의 공식 비전 가이드는 이미지 데이터를 API의 `images` 배열로 전달하는 방식을 설명한다.&#x20;

[image](https://www.google.com/s2/favicons?domain=https://github.com\&sz=32)

GitHub

+1

모델 설정은 배포 시 확인된 Ollama Cloud 모델 ID를 사용한다. 기본 설정 후보는 `gemma4:cloud`이며, 모델 별칭과 API에서 실제 지원하는 식별자를 설정 화면에서 변경할 수 있게 한다.&#x20;

[image](https://www.google.com/s2/favicons?domain=https://ollama.com\&sz=32)

Ollama

+1

### 5.1 전체 처리 흐름

\#chatgpt-mermaid-\_r_kg\_{font-family:-apple-system-body,ui-sans-serif,-apple-system,system-ui,"Segoe UI",Helvetica,"Apple Color Emoji",Arial,sans-serif,"Segoe UI Emoji","Segoe UI Symbol";font-size:16px;fill:rgb(237, 237, 237);}@keyframes edge-animation-frame{from{stroke-dashoffset:0;}}@keyframes dash{to{stroke-dashoffset:0;}}#chatgpt-mermaid-\_r_kg\_ .edge-animation-slow{stroke-dasharray:9,5!important;stroke-dashoffset:900;animation:dash 50s linear infinite;stroke-linecap:round;}#chatgpt-mermaid-\_r_kg\_ .edge-animation-fast{stroke-dasharray:9,5!important;stroke-dashoffset:900;animation:dash 20s linear infinite;stroke-linecap:round;}#chatgpt-mermaid-\_r_kg\_ .error-icon{fill:rgb(48, 48, 48);}#chatgpt-mermaid-\_r_kg\_ .error-text{fill:rgb(237, 237, 237);stroke:rgb(237, 237, 237);}#chatgpt-mermaid-\_r_kg\_ .edge-thickness-normal{stroke-width:1px;}#chatgpt-mermaid-\_r_kg\_ .edge-thickness-thick{stroke-width:3.5px;}#chatgpt-mermaid-\_r_kg\_ .edge-pattern-solid{stroke-dasharray:0;}#chatgpt-mermaid-\_r_kg\_ .edge-thickness-invisible{stroke-width:0;fill:none;}#chatgpt-mermaid-\_r_kg\_ .edge-pattern-dashed{stroke-dasharray:3;}#chatgpt-mermaid-\_r_kg\_ .edge-pattern-dotted{stroke-dasharray:2;}#chatgpt-mermaid-\_r_kg\_ .marker{fill:rgb(175, 175, 175);stroke:rgb(175, 175, 175);}#chatgpt-mermaid-\_r_kg\_ .marker.cross{stroke:rgb(175, 175, 175);}#chatgpt-mermaid-\_r_kg\_ svg{font-family:-apple-system-body,ui-sans-serif,-apple-system,system-ui,"Segoe UI",Helvetica,"Apple Color Emoji",Arial,sans-serif,"Segoe UI Emoji","Segoe UI Symbol";font-size:16px;}#chatgpt-mermaid-\_r_kg\_ p{margin:0;}#chatgpt-mermaid-\_r_kg\_ .label{font-family:-apple-system-body,ui-sans-serif,-apple-system,system-ui,"Segoe UI",Helvetica,"Apple Color Emoji",Arial,sans-serif,"Segoe UI Emoji","Segoe UI Symbol";color:rgb(237, 237, 237);}#chatgpt-mermaid-\_r_kg\_ .cluster-label text{fill:rgb(237, 237, 237);}#chatgpt-mermaid-\_r_kg\_ .cluster-label span{color:rgb(237, 237, 237);}#chatgpt-mermaid-\_r_kg\_ .cluster-label span p{background-color:transparent;}#chatgpt-mermaid-\_r_kg\_ .label text,#chatgpt-mermaid-\_r_kg\_ span{fill:rgb(237, 237, 237);color:rgb(237, 237, 237);}#chatgpt-mermaid-\_r_kg\_ .node rect,#chatgpt-mermaid-\_r_kg\_ .node circle,#chatgpt-mermaid-\_r_kg\_ .node ellipse,#chatgpt-mermaid-\_r_kg\_ .node polygon,#chatgpt-mermaid-\_r_kg\_ .node path{fill:rgb(9, 23, 44);stroke:rgb(31, 78, 148);stroke-width:1px;}#chatgpt-mermaid-\_r_kg\_ .rough-node .label text,#chatgpt-mermaid-\_r_kg\_ .node .label text,#chatgpt-mermaid-\_r_kg\_ .image-shape .label,#chatgpt-mermaid-\_r_kg\_ .icon-shape .label{text-anchor:middle;}#chatgpt-mermaid-\_r_kg\_ .node .katex path{fill:#000;stroke:#000;stroke-width:1px;}#chatgpt-mermaid-\_r_kg\_ .rough-node .label,#chatgpt-mermaid-\_r_kg\_ .node .label,#chatgpt-mermaid-\_r_kg\_ .image-shape .label,#chatgpt-mermaid-\_r_kg\_ .icon-shape .label{text-align:center;}#chatgpt-mermaid-\_r_kg\_ .node.clickable{cursor:pointer;}#chatgpt-mermaid-\_r_kg\_ .root .anchor path{fill:rgb(175, 175, 175)!important;stroke-width:0;stroke:rgb(175, 175, 175);}#chatgpt-mermaid-\_r_kg\_ .arrowheadPath{fill:rgb(175, 175, 175);}#chatgpt-mermaid-\_r_kg\_ .edgePath .path{stroke:rgb(175, 175, 175);stroke-width:1px;}#chatgpt-mermaid-\_r_kg\_ .flowchart-link{stroke:rgb(175, 175, 175);fill:none;}#chatgpt-mermaid-\_r_kg\_ .edgeLabel{background-color:rgb(0, 0, 0);text-align:center;}#chatgpt-mermaid-\_r_kg\_ .edgeLabel p{background-color:rgb(0, 0, 0);}#chatgpt-mermaid-\_r_kg\_ .edgeLabel rect{opacity:0.5;background-color:rgb(0, 0, 0);fill:rgb(0, 0, 0);}#chatgpt-mermaid-\_r_kg\_ .labelBkg{background-color:rgba(0, 0, 0, 0.5);}#chatgpt-mermaid-\_r_kg\_ .cluster rect{fill:rgb(48, 48, 48);stroke:rgba(255, 255, 255, 0.15);stroke-width:1px;}#chatgpt-mermaid-\_r_kg\_ .cluster text{fill:rgb(237, 237, 237);}#chatgpt-mermaid-\_r_kg\_ .cluster span{color:rgb(237, 237, 237);}#chatgpt-mermaid-\_r_kg\_ div.mermaidTooltip{position:absolute;text-align:center;max-width:200px;padding:2px;font-family:-apple-system-body,ui-sans-serif,-apple-system,system-ui,"Segoe UI",Helvetica,"Apple Color Emoji",Arial,sans-serif,"Segoe UI Emoji","Segoe UI Symbol";font-size:12px;background:rgb(48, 48, 48);border:1px solid rgba(255, 255, 255, 0.15);border-radius:2px;pointer-events:none;z-index:100;}#chatgpt-mermaid-\_r_kg\_ .flowchartTitleText{text-anchor:middle;font-size:18px;fill:rgb(237, 237, 237);}#chatgpt-mermaid-\_r_kg\_ rect.text{fill:none;stroke-width:0;}#chatgpt-mermaid-\_r_kg\_ .icon-shape,#chatgpt-mermaid-\_r_kg\_ .image-shape{background-color:rgb(0, 0, 0);text-align:center;}#chatgpt-mermaid-\_r_kg\_ .icon-shape p,#chatgpt-mermaid-\_r_kg\_ .image-shape p{background-color:rgb(0, 0, 0);padding:2px;}#chatgpt-mermaid-\_r_kg\_ .icon-shape .label rect,#chatgpt-mermaid-\_r_kg\_ .image-shape .label rect{opacity:0.5;background-color:rgb(0, 0, 0);fill:rgb(0, 0, 0);}#chatgpt-mermaid-\_r_kg\_ .label-icon{display:inline-block;height:1em;overflow:visible;vertical-align:-0.125em;}#chatgpt-mermaid-\_r_kg\_ .node .label-icon path{fill:currentColor;stroke:revert;stroke-width:revert;}#chatgpt-mermaid-\_r_kg\_ .node .neo-node{stroke:rgb(31, 78, 148);}#chatgpt-mermaid-\_r_kg\_ [data-look="neo"].node rect,#chatgpt-mermaid-\_r_kg\_ [data-look="neo"].cluster rect,#chatgpt-mermaid-\_r_kg\_ [data-look="neo"].node polygon{stroke:url(#chatgpt-mermaid-\_r_kg\_-gradient);filter:drop-shadow( 1px 2px 2px rgba(185,185,185,1));}#chatgpt-mermaid-\_r_kg\_ [data-look="neo"].swimlane.cluster rect{filter:none;}#chatgpt-mermaid-\_r_kg\_ [data-look="neo"].node path{stroke:url(#chatgpt-mermaid-\_r_kg\_-gradient);stroke-width:1px;}#chatgpt-mermaid-\_r_kg\_ [data-look="neo"].node .outer-path{filter:drop-shadow( 1px 2px 2px rgba(185,185,185,1));}#chatgpt-mermaid-\_r_kg\_ [data-look="neo"].node .neo-line path{stroke:rgb(31, 78, 148);filter:none;}#chatgpt-mermaid-\_r_kg\_ [data-look="neo"].node circle{stroke:url(#chatgpt-mermaid-\_r_kg\_-gradient);filter:drop-shadow( 1px 2px 2px rgba(185,185,185,1));}#chatgpt-mermaid-\_r_kg\_ [data-look="neo"].node circle .state-start{fill:#000000;}#chatgpt-mermaid-\_r_kg\_ [data-look="neo"].icon-shape .icon{fill:url(#chatgpt-mermaid-\_r_kg\_-gradient);filter:drop-shadow( 1px 2px 2px rgba(185,185,185,1));}#chatgpt-mermaid-\_r_kg\_ [data-look="neo"].icon-shape .icon-neo path{stroke:url(#chatgpt-mermaid-\_r_kg\_-gradient);filter:drop-shadow( 1px 2px 2px rgba(185,185,185,1));}#chatgpt-mermaid-\_r_kg\_ .node text{font-size:14px;font-weight:600;letter-spacing:normal;fill:rgb(153, 206, 255);}#chatgpt-mermaid-\_r_kg\_ .edgeLabels text{font-size:13px;font-weight:600;letter-spacing:-0.08px;fill:rgb(153, 206, 255);}#chatgpt-mermaid-\_r_kg\_ .node tspan[font-weight="normal"],#chatgpt-mermaid-\_r_kg\_ .edgeLabels tspan[font-weight="normal"]{font-weight:600;}#chatgpt-mermaid-\_r_kg\_ .edgeLabel .label rect{opacity:1;rx:13px;ry:13px;fill:rgb(0, 14, 26);stroke:rgb(26, 62, 95);stroke-width:1px;}#chatgpt-mermaid-\_r_kg\_ .node rect,#chatgpt-mermaid-\_r_kg\_ .node circle,#chatgpt-mermaid-\_r_kg\_ .node ellipse,#chatgpt-mermaid-\_r_kg\_ .node polygon,#chatgpt-mermaid-\_r_kg\_ .node path{fill:rgb(0, 40, 77);stroke:rgba(255, 255, 255, 0.1);stroke-width:1px;}#chatgpt-mermaid-\_r_kg\_ .node rect{rx:16px;ry:16px;}#chatgpt-mermaid-\_r_kg\_ .node.mermaid-decision .label-container{fill:rgb(0, 14, 26);stroke:rgb(26, 62, 95);stroke-dasharray:2,2;}#chatgpt-mermaid-\_r_kg\_ .edgePaths .flowchart-link{stroke:rgb(175, 175, 175);stroke-width:1px;stroke-linecap:round;stroke-linejoin:round;}#chatgpt-mermaid-\_r_kg\_ .marker{fill:rgb(175, 175, 175);stroke:rgb(175, 175, 175);}#chatgpt-mermaid-\_r_kg\_ :root{--mermaid-font-family:-apple-system-body,ui-sans-serif,-apple-system,system-ui,"Segoe UI",Helvetica,"Apple Color Emoji",Arial,sans-serif,"Segoe UI Emoji","Segoe UI Symbol";}Flutter 카메라 또는 갤러리이미지 검증 및 전처리Ollama Cloud API 요청Gemma 4 멀티모달 분석음식 항목별 결과 추출응답 스키마 검증결과 유효성음식명 및 위치 검수제한된 재시도 또는 오류 안내영양 데이터 매칭중량 및 칼로리 계산사용자 편집 및 확정로컬 DB 식사 기록 저장일별 통계 및 대시보드유효오류

### 5.2 AI 분석 요청 데이터

이미지와 함께 다음과 같은 지시를 전달한다.

- 이미지에 나타난 음식 항목을 가능한 한 빠짐없이 식별한다.
- 접시나 그릇 단위로 구분 가능한 음식을 독립 항목으로 추출한다.
- 한식의 밥, 국, 찌개, 김치, 나물, 메인 요리를 구분한다.
- 음식마다 추정 중량과 불확실성을 제공한다.
- 사진에서 직접 확인 가능한 사실과 추정에 의한 정보를 구분한다.
- 확실하지 않은 음식은 후보 또는 미확인으로 표시한다.
- 식사 전체의 합계를 반환하더라도 앱에서 항목별로 다시 계산할 수 있도록 한다.
- 설명 문장만 출력하지 말고 사전에 정의한 JSON 스키마에 맞춰 응답한다.

### 5.3 분석 결과 JSON 스키마 예시

```
{
  "meal_type": "lunch",
  "currency": null,
  "foods": [
    {
      "item_id": "food-001",
      "name": "흰쌀밥",
      "category": "grain",
      "estimated_weight_g": 210,
      "estimated_calories_kcal": 315,
      "confidence": 0.93,
      "calorie_source": "estimated",
      "bbox": {
        "x": 0.05,
        "y": 0.1,
        "width": 0.35,
        "height": 0.3
      },
      "needs_review": false
    },
    {
      "item_id": "food-002",
      "name": "김치",
      "category": "side_dish",
      "estimated_weight_g": 35,
      "estimated_calories_kcal": 12,
      "confidence": 0.86,
      "calorie_source": "estimated",
      "bbox": {
        "x": 0.52,
        "y": 0.12,
        "width": 0.18,
        "height": 0.16
      },
      "needs_review": true
    }
  ],
  "total_calories_kcal": 327,
  "analysis_status": "needs_review"
}
```

이 JSON은 출력 계약을 설명하기 위한 예시다. 실제 결과의 숫자와 좌표를 검증된 값으로 간주해서는 안 된다. `bbox`는 원본 이미지 기준의 0\~1 정규화 좌표이며, 좌표를 신뢰할 수 없으면 `null`을 허용한다.

실제 구현에서는 JSON Schema 또는 이에 준하는 모델 검증기를 두고, 필수 필드, 자료형, 수치 범위, 항목 ID 중복, 잘못된 좌표, 칼로리 합계 불일치를 검사한다. JSON이 깨졌을 경우 제한적으로 재요청하고, 실패하면 사용자가 수동으로 입력할 수 있게 한다.

## 6. AI 프롬프트 설계

AI 프롬프트는 코드에 고정하지 않고 버전 관리 가능한 템플릿으로 분리한다.

### 6.1 기본 시스템 프롬프트

```
당신은 한국 음식 분석과 영양 정보 추정을 수행하는
멀티모달 음식 분석 엔진이다.

목표:
1. 입력 이미지에 보이는 음식 항목을 개별적으로 식별한다.
2. 밥, 국, 찌개, 메인 요리, 반찬, 소스, 음료를 구분한다.
3. 접시나 그릇 단위로 구별 가능한 음식을 각각 반환한다.
4. 각 음식의 표준 명칭 후보와 음식 분류를 제공한다.
5. 이미지에서 보이는 양을 근거로 섭취 중량을 추정한다.
6. 음식의 종류, 중량, 조리법에 따른 칼로리를 추정한다.
7. 확실하지 않은 정보는 추정 또는 미확인으로 표시한다.
8. 중복된 음식 항목을 생성하지 않는다.

제약:
- 사진에 보이지 않는 음식이나 재료를 확정하지 않는다.
- 정확한 중량을 측정한 것처럼 표현하지 않는다.
- 음식의 시각적 인식 신뢰도와 중량 추정의 신뢰도를 구분한다.
- 이미지에서 직접 확인한 정보와 추정 정보를 분리한다.
- 좌표는 이미지에서 실제로 식별 가능한 경우에만 반환한다.
- 사용자가 수정할 수 있도록 모든 음식 항목을 독립적으로 반환한다.
- 결과는 지정된 JSON 스키마에 맞춰 출력한다.
- JSON 외의 설명 문장은 출력하지 않는다.
```

### 6.2 다중 음식 인식 보강 규칙

한식 사진에서는 음식의 종류를 식별하는 것과 접시를 구분하는 것이 서로 다른 문제다. 다음 규칙을 추가한다.

- 밥그릇, 국그릇, 반찬 접시를 우선적으로 구분한다.
- 큰 접시에 여러 음식이 놓여 있다면 실제로 구분 가능한 항목만 분리한다.
- 동일한 반찬이 여러 곳에 보이면 서로 다른 제공량인지 중복 인식인지 확인한다.
- 국이나 찌개는 그릇 전체의 양과 실제 섭취량을 구분한다.
- 소스가 음식에 포함되어 있는지 별도 항목인지 명확히 한다.
- 사진의 시각적 크기만으로 정확한 중량을 단정하지 않는다.
- 식별할 수 없는 항목은 `unknown` 후보로 남긴다.

### 6.3 분석 품질 향상 전략

AI가 한 번에 모든 작업을 수행하게 하기보다 분석 단계를 분리한다.

\#chatgpt-mermaid-\_r_l6\_{font-family:-apple-system-body,ui-sans-serif,-apple-system,system-ui,"Segoe UI",Helvetica,"Apple Color Emoji",Arial,sans-serif,"Segoe UI Emoji","Segoe UI Symbol";font-size:16px;fill:rgb(237, 237, 237);}@keyframes edge-animation-frame{from{stroke-dashoffset:0;}}@keyframes dash{to{stroke-dashoffset:0;}}#chatgpt-mermaid-\_r_l6\_ .edge-animation-slow{stroke-dasharray:9,5!important;stroke-dashoffset:900;animation:dash 50s linear infinite;stroke-linecap:round;}#chatgpt-mermaid-\_r_l6\_ .edge-animation-fast{stroke-dasharray:9,5!important;stroke-dashoffset:900;animation:dash 20s linear infinite;stroke-linecap:round;}#chatgpt-mermaid-\_r_l6\_ .error-icon{fill:rgb(48, 48, 48);}#chatgpt-mermaid-\_r_l6\_ .error-text{fill:rgb(237, 237, 237);stroke:rgb(237, 237, 237);}#chatgpt-mermaid-\_r_l6\_ .edge-thickness-normal{stroke-width:1px;}#chatgpt-mermaid-\_r_l6\_ .edge-thickness-thick{stroke-width:3.5px;}#chatgpt-mermaid-\_r_l6\_ .edge-pattern-solid{stroke-dasharray:0;}#chatgpt-mermaid-\_r_l6\_ .edge-thickness-invisible{stroke-width:0;fill:none;}#chatgpt-mermaid-\_r_l6\_ .edge-pattern-dashed{stroke-dasharray:3;}#chatgpt-mermaid-\_r_l6\_ .edge-pattern-dotted{stroke-dasharray:2;}#chatgpt-mermaid-\_r_l6\_ .marker{fill:rgb(175, 175, 175);stroke:rgb(175, 175, 175);}#chatgpt-mermaid-\_r_l6\_ .marker.cross{stroke:rgb(175, 175, 175);}#chatgpt-mermaid-\_r_l6\_ svg{font-family:-apple-system-body,ui-sans-serif,-apple-system,system-ui,"Segoe UI",Helvetica,"Apple Color Emoji",Arial,sans-serif,"Segoe UI Emoji","Segoe UI Symbol";font-size:16px;}#chatgpt-mermaid-\_r_l6\_ p{margin:0;}#chatgpt-mermaid-\_r_l6\_ .label{font-family:-apple-system-body,ui-sans-serif,-apple-system,system-ui,"Segoe UI",Helvetica,"Apple Color Emoji",Arial,sans-serif,"Segoe UI Emoji","Segoe UI Symbol";color:rgb(237, 237, 237);}#chatgpt-mermaid-\_r_l6\_ .cluster-label text{fill:rgb(237, 237, 237);}#chatgpt-mermaid-\_r_l6\_ .cluster-label span{color:rgb(237, 237, 237);}#chatgpt-mermaid-\_r_l6\_ .cluster-label span p{background-color:transparent;}#chatgpt-mermaid-\_r_l6\_ .label text,#chatgpt-mermaid-\_r_l6\_ span{fill:rgb(237, 237, 237);color:rgb(237, 237, 237);}#chatgpt-mermaid-\_r_l6\_ .node rect,#chatgpt-mermaid-\_r_l6\_ .node circle,#chatgpt-mermaid-\_r_l6\_ .node ellipse,#chatgpt-mermaid-\_r_l6\_ .node polygon,#chatgpt-mermaid-\_r_l6\_ .node path{fill:rgb(9, 23, 44);stroke:rgb(31, 78, 148);stroke-width:1px;}#chatgpt-mermaid-\_r_l6\_ .rough-node .label text,#chatgpt-mermaid-\_r_l6\_ .node .label text,#chatgpt-mermaid-\_r_l6\_ .image-shape .label,#chatgpt-mermaid-\_r_l6\_ .icon-shape .label{text-anchor:middle;}#chatgpt-mermaid-\_r_l6\_ .node .katex path{fill:#000;stroke:#000;stroke-width:1px;}#chatgpt-mermaid-\_r_l6\_ .rough-node .label,#chatgpt-mermaid-\_r_l6\_ .node .label,#chatgpt-mermaid-\_r_l6\_ .image-shape .label,#chatgpt-mermaid-\_r_l6\_ .icon-shape .label{text-align:center;}#chatgpt-mermaid-\_r_l6\_ .node.clickable{cursor:pointer;}#chatgpt-mermaid-\_r_l6\_ .root .anchor path{fill:rgb(175, 175, 175)!important;stroke-width:0;stroke:rgb(175, 175, 175);}#chatgpt-mermaid-\_r_l6\_ .arrowheadPath{fill:rgb(175, 175, 175);}#chatgpt-mermaid-\_r_l6\_ .edgePath .path{stroke:rgb(175, 175, 175);stroke-width:1px;}#chatgpt-mermaid-\_r_l6\_ .flowchart-link{stroke:rgb(175, 175, 175);fill:none;}#chatgpt-mermaid-\_r_l6\_ .edgeLabel{background-color:rgb(0, 0, 0);text-align:center;}#chatgpt-mermaid-\_r_l6\_ .edgeLabel p{background-color:rgb(0, 0, 0);}#chatgpt-mermaid-\_r_l6\_ .edgeLabel rect{opacity:0.5;background-color:rgb(0, 0, 0);fill:rgb(0, 0, 0);}#chatgpt-mermaid-\_r_l6\_ .labelBkg{background-color:rgba(0, 0, 0, 0.5);}#chatgpt-mermaid-\_r_l6\_ .cluster rect{fill:rgb(48, 48, 48);stroke:rgba(255, 255, 255, 0.15);stroke-width:1px;}#chatgpt-mermaid-\_r_l6\_ .cluster text{fill:rgb(237, 237, 237);}#chatgpt-mermaid-\_r_l6\_ .cluster span{color:rgb(237, 237, 237);}#chatgpt-mermaid-\_r_l6\_ div.mermaidTooltip{position:absolute;text-align:center;max-width:200px;padding:2px;font-family:-apple-system-body,ui-sans-serif,-apple-system,system-ui,"Segoe UI",Helvetica,"Apple Color Emoji",Arial,sans-serif,"Segoe UI Emoji","Segoe UI Symbol";font-size:12px;background:rgb(48, 48, 48);border:1px solid rgba(255, 255, 255, 0.15);border-radius:2px;pointer-events:none;z-index:100;}#chatgpt-mermaid-\_r_l6\_ .flowchartTitleText{text-anchor:middle;font-size:18px;fill:rgb(237, 237, 237);}#chatgpt-mermaid-\_r_l6\_ rect.text{fill:none;stroke-width:0;}#chatgpt-mermaid-\_r_l6\_ .icon-shape,#chatgpt-mermaid-\_r_l6\_ .image-shape{background-color:rgb(0, 0, 0);text-align:center;}#chatgpt-mermaid-\_r_l6\_ .icon-shape p,#chatgpt-mermaid-\_r_l6\_ .image-shape p{background-color:rgb(0, 0, 0);padding:2px;}#chatgpt-mermaid-\_r_l6\_ .icon-shape .label rect,#chatgpt-mermaid-\_r_l6\_ .image-shape .label rect{opacity:0.5;background-color:rgb(0, 0, 0);fill:rgb(0, 0, 0);}#chatgpt-mermaid-\_r_l6\_ .label-icon{display:inline-block;height:1em;overflow:visible;vertical-align:-0.125em;}#chatgpt-mermaid-\_r_l6\_ .node .label-icon path{fill:currentColor;stroke:revert;stroke-width:revert;}#chatgpt-mermaid-\_r_l6\_ .node .neo-node{stroke:rgb(31, 78, 148);}#chatgpt-mermaid-\_r_l6\_ [data-look="neo"].node rect,#chatgpt-mermaid-\_r_l6\_ [data-look="neo"].cluster rect,#chatgpt-mermaid-\_r_l6\_ [data-look="neo"].node polygon{stroke:url(#chatgpt-mermaid-\_r_l6\_-gradient);filter:drop-shadow( 1px 2px 2px rgba(185,185,185,1));}#chatgpt-mermaid-\_r_l6\_ [data-look="neo"].swimlane.cluster rect{filter:none;}#chatgpt-mermaid-\_r_l6\_ [data-look="neo"].node path{stroke:url(#chatgpt-mermaid-\_r_l6\_-gradient);stroke-width:1px;}#chatgpt-mermaid-\_r_l6\_ [data-look="neo"].node .outer-path{filter:drop-shadow( 1px 2px 2px rgba(185,185,185,1));}#chatgpt-mermaid-\_r_l6\_ [data-look="neo"].node .neo-line path{stroke:rgb(31, 78, 148);filter:none;}#chatgpt-mermaid-\_r_l6\_ [data-look="neo"].node circle{stroke:url(#chatgpt-mermaid-\_r_l6\_-gradient);filter:drop-shadow( 1px 2px 2px rgba(185,185,185,1));}#chatgpt-mermaid-\_r_l6\_ [data-look="neo"].node circle .state-start{fill:#000000;}#chatgpt-mermaid-\_r_l6\_ [data-look="neo"].icon-shape .icon{fill:url(#chatgpt-mermaid-\_r_l6\_-gradient);filter:drop-shadow( 1px 2px 2px rgba(185,185,185,1));}#chatgpt-mermaid-\_r_l6\_ [data-look="neo"].icon-shape .icon-neo path{stroke:url(#chatgpt-mermaid-\_r_l6\_-gradient);filter:drop-shadow( 1px 2px 2px rgba(185,185,185,1));}#chatgpt-mermaid-\_r_l6\_ .node text{font-size:14px;font-weight:600;letter-spacing:normal;fill:rgb(153, 206, 255);}#chatgpt-mermaid-\_r_l6\_ .edgeLabels text{font-size:13px;font-weight:600;letter-spacing:-0.08px;fill:rgb(153, 206, 255);}#chatgpt-mermaid-\_r_l6\_ .node tspan[font-weight="normal"],#chatgpt-mermaid-\_r_l6\_ .edgeLabels tspan[font-weight="normal"]{font-weight:600;}#chatgpt-mermaid-\_r_l6\_ .edgeLabel .label rect{opacity:1;rx:13px;ry:13px;fill:rgb(0, 14, 26);stroke:rgb(26, 62, 95);stroke-width:1px;}#chatgpt-mermaid-\_r_l6\_ .node rect,#chatgpt-mermaid-\_r_l6\_ .node circle,#chatgpt-mermaid-\_r_l6\_ .node ellipse,#chatgpt-mermaid-\_r_l6\_ .node polygon,#chatgpt-mermaid-\_r_l6\_ .node path{fill:rgb(0, 40, 77);stroke:rgba(255, 255, 255, 0.1);stroke-width:1px;}#chatgpt-mermaid-\_r_l6\_ .node rect{rx:16px;ry:16px;}#chatgpt-mermaid-\_r_l6\_ .node.mermaid-decision .label-container{fill:rgb(0, 14, 26);stroke:rgb(26, 62, 95);stroke-dasharray:2,2;}#chatgpt-mermaid-\_r_l6\_ .edgePaths .flowchart-link{stroke:rgb(175, 175, 175);stroke-width:1px;stroke-linecap:round;stroke-linejoin:round;}#chatgpt-mermaid-\_r_l6\_ .marker{fill:rgb(175, 175, 175);stroke:rgb(175, 175, 175);}#chatgpt-mermaid-\_r_l6\_ :root{--mermaid-font-family:-apple-system-body,ui-sans-serif,-apple-system,system-ui,"Segoe UI",Helvetica,"Apple Color Emoji",Arial,sans-serif,"Segoe UI Emoji","Segoe UI Symbol";}원본 식사 이미지1단계: 음식 후보 탐지2단계: 음식명 및 접시 구분3단계: 중량 추정4단계: 영양 데이터 매칭5단계: 칼로리 계산6단계: 결과 검증검수 필요 여부결과 표시사용자 확인낮은 불확실성높은 불확실성

여기서 여러 단계가 반드시 각각 별도의 API 호출을 의미하지는 않는다. 우선 단일 호출로 음식 후보를 추출하고, 불확실하거나 중요한 항목에 한해 추가 호출을 수행한다. 호출 수와 지연 시간, 비용, 인식 품질을 측정해 처리 전략을 조정한다.

## 7. 화면 설계

### 7.1 홈 대시보드

[AI Powered Food Calorie Tracker App by Abu Hossain on Dribbble](https://images.openai.com/static-rsc-4/_VUjgXxdZNZDX2oKqRizR-ldUadBORhmYU-XGkSTpF6SiGbRbJmJHIjDRVB6XAWb2fbpwx4ISuL7DdFSvfqguAKLQJVC9J2xflUdkwHLxRjz4oQI_WM-Sn0llsvODQHm03J5Jo64XN1KQgNWmwPmkEJMv__1P5SJPq8Dcu4lq64?purpose=inline)

주요 구성:

- 오늘 섭취 칼로리와 일일 목표
- 아침·점심·저녁·간식별 열량
- 음식 촬영 버튼
- 최근 식사 기록
- 일일 영양소 요약
- 주간 칼로리 변화 차트
- 식사 기록이 없는 날짜에 대한 입력 안내

대시보드의 총열량은 확정된 식사 기록을 기준으로 집계한다. AI 분석이 진행 중인 데이터는 확정 기록과 시각적으로 구분한다.

### 7.2 음식 촬영 화면

[Foody-AI — The world's first batch meal scan](https://images.openai.com/static-rsc-4/iI-CK-D37hgzdlbHx50YLb5D7R0l7FzGBIyOKhW2TA0DoMBuXHo2lZ1cy8mZFZs0t_Gi5ohAKuywJfYJ7S_KplCZLG6yisdYgTmy52A7sy_rYDYKiTtUUOPvRbPotg3hLxs1Q3xmncwFSxO9D_h9n99vw6OEzOVRPbFLUUaeOY8?purpose=inline)

- 카메라 미리보기
- 촬영 버튼과 갤러리 버튼
- 식사 유형 선택
- 촬영 가이드 오버레이
- 재촬영 및 이미지 교체
- 다중 이미지 추가
- 분석 시작 및 취소

촬영 가이드는 음식이 프레임 안에 들어오도록 안내한다. 음식의 위치가 겹치거나 접시가 잘린 경우 재촬영을 권장한다.

### 7.3 분석 결과 화면

[두잉랩, 인공지능 음식 인식 솔루션 ‘푸드렌즈’ API 플랫폼 오픈 - 뉴스와이어](https://images.openai.com/static-rsc-4/gW8DUFqUFb4s-5-_ECzVKTCV1yI0VpVTXyLtQbIFkcbroqHeI22A5_uOvheNLFHyZ3ZRSVHD1-biXJ2BKWV3vMdGeXAVProJDDRk9eIo7zUQn_wSVpyqYENynZdZaQGuZdD_FVwlJiCD8_u5gsXzNRBCNg5o9YCGzGV65IE4ROo?purpose=inline)

화면은 사진 영역과 음식 목록 영역으로 구성한다.

- 사진 위 음식별 영역 표시
- 각 항목의 음식명 및 추정 열량
- 추정 중량과 신뢰도
- 영양 데이터 출처
- 음식 수정·삭제·추가
- 전체 식사 칼로리 실시간 재계산
- 확인 필요 항목 표시
- 최종 저장 버튼

사용자가 음식 항목을 선택하면 사진 위의 해당 영역을 강조한다. 음식명이 바뀌거나 중량이 수정되면 총열량을 즉시 다시 계산한다.

### 7.4 식사 상세 화면

- 식사 사진 및 촬영 시각
- 음식별 칼로리와 중량
- 탄수화물·단백질·지방
- AI 추정값과 사용자 확정값 구분
- 식사 기록 수정 및 삭제
- 이전 분석 결과와 수정 이력
- 같은 음식의 과거 기록 불러오기

### 7.5 통계 및 리포트 화면

- 일별·주별·월별 총열량
- 식사 유형별 평균 열량
- 음식 분류별 섭취 비중
- 탄수화물·단백질·지방 섭취 추이
- 목표 대비 섭취량
- 자주 먹는 음식 순위
- 날짜 범위별 식사 기록 검색
- CSV 형식의 기록 내보내기

영양소 값이 없는 음식은 통계에서 0으로 간주하지 않고, 데이터가 없는 상태로 구분한다.

## 8. 데이터 모델

로컬 SQLite 데이터베이스는 다음 엔티티를 중심으로 설계한다.

| 엔티티                   | 주요 필드                                                     | 역할          |
| --------------------- | --------------------------------------------------------- | ----------- |
| Meal                  | id, mealType, consumedAt, status, totalCalories           | 식사 기록       |
| MealImage             | id, mealId, localPath, imageHash                          | 식사 이미지      |
| FoodItem              | id, mealId, foodName, category, weightGrams               | 개별 음식       |
| NutritionInfo         | id, foodCode, standardName, caloriesPer100g               | 표준 영양 정보    |
| FoodNutritionSnapshot | foodItemId, calories, carbs, protein, fat, source         | 기록 당시 영양값   |
| AIAnalysis            | id, mealId, modelId, promptVersion, status                | 분석 실행 기록    |
| AIAnalysisItem        | id, analysisId, foodName, confidence, bboxJson            | AI 원본 분석 항목 |
| FoodEditHistory       | id, foodItemId, fieldName, oldValue, newValue             | 사용자 수정 이력   |
| DailyGoal             | date, calorieTarget, carbTarget, proteinTarget, fatTarget | 일일 목표       |
| AppSettings           | key, value, updatedAt                                     | 앱 설정        |

데이터 모델 설계 원칙:

- 식사와 음식 항목은 일대다 관계로 관리한다.
- AI 원본 응답과 최종 확정 데이터를 분리한다.
- 식사 당시 사용한 영양값을 스냅샷으로 보존한다.
- 영양 데이터베이스가 갱신되어도 과거 기록이 임의로 변경되지 않게 한다.
- 이미지 경로와 데이터베이스 레코드의 정합성을 유지한다.
- 분석 요청 ID를 사용해 중복 저장을 방지한다.
- 음식 삭제 시 관련 이력과 데이터 보존 정책을 일관되게 적용한다.
- 데이터베이스 스키마 변경은 버전 기반 마이그레이션으로 처리한다.

## 9. 주요 처리 시퀀스

### 9.1 식사 사진 분석

SQLite결과 검증기Ollama Cloud이미지 처리기Flutter 앱SQLite결과 검증기Ollama Cloud이미지 처리기Flutter 앱#chatgpt-mermaid-\_r_m4\_{font-family:-apple-system-body,ui-sans-serif,-apple-system,system-ui,"Segoe UI",Helvetica,"Apple Color Emoji",Arial,sans-serif,"Segoe UI Emoji","Segoe UI Symbol";font-size:16px;fill:rgb(237, 237, 237);}@keyframes edge-animation-frame{from{stroke-dashoffset:0;}}@keyframes dash{to{stroke-dashoffset:0;}}#chatgpt-mermaid-\_r_m4\_ .edge-animation-slow{stroke-dasharray:9,5!important;stroke-dashoffset:900;animation:dash 50s linear infinite;stroke-linecap:round;}#chatgpt-mermaid-\_r_m4\_ .edge-animation-fast{stroke-dasharray:9,5!important;stroke-dashoffset:900;animation:dash 20s linear infinite;stroke-linecap:round;}#chatgpt-mermaid-\_r_m4\_ .error-icon{fill:rgb(48, 48, 48);}#chatgpt-mermaid-\_r_m4\_ .error-text{fill:rgb(237, 237, 237);stroke:rgb(237, 237, 237);}#chatgpt-mermaid-\_r_m4\_ .edge-thickness-normal{stroke-width:1px;}#chatgpt-mermaid-\_r_m4\_ .edge-thickness-thick{stroke-width:3.5px;}#chatgpt-mermaid-\_r_m4\_ .edge-pattern-solid{stroke-dasharray:0;}#chatgpt-mermaid-\_r_m4\_ .edge-thickness-invisible{stroke-width:0;fill:none;}#chatgpt-mermaid-\_r_m4\_ .edge-pattern-dashed{stroke-dasharray:3;}#chatgpt-mermaid-\_r_m4\_ .edge-pattern-dotted{stroke-dasharray:2;}#chatgpt-mermaid-\_r_m4\_ .marker{fill:rgb(175, 175, 175);stroke:rgb(175, 175, 175);}#chatgpt-mermaid-\_r_m4\_ .marker.cross{stroke:rgb(175, 175, 175);}#chatgpt-mermaid-\_r_m4\_ svg{font-family:-apple-system-body,ui-sans-serif,-apple-system,system-ui,"Segoe UI",Helvetica,"Apple Color Emoji",Arial,sans-serif,"Segoe UI Emoji","Segoe UI Symbol";font-size:16px;}#chatgpt-mermaid-\_r_m4\_ p{margin:0;}#chatgpt-mermaid-\_r_m4\_ .actor{stroke:rgb(31, 78, 148);fill:rgb(9, 23, 44);stroke-width:1;}#chatgpt-mermaid-\_r_m4\_ rect.actor.outer-path[data-look="neo"]{filter:drop-shadow( 1px 2px 2px rgba(185,185,185,1));}#chatgpt-mermaid-\_r_m4\_ rect.note[data-look="neo"]{stroke:rgb(58, 132, 63);fill:rgb(48, 48, 48);filter:drop-shadow( 1px 2px 2px rgba(185,185,185,1));}#chatgpt-mermaid-\_r_m4\_ text.actor>tspan{fill:rgb(237, 237, 237);stroke:none;}#chatgpt-mermaid-\_r_m4\_ .actor-line{stroke:rgb(175, 175, 175);}#chatgpt-mermaid-\_r_m4\_ .innerArc{stroke-width:1.5;stroke-dasharray:none;}#chatgpt-mermaid-\_r_m4\_ .messageLine0{stroke-width:1.5;stroke-dasharray:none;stroke:rgb(175, 175, 175);}#chatgpt-mermaid-\_r_m4\_ .messageLine1{stroke-width:1.5;stroke-dasharray:2,2;stroke:rgb(175, 175, 175);}#chatgpt-mermaid-\_r_m4\_ [id$="-arrowhead"] path{fill:rgb(175, 175, 175);stroke:rgb(175, 175, 175);}#chatgpt-mermaid-\_r_m4\_ .sequenceNumber{fill:#505050;}#chatgpt-mermaid-\_r_m4\_ [id$="-sequencenumber"]{fill:rgb(175, 175, 175);}#chatgpt-mermaid-\_r_m4\_ [id$="-crosshead"] path{fill:rgb(175, 175, 175);stroke:rgb(175, 175, 175);}#chatgpt-mermaid-\_r_m4\_ .messageText{fill:rgb(237, 237, 237);stroke:none;}#chatgpt-mermaid-\_r_m4\_ .labelBox{stroke:rgba(255, 255, 255, 0.15);fill:rgb(0, 0, 0);filter:none;}#chatgpt-mermaid-\_r_m4\_ .labelText,#chatgpt-mermaid-\_r_m4\_ .labelText>tspan{fill:rgb(237, 237, 237);stroke:none;}#chatgpt-mermaid-\_r_m4\_ .loopText,#chatgpt-mermaid-\_r_m4\_ .loopText>tspan{fill:rgb(237, 237, 237);stroke:none;}#chatgpt-mermaid-\_r_m4\_ .sectionTitle,#chatgpt-mermaid-\_r_m4\_ .sectionTitle>tspan{fill:rgb(237, 237, 237);stroke:none;}#chatgpt-mermaid-\_r_m4\_ .loopLine{stroke-width:2px;stroke-dasharray:2,2;stroke:rgba(255, 255, 255, 0.15);fill:rgba(255, 255, 255, 0.15);}#chatgpt-mermaid-\_r_m4\_ .note{stroke:rgb(58, 132, 63);fill:rgb(48, 48, 48);}#chatgpt-mermaid-\_r_m4\_ .noteText,#chatgpt-mermaid-\_r_m4\_ .noteText>tspan{fill:rgb(237, 237, 237);stroke:none;font-weight:normal;}#chatgpt-mermaid-\_r_m4\_ .activation0{fill:rgb(48, 48, 48);stroke:hsl(0, 0%, 8.8235294118%);}#chatgpt-mermaid-\_r_m4\_ .activation1{fill:rgb(48, 48, 48);stroke:hsl(0, 0%, 8.8235294118%);}#chatgpt-mermaid-\_r_m4\_ .activation2{fill:rgb(48, 48, 48);stroke:hsl(0, 0%, 8.8235294118%);}#chatgpt-mermaid-\_r_m4\_ .actorPopupMenu{position:absolute;}#chatgpt-mermaid-\_r_m4\_ .actorPopupMenuPanel{position:absolute;fill:rgb(9, 23, 44);box-shadow:0px 8px 16px 0px rgba(0,0,0,0.2);filter:drop-shadow(3px 5px 2px rgb(0 0 0 / 0.4));}#chatgpt-mermaid-\_r_m4\_ .actor-man circle,#chatgpt-mermaid-\_r_m4\_ line{fill:rgb(9, 23, 44);stroke-width:2px;}#chatgpt-mermaid-\_r_m4\_ g rect.rect{filter:drop-shadow( 1px 2px 2px rgba(185,185,185,1));stroke:rgb(31, 78, 148);}#chatgpt-mermaid-\_r_m4\_ .node .neo-node{stroke:rgb(31, 78, 148);}#chatgpt-mermaid-\_r_m4\_ [data-look="neo"].node rect,#chatgpt-mermaid-\_r_m4\_ [data-look="neo"].cluster rect,#chatgpt-mermaid-\_r_m4\_ [data-look="neo"].node polygon{stroke:url(#chatgpt-mermaid-\_r_m4\_-gradient);filter:drop-shadow( 1px 2px 2px rgba(185,185,185,1));}#chatgpt-mermaid-\_r_m4\_ [data-look="neo"].swimlane.cluster rect{filter:none;}#chatgpt-mermaid-\_r_m4\_ [data-look="neo"].node path{stroke:url(#chatgpt-mermaid-\_r_m4\_-gradient);stroke-width:1px;}#chatgpt-mermaid-\_r_m4\_ [data-look="neo"].node .outer-path{filter:drop-shadow( 1px 2px 2px rgba(185,185,185,1));}#chatgpt-mermaid-\_r_m4\_ [data-look="neo"].node .neo-line path{stroke:rgb(31, 78, 148);filter:none;}#chatgpt-mermaid-\_r_m4\_ [data-look="neo"].node circle{stroke:url(#chatgpt-mermaid-\_r_m4\_-gradient);filter:drop-shadow( 1px 2px 2px rgba(185,185,185,1));}#chatgpt-mermaid-\_r_m4\_ [data-look="neo"].node circle .state-start{fill:#000000;}#chatgpt-mermaid-\_r_m4\_ [data-look="neo"].icon-shape .icon{fill:url(#chatgpt-mermaid-\_r_m4\_-gradient);filter:drop-shadow( 1px 2px 2px rgba(185,185,185,1));}#chatgpt-mermaid-\_r_m4\_ [data-look="neo"].icon-shape .icon-neo path{stroke:url(#chatgpt-mermaid-\_r_m4\_-gradient);filter:drop-shadow( 1px 2px 2px rgba(185,185,185,1));}#chatgpt-mermaid-\_r_m4\_ :root{--mermaid-font-family:-apple-system-body,ui-sans-serif,-apple-system,system-ui,"Segoe UI",Helvetica,"Apple Color Emoji",Arial,sans-serif,"Segoe UI Emoji","Segoe UI Symbol";}사용자사진 촬영이미지 검증 및 압축분석용 이미지이미지 + 분석 프롬프트음식 분석 JSON스키마 및 값 검증검증된 음식 목록분석 원본 저장음식별 결과 표시음식명 및 중량 수정열량 재계산식사 확정최종 식사 기록 저장저장 완료 및 총열량 표시사용자

### 9.2 음식별 칼로리 계산

SQLite영양 정보 저장소칼로리 계산기결과 화면SQLite영양 정보 저장소칼로리 계산기결과 화면#chatgpt-mermaid-\_r_md\_{font-family:-apple-system-body,ui-sans-serif,-apple-system,system-ui,"Segoe UI",Helvetica,"Apple Color Emoji",Arial,sans-serif,"Segoe UI Emoji","Segoe UI Symbol";font-size:16px;fill:rgb(237, 237, 237);}@keyframes edge-animation-frame{from{stroke-dashoffset:0;}}@keyframes dash{to{stroke-dashoffset:0;}}#chatgpt-mermaid-\_r_md\_ .edge-animation-slow{stroke-dasharray:9,5!important;stroke-dashoffset:900;animation:dash 50s linear infinite;stroke-linecap:round;}#chatgpt-mermaid-\_r_md\_ .edge-animation-fast{stroke-dasharray:9,5!important;stroke-dashoffset:900;animation:dash 20s linear infinite;stroke-linecap:round;}#chatgpt-mermaid-\_r_md\_ .error-icon{fill:rgb(48, 48, 48);}#chatgpt-mermaid-\_r_md\_ .error-text{fill:rgb(237, 237, 237);stroke:rgb(237, 237, 237);}#chatgpt-mermaid-\_r_md\_ .edge-thickness-normal{stroke-width:1px;}#chatgpt-mermaid-\_r_md\_ .edge-thickness-thick{stroke-width:3.5px;}#chatgpt-mermaid-\_r_md\_ .edge-pattern-solid{stroke-dasharray:0;}#chatgpt-mermaid-\_r_md\_ .edge-thickness-invisible{stroke-width:0;fill:none;}#chatgpt-mermaid-\_r_md\_ .edge-pattern-dashed{stroke-dasharray:3;}#chatgpt-mermaid-\_r_md\_ .edge-pattern-dotted{stroke-dasharray:2;}#chatgpt-mermaid-\_r_md\_ .marker{fill:rgb(175, 175, 175);stroke:rgb(175, 175, 175);}#chatgpt-mermaid-\_r_md\_ .marker.cross{stroke:rgb(175, 175, 175);}#chatgpt-mermaid-\_r_md\_ svg{font-family:-apple-system-body,ui-sans-serif,-apple-system,system-ui,"Segoe UI",Helvetica,"Apple Color Emoji",Arial,sans-serif,"Segoe UI Emoji","Segoe UI Symbol";font-size:16px;}#chatgpt-mermaid-\_r_md\_ p{margin:0;}#chatgpt-mermaid-\_r_md\_ .actor{stroke:rgb(31, 78, 148);fill:rgb(9, 23, 44);stroke-width:1;}#chatgpt-mermaid-\_r_md\_ rect.actor.outer-path[data-look="neo"]{filter:drop-shadow( 1px 2px 2px rgba(185,185,185,1));}#chatgpt-mermaid-\_r_md\_ rect.note[data-look="neo"]{stroke:rgb(58, 132, 63);fill:rgb(48, 48, 48);filter:drop-shadow( 1px 2px 2px rgba(185,185,185,1));}#chatgpt-mermaid-\_r_md\_ text.actor>tspan{fill:rgb(237, 237, 237);stroke:none;}#chatgpt-mermaid-\_r_md\_ .actor-line{stroke:rgb(175, 175, 175);}#chatgpt-mermaid-\_r_md\_ .innerArc{stroke-width:1.5;stroke-dasharray:none;}#chatgpt-mermaid-\_r_md\_ .messageLine0{stroke-width:1.5;stroke-dasharray:none;stroke:rgb(175, 175, 175);}#chatgpt-mermaid-\_r_md\_ .messageLine1{stroke-width:1.5;stroke-dasharray:2,2;stroke:rgb(175, 175, 175);}#chatgpt-mermaid-\_r_md\_ [id$="-arrowhead"] path{fill:rgb(175, 175, 175);stroke:rgb(175, 175, 175);}#chatgpt-mermaid-\_r_md\_ .sequenceNumber{fill:#505050;}#chatgpt-mermaid-\_r_md\_ [id$="-sequencenumber"]{fill:rgb(175, 175, 175);}#chatgpt-mermaid-\_r_md\_ [id$="-crosshead"] path{fill:rgb(175, 175, 175);stroke:rgb(175, 175, 175);}#chatgpt-mermaid-\_r_md\_ .messageText{fill:rgb(237, 237, 237);stroke:none;}#chatgpt-mermaid-\_r_md\_ .labelBox{stroke:rgba(255, 255, 255, 0.15);fill:rgb(0, 0, 0);filter:none;}#chatgpt-mermaid-\_r_md\_ .labelText,#chatgpt-mermaid-\_r_md\_ .labelText>tspan{fill:rgb(237, 237, 237);stroke:none;}#chatgpt-mermaid-\_r_md\_ .loopText,#chatgpt-mermaid-\_r_md\_ .loopText>tspan{fill:rgb(237, 237, 237);stroke:none;}#chatgpt-mermaid-\_r_md\_ .sectionTitle,#chatgpt-mermaid-\_r_md\_ .sectionTitle>tspan{fill:rgb(237, 237, 237);stroke:none;}#chatgpt-mermaid-\_r_md\_ .loopLine{stroke-width:2px;stroke-dasharray:2,2;stroke:rgba(255, 255, 255, 0.15);fill:rgba(255, 255, 255, 0.15);}#chatgpt-mermaid-\_r_md\_ .note{stroke:rgb(58, 132, 63);fill:rgb(48, 48, 48);}#chatgpt-mermaid-\_r_md\_ .noteText,#chatgpt-mermaid-\_r_md\_ .noteText>tspan{fill:rgb(237, 237, 237);stroke:none;font-weight:normal;}#chatgpt-mermaid-\_r_md\_ .activation0{fill:rgb(48, 48, 48);stroke:hsl(0, 0%, 8.8235294118%);}#chatgpt-mermaid-\_r_md\_ .activation1{fill:rgb(48, 48, 48);stroke:hsl(0, 0%, 8.8235294118%);}#chatgpt-mermaid-\_r_md\_ .activation2{fill:rgb(48, 48, 48);stroke:hsl(0, 0%, 8.8235294118%);}#chatgpt-mermaid-\_r_md\_ .actorPopupMenu{position:absolute;}#chatgpt-mermaid-\_r_md\_ .actorPopupMenuPanel{position:absolute;fill:rgb(9, 23, 44);box-shadow:0px 8px 16px 0px rgba(0,0,0,0.2);filter:drop-shadow(3px 5px 2px rgb(0 0 0 / 0.4));}#chatgpt-mermaid-\_r_md\_ .actor-man circle,#chatgpt-mermaid-\_r_md\_ line{fill:rgb(9, 23, 44);stroke-width:2px;}#chatgpt-mermaid-\_r_md\_ g rect.rect{filter:drop-shadow( 1px 2px 2px rgba(185,185,185,1));stroke:rgb(31, 78, 148);}#chatgpt-mermaid-\_r_md\_ .node .neo-node{stroke:rgb(31, 78, 148);}#chatgpt-mermaid-\_r_md\_ [data-look="neo"].node rect,#chatgpt-mermaid-\_r_md\_ [data-look="neo"].cluster rect,#chatgpt-mermaid-\_r_md\_ [data-look="neo"].node polygon{stroke:url(#chatgpt-mermaid-\_r_md\_-gradient);filter:drop-shadow( 1px 2px 2px rgba(185,185,185,1));}#chatgpt-mermaid-\_r_md\_ [data-look="neo"].swimlane.cluster rect{filter:none;}#chatgpt-mermaid-\_r_md\_ [data-look="neo"].node path{stroke:url(#chatgpt-mermaid-\_r_md\_-gradient);stroke-width:1px;}#chatgpt-mermaid-\_r_md\_ [data-look="neo"].node .outer-path{filter:drop-shadow( 1px 2px 2px rgba(185,185,185,1));}#chatgpt-mermaid-\_r_md\_ [data-look="neo"].node .neo-line path{stroke:rgb(31, 78, 148);filter:none;}#chatgpt-mermaid-\_r_md\_ [data-look="neo"].node circle{stroke:url(#chatgpt-mermaid-\_r_md\_-gradient);filter:drop-shadow( 1px 2px 2px rgba(185,185,185,1));}#chatgpt-mermaid-\_r_md\_ [data-look="neo"].node circle .state-start{fill:#000000;}#chatgpt-mermaid-\_r_md\_ [data-look="neo"].icon-shape .icon{fill:url(#chatgpt-mermaid-\_r_md\_-gradient);filter:drop-shadow( 1px 2px 2px rgba(185,185,185,1));}#chatgpt-mermaid-\_r_md\_ [data-look="neo"].icon-shape .icon-neo path{stroke:url(#chatgpt-mermaid-\_r_md\_-gradient);filter:drop-shadow( 1px 2px 2px rgba(185,185,185,1));}#chatgpt-mermaid-\_r_md\_ :root{--mermaid-font-family:-apple-system-body,ui-sans-serif,-apple-system,system-ui,"Segoe UI",Helvetica,"Apple Color Emoji",Arial,sans-serif,"Segoe UI Emoji","Segoe UI Symbol";}음식명 및 섭취량 전달표준 음식 정보 조회음식 코드 검색영양 데이터 후보매칭 결과 및 출처중량 기준 열량 계산음식별 합계 재계산칼로리 및 영양소 결과화면 갱신

## 10. Ollama Cloud 연동 구현 기준

### 10.1 API 통신

- Ollama Cloud의 공식 API를 통해 이미지와 프롬프트를 전달한다.
- HTTPS와 Bearer 인증을 사용한다.
- 모델 ID, API 기본 URL, 타임아웃, 최대 응답 크기를 설정으로 분리한다.
- 이미지 데이터는 요청 규격에 맞춰 Base64 등으로 인코딩한다.
- 요청마다 고유한 분석 ID를 부여한다.
- 요청 및 응답 처리 시간을 기록한다.
- API 키는 소스 코드, 로그, 분석 결과에 노출하지 않는다.
- API 오류와 모델 응답 오류를 서로 구분한다.

Ollama의 Cloud API는 이미지 지원 모델을 사용할 수 있으며, 공식 문서는 `https://ollama.com/api/chat` 형태의 요청과 Bearer 인증을 안내한다. 실제 요청 본문과 모델 ID는 배포 시 공식 API 규격에 맞춰 검증한다.&#x20;

[image](https://www.google.com/s2/favicons?domain=https://ollama.com\&sz=32)

Ollama

+1

### 10.2 모델 설정

설정 화면에서 다음 값을 관리한다.

- API 기본 URL
- API 키
- 모델 ID
- 요청 타임아웃
- 이미지 최대 크기
- 분석 상세 수준
- 재시도 횟수
- 결과 보관 정책

API 키는 OS 보안 저장소에 저장한다. 설정 화면에는 키의 일부만 마스킹해 표시하며, 로그에는 키나 Base64 이미지가 포함되지 않도록 한다.

배포 환경에서 API 키를 앱에 직접 포함하는 구성은 피한다. 개인용 모드에서 사용자가 직접 입력한 키를 보관하더라도, 앱을 분석할 수 있는 사용자가 키를 추출할 위험은 남는다.

### 10.3 오류 처리 정책

| 오류 유형        | 처리                    |
| ------------ | --------------------- |
| 네트워크 단절      | 사용자 안내 및 수동 재시도       |
| 요청 타임아웃      | 진행 상태 종료, 재시도 선택      |
| HTTP 401·403 | 인증 및 권한 설정 확인 안내      |
| HTTP 429     | 요청 제한에 따른 대기 및 재시도    |
| 서버 오류        | 제한된 재시도 후 실패 상태 저장    |
| 잘못된 JSON     | 응답 검증 실패 처리 및 제한적 재요청 |
| 이미지 입력 오류    | 형식·크기 검증 후 재촬영 안내     |
| 모델 응답이 비어 있음 | 빈 결과 저장 방지 및 오류 표시    |
| 앱 종료 또는 재시작  | 미완료 분석 복구 또는 안전한 취소   |

재시도는 무제한으로 수행하지 않는다. 동일 분석의 중복 요청과 중복 저장을 방지하고, 사용자에게 분석 비용이 발생할 수 있음을 표시한다.

## 11. 영양 정보 및 건강 관리 기능

### 11.1 영양소 분석

칼로리뿐 아니라 탄수화물, 단백질, 지방, 식이섬유, 나트륨 등 주요 영양소를 관리한다.

- 음식별 영양소 추정 및 조회
- 식사별 영양소 합계
- 일일 영양 목표 설정
- 목표 대비 섭취 현황
- 주간 평균 섭취량
- 영양소 정보가 없는 음식의 별도 표시

영양소 데이터는 가능한 한 검증된 영양 데이터베이스에서 가져온다. AI가 영양소 값을 추정한 경우에는 출처와 불확실성을 구분한다.

### 11.2 일일 목표 관리

사용자가 일일 열량 목표를 직접 설정할 수 있어야 한다.

- 하루 목표 칼로리
- 탄수화물·단백질·지방 목표
- 식사별 목표 배분
- 목표 대비 섭취량
- 목표 초과 또는 미달 알림
- 일주일간 섭취 추이

체중, 키, 나이, 활동량 등의 정보를 이용한 목표 추천은 선택 기능으로 제공한다. 추천값과 사용자가 직접 설정한 값을 구분하고, 의학적 진단이나 치료를 대신하는 기능으로 설계하지 않는다.

### 11.3 음식 기록 재사용

자주 먹는 음식과 식사 구성을 저장해 반복 입력을 줄인다.

- 즐겨찾는 음식
- 자주 먹는 반찬
- 자주 먹는 식사 조합
- 이전 식사 복사
- 최근 사용한 음식명 자동완성
- 직접 등록한 음식과 영양 정보

반복 식사는 이전 기록을 복사하되, 실제 섭취량이 달라질 수 있으므로 복사 후 수정할 수 있게 한다.

## 12. 앱 설정 및 관리 기능

- Ollama Cloud 연결 테스트
- 모델 ID 조회 및 변경
- 이미지 처리 품질 설정
- AI 응답 상세 수준 설정
- 일일 칼로리 목표 설정
- 식사 유형별 알림 설정
- 데이터 백업 및 복원
- 분석 기록 삭제
- 전체 식사 데이터 삭제
- CSV 내보내기
- 앱 버전 및 라이선스 정보

API 키가 잘못되었거나 모델이 이미지 입력을 지원하지 않는 경우, 연결 테스트에서 명확한 오류를 보여준다.

## 13. 보안 및 개인정보 보호

- 식사 이미지와 식사 기록은 기본적으로 앱 내부에 저장한다.
- 이미지 분석 시 사진이 Ollama Cloud로 전송된다는 사실을 안내한다.
- 분석 요청에 불필요한 개인정보를 포함하지 않는다.
- API 키를 소스 코드와 로그에 기록하지 않는다.
- 앱 내 로컬 데이터는 삭제할 수 있어야 한다.
- 이미지 파일과 데이터베이스의 삭제 정책을 일관되게 유지한다.
- 앱 로그에는 음식 분석 결과 전체나 이미지 원문을 기본적으로 기록하지 않는다.
- API 요청 오류에는 사용자에게 필요한 정보만 노출한다.
- 사용자가 원할 경우 사진 원본을 삭제하고 식사 기록만 보존할 수 있게 한다.
- 백업 파일을 생성하는 경우 민감한 데이터의 포함 여부와 보호 방식을 명확히 한다.

향후 계정 동기화 기능을 추가한다면 사용자 인증, 접근 제어, 전송 암호화, 데이터 삭제 요청 처리 등을 별도로 설계한다.

## 14. 테스트 및 검증 시나리오

### 14.1 음식 인식 테스트

| 테스트 케이스            | 검증 항목            |
| ------------------ | ---------------- |
| 밥·국·김치·반찬 5종 사진    | 음식별 항목 분리        |
| 반찬 10종이 담긴 한식 상차림  | 항목 누락과 중복 여부     |
| 비빔밥 한 그릇           | 복합 음식의 과도한 분리 방지 |
| 같은 김치가 두 접시에 담긴 사진 | 접시 구분 및 중복 판단    |
| 음식이 겹쳐 있는 사진       | 위치 추정 및 검수 안내    |
| 음식 일부가 가려진 사진      | 불확실성 표시          |
| 조명이 어두운 사진         | 인식 품질 저하 처리      |
| 음식이 아닌 물체가 포함된 사진  | 음식 오인식 억제        |
| 음식 사진 여러 장         | 이미지별 항목 관리       |
| 국물과 건더기가 혼합된 사진    | 음식 단위 및 중량 추정    |

### 14.2 칼로리 계산 테스트

- 중량을 변경하면 음식별 칼로리가 다시 계산되는지 확인한다.
- 음식 항목을 삭제하면 식사 합계에서 제외되는지 확인한다.
- 음식을 추가하면 식사 총열량에 반영되는지 확인한다.
- 동일한 음식을 두 번 등록했을 때 자동 중복 제거와 사용자의 의도적 중복 등록을 구분할 수 있는지 확인한다.
- 영양 데이터가 없을 때 임의의 확정값을 저장하지 않는지 확인한다.
- 영양 데이터베이스 변경 후 과거 기록의 스냅샷이 유지되는지 확인한다.
- 반올림으로 인해 화면에 표시된 항목별 합계와 총합계가 달라지는 문제를 방지한다.
- `null`, 음수, 비정상적으로 큰 중량, 잘못된 좌표를 검증한다.

### 14.3 네트워크 및 장애 테스트

- 비행기 모드에서 기존 식사 기록을 조회할 수 있는지 확인한다.
- API 요청 중 앱을 종료한 뒤 상태가 일관되게 복구되는지 확인한다.
- 타임아웃 및 429 응답에서 중복 요청이 발생하지 않는지 확인한다.
- 잘못된 API 키에 대한 안내를 검증한다.
- AI가 JSON 대신 일반 문장을 반환할 때 오류 처리 경로를 검증한다.
- 모델 ID 변경 후 연결 테스트가 정상 동작하는지 확인한다.
- 사진 분석 실패가 기존 식사 기록을 훼손하지 않는지 확인한다.

### 14.4 모바일 기기 테스트

- Android와 iOS의 카메라 권한 및 갤러리 권한
- 이미지 회전과 크기 조정
- 앱 백그라운드 전환 및 복귀
- 화면 회전과 다양한 화면 크기
- 메모리 부족 상황의 이미지 처리
- 데이터베이스 마이그레이션
- 분석 중 취소와 화면 이동
- 장기간 사용 시 이미지 저장 공간 관리

## 15. 완료 조건

프로젝트는 아래 항목이 모두 충족되어야 완료된 것으로 판단한다.

- Flutter Android 및 iOS 빌드가 성공한다.
- 카메라 촬영 및 갤러리 이미지 선택이 가능하다.
- 한식 상차림에서 여러 음식을 개별 항목으로 반환한다.
- 음식명과 이미지 내 위치를 연결해 보여준다.
- 중량 추정값을 수정할 수 있다.
- 검증된 영양 데이터와 AI 추정값을 구분한다.
- 음식별 칼로리와 식사 총열량이 자동 계산된다.
- 음식 추가·수정·삭제 시 합계가 갱신된다.
- 분석 결과를 로컬 데이터베이스에 저장한다.
- 일별 식사 기록과 통계가 표시된다.
- API 오류 및 잘못된 AI 응답을 처리한다.
- API 키가 로그와 소스 코드에 노출되지 않는다.
- 단위 테스트 및 통합 테스트가 통과한다.
- 데이터 백업·복원 및 삭제 기능이 검증된다.
- 설치와 운영에 필요한 문서가 작성된다.

음식 인식 품질은 단순히 API가 정상 응답하는지로 판정하지 않는다. 별도의 한식 사진 검증 데이터셋을 구성해 음식별 재현율, 중복률, 음식명 정확도, 중량 추정 오차, 칼로리 추정 오차를 측정한다. 성능 수치는 검증 결과를 바탕으로 정하고, 실제 측정 전에 달성했다고 간주하지 않는다.

## 16. 개발 산출물

각 문서는 `docs` 디렉터리에 독립적인 한국어 Markdown 파일로 작성한다.

| 문서  | 파일명                   | 주요 내용                                           |
| --- | --------------------- | ----------------------------------------------- |
| 1   | `01_프로젝트_개요.md`       | 목적, 범위, 기능 및 기술 스택                              |
| 2   | `02_화면_설계.md`         | 화면별 구성, 사용자 흐름, 편집 동작                           |
| 3   | `03_시스템_아키텍처.md`      | Flutter, Ollama Cloud, 로컬 DB 구조 및 Mermaid 다이어그램 |
| 4   | `04_AI_음식분석_설계.md`    | 프롬프트, JSON 스키마, 음식별 분리 인식, 검증 정책                |
| 5   | `05_데이터모델_설계.md`      | 엔티티, 관계, 스키마, 마이그레이션                            |
| 6   | `06_API_연동_설계.md`     | Ollama Cloud 요청, 인증, 오류 처리                      |
| 7   | `07_칼로리_계산_및_영양정보.md` | 영양 데이터 매칭, 계산식, 출처 관리                           |
| 8   | `08_보안_및_개인정보.md`     | API 키, 이미지 처리, 로컬 데이터 보호                        |
| 9   | `09_테스트_계획.md`        | 단위·통합·기기 테스트, 음식 인식 평가                          |
| 10  | `10_설치_및_운영_가이드.md`   | 개발 환경, 빌드, 배포, 장애 대응                            |

각 문서에는 필요한 Mermaid 다이어그램과 설명을 포함한다. 실제 구현 코드에는 한국어 또는 영어의 일관된 주석 규칙을 적용하고, 공개 API와 주요 비즈니스 로직에는 이해 가능한 설명을 제공한다.

## 17. 공식 참고 자료

- [Ollama Cloud 모델 — Gemma 4](https://ollama.com/library/gemma4:cloud?utm_source=chatgpt.com)
- [Ollama Vision API 문서](https://github.com/ollama/ollama/blob/main/docs/capabilities/vision.mdx?utm_source=chatgpt.com)
- [Google Gemma 4 모델 카드](https://ai.google.dev/gemma/docs/core/model_card_4?utm_source=chatgpt.com)
- [Flutter 공식 문서](https://docs.flutter.dev/?utm_source=chatgpt.com)
- [Flutter 보안 가이드](https://docs.flutter.dev/security?utm_source=chatgpt.com)
- [식품안전나라](https://www.foodsafetykorea.go.kr/?utm_source=chatgpt.com)
- [공공데이터포털](https://www.data.go.kr/?utm_source=chatgpt.com)

최종 구현 방향: Flutter 앱에서 사진을 촬영하고, Gemma 4가 음식별 인식 결과를 생성하며, 별도의 영양 정보 계층이 칼로리를 계산한다. 사용자는 AI가 놓친 반찬을 추가하고 중량을 수정해 식사 기록을 확정한다. 이 구조를 유지해야 음식 인식 모델이 바뀌거나 영양 데이터 출처가 추가되어도 앱 전체를 다시 설계할 필요가 없다.