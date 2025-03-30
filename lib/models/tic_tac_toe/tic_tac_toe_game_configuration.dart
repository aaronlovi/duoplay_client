import 'package:duoplay/models/tic_tac_toe/tic_tac_toe_cell_state.dart';

class TTTGameConfiguration {
  TicTacToeCellState enginePlayer;
  Duration betweenGamesWaitTime;
  Duration? engineMoveWaitTime;

  TTTGameConfiguration({
    required this.enginePlayer,
    required this.betweenGamesWaitTime,
    this.engineMoveWaitTime,
  });

  TTTGameConfiguration.defaults()
    : enginePlayer = TicTacToeCellState.o,
      betweenGamesWaitTime = Duration(seconds: 7),
      engineMoveWaitTime = Duration(seconds: 5);

  void changeSides() => enginePlayer = enginePlayer.getOpponent();

  @override
  String toString() =>
      "TTTGameConfiguration[engine:$enginePlayer,betweenGamesWaitTime:$betweenGamesWaitTime,engineMoveWaitTime:$engineMoveWaitTime]";
}
