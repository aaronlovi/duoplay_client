import 'package:duoplay/engines/turn_based_game/turn_based_game_engine_contract.dart';
import 'package:duoplay/models/connect_4/connect_4_game_logic.dart';

class Connect4EngineFactory {
  static TurnBasedGameEngineContract createEngine(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'beginner':
        return Connect4BeginnerEngine(Connect4GameLogic());
      case 'intermediate':
        return Connect4IntermediateEngine(Connect4GameLogic());
      case 'expert':
        return Connect4ExpertEngine(Connect4GameLogic());
      default:
        throw ArgumentError('Invalid difficulty level: $difficulty');
    }
  }
}
