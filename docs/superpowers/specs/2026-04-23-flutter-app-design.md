# Flutter 보드게임 점수판 앱 설계

**작성일:** 2026-04-23
**대상:** quick-board 웹 버전의 Flutter 모바일 앱 전환

---

## 결정 요약

| 항목 | 결정 |
|---|---|
| 프레임워크 | Flutter (Dart) |
| 저장소 구조 | 모노레포 (packages + apps) |
| 첫 앱 | 스컬킹 단독 앱 |
| 플랫폼 | iOS 14+ / Android 6+ 동시 출시 |
| 언어 | 한국어 + 영어 (기기 설정 자동 전환) |
| 상태관리 | Riverpod (StateNotifierProvider) |
| 테마 | 해적 다크 테마 (웹과 동일한 색상) |
| 데이터 저장 | 없음 (세션 전용) |
| 결과 공유 | 시스템 공유 시트 (share_plus) |
| 수익 모델 | 완전 무료, 광고 없음 |
| 배포 | App Store + Google Play 공개 출시 |

---

## 프로젝트 구조

```
quick-board-flutter/
├── packages/
│   └── quick_board_core/
│       ├── lib/
│       │   ├── theme/
│       │   │   ├── app_colors.dart
│       │   │   ├── app_text_styles.dart
│       │   │   └── app_theme.dart
│       │   └── widgets/
│       │       ├── app_button.dart
│       │       ├── score_card.dart
│       │       └── player_name_input.dart
│       └── pubspec.yaml
│
└── apps/
    └── skulking/
        ├── lib/
        │   ├── main.dart
        │   ├── l10n/
        │   │   ├── app_ko.arb
        │   │   └── app_en.arb
        │   ├── models/
        │   │   ├── player_score.dart
        │   │   └── skulking_state.dart
        │   ├── notifiers/
        │   │   └── skulking_notifier.dart
        │   ├── screens/
        │   │   ├── setup_screen.dart
        │   │   ├── game_screen.dart
        │   │   └── result_screen.dart
        │   └── widgets/
        │       ├── round_pips.dart
        │       ├── score_input_table.dart
        │       ├── scoreboard_table.dart
        │       └── tricks_sum_indicator.dart
        ├── android/
        ├── ios/
        └── pubspec.yaml
```

새 게임 추가 시: `apps/<game_name>/` 폴더 생성 후 `quick_board_core` 로컬 의존성 추가.

---

## 화면 구성 & 네비게이션

```
SetupScreen
 ├── 플레이어 수 선택 (2~8명)
 ├── 플레이어 이름 입력
 └── [게임 시작] → GameScreen

GameScreen
 ├── 라운드 네비게이션 (◀ ▶ + 숫자 pip)
 ├── 입력 테이블 (예측승 / 획득승 / 보너스)
 ├── 획득승 합계 검증 표시 (합계 ≠ 라운드 수 시 경고)
 ├── 누적 점수판
 └── [다음 라운드] / [게임 종료] → ResultScreen

ResultScreen
 ├── 순위 포디움 (🥇🥈🥉)
 ├── 라운드별 점수 테이블
 ├── [결과 공유] → 시스템 공유 시트
 └── [다시 하기] → SetupScreen
```

네비게이션: `go_router` 사용. 라우트 정의:
- `/` → SetupScreen
- `/game` → GameScreen
- `/result` → ResultScreen

---

## 데이터 모델

```dart
// models/player_score.dart
class PlayerScore {
  final int predictedWins;
  final int actualWins;
  final int bonus;
  final int roundScore;
}

// models/skulking_state.dart
class SkulkingState {
  final List<String> players;               // 플레이어 이름 (2~8명)
  final int currentRound;                   // 현재 라운드 (1~10)
  final int maxVisitedRound;                // 방문한 최대 라운드
  final List<Map<int, PlayerScore>> scores; // scores[playerIdx][round]
}
```

---

## 점수 계산 규칙

웹 버전과 동일:

```dart
int calculateRoundScore(int round, int predicted, int actual, int bonus) {
  // 0승 선언: 성공 시 round×10, 실패 시 -(round×10), 보너스 없음
  if (predicted == 0) {
    return predicted == actual ? round * 10 : -(round * 10);
  }
  // 1승 이상: 성공 시 predicted×20 + bonus, 실패 시 -|diff|×10
  return predicted == actual
      ? predicted * 20 + bonus
      : -(predicted - actual).abs() * 10;
}
```

**게임 규칙 제약:**
- 예측승 / 획득승은 현재 라운드 수를 초과할 수 없음 (입력 시 즉시 clamp)
- 모든 플레이어의 획득승 합계 = 현재 라운드 수여야 다음 라운드 진입 가능
- 방문한 라운드만 pip 버튼으로 이동 가능, 미방문 라운드는 잠김

---

## 상태 관리

```dart
// notifiers/skulking_notifier.dart
final skulkingProvider =
    StateNotifierProvider<SkulkingNotifier, SkulkingState>(
        (ref) => SkulkingNotifier());

class SkulkingNotifier extends StateNotifier<SkulkingState> {
  void startGame(List<String> players) { ... }
  void updateScore(int playerIdx, int round, PlayerScore score) { ... }
  void advanceRound() { ... }
  void goToRound(int round) { ... }
  void endGame() { ... }
}
```

---

## 테마

```dart
// packages/quick_board_core/lib/theme/app_colors.dart
class AppColors {
  static const background = Color(0xFF0D0D0D);
  static const card       = Color(0xFF1A1410);
  static const gold       = Color(0xFFC9973A);
  static const goldBright = Color(0xFFF0C060);
  static const red        = Color(0xFFCC4444);
  static const green      = Color(0xFF44AA66);
  static const text       = Color(0xFFE8D8B0);
  static const textDim    = Color(0xFF8A7A60);
}
```

- 폰트: `google_fonts` 패키지의 Cinzel (해적 테마, 웹의 Georgia 대체)
- 다크 테마 전용 (라이트 모드 미지원)

---

## 다국어 (i18n)

`flutter_localizations` + `intl` 패키지 사용. 기기 언어 설정에 따라 자동 전환.

```json
// l10n/app_ko.arb
{
  "appName": "스컬킹 점수판",
  "setupTitle": "게임 설정",
  "playerCount": "플레이어 수",
  "playerName": "플레이어 {n} 이름",
  "startGame": "게임 시작",
  "predictedWins": "예측한 승수",
  "actualWins": "획득한 승수",
  "bonus": "보너스 점수",
  "roundScore": "라운드 점수",
  "nextRound": "다음 라운드",
  "endGame": "게임 종료",
  "tricksTotal": "획득승 합계: {sum} / {round}",
  "tricksMismatch": "합계가 라운드 수와 맞지 않습니다",
  "finalResult": "최종 결과",
  "shareResult": "결과 공유",
  "playAgain": "다시 하기",
  "shareHeader": "☠️ 스컬킹 게임 결과 ☠️",
  "shareFinalStandings": "[ 최종 순위 ]",
  "shareRoundScores": "[ 라운드별 점수 ]",
  "shareTotal": "합계"
}

// l10n/app_en.arb
{
  "appName": "Skull King Score",
  "setupTitle": "Game Setup",
  "playerCount": "Number of Players",
  "playerName": "Player {n} Name",
  "startGame": "Start Game",
  "predictedWins": "Bid",
  "actualWins": "Tricks Won",
  "bonus": "Bonus",
  "roundScore": "Round Score",
  "nextRound": "Next Round",
  "endGame": "End Game",
  "tricksTotal": "Tricks total: {sum} / {round}",
  "tricksMismatch": "Total must equal the round number",
  "finalResult": "Final Results",
  "shareResult": "Share Results",
  "playAgain": "Play Again",
  "shareHeader": "☠️ Skull King Results ☠️",
  "shareFinalStandings": "[ Final Standings ]",
  "shareRoundScores": "[ Round Scores ]",
  "shareTotal": "Total"
}
```

앱 내 수동 언어 변경 기능은 미지원 (기기 설정 따름).

---

## 결과 공유

`share_plus` 패키지로 시스템 공유 시트 호출. 웹의 클립보드 텍스트 포맷을 그대로 사용:

```
☠️ Skull King Results ☠️
2026-04-23

[ Final Standings ]
1st  Alice       +240
2nd  Bob         +180

[ Round Scores ]
       Alice  Bob
R1     +20   -10
...
Total  +240  +180
```

---

## 앱스토어 출시 정보

| | 값 |
|---|---|
| 번들 ID (iOS) | `com.quickboard.skulking` |
| 패키지명 (Android) | `com.quickboard.skulking` |
| 카테고리 | 게임 유틸리티 / Card Games |
| 최소 버전 | iOS 14.0 / Android 6.0 (API 23) |
| 앱 아이콘 | 해적 해골 기반, 1024×1024 |
| 개발자 계정 | Apple ($99/년) + Google Play ($25 일회성) |

---

## 주요 패키지

```yaml
dependencies:
  flutter_riverpod: ^2.x      # 상태 관리
  go_router: ^13.x            # 네비게이션
  google_fonts: ^6.x          # Cinzel 폰트
  share_plus: ^9.x            # 시스템 공유 시트
  flutter_localizations:      # 다국어 (Flutter SDK 포함)
  intl: ^0.19.x               # 다국어 메시지 포맷
```

---

## 범위 외 (이번 버전 미포함)

- 게임 기록 저장 (로컬/클라우드)
- 앱 내 언어 수동 변경
- 라이트 모드
- 푸시 알림
- 온라인 멀티플레이
