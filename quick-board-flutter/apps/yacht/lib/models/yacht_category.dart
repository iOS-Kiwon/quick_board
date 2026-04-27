enum YachtCategory {
  aces, duals, triples, quads, penta, hexa,
  choice, poker, fullHouse, smallStraight, largeStraight, yacht,
}

extension YachtCategoryX on YachtCategory {
  bool get isUpper => index < 6;

  int get maxScore => switch (this) {
    YachtCategory.aces => 5,
    YachtCategory.duals => 10,
    YachtCategory.triples => 15,
    YachtCategory.quads => 20,
    YachtCategory.penta => 25,
    YachtCategory.hexa => 30,
    YachtCategory.choice => 30,
    YachtCategory.poker => 24,
    YachtCategory.fullHouse => 28,
    YachtCategory.smallStraight => 30,
    YachtCategory.largeStraight => 30,
    YachtCategory.yacht => 50,
  };

  int? get fixedScore => switch (this) {
    YachtCategory.smallStraight => 30,
    YachtCategory.largeStraight => 30,
    YachtCategory.yacht => 50,
    _ => null,
  };
}
