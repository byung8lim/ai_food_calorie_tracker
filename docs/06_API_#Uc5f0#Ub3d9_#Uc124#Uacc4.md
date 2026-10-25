# Ollama API 연동

## 요청
`POST https://ollama.com/api/chat`

헤더: `Authorization: Bearer <user API key>`, `Content-Type: application/json`.

본문: `model`, `stream:false`, `format:'json'`, `messages:[{role:'user',content:...,images:[base64]}]`.

응답: `message.content` 안의 JSON 문자열을 검증하고 데이터 모델로 변환한다.

## 장애와 보안
네트워크 연결 제한 20초, 응답 제한 120초. API 키는 `flutter_secure_storage`에만 저장하며 로그에 출력하지 않는다. 현재 자동 재시도·토큰 만료 대응·서버 측 사용자별 제한은 구현되지 않았다.

## 운영 결정
개인 테스트 외에 앱 공용 API 키를 번들에 넣어서는 안 된다. 서비스 배포 시 인증 프록시를 설계하고 HTTPS, 비용 상한, 이미지 보존 정책을 검증해야 한다.
