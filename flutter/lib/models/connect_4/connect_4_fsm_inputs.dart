import 'package:duoplay/models/connect_4/connect_4_enums.dart';
import 'package:duoplay/models/connect_4/connect_4_game_configuration.dart';

abstract class Connect4InputBase {
  final DateTime nowUtc;

  Connect4InputBase({required this.nowUtc});
}

class Connect4GameConfigInput extends Connect4InputBase {
  final Connect4GameConfiguration configuration;

  Connect4GameConfigInput({required super.nowUtc, required this.configuration});

  @override
  String toString() => "Connect4GameConfigInput[now:$nowUtc,config:$configuration]";
}

class Connect4PlayerMoveInput extends Connect4InputBase {
  final int column;
  final Connect4SquareState player;

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
  final Connect4SquareState enginePlayer;

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