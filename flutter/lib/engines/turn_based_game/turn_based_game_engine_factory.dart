import 'package:duoplay/engines/turn_based_game/turn_based_game_engine_contract.dart';

abstract class TurnBasedGameEngineFactory {
  TurnBasedGameEngineContract createEngine(String difficulty);
}
