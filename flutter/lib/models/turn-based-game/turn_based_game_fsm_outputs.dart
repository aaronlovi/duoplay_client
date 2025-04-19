import 'package:duoplay/models/turn-based-game/turn_based_game_configuration.dart';

abstract class TurnBasedGameFsmOutputBase {}

class TurnBasedGameStartGameFsmOutput implements TurnBasedGameFsmOutputBase {
  final TurnBasedGameConfiguration configuration;

  TurnBasedGameStartGameFsmOutput(this.configuration);

  @override
  String toString() => 'TurnBasedGameStartGameFsmOutput[configuration: $configuration]';
}
