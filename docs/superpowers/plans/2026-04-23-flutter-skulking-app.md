# Flutter Skull King App Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a Flutter iOS+Android app for the Skull King board game score tracker, supporting Korean/English, pirate dark theme, and App Store/Play Store public release.

**Architecture:** Flutter monorepo with `packages/quick_board_core` (shared theme + widgets) and `apps/skulking` (game app). State managed via Riverpod `StateNotifierProvider`. Navigation via go_router. Session-only (no persistence).

**Tech Stack:** Flutter 3.x, Dart 3.x, flutter_riverpod ^2.x, go_router ^13.x, google_fonts ^6.x, share_plus ^9.x, flutter_localizations (SDK), intl ^0.19.x

---

## File Structure

```
quick-board-flutter/
├── packages/
│   └── quick_board_core/
│       ├── lib/
│       │   ├── quick_board_core.dart        # barrel export
│       │   ├── theme/
│       │   │   ├── app_colors.dart          # color constants
│       │   │   ├── app_text_styles.dart     # text styles
│       │   │   └── app_theme.dart           # ThemeData factory
│       │   └── widgets/
│       │       ├── app_button.dart          # primary/ghost/danger variants
│       │       ├── score_card.dart          # score display chip
│       │       └── player_name_input.dart   # text field with pirate styling
│       ├── test/
│       │   └── theme/
│       │       └── app_colors_test.dart
│       └── pubspec.yaml
│
└── apps/
    └── skulking/
        ├── lib/
        │   ├── main.dart                    # app entry point, ProviderScope, MaterialApp.router
        │   ├── router.dart                  # go_router config
        │   ├── l10n/
        │   │   ├── app_ko.arb
        │   │   └── app_en.arb
        │   ├── models/
        │   │   ├── player_score.dart        # immutable value object
        │   │   └── skulking_state.dart      # immutable app state
        │   ├── notifiers/
        │   │   └── skulking_notifier.dart   # StateNotifier + provider
        │   ├── screens/
        │   │   ├── setup_screen.dart
        │   │   ├── game_screen.dart
        │   │   └── result_screen.dart
        │   └── widgets/
        │       ├── round_pips.dart          # 10 pip buttons
        │       ├── score_input_table.dart   # per-round entry table
        │       ├── scoreboard_table.dart    # cumulative totals table
        │       └── tricks_sum_indicator.dart# sum == round validation badge
        ├── test/
        │   ├── models/
        │   │   └── player_score_test.dart
        │   ├── notifiers/
        │   │   └── skulking_notifier_test.dart
        │   └── widgets/
        │       └── tricks_sum_indicator_test.dart
        ├── android/
        ├── ios/
        ├── l10n.yaml
        └── pubspec.yaml
```

---

### Task 1: 모노레포 디렉토리 + quick_board_core pubspec 생성

**Files:**
- Create: `quick-board-flutter/packages/quick_board_core/pubspec.yaml`
- Create: `quick-board-flutter/packages/quick_board_core/lib/quick_board_core.dart`

- [ ] **Step 1: 루트 디렉토리 생성**

```bash
mkdir -p quick-board-flutter/packages/quick_board_core/lib/theme
mkdir -p quick-board-flutter/packages/quick_board_core/lib/widgets
mkdir -p quick-board-flutter/packages/quick_board_core/test/theme
```

- [ ] **Step 2: quick_board_core pubspec.yaml 작성**

파일: `quick-board-flutter/packages/quick_board_core/pubspec.yaml`

```yaml
name: quick_board_core
description: Shared theme and widgets for Quick Board games.
version: 0.0.1

environment:
  sdk: '>=3.0.0 <4.0.0'
  flutter: '>=3.10.0'

dependencies:
  flutter:
    sdk: flutter
  google_fonts: ^6.2.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0

flutter:
  uses-material-design: true
```

- [ ] **Step 3: barrel export 파일 작성**

파일: `quick-board-flutter/packages/quick_board_core/lib/quick_board_core.dart`

```dart
library quick_board_core;

export 'theme/app_colors.dart';
export 'theme/app_text_styles.dart';
export 'theme/app_theme.dart';
export 'widgets/app_button.dart';
export 'widgets/score_card.dart';
export 'widgets/player_name_input.dart';
```

- [ ] **Step 4: Commit**

```bash
git add quick-board-flutter/packages/
git commit -m "feat: add quick_board_core package scaffold"
```

---

### Task 2: AppColors + AppTextStyles + AppTheme 구현

**Files:**
- Create: `quick-board-flutter/packages/quick_board_core/lib/theme/app_colors.dart`
- Create: `quick-board-flutter/packages/quick_board_core/lib/theme/app_text_styles.dart`
- Create: `quick-board-flutter/packages/quick_board_core/lib/theme/app_theme.dart`
- Test: `quick-board-flutter/packages/quick_board_core/test/theme/app_colors_test.dart`

- [ ] **Step 1: 테스트 먼저 작성**

파일: `quick-board-flutter/packages/quick_board_core/test/theme/app_colors_test.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quick_board_core/quick_board_core.dart';

void main() {
  group('AppColors', () {
    test('background is very dark', () {
      expect(AppColors.background, const Color(0xFF0D0D0D));
    });

    test('gold is warm amber', () {
      expect(AppColors.gold, const Color(0xFFC9973A));
    });

    test('positive score color is green', () {
      expect(AppColors.scorePositive, const Color(0xFF44AA66));
    });

    test('negative score color is red', () {
      expect(AppColors.scoreNegative, const Color(0xFFCC4444));
    });
  });
}
```

- [ ] **Step 2: 테스트 실패 확인**

```bash
cd quick-board-flutter/packages/quick_board_core
flutter test test/theme/app_colors_test.dart
```

Expected: FAIL — `app_colors.dart` 없음

- [ ] **Step 3: AppColors 구현**

파일: `quick-board-flutter/packages/quick_board_core/lib/theme/app_colors.dart`

```dart
import 'package:flutter/material.dart';

abstract final class AppColors {
  static const background  = Color(0xFF0D0D0D);
  static const card        = Color(0xFF1A1410);
  static const gold        = Color(0xFFC9973A);
  static const goldBright  = Color(0xFFF0C060);
  static const scorePositive = Color(0xFF44AA66);
  static const scoreNegative = Color(0xFFCC4444);
  static const text        = Color(0xFFE8D8B0);
  static const textDim     = Color(0xFF8A7A60);
  static const border      = Color(0xFF2A2018);
}
```

- [ ] **Step 4: 테스트 통과 확인**

```bash
flutter test test/theme/app_colors_test.dart
```

Expected: All 4 tests PASS

- [ ] **Step 5: AppTextStyles 구현**

파일: `quick-board-flutter/packages/quick_board_core/lib/theme/app_text_styles.dart`

```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

abstract final class AppTextStyles {
  static TextStyle get heading => GoogleFonts.cinzel(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: AppColors.goldBright,
        letterSpacing: 1.5,
      );

  static TextStyle get subheading => GoogleFonts.cinzel(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.gold,
      );

  static TextStyle get body => GoogleFonts.cinzel(
        fontSize: 14,
        color: AppColors.text,
      );

  static TextStyle get bodyDim => GoogleFonts.cinzel(
        fontSize: 13,
        color: AppColors.textDim,
      );

  static TextStyle get scorePositive => GoogleFonts.cinzel(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: AppColors.scorePositive,
      );

  static TextStyle get scoreNegative => GoogleFonts.cinzel(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: AppColors.scoreNegative,
      );

  static TextStyle get scoreZero => GoogleFonts.cinzel(
        fontSize: 14,
        color: AppColors.textDim,
      );
}
```

- [ ] **Step 6: AppTheme 구현**

파일: `quick-board-flutter/packages/quick_board_core/lib/theme/app_theme.dart`

```dart
import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

abstract final class AppTheme {
  static ThemeData get dark => ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.gold,
          secondary: AppColors.goldBright,
          surface: AppColors.card,
          error: AppColors.scoreNegative,
        ),
        cardColor: AppColors.card,
        textTheme: TextTheme(
          headlineMedium: AppTextStyles.heading,
          titleMedium: AppTextStyles.subheading,
          bodyMedium: AppTextStyles.body,
          bodySmall: AppTextStyles.bodyDim,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.card,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.gold, width: 1.5),
          ),
          labelStyle: AppTextStyles.bodyDim,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.gold,
            foregroundColor: AppColors.background,
            textStyle: AppTextStyles.subheading,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        useMaterial3: true,
      );
}
```

- [ ] **Step 7: Commit**

```bash
git add quick-board-flutter/packages/quick_board_core/lib/theme/
git add quick-board-flutter/packages/quick_board_core/test/
git commit -m "feat: add AppColors, AppTextStyles, AppTheme"
```

---

### Task 3: 공통 위젯 구현 (AppButton, ScoreCard, PlayerNameInput)

**Files:**
- Create: `quick-board-flutter/packages/quick_board_core/lib/widgets/app_button.dart`
- Create: `quick-board-flutter/packages/quick_board_core/lib/widgets/score_card.dart`
- Create: `quick-board-flutter/packages/quick_board_core/lib/widgets/player_name_input.dart`

- [ ] **Step 1: AppButton 구현**

파일: `quick-board-flutter/packages/quick_board_core/lib/widgets/app_button.dart`

```dart
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

enum AppButtonVariant { primary, ghost, danger }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.isEnabled = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    final (bg, fg, border) = switch (variant) {
      AppButtonVariant.primary => (AppColors.gold, AppColors.background, AppColors.gold),
      AppButtonVariant.ghost   => (Colors.transparent, AppColors.gold, AppColors.gold),
      AppButtonVariant.danger  => (AppColors.scoreNegative, AppColors.text, AppColors.scoreNegative),
    };

    return Opacity(
      opacity: isEnabled ? 1.0 : 0.4,
      child: OutlinedButton(
        onPressed: isEnabled ? onPressed : null,
        style: OutlinedButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: fg,
          side: BorderSide(color: border),
          textStyle: AppTextStyles.subheading.copyWith(color: fg),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(label),
      ),
    );
  }
}
```

- [ ] **Step 2: ScoreCard 구현**

파일: `quick-board-flutter/packages/quick_board_core/lib/widgets/score_card.dart`

```dart
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class ScoreCard extends StatelessWidget {
  const ScoreCard({super.key, required this.score});

  final int score;

  @override
  Widget build(BuildContext context) {
    final style = score > 0
        ? AppTextStyles.scorePositive
        : score < 0
            ? AppTextStyles.scoreNegative
            : AppTextStyles.scoreZero;

    final label = score > 0 ? '+$score' : '$score';

    return Text(label, style: style);
  }
}
```

- [ ] **Step 3: PlayerNameInput 구현**

파일: `quick-board-flutter/packages/quick_board_core/lib/widgets/player_name_input.dart`

```dart
import 'package:flutter/material.dart';
import '../theme/app_text_styles.dart';

class PlayerNameInput extends StatelessWidget {
  const PlayerNameInput({
    super.key,
    required this.label,
    required this.controller,
  });

  final String label;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLength: 12,
      style: AppTextStyles.body,
      decoration: InputDecoration(
        labelText: label,
        counterText: '',
      ),
    );
  }
}
```

- [ ] **Step 4: Commit**

```bash
git add quick-board-flutter/packages/quick_board_core/lib/widgets/
git commit -m "feat: add AppButton, ScoreCard, PlayerNameInput widgets"
```

---

### Task 4: skulking 앱 생성 + pubspec + go_router 설정

**Files:**
- Create: `quick-board-flutter/apps/skulking/pubspec.yaml`
- Create: `quick-board-flutter/apps/skulking/l10n.yaml`
- Create: `quick-board-flutter/apps/skulking/lib/main.dart`
- Create: `quick-board-flutter/apps/skulking/lib/router.dart`

- [ ] **Step 1: Flutter 앱 생성**

```bash
cd quick-board-flutter/apps
flutter create skulking --org com.quickboard --platforms ios,android
```

Expected: skulking/ 디렉토리 생성 완료

- [ ] **Step 2: pubspec.yaml 교체**

파일: `quick-board-flutter/apps/skulking/pubspec.yaml`

```yaml
name: skulking
description: Skull King board game score tracker.
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter
  intl: ^0.19.0
  flutter_riverpod: ^2.5.1
  go_router: ^13.2.0
  google_fonts: ^6.2.1
  share_plus: ^9.0.0
  quick_board_core:
    path: ../../packages/quick_board_core

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0

flutter:
  generate: true
  uses-material-design: true
```

- [ ] **Step 3: l10n.yaml 작성**

파일: `quick-board-flutter/apps/skulking/l10n.yaml`

```yaml
arb-dir: lib/l10n
template-arb-file: app_ko.arb
output-localization-file: app_localizations.dart
```

- [ ] **Step 4: router.dart 작성**

파일: `quick-board-flutter/apps/skulking/lib/router.dart`

```dart
import 'package:go_router/go_router.dart';
import 'screens/setup_screen.dart';
import 'screens/game_screen.dart';
import 'screens/result_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SetupScreen(),
    ),
    GoRoute(
      path: '/game',
      builder: (context, state) => const GameScreen(),
    ),
    GoRoute(
      path: '/result',
      builder: (context, state) => const ResultScreen(),
    ),
  ],
);
```

- [ ] **Step 5: main.dart 작성**

파일: `quick-board-flutter/apps/skulking/lib/main.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:quick_board_core/quick_board_core.dart';
import 'router.dart';
import 'l10n/app_localizations.dart';

void main() {
  runApp(const ProviderScope(child: SkulkingApp()));
}

class SkulkingApp extends StatelessWidget {
  const SkulkingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: appRouter,
      theme: AppTheme.dark,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ko'),
        Locale('en'),
      ],
    );
  }
}
```

- [ ] **Step 6: 빌드 확인**

```bash
cd quick-board-flutter/apps/skulking
flutter pub get
flutter build ios --no-codesign --simulator
```

Expected: Build succeeded (스크린 파일 없어서 빌드 에러 — 빈 화면 placeholder로 진행)

> 빌드 에러 시: `lib/screens/` 아래 각 파일에 `class SetupScreen extends StatelessWidget { @override Widget build(BuildContext context) => const Scaffold(); }` 임시 추가 후 진행.

- [ ] **Step 7: Commit**

```bash
git add quick-board-flutter/apps/skulking/
git commit -m "feat: add skulking app scaffold with go_router and Riverpod"
```

---

### Task 5: i18n ARB 파일 + 코드 생성

**Files:**
- Create: `quick-board-flutter/apps/skulking/lib/l10n/app_ko.arb`
- Create: `quick-board-flutter/apps/skulking/lib/l10n/app_en.arb`

- [ ] **Step 1: 한국어 ARB 작성**

파일: `quick-board-flutter/apps/skulking/lib/l10n/app_ko.arb`

```json
{
  "@@locale": "ko",
  "appName": "스컬킹 점수판",
  "setupTitle": "게임 설정",
  "playerCount": "플레이어 수",
  "playerName": "플레이어 {n} 이름",
  "@playerName": {
    "placeholders": {
      "n": { "type": "int" }
    }
  },
  "startGame": "⚓ 게임 시작",
  "predictedWins": "예측승",
  "actualWins": "획득승",
  "bonus": "보너스",
  "roundScore": "점수",
  "nextRound": "다음 라운드 ▶",
  "endGame": "🏁 게임 종료",
  "tricksTotal": "획득승 합계: {sum} / {round}",
  "@tricksTotal": {
    "placeholders": {
      "sum": { "type": "int" },
      "round": { "type": "int" }
    }
  },
  "tricksMismatch": "합계가 라운드 수와 맞지 않습니다",
  "tricksOk": "✓",
  "finalResult": "🏆 최종 결과",
  "shareResult": "📋 결과 공유",
  "playAgain": "🔄 다시 하기",
  "shareHeader": "☠️ 스컬킹 게임 결과 ☠️",
  "shareFinalStandings": "[ 최종 순위 ]",
  "shareRoundScores": "[ 라운드별 점수 ]",
  "shareTotal": "합계",
  "roundLabel": "{round} / 10",
  "@roundLabel": {
    "placeholders": {
      "round": { "type": "int" }
    }
  },
  "cumulativeScore": "📊 누적 총점",
  "roundPrefix": "R{round}",
  "@roundPrefix": {
    "placeholders": {
      "round": { "type": "int" }
    }
  },
  "rankLabel": "{rank}위",
  "@rankLabel": {
    "placeholders": {
      "rank": { "type": "int" }
    }
  },
  "pointsSuffix": "{score}점",
  "@pointsSuffix": {
    "placeholders": {
      "score": { "type": "String" }
    }
  }
}
```

- [ ] **Step 2: 영어 ARB 작성**

파일: `quick-board-flutter/apps/skulking/lib/l10n/app_en.arb`

```json
{
  "@@locale": "en",
  "appName": "Skull King Score",
  "setupTitle": "Game Setup",
  "playerCount": "Number of Players",
  "playerName": "Player {n} Name",
  "@playerName": {
    "placeholders": {
      "n": { "type": "int" }
    }
  },
  "startGame": "⚓ Start Game",
  "predictedWins": "Bid",
  "actualWins": "Tricks",
  "bonus": "Bonus",
  "roundScore": "Score",
  "nextRound": "Next Round ▶",
  "endGame": "🏁 End Game",
  "tricksTotal": "Tricks total: {sum} / {round}",
  "@tricksTotal": {
    "placeholders": {
      "sum": { "type": "int" },
      "round": { "type": "int" }
    }
  },
  "tricksMismatch": "Total must equal the round number",
  "tricksOk": "✓",
  "finalResult": "🏆 Final Results",
  "shareResult": "📋 Share Results",
  "playAgain": "🔄 Play Again",
  "shareHeader": "☠️ Skull King Results ☠️",
  "shareFinalStandings": "[ Final Standings ]",
  "shareRoundScores": "[ Round Scores ]",
  "shareTotal": "Total",
  "roundLabel": "{round} / 10",
  "@roundLabel": {
    "placeholders": {
      "round": { "type": "int" }
    }
  },
  "cumulativeScore": "📊 Cumulative Score",
  "roundPrefix": "R{round}",
  "@roundPrefix": {
    "placeholders": {
      "round": { "type": "int" }
    }
  },
  "rankLabel": "{rank}th",
  "@rankLabel": {
    "placeholders": {
      "rank": { "type": "int" }
    }
  },
  "pointsSuffix": "{score}pts",
  "@pointsSuffix": {
    "placeholders": {
      "score": { "type": "String" }
    }
  }
}
```

- [ ] **Step 3: 코드 생성**

```bash
cd quick-board-flutter/apps/skulking
flutter gen-l10n
```

Expected: `.dart_tool/flutter_gen/gen_l10n/app_localizations.dart` 생성

- [ ] **Step 4: Commit**

```bash
git add quick-board-flutter/apps/skulking/lib/l10n/
git commit -m "feat: add Korean and English ARB localizations"
```

---

### Task 6: 데이터 모델 (PlayerScore, SkulkingState)

**Files:**
- Create: `quick-board-flutter/apps/skulking/lib/models/player_score.dart`
- Create: `quick-board-flutter/apps/skulking/lib/models/skulking_state.dart`
- Test: `quick-board-flutter/apps/skulking/test/models/player_score_test.dart`

- [ ] **Step 1: 테스트 먼저 작성**

파일: `quick-board-flutter/apps/skulking/test/models/player_score_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:skulking/models/player_score.dart';

void main() {
  group('calculateRoundScore', () {
    test('0 bid success: round × 10', () {
      final s = PlayerScore(predictedWins: 0, actualWins: 0, bonus: 0, round: 3);
      expect(s.roundScore, 30);
    });

    test('0 bid fail: -(round × 10)', () {
      final s = PlayerScore(predictedWins: 0, actualWins: 2, bonus: 0, round: 3);
      expect(s.roundScore, -30);
    });

    test('non-zero bid success: bid × 20 + bonus', () {
      final s = PlayerScore(predictedWins: 2, actualWins: 2, bonus: 30, round: 3);
      expect(s.roundScore, 70);
    });

    test('non-zero bid fail: -|diff| × 10', () {
      final s = PlayerScore(predictedWins: 3, actualWins: 1, bonus: 0, round: 4);
      expect(s.roundScore, -20);
    });

    test('bonus ignored on fail', () {
      final s = PlayerScore(predictedWins: 3, actualWins: 1, bonus: 50, round: 4);
      expect(s.roundScore, -20);
    });

    test('bonus ignored when bid is 0', () {
      final s = PlayerScore(predictedWins: 0, actualWins: 0, bonus: 20, round: 2);
      expect(s.roundScore, 20);
    });
  });
}
```

- [ ] **Step 2: 테스트 실패 확인**

```bash
cd quick-board-flutter/apps/skulking
flutter test test/models/player_score_test.dart
```

Expected: FAIL — `player_score.dart` 없음

- [ ] **Step 3: PlayerScore 구현**

파일: `quick-board-flutter/apps/skulking/lib/models/player_score.dart`

```dart
class PlayerScore {
  const PlayerScore({
    required this.predictedWins,
    required this.actualWins,
    required this.bonus,
    required this.round,
  });

  final int predictedWins;
  final int actualWins;
  final int bonus;
  final int round;

  int get roundScore {
    final success = predictedWins == actualWins;
    if (predictedWins == 0) {
      return success ? round * 10 : -(round * 10);
    }
    return success
        ? predictedWins * 20 + bonus
        : -(predictedWins - actualWins).abs() * 10;
  }

  PlayerScore copyWith({
    int? predictedWins,
    int? actualWins,
    int? bonus,
    int? round,
  }) =>
      PlayerScore(
        predictedWins: predictedWins ?? this.predictedWins,
        actualWins: actualWins ?? this.actualWins,
        bonus: bonus ?? this.bonus,
        round: round ?? this.round,
      );
}
```

- [ ] **Step 4: 테스트 통과 확인**

```bash
flutter test test/models/player_score_test.dart
```

Expected: All 6 tests PASS

- [ ] **Step 5: SkulkingState 구현**

파일: `quick-board-flutter/apps/skulking/lib/models/skulking_state.dart`

```dart
import 'player_score.dart';

const kMaxRounds = 10;

class SkulkingState {
  const SkulkingState({
    this.players = const [],
    this.currentRound = 1,
    this.maxVisitedRound = 1,
    this.scores = const {},
  });

  final List<String> players;
  final int currentRound;
  final int maxVisitedRound;

  // scores[playerIndex][round] = PlayerScore
  final Map<int, Map<int, PlayerScore>> scores;

  int totalScore(int playerIndex) {
    final playerScores = scores[playerIndex] ?? {};
    return playerScores.values.fold(0, (sum, s) => sum + s.roundScore);
  }

  int actualWinsSum() {
    final r = currentRound;
    var sum = 0;
    for (var i = 0; i < players.length; i++) {
      sum += scores[i]?[r]?.actualWins ?? 0;
    }
    return sum;
  }

  bool get isSumValid => actualWinsSum() == currentRound;

  SkulkingState copyWith({
    List<String>? players,
    int? currentRound,
    int? maxVisitedRound,
    Map<int, Map<int, PlayerScore>>? scores,
  }) =>
      SkulkingState(
        players: players ?? this.players,
        currentRound: currentRound ?? this.currentRound,
        maxVisitedRound: maxVisitedRound ?? this.maxVisitedRound,
        scores: scores ?? this.scores,
      );
}
```

- [ ] **Step 6: Commit**

```bash
git add quick-board-flutter/apps/skulking/lib/models/
git add quick-board-flutter/apps/skulking/test/models/
git commit -m "feat: add PlayerScore and SkulkingState models with score logic"
```

---

### Task 7: SkulkingNotifier (Riverpod StateNotifier)

**Files:**
- Create: `quick-board-flutter/apps/skulking/lib/notifiers/skulking_notifier.dart`
- Test: `quick-board-flutter/apps/skulking/test/notifiers/skulking_notifier_test.dart`

- [ ] **Step 1: 테스트 작성**

파일: `quick-board-flutter/apps/skulking/test/notifiers/skulking_notifier_test.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skulking/models/player_score.dart';
import 'package:skulking/models/skulking_state.dart';
import 'package:skulking/notifiers/skulking_notifier.dart';

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer();
  });

  tearDown(() {
    container.dispose();
  });

  SkulkingNotifier notifier() =>
      container.read(skulkingProvider.notifier);

  SkulkingState state() => container.read(skulkingProvider);

  group('startGame', () {
    test('sets players and resets to round 1', () {
      notifier().startGame(['Alice', 'Bob']);
      expect(state().players, ['Alice', 'Bob']);
      expect(state().currentRound, 1);
      expect(state().maxVisitedRound, 1);
      expect(state().scores, isEmpty);
    });
  });

  group('updateScore', () {
    setUp(() => notifier().startGame(['Alice', 'Bob']));

    test('stores score for player+round', () {
      final score = PlayerScore(predictedWins: 1, actualWins: 1, bonus: 0, round: 1);
      notifier().updateScore(0, 1, score);
      expect(state().scores[0]?[1]?.roundScore, 20);
    });

    test('overwriting a score updates it', () {
      notifier().updateScore(0, 1, PlayerScore(predictedWins: 1, actualWins: 1, bonus: 0, round: 1));
      notifier().updateScore(0, 1, PlayerScore(predictedWins: 0, actualWins: 0, bonus: 0, round: 1));
      expect(state().scores[0]?[1]?.roundScore, 10);
    });
  });

  group('advanceRound', () {
    setUp(() {
      notifier().startGame(['Alice', 'Bob']);
      notifier().updateScore(0, 1, PlayerScore(predictedWins: 1, actualWins: 1, bonus: 0, round: 1));
      notifier().updateScore(1, 1, PlayerScore(predictedWins: 0, actualWins: 0, bonus: 0, round: 1));
    });

    test('advances when sum equals round (1+0=1)', () {
      notifier().advanceRound();
      expect(state().currentRound, 2);
      expect(state().maxVisitedRound, 2);
    });

    test('does not advance when sum != round', () {
      notifier().updateScore(1, 1, PlayerScore(predictedWins: 1, actualWins: 1, bonus: 0, round: 1));
      // now both got 1 trick = sum 2 != round 1
      notifier().advanceRound();
      expect(state().currentRound, 1);
    });

    test('does not advance past round 10', () {
      for (var r = 1; r <= 10; r++) {
        notifier().updateScore(0, r, PlayerScore(predictedWins: 1, actualWins: 1, bonus: 0, round: r));
        notifier().updateScore(1, r, PlayerScore(predictedWins: 0, actualWins: 0, bonus: 0, round: r));
        notifier().advanceRound();
      }
      expect(state().maxVisitedRound, kMaxRounds);
      expect(state().currentRound, kMaxRounds);
    });
  });

  group('goToRound', () {
    setUp(() {
      notifier().startGame(['Alice', 'Bob']);
      notifier().updateScore(0, 1, PlayerScore(predictedWins: 1, actualWins: 1, bonus: 0, round: 1));
      notifier().updateScore(1, 1, PlayerScore(predictedWins: 0, actualWins: 0, bonus: 0, round: 1));
      notifier().advanceRound(); // now on round 2, maxVisited=2
    });

    test('goes back to a visited round', () {
      notifier().goToRound(1);
      expect(state().currentRound, 1);
    });

    test('cannot go to unvisited round', () {
      notifier().goToRound(5);
      expect(state().currentRound, 2); // unchanged
    });
  });
}
```

- [ ] **Step 2: 테스트 실패 확인**

```bash
flutter test test/notifiers/skulking_notifier_test.dart
```

Expected: FAIL — `skulking_notifier.dart` 없음

- [ ] **Step 3: SkulkingNotifier 구현**

파일: `quick-board-flutter/apps/skulking/lib/notifiers/skulking_notifier.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/player_score.dart';
import '../models/skulking_state.dart';

final skulkingProvider =
    StateNotifierProvider<SkulkingNotifier, SkulkingState>(
  (ref) => SkulkingNotifier(),
);

class SkulkingNotifier extends StateNotifier<SkulkingState> {
  SkulkingNotifier() : super(const SkulkingState());

  void startGame(List<String> players) {
    state = SkulkingState(players: List.unmodifiable(players));
  }

  void updateScore(int playerIndex, int round, PlayerScore score) {
    final newPlayerScores = Map<int, PlayerScore>.from(
      state.scores[playerIndex] ?? {},
    )..[round] = score;

    final newScores = Map<int, Map<int, PlayerScore>>.from(state.scores)
      ..[playerIndex] = Map.unmodifiable(newPlayerScores);

    state = state.copyWith(scores: Map.unmodifiable(newScores));
  }

  void advanceRound() {
    if (!state.isSumValid) return;
    final next = state.currentRound + 1;
    if (next > kMaxRounds) return;
    state = state.copyWith(
      currentRound: next,
      maxVisitedRound: next > state.maxVisitedRound ? next : state.maxVisitedRound,
    );
  }

  void goToRound(int round) {
    if (round < 1 || round > state.maxVisitedRound) return;
    state = state.copyWith(currentRound: round);
  }

  void endGame() {
    // Navigates to result — caller handles routing
  }
}
```

- [ ] **Step 4: 테스트 통과 확인**

```bash
flutter test test/notifiers/skulking_notifier_test.dart
```

Expected: All tests PASS

- [ ] **Step 5: Commit**

```bash
git add quick-board-flutter/apps/skulking/lib/notifiers/
git add quick-board-flutter/apps/skulking/test/notifiers/
git commit -m "feat: add SkulkingNotifier with Riverpod StateNotifier"
```

---

### Task 8: SetupScreen 구현

**Files:**
- Create: `quick-board-flutter/apps/skulking/lib/screens/setup_screen.dart`

- [ ] **Step 1: SetupScreen 구현**

파일: `quick-board-flutter/apps/skulking/lib/screens/setup_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quick_board_core/quick_board_core.dart';
import '../l10n/app_localizations.dart';
import '../notifiers/skulking_notifier.dart';

class SetupScreen extends ConsumerStatefulWidget {
  const SetupScreen({super.key});

  @override
  ConsumerState<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends ConsumerState<SetupScreen> {
  int _playerCount = 5;
  late List<TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    _controllers = _buildControllers(_playerCount);
  }

  List<TextEditingController> _buildControllers(int count) {
    return List.generate(
      count,
      (i) => TextEditingController(
        text: _controllers.length > i ? _controllers[i].text : '',
      ),
    );
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _onPlayerCountChanged(int? value) {
    if (value == null) return;
    final old = _controllers;
    setState(() {
      _playerCount = value;
      _controllers = _buildControllers(value);
    });
    for (final c in old) {
      c.dispose();
    }
  }

  void _startGame() {
    final l10n = AppLocalizations.of(context)!;
    final players = List.generate(
      _playerCount,
      (i) {
        final name = _controllers[i].text.trim();
        return name.isEmpty ? l10n.playerName(i + 1) : name;
      },
    );
    ref.read(skulkingProvider.notifier).startGame(players);
    context.go('/game');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              Text(
                '☠️ ${l10n.setupTitle}',
                style: theme.textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Text(l10n.playerCount, style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              DropdownButton<int>(
                value: _playerCount,
                dropdownColor: AppColors.card,
                style: AppTextStyles.body,
                isExpanded: true,
                items: List.generate(7, (i) => i + 2)
                    .map((n) => DropdownMenuItem(value: n, child: Text('$n명')))
                    .toList(),
                onChanged: _onPlayerCountChanged,
              ),
              const SizedBox(height: 24),
              Text(l10n.playerCount, style: theme.textTheme.titleMedium),
              const SizedBox(height: 12),
              ...List.generate(
                _playerCount,
                (i) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: PlayerNameInput(
                    label: l10n.playerName(i + 1),
                    controller: _controllers[i],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              AppButton(
                label: l10n.startGame,
                onPressed: _startGame,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: 시뮬레이터에서 확인**

```bash
cd quick-board-flutter/apps/skulking
flutter run -d "iPhone 15"
```

확인 사항:
- 플레이어 수 드롭다운 2~8 동작
- 이름 입력 필드 개수가 드롭다운에 맞게 변경
- "게임 시작" 버튼 탭 시 `/game` 으로 이동 (GameScreen placeholder)

- [ ] **Step 3: Commit**

```bash
git add quick-board-flutter/apps/skulking/lib/screens/setup_screen.dart
git commit -m "feat: add SetupScreen with player count and name inputs"
```

---

### Task 9: GameScreen 서브 위젯 구현

**Files:**
- Create: `quick-board-flutter/apps/skulking/lib/widgets/round_pips.dart`
- Create: `quick-board-flutter/apps/skulking/lib/widgets/tricks_sum_indicator.dart`
- Create: `quick-board-flutter/apps/skulking/lib/widgets/score_input_table.dart`
- Create: `quick-board-flutter/apps/skulking/lib/widgets/scoreboard_table.dart`
- Test: `quick-board-flutter/apps/skulking/test/widgets/tricks_sum_indicator_test.dart`

- [ ] **Step 1: TricksSumIndicator 테스트 작성**

파일: `quick-board-flutter/apps/skulking/test/widgets/tricks_sum_indicator_test.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skulking/widgets/tricks_sum_indicator.dart';

Widget _wrap(Widget child) => MaterialApp(
      home: Scaffold(body: child),
    );

void main() {
  testWidgets('shows green check when sum equals round', (tester) async {
    await tester.pumpWidget(_wrap(
      const TricksSumIndicator(sum: 3, round: 3),
    ));
    final text = find.textContaining('✓');
    expect(text, findsOneWidget);
  });

  testWidgets('shows warning when sum != round', (tester) async {
    await tester.pumpWidget(_wrap(
      const TricksSumIndicator(sum: 2, round: 3),
    ));
    final text = find.textContaining('2 / 3');
    expect(text, findsOneWidget);
  });
}
```

- [ ] **Step 2: TricksSumIndicator 구현**

파일: `quick-board-flutter/apps/skulking/lib/widgets/tricks_sum_indicator.dart`

```dart
import 'package:flutter/material.dart';
import 'package:quick_board_core/quick_board_core.dart';

class TricksSumIndicator extends StatelessWidget {
  const TricksSumIndicator({
    super.key,
    required this.sum,
    required this.round,
  });

  final int sum;
  final int round;

  @override
  Widget build(BuildContext context) {
    final ok = sum == round;
    final color = ok ? AppColors.scorePositive : AppColors.scoreNegative;
    final label = ok
        ? '획득승 합계: $sum / $round ✓'
        : '획득승 합계: $sum / $round — 합계가 라운드 수와 맞지 않습니다';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(label, style: AppTextStyles.body.copyWith(color: color)),
    );
  }
}
```

- [ ] **Step 3: 테스트 통과 확인**

```bash
flutter test test/widgets/tricks_sum_indicator_test.dart
```

Expected: Both tests PASS

- [ ] **Step 4: RoundPips 구현**

파일: `quick-board-flutter/apps/skulking/lib/widgets/round_pips.dart`

```dart
import 'package:flutter/material.dart';
import 'package:quick_board_core/quick_board_core.dart';
import '../models/skulking_state.dart';

class RoundPips extends StatelessWidget {
  const RoundPips({
    super.key,
    required this.currentRound,
    required this.maxVisitedRound,
    required this.hasDoneRound,
    required this.onTap,
  });

  final int currentRound;
  final int maxVisitedRound;

  /// hasDoneRound(r) returns true if round r has any input
  final bool Function(int round) hasDoneRound;
  final void Function(int round) onTap;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: List.generate(kMaxRounds, (i) {
        final r = i + 1;
        final locked = r > maxVisitedRound;
        final isCurrent = r == currentRound;
        final isDone = !locked && hasDoneRound(r);

        Color bg;
        Color border;
        if (isCurrent) {
          bg = AppColors.gold;
          border = AppColors.goldBright;
        } else if (isDone) {
          bg = AppColors.gold.withOpacity(0.25);
          border = AppColors.gold.withOpacity(0.5);
        } else if (locked) {
          bg = AppColors.card;
          border = AppColors.border;
        } else {
          bg = AppColors.card;
          border = AppColors.gold.withOpacity(0.4);
        }

        return GestureDetector(
          onTap: locked ? null : () => onTap(r),
          child: Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: bg,
              border: Border.all(color: border),
              borderRadius: BorderRadius.circular(6),
            ),
            alignment: Alignment.center,
            child: Text(
              '$r',
              style: AppTextStyles.body.copyWith(
                color: isCurrent ? AppColors.background : AppColors.text,
                fontWeight: isCurrent ? FontWeight.bold : null,
              ),
            ),
          ),
        );
      }),
    );
  }
}
```

- [ ] **Step 5: ScoreInputTable 구현**

파일: `quick-board-flutter/apps/skulking/lib/widgets/score_input_table.dart`

```dart
import 'package:flutter/material.dart';
import 'package:quick_board_core/quick_board_core.dart';
import '../models/player_score.dart';

class ScoreInputTable extends StatefulWidget {
  const ScoreInputTable({
    super.key,
    required this.players,
    required this.currentRound,
    required this.savedScores,
    required this.onScoreChanged,
  });

  final List<String> players;
  final int currentRound;

  /// savedScores[playerIndex] = PlayerScore (or null if empty)
  final Map<int, PlayerScore?> savedScores;
  final void Function(int playerIndex, PlayerScore score) onScoreChanged;

  @override
  State<ScoreInputTable> createState() => _ScoreInputTableState();
}

class _ScoreInputTableState extends State<ScoreInputTable> {
  late final List<TextEditingController> _bidCtrl;
  late final List<TextEditingController> _tricksCtrl;
  late final List<TextEditingController> _bonusCtrl;

  @override
  void initState() {
    super.initState();
    _bidCtrl = List.generate(widget.players.length, (i) {
      final s = widget.savedScores[i];
      return TextEditingController(text: s != null ? '${s.predictedWins}' : '');
    });
    _tricksCtrl = List.generate(widget.players.length, (i) {
      final s = widget.savedScores[i];
      return TextEditingController(text: s != null ? '${s.actualWins}' : '');
    });
    _bonusCtrl = List.generate(widget.players.length, (i) {
      final s = widget.savedScores[i];
      return TextEditingController(text: s != null && s.bonus != 0 ? '${s.bonus}' : '');
    });
  }

  @override
  void dispose() {
    for (final c in [..._bidCtrl, ..._tricksCtrl, ..._bonusCtrl]) {
      c.dispose();
    }
    super.dispose();
  }

  void _onInput(int i) {
    final bidText = _bidCtrl[i].text;
    if (bidText.isEmpty) return;

    final r = widget.currentRound;
    final bid = (int.tryParse(bidText) ?? 0).clamp(0, r);
    final tricks = (int.tryParse(_tricksCtrl[i].text) ?? 0).clamp(0, r);
    final bonus = int.tryParse(_bonusCtrl[i].text) ?? 0;

    // clamp back the displayed values
    if (_bidCtrl[i].text != '$bid') {
      _bidCtrl[i].text = '$bid';
      _bidCtrl[i].selection = TextSelection.collapsed(offset: '$bid'.length);
    }
    if (_tricksCtrl[i].text != '$tricks') {
      _tricksCtrl[i].text = '$tricks';
      _tricksCtrl[i].selection = TextSelection.collapsed(offset: '$tricks'.length);
    }

    final score = PlayerScore(
      predictedWins: bid,
      actualWins: tricks,
      bonus: bonus,
      round: r,
    );
    widget.onScoreChanged(i, score);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingTextStyle: AppTextStyles.bodyDim,
        dataTextStyle: AppTextStyles.body,
        columnSpacing: 12,
        columns: [
          DataColumn(label: Text('플레이어', style: AppTextStyles.bodyDim)),
          DataColumn(label: Text('예측승', style: AppTextStyles.bodyDim), numeric: true),
          DataColumn(label: Text('획득승', style: AppTextStyles.bodyDim), numeric: true),
          DataColumn(label: Text('보너스', style: AppTextStyles.bodyDim), numeric: true),
          DataColumn(label: Text('점수', style: AppTextStyles.bodyDim), numeric: true),
        ],
        rows: List.generate(widget.players.length, (i) {
          final saved = widget.savedScores[i];
          final bonusApplies = saved != null &&
              saved.predictedWins > 0 &&
              saved.predictedWins == saved.actualWins;

          return DataRow(cells: [
            DataCell(Text(widget.players[i])),
            DataCell(_numberField(_bidCtrl[i], i)),
            DataCell(_numberField(_tricksCtrl[i], i)),
            DataCell(
              Opacity(
                opacity: bonusApplies ? 1.0 : 0.35,
                child: _numberField(_bonusCtrl[i], i),
              ),
            ),
            DataCell(
              saved != null
                  ? ScoreCard(score: saved.roundScore)
                  : Text('—', style: AppTextStyles.bodyDim),
            ),
          ]);
        }),
      ),
    );
  }

  Widget _numberField(TextEditingController ctrl, int playerIndex) {
    return SizedBox(
      width: 52,
      child: TextField(
        controller: ctrl,
        keyboardType: TextInputType.number,
        style: AppTextStyles.body,
        textAlign: TextAlign.center,
        decoration: const InputDecoration(
          contentPadding: EdgeInsets.symmetric(vertical: 6),
          isDense: true,
        ),
        onChanged: (_) => _onInput(playerIndex),
      ),
    );
  }
}
```

- [ ] **Step 6: ScoreboardTable 구현**

파일: `quick-board-flutter/apps/skulking/lib/widgets/scoreboard_table.dart`

```dart
import 'package:flutter/material.dart';
import 'package:quick_board_core/quick_board_core.dart';
import '../models/player_score.dart';
import '../models/skulking_state.dart';

class ScoreboardTable extends StatelessWidget {
  const ScoreboardTable({
    super.key,
    required this.players,
    required this.scores,
    required this.currentRound,
    required this.totalScores,
  });

  final List<String> players;
  final Map<int, Map<int, PlayerScore>> scores;
  final int currentRound;
  final List<int> totalScores;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingTextStyle: AppTextStyles.bodyDim,
        dataTextStyle: AppTextStyles.body,
        columnSpacing: 12,
        columns: [
          DataColumn(label: Text('라운드', style: AppTextStyles.bodyDim)),
          ...players.map((p) => DataColumn(
                label: Text(p, style: AppTextStyles.bodyDim),
                numeric: true,
              )),
        ],
        rows: [
          ...List.generate(kMaxRounds, (i) {
            final r = i + 1;
            final isCurrent = r == currentRound;
            return DataRow(
              color: isCurrent
                  ? WidgetStateProperty.all(AppColors.gold.withOpacity(0.08))
                  : null,
              cells: [
                DataCell(Text('R$r',
                    style: isCurrent
                        ? AppTextStyles.body.copyWith(color: AppColors.goldBright)
                        : AppTextStyles.bodyDim)),
                ...List.generate(players.length, (pi) {
                  final s = scores[pi]?[r];
                  return DataCell(
                    s != null
                        ? ScoreCard(score: s.roundScore)
                        : Text('—', style: AppTextStyles.bodyDim),
                  );
                }),
              ],
            );
          }),
          DataRow(
            color: WidgetStateProperty.all(AppColors.card),
            cells: [
              DataCell(Text('합계', style: AppTextStyles.subheading)),
              ...totalScores
                  .map((t) => DataCell(ScoreCard(score: t))),
            ],
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 7: Commit**

```bash
git add quick-board-flutter/apps/skulking/lib/widgets/
git add quick-board-flutter/apps/skulking/test/widgets/
git commit -m "feat: add game screen widgets (pips, input table, scoreboard, tricks sum)"
```

---

### Task 10: GameScreen 구현

**Files:**
- Create: `quick-board-flutter/apps/skulking/lib/screens/game_screen.dart`

- [ ] **Step 1: GameScreen 구현**

파일: `quick-board-flutter/apps/skulking/lib/screens/game_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quick_board_core/quick_board_core.dart';
import '../models/player_score.dart';
import '../models/skulking_state.dart';
import '../notifiers/skulking_notifier.dart';
import '../widgets/round_pips.dart';
import '../widgets/score_input_table.dart';
import '../widgets/scoreboard_table.dart';
import '../widgets/tricks_sum_indicator.dart';

class GameScreen extends ConsumerWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(skulkingProvider);
    final notifier = ref.read(skulkingProvider.notifier);
    final r = state.currentRound;
    final isOnLatest = r == state.maxVisitedRound;
    final canAdvance = state.isSumValid && isOnLatest && r < kMaxRounds;

    // saved scores for current round
    final savedScores = <int, PlayerScore?>{
      for (var i = 0; i < state.players.length; i++)
        i: state.scores[i]?[r],
    };

    final totals = List.generate(
      state.players.length,
      state.totalScore,
    );

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Round navigation
            Card(
              color: AppColors.card,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Text(
                          '$r / $kMaxRounds',
                          style: AppTextStyles.heading,
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: r > 1
                              ? () => notifier.goToRound(r - 1)
                              : null,
                          icon: const Icon(Icons.arrow_back_ios),
                          color: AppColors.gold,
                        ),
                        IconButton(
                          onPressed: r < state.maxVisitedRound
                              ? () => notifier.goToRound(r + 1)
                              : null,
                          icon: const Icon(Icons.arrow_forward_ios),
                          color: AppColors.gold,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    RoundPips(
                      currentRound: r,
                      maxVisitedRound: state.maxVisitedRound,
                      hasDoneRound: (round) =>
                          state.scores.values.any((m) => m.containsKey(round)),
                      onTap: notifier.goToRound,
                    ),
                    const SizedBox(height: 16),
                    ScoreInputTable(
                      players: state.players,
                      currentRound: r,
                      savedScores: savedScores,
                      onScoreChanged: (i, score) =>
                          notifier.updateScore(i, r, score),
                    ),
                    const SizedBox(height: 12),
                    TricksSumIndicator(
                      sum: state.actualWinsSum(),
                      round: r,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (canAdvance)
                          AppButton(
                            label: '다음 라운드 ▶',
                            onPressed: notifier.advanceRound,
                          ),
                        const SizedBox(width: 12),
                        AppButton(
                          label: '🏁 게임 종료',
                          variant: AppButtonVariant.danger,
                          onPressed: () => context.go('/result'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Cumulative scoreboard
            Card(
              color: AppColors.card,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('📊 누적 총점', style: AppTextStyles.subheading),
                    const SizedBox(height: 12),
                    ScoreboardTable(
                      players: state.players,
                      scores: state.scores,
                      currentRound: r,
                      totalScores: totals,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: 시뮬레이터에서 확인**

```bash
flutter run -d "iPhone 15"
```

확인 사항:
- Setup → Game 화면 전환
- 점수 입력 시 실시간 합계 표시 및 색상 변경
- 획득승 합계 == 라운드 수일 때만 "다음 라운드" 버튼 활성화
- 라운드 pip 탭으로 방문한 라운드 이동
- 누적 점수판 업데이트

- [ ] **Step 3: Commit**

```bash
git add quick-board-flutter/apps/skulking/lib/screens/game_screen.dart
git commit -m "feat: add GameScreen with round navigation, input, and scoreboard"
```

---

### Task 11: ResultScreen + share_plus 공유

**Files:**
- Create: `quick-board-flutter/apps/skulking/lib/screens/result_screen.dart`

- [ ] **Step 1: ResultScreen 구현**

파일: `quick-board-flutter/apps/skulking/lib/screens/result_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:quick_board_core/quick_board_core.dart';
import '../models/skulking_state.dart';
import '../notifiers/skulking_notifier.dart';

class ResultScreen extends ConsumerWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(skulkingProvider);
    final standings = _buildStandings(state);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              '🏆 최종 결과',
              style: AppTextStyles.heading,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            _PodiumRow(standings: standings),
            const SizedBox(height: 24),
            _ResultTable(state: state, standings: standings),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppButton(
                  label: '📋 결과 공유',
                  variant: AppButtonVariant.ghost,
                  onPressed: () => _share(state, standings),
                ),
                const SizedBox(width: 12),
                AppButton(
                  label: '🔄 다시 하기',
                  onPressed: () => context.go('/'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<({String name, int total, int rank})> _buildStandings(SkulkingState state) {
    final sorted = List.generate(state.players.length, (i) {
      return (name: state.players[i], total: state.totalScore(i));
    })
      ..sort((a, b) => b.total.compareTo(a.total));

    return sorted.indexed
        .map((e) => (name: e.$2.name, total: e.$2.total, rank: e.$1 + 1))
        .toList();
  }

  void _share(
    SkulkingState state,
    List<({String name, int total, int rank})> standings,
  ) {
    const pad = 12;
    const scorePad = 8;
    final buf = StringBuffer();

    buf.writeln('☠️ 스컬킹 게임 결과 ☠️');
    buf.writeln(DateTime.now().toIso8601String().substring(0, 10));
    buf.writeln();
    buf.writeln('[ 최종 순위 ]');
    for (final s in standings) {
      final score = s.total > 0 ? '+${s.total}' : '${s.total}';
      buf.writeln('${s.rank}위  ${s.name.padRight(pad)}${score}점');
    }

    buf.writeln();
    buf.writeln('[ 라운드별 점수 ]');
    buf.write(''.padRight(pad));
    for (final p in state.players) {
      buf.write(p.length > 6 ? p.substring(0, 6) : p.padRight(scorePad));
    }
    buf.writeln();

    for (var r = 1; r <= kMaxRounds; r++) {
      final hasAny = state.players
          .asMap()
          .keys
          .any((i) => state.scores[i]?[r] != null);
      if (!hasAny) continue;

      buf.write('R$r'.padRight(pad));
      for (var i = 0; i < state.players.length; i++) {
        final s = state.scores[i]?[r];
        final label = s != null
            ? (s.roundScore > 0 ? '+${s.roundScore}' : '${s.roundScore}')
            : '—';
        buf.write(label.padRight(scorePad));
      }
      buf.writeln();
    }

    buf.write('합계'.padRight(pad));
    for (var i = 0; i < state.players.length; i++) {
      final t = state.totalScore(i);
      buf.write((t > 0 ? '+$t' : '$t').padRight(scorePad));
    }

    Share.share(buf.toString());
  }
}

class _PodiumRow extends StatelessWidget {
  const _PodiumRow({required this.standings});

  final List<({String name, int total, int rank})> standings;

  @override
  Widget build(BuildContext context) {
    const emojis = ['🥇', '🥈', '🥉'];
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 16,
      runSpacing: 12,
      children: standings.map((s) {
        final rankEmoji = s.rank <= 3 ? emojis[s.rank - 1] : '${s.rank}위';
        final scoreLabel = s.total > 0 ? '+${s.total}' : '${s.total}';
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(rankEmoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(height: 4),
            Text(s.name, style: AppTextStyles.body),
            ScoreCard(score: s.total),
          ],
        );
      }).toList(),
    );
  }
}

class _ResultTable extends StatelessWidget {
  const _ResultTable({required this.state, required this.standings});

  final SkulkingState state;
  final List<({String name, int total, int rank})> standings;

  @override
  Widget build(BuildContext context) {
    final totals = List.generate(state.players.length, state.totalScore);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingTextStyle: AppTextStyles.bodyDim,
        dataTextStyle: AppTextStyles.body,
        columnSpacing: 12,
        columns: [
          DataColumn(label: Text('라운드', style: AppTextStyles.bodyDim)),
          ...state.players.map((p) => DataColumn(
                label: Text(p, style: AppTextStyles.bodyDim),
                numeric: true,
              )),
        ],
        rows: [
          ...List.generate(kMaxRounds, (i) {
            final r = i + 1;
            final hasAny = state.players
                .asMap()
                .keys
                .any((pi) => state.scores[pi]?[r] != null);
            if (!hasAny) return null;

            return DataRow(cells: [
              DataCell(Text('R$r', style: AppTextStyles.bodyDim)),
              ...List.generate(state.players.length, (pi) {
                final s = state.scores[pi]?[r];
                return DataCell(
                  s != null
                      ? ScoreCard(score: s.roundScore)
                      : Text('—', style: AppTextStyles.bodyDim),
                );
              }),
            ]);
          }).whereType<DataRow>().toList(),
          DataRow(
            color: WidgetStateProperty.all(AppColors.card),
            cells: [
              DataCell(Text('합계', style: AppTextStyles.subheading)),
              ...totals.map((t) => DataCell(ScoreCard(score: t))),
            ],
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: 전체 흐름 시뮬레이터 테스트**

```bash
flutter run -d "iPhone 15"
```

확인 사항:
- 게임 종료 → ResultScreen 이동
- 포디움에 🥇🥈🥉 순위 표시
- 라운드별 점수 테이블 표시
- "결과 공유" 탭 시 iOS 공유 시트 열림
- "다시 하기" 탭 시 SetupScreen으로 복귀

- [ ] **Step 3: Commit**

```bash
git add quick-board-flutter/apps/skulking/lib/screens/result_screen.dart
git commit -m "feat: add ResultScreen with podium, score table, and share_plus"
```

---

### Task 12: 전체 테스트 실행 + iOS 빌드 검증

**Files:** 없음 (검증만)

- [ ] **Step 1: 전체 단위 테스트 실행**

```bash
cd quick-board-flutter/packages/quick_board_core
flutter test

cd ../../apps/skulking
flutter test
```

Expected: All tests pass with no errors

- [ ] **Step 2: iOS 릴리즈 빌드 확인**

```bash
cd quick-board-flutter/apps/skulking
flutter build ios --no-codesign
```

Expected: `Build target skulking succeeded`

- [ ] **Step 3: Android 빌드 확인**

```bash
flutter build apk --debug
```

Expected: `Built build/app/outputs/flutter-apk/app-debug.apk`

- [ ] **Step 4: 앱 아이디 설정 (iOS)**

파일: `quick-board-flutter/apps/skulking/ios/Runner/Info.plist`

`CFBundleIdentifier` 값을 `com.quickboard.skulking` 으로 변경 (Xcode → Runner target → Bundle Identifier).

- [ ] **Step 5: 앱 아이디 설정 (Android)**

파일: `quick-board-flutter/apps/skulking/android/app/build.gradle`

```gradle
android {
    namespace "com.quickboard.skulking"
    defaultConfig {
        applicationId "com.quickboard.skulking"
        minSdk 23
        targetSdk 34
        ...
    }
}
```

- [ ] **Step 6: 최종 커밋**

```bash
git add quick-board-flutter/
git commit -m "feat: complete Skull King Flutter app - all screens, tests, and build verified"
```

---

## 스펙 커버리지 체크

| 스펙 항목 | 구현 태스크 |
|-----------|-------------|
| 플랫폼: iOS 14+ / Android 6+ | Task 12 (minSdk 23, iOS deployment target) |
| 상태관리: Riverpod StateNotifierProvider | Task 7 |
| 테마: 해적 다크 테마 | Task 2, 3 |
| 데이터 저장: 없음 (세션 전용) | Task 7 (메모리만 사용) |
| 결과 공유: share_plus | Task 11 |
| 다국어 ko+en | Task 5 |
| go_router 네비게이션 | Task 4 |
| SetupScreen (2~8명) | Task 8 |
| GameScreen (라운드 pip, 입력 테이블, 획득승 합계) | Task 9, 10 |
| ResultScreen (포디움, 순위 테이블) | Task 11 |
| 점수 계산 규칙 | Task 6 (PlayerScore) |
| maxVisitedRound 잠금 | Task 7 (SkulkingNotifier) |
| 획득승 합계 == 라운드 수 검증 | Task 7 (isSumValid) |
| 모노레포 구조 | Task 1 |
| Cinzel 폰트 | Task 2 (AppTextStyles) |
| Bundle ID com.quickboard.skulking | Task 12 |
