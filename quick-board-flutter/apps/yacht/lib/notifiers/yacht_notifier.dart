import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/yacht_category.dart';
import '../models/yacht_state.dart';

final yachtProvider = StateNotifierProvider<YachtNotifier, YachtState>(
  (_) => YachtNotifier(),
);

class YachtNotifier extends StateNotifier<YachtState> {
  YachtNotifier()
      : super(const YachtState(players: [], scores: {}));

  void startGame(List<String> players) {
    state = YachtState(players: List.unmodifiable(players), scores: {});
  }

  void enterScore(int playerIndex, YachtCategory category, int score) {
    final capped = score.clamp(0, category.maxScore);

    final newPlayerScores = Map<YachtCategory, int>.from(
      state.scores[playerIndex] ?? {},
    )..[category] = capped;

    state = state.copyWith(
      scores: {
        ...state.scores,
        playerIndex: Map.unmodifiable(newPlayerScores),
      },
    );
  }

  void clearScore(int playerIndex, YachtCategory category) {
    final newPlayerScores = Map<YachtCategory, int>.from(
      state.scores[playerIndex] ?? {},
    )..remove(category);

    state = state.copyWith(
      scores: {
        ...state.scores,
        playerIndex: Map.unmodifiable(newPlayerScores),
      },
    );
  }

  void resetGame() {
    state = const YachtState(players: [], scores: {});
  }
}
