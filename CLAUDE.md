# 코인원 보드게임 동아리 — 퀵보드 점수판

코인원 보드게임 동아리를 위한 보드게임 점수 계산 웹사이트.
현재 스컬킹(Skull King)을 지원하며, 새 게임을 카드 형태로 추가할 수 있는 구조입니다.

## 개발

별도 빌드 없음. `index.html`을 브라우저에서 직접 열면 됩니다.

## 배포 (GitHub Pages)

1. `main` 브랜치에 푸시
2. Settings → Pages → Source: `main` 브랜치 루트 선택

## 파일 구조

```
quick-board/
├── index.html                  # HTML 골격 (화면 구조만)
├── style.css                   # 공통 스타일 (레이아웃, 버튼, 카드 등)
├── main.js                     # 공통 로직 (showScreen, selectGame, 초기화)
└── games/
    └── skulking/
        ├── skulking.css        # 스컬킹 전용 스타일
        └── skulking.js         # 스컬킹 로직 전체
```

## 화면 구조

4개의 화면이 `hidden` 속성으로 전환됩니다.

```
로비 (screen-lobby)
 └─ 게임 선택 카드 목록
     └─ 스컬킹 선택
         └─ 게임 설정 (screen-setup)    플레이어 수 · 이름 입력
             └─ 게임 진행 (screen-game) 라운드별 예측승/획득승/보너스 입력 + 실시간 합산
                 └─ 결과 (screen-result) 최종 순위 · 텍스트 클립보드 복사
```

- `showScreen(name)` — `main.js`, 화면 전환
- `selectGame(gameId)` — `main.js`, 로비 카드 클릭 시 게임별 진입 함수 호출

## 새 게임 추가 방법

1. `games/<게임명>/` 폴더 생성 후 `<게임명>.js`, `<게임명>.css` 작성
2. `index.html`에 화면 HTML 추가 (`screen-setup`, `screen-game`, `screen-result` 등)
3. `index.html` `<head>`에 CSS `<link>` 추가
4. `index.html` 하단에 `<script src="games/<게임명>/<게임명>.js">` 추가
5. `main.js`의 `selectGame()` 에 새 게임 ID 분기 한 줄 추가
6. `screen-lobby`에 `.game-card` div 추가

## 수정 가이드

| 항목 | 위치 |
|------|------|
| 점수 계산 규칙 | `games/skulking/skulking.js` — `calculateRoundScore()` |
| 최대 라운드 수 | `games/skulking/skulking.js` — `MAX_ROUNDS` 상수 |
| 최대 플레이어 수 | `index.html` — `<select id="player-count">` 옵션 |
| 테마 색상 | `style.css` — `:root {}` CSS 변수 |
| 공통 스타일 | `style.css` |
| 스컬킹 전용 스타일 | `games/skulking/skulking.css` |
