import 'package:duoplay/models/turn-based-game/turn_based_game_utils.dart';

class TurnBasedGameConfiguration {
  TurnBasedGameCellState enginePlayer;
  Duration betweenGamesWaitTime;
  Duration? engineMoveWaitTime;
  String difficulty;

  TurnBasedGameConfiguration({
    required this.enginePlayer,
    required this.betweenGamesWaitTime,
    this.engineMoveWaitTime,
    this.difficulty = 'beginner',
  });

  TurnBasedGameConfiguration.defaults()
      : enginePlayer = TurnBasedGameCellState.player2,
        betweenGamesWaitTime = Duration(seconds: 7),
        engineMoveWaitTime = Duration(seconds: 5),
        difficulty = 'beginner';

  void changeSides() => enginePlayer = enginePlayer.getOpponent();

  @override
  String toString() =>
      "TurnBasedGameConfiguration[engine:$enginePlayer,betweenGamesWaitTime:$betweenGamesWaitTime,engineMoveWaitTime:$engineMoveWaitTime,difficulty:$difficulty]";
}
