import 'package:duoplay/models/turn-based-game/turn_based_game_configuration.dart';
import 'package:duoplay/models/turn-based-game/turn_based_game_utils.dart';

abstract class Connect4InputBase {
  final DateTime nowUtc;

  Connect4InputBase({required this.nowUtc});
}

class Connect4GameConfigInput extends Connect4InputBase {
  final TurnBasedGameConfiguration configuration;

  Connect4GameConfigInput({required super.nowUtc, required this.configuration});

  @override
  String toString() => "Connect4GameConfigInput[now:$nowUtc,config:$configuration]";
}

class Connect4PlayerMoveInput extends Connect4InputBase {
  final int column;
  final TurnBasedGameCellState player;

  Connect4PlayerMoveInput({
    required super.nowUtc,
    required this.column,
    required this.player,
  });

  @override
  String toString() => "Connect4PlayerMoveInput[now:$nowUtc,column:$column,player:$player]";
}

class Connect4EngineMoveInput extends Connect4InputBase {
  final int column;
  final TurnBasedGameCellState enginePlayer;

  Connect4EngineMoveInput({
    required super.nowUtc,
    required this.column,
    required this.enginePlayer,
  });

  @override
  String toString() => "Connect4EngineMoveInput[now:$nowUtc,column:$column,enginePlayer:$enginePlayer]";
}

class Connect4UpdateTime extends Connect4InputBase {
  Connect4UpdateTime({required super.nowUtc});

  @override
  String toString() => "Connect4UpdateTime[now:$nowUtc]";
}

class Connect4SettingsChangeInput extends Connect4InputBase {
  final String newDifficulty;
  final int betweenMoveDelaySeconds;
  final int betweenGameDelaySeconds;

  Connect4SettingsChangeInput({
    required this.newDifficulty,
    required this.betweenMoveDelaySeconds,
    required this.betweenGameDelaySeconds,
    required super.nowUtc,
  });

  @override
  String toString() =>
      'Connect4SettingsChangeInput[newDifficulty:$newDifficulty,betweenMoveDelaySeconds:$betweenMoveDelaySeconds,betweenGameDelaySeconds:$betweenGameDelaySeconds]';
}