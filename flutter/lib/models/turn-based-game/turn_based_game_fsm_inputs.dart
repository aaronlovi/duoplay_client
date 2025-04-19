import 'package:duoplay/models/turn-based-game/turn_based_game_configuration.dart';
import 'package:duoplay/models/turn-based-game/turn_based_game_utils.dart';

abstract class TurnBasedGameFsmInputBase {
  final DateTime nowUtc;

  TurnBasedGameFsmInputBase({required this.nowUtc});
}

class TurnBasedGameConfigFsmInput extends TurnBasedGameFsmInputBase {
  TurnBasedGameConfiguration configuration;

  TurnBasedGameConfigFsmInput({required super.nowUtc, required this.configuration});

  @override
  String toString() => "TurnBasedGameConfigFsmInput[now:$nowUtc,config:$configuration]";
}

class TurnBasedGamePlayerMoveFsmInput extends TurnBasedGameFsmInputBase {
  final int index;
  final TurnBasedGameCellState player;

  TurnBasedGamePlayerMoveFsmInput({
    required super.nowUtc,
    required this.index,
    required this.player,
  });

  @override
  String toString() =>
      "TurnBasedGamePlayerMoveFsmInput[now:$nowUtc,index:$index,player:$player]";
}

class TurnBasedGameEngineMoveFsmInput extends TurnBasedGameFsmInputBase {
  final int index;
  final TurnBasedGameCellState enginePlayer;

  TurnBasedGameEngineMoveFsmInput({
    required super.nowUtc,
    required this.index,
    required this.enginePlayer,
  });

  @override
  String toString() =>
      "TurnBasedGameEngineMoveFsmInput[now:$nowUtc,index:$index,enginePlayer:$enginePlayer]";
}

class TurnBasedGameUpdateTimeFsmInput extends TurnBasedGameFsmInputBase {
  TurnBasedGameUpdateTimeFsmInput({required super.nowUtc});

  @override
  String toString() => "TurnBasedGameUpdateTimeFsmInput[now:$nowUtc]";
}
