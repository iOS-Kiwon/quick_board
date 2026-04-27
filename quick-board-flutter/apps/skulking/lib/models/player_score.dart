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
