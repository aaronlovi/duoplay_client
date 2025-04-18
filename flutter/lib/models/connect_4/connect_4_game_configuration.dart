import 'package:duoplay/models/connect_4/connect_4_enums.dart';

class Connect4GameConfiguration {
  Connect4SquareState enginePlayer;
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
      : enginePlayer = Connect4SquareState.yellow,
        betweenGamesWaitTime = Duration(seconds: 7),
        engineMoveWaitTime = Duration(seconds: 5),
        difficulty = 'beginner';

  void changeSides() => enginePlayer = enginePlayer == Connect4SquareState.red
      ? Connect4SquareState.yellow
      : Connect4SquareState.red;

  @override
  String toString() =>
      "Connect4GameConfiguration[engine:$enginePlayer,betweenGamesWaitTime:$betweenGamesWaitTime,engineMoveWaitTime:$engineMoveWaitTime,difficulty:$difficulty]";
}