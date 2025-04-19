import 'package:duoplay/models/turn-based-game/turn_based_game_utils.dart';

class TTTGameConfiguration {
  TurnBasedGameCellState enginePlayer;
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
    : enginePlayer = TurnBasedGameCellState.player2,
      betweenGamesWaitTime = Duration(seconds: 7),
      engineMoveWaitTime = Duration(seconds: 5),
      difficulty = 'beginner';

  void changeSides() => enginePlayer = enginePlayer.getOpponent();

  @override
  String toString() =>
      "TTTGameConfiguration[engine:$enginePlayer,betweenGamesWaitTime:$betweenGamesWaitTime,engineMoveWaitTime:$engineMoveWaitTime,difficulty:$difficulty]";
}
