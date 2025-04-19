import 'package:duoplay/models/turn-based-game/turn_based_game_configuration.dart';
import 'package:duoplay/models/turn-based-game/turn_based_game_fsm_inputs.dart';
import 'package:duoplay/models/turn-based-game/turn_based_game_utils.dart';

class TTTGameConfigInput extends TurnBasedGameFsmInputBase {
  TurnBasedGameConfiguration configuration;

  TTTGameConfigInput({required super.nowUtc, required this.configuration});

  @override
  String toString() => "TTTGameConfigInput[now:$nowUtc,config:$configuration]";
}

class TTTPlayerMoveInput extends TurnBasedGameFsmInputBase {
  int index;
  TurnBasedGameCellState player;

  TTTPlayerMoveInput({
    required super.nowUtc,
    required this.index,
    required this.player,
  });

  @override
  String toString() =>
      "TTTPlayerMoveInput[now:$nowUtc,index:$index,player:$player]";
}

class TTTEngineMoveInput extends TurnBasedGameFsmInputBase {
  int index;
  TurnBasedGameCellState enginePlayer;

  TTTEngineMoveInput({
    required super.nowUtc,
    required this.index,
    required this.enginePlayer,
  });

  @override
  String toString() =>
      "TTTEngineMoveInput[now:$nowUtc,index:$index,enginePlayer:$enginePlayer]";
}

class TTTUpdateTime extends TurnBasedGameFsmInputBase {
  TTTUpdateTime({required super.nowUtc});

  @override
  String toString() => "TTTUpdateTime[now:$nowUtc]";
}

class TTTSettingsChangeInput extends TurnBasedGameFsmInputBase {
  final String newDifficulty;
  final int betweenMoveDelaySeconds;
  final int betweenGameDelaySeconds;

  TTTSettingsChangeInput({
    required this.newDifficulty,
    required this.betweenMoveDelaySeconds,
    required this.betweenGameDelaySeconds,
    required super.nowUtc,
  });

  @override
  String toString() =>
      'TTTSetEngineDifficultyInput[newDifficulty:$newDifficulty,betweenMoveDelaySeconds:$betweenMoveDelaySeconds,betweenGameDelaySeconds:$betweenGameDelaySeconds]';
}
