import 'package:duoplay/models/tic_tac_toe/tic_tac_toe_enums.dart';

class TTTGameConfiguration {
  TTTCellState enginePlayer;
  Duration betweenGamesWaitTime;
  Duration? engineMoveWaitTime;
  String difficulty;

  TTTGameConfiguration({
    required this.enginePlayer,
    required this.betweenGamesWaitTime,
    this.engineMoveWaitTime,
    this.difficulty = 'beginner',
  });

  TTTGameConfiguration.defaults()
    : enginePlayer = TTTCellState.o,
      betweenGamesWaitTime = Duration(seconds: 7),
      engineMoveWaitTime = Duration(seconds: 5),
      difficulty = 'beginner';

  void changeSides() => enginePlayer = enginePlayer.getOpponent();

  @override
  String toString() =>
      "TTTGameConfiguration[engine:$enginePlayer,betweenGamesWaitTime:$betweenGamesWaitTime,engineMoveWaitTime:$engineMoveWaitTime,difficulty:$difficulty]";
}
