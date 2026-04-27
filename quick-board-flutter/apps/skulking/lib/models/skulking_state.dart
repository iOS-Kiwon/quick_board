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
