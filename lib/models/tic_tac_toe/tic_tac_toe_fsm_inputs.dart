import 'package:duoplay/models/tic_tac_toe/tic_tac_toe_cell_state.dart';
import 'package:duoplay/models/tic_tac_toe/tic_tac_toe_game_configuration.dart';

abstract class TicTacToeInputBase {
  final DateTime nowUtc;

  TicTacToeInputBase({required this.nowUtc});
}

class TicTacToeGameConfigInput extends TicTacToeInputBase {
  TTTGameConfiguration configuration;

  TicTacToeGameConfigInput({
    required super.nowUtc,
    required this.configuration,
  });

  @override
  String toString() => "TTTGameConfigInput[now:$nowUtc,config:$configuration]";
}

class TicTacToePlayerMoveInput extends TicTacToeInputBase {
  int index;
  TicTacToeCellState player;

  TicTacToePlayerMoveInput({
    required super.nowUtc,
    required this.index,
    required this.player,
  });

  @override
  String toString() =>
      "TTTPlayerMoveInput[now:$nowUtc,index:$index,player:$player]";
}

class TicTacToeEngineMoveInput extends TicTacToeInputBase {
  int index;
  TicTacToeCellState enginePlayer;

  TicTacToeEngineMoveInput({
    required super.nowUtc,
    required this.index,
    required this.enginePlayer,
  });

  @override
  String toString() =>
      "TTTEngineMoveInput[now:$nowUtc,index:$index,enginePlayer:$enginePlayer]";
}

class TicTacToeUpdateTime extends TicTacToeInputBase {
  TicTacToeUpdateTime({required super.nowUtc});

  @override
  String toString() => "TTTUpdateTime[now:$nowUtc]";
}
