import 'package:duoplay/models/turn-based-game/turn_based_game_utils.dart';

class Connect4GameConfiguration {
  TurnBasedGameCellState enginePlayer;
  Duration betweenGamesWaitTime;
  Duration? engineMoveWaitTime;
  String difficulty;

  Connect4GameConfiguration({
    required this.enginePlayer,
    required this.betweenGamesWaitTime,
    this.engineMoveWaitTime,
    this.difficulty = 'beginner',
  });

  Connect4GameConfiguration.defaults()
      : enginePlayer = TurnBasedGameCellState.player2,
        betweenGamesWaitTime = Duration(seconds: 7),
        engineMoveWaitTime = Duration(seconds: 5),
        difficulty = 'beginner';

  void changeSides() => enginePlayer = enginePlayer.getOpponent();

  @override
  String toString() =>
      "Connect4GameConfiguration[engine:$enginePlayer,betweenGamesWaitTime:$betweenGamesWaitTime,engineMoveWaitTime:$engineMoveWaitTime,difficulty:$difficulty]";
}