import 'yacht_category.dart';

class YachtState {
  final List<String> players;
  final Map<int, Map<YachtCategory, int>> scores;

  const YachtState({
    required this.players,
    required this.scores,
  });

  int upperSubtotal(int playerIndex) {
    final playerScores = scores[playerIndex] ?? {};
    return YachtCategory.values
        .where((c) => c.isUpper)
        .fold(0, (sum, cat) => sum + (playerScores[cat] ?? 0));
  }

  int bonus(int playerIndex) => upperSubtotal(playerIndex) >= 63 ? 35 : 0;

  int lowerTotal(int playerIndex) {
    final playerScores = scores[playerIndex] ?? {};
    return YachtCategory.values
        .where((c) => !c.isUpper)
        .fold(0, (sum, cat) => sum + (playerScores[cat] ?? 0));
  }

  int totalScore(int playerIndex) =>
      upperSubtotal(playerIndex) + bonus(playerIndex) + lowerTotal(playerIndex);

  bool get isGameComplete {
    if (players.isEmpty) return false;
    return List.generate(players.length, (i) => i).every((playerIndex) {
      final playerScores = scores[playerIndex] ?? {};
      return YachtCategory.values.every((cat) => playerScores.containsKey(cat));
    });
  }

  YachtState copyWith({
    List<String>? players,
    Map<int, Map<YachtCategory, int>>? scores,
  }) {
    return YachtState(
      players: players ?? this.players,
      scores: scores ?? this.scores,
    );
  }
}
