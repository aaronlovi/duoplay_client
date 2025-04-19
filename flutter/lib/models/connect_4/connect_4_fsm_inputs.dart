import 'package:duoplay/models/turn-based-game/turn_based_game_fsm_inputs.dart';

class Connect4UpdateTime extends TurnBasedGameFsmInputBase {
  Connect4UpdateTime({required super.nowUtc});

  @override
  String toString() => "Connect4UpdateTime[now:$nowUtc]";
}

class Connect4SettingsChangeInput extends TurnBasedGameFsmInputBase {
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
