import 'package:duoplay/models/turn-based-game/turn_based_game_configuration.dart';

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
