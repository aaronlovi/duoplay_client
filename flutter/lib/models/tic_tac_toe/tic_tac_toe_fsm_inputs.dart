import 'package:duoplay/models/tic_tac_toe/tic_tac_toe_cell_state.dart';
import 'package:duoplay/models/tic_tac_toe/tic_tac_toe_game_configuration.dart';

abstract class TTTInputBase {
  final DateTime nowUtc;

  TTTInputBase({required this.nowUtc});
}

class TTTGameConfigInput extends TTTInputBase {
  TTTGameConfiguration configuration;

  TTTGameConfigInput({required super.nowUtc, required this.configuration});

  @override
  String toString() => "TTTGameConfigInput[now:$nowUtc,config:$configuration]";
}

class TTTPlayerMoveInput extends TTTInputBase {
  int index;
  TTTCellState player;

  TTTPlayerMoveInput({
    required super.nowUtc,
    required this.index,
    required this.player,
  });

  @override
  String toString() =>
      "TTTPlayerMoveInput[now:$nowUtc,index:$index,player:$player]";
}

class TTTEngineMoveInput extends TTTInputBase {
  int index;
  TTTCellState enginePlayer;

  TTTEngineMoveInput({
    required super.nowUtc,
    required this.index,
    required this.enginePlayer,
  });

  @override
  String toString() =>
      "TTTEngineMoveInput[now:$nowUtc,index:$index,enginePlayer:$enginePlayer]";
}

class TTTUpdateTime extends TTTInputBase {
  TTTUpdateTime({required super.nowUtc});

  @override
  String toString() => "TTTUpdateTime[now:$nowUtc]";
}

class TTTSetEngineDifficultyInput extends TTTInputBase {
  final String newDifficulty;
  TTTSetEngineDifficultyInput({
    required this.newDifficulty,
    required super.nowUtc,
  });

  @override
  String toString() =>
      'TTTSetEngineDifficultyInput[newDifficulty:$newDifficulty]';
}
