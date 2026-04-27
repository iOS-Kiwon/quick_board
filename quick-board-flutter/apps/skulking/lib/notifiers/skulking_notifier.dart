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
    // Navigation is handled by the caller
  }
}
