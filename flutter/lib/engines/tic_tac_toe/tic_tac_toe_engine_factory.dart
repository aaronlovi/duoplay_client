import 'package:duoplay/engines/turn_based_game/turn_based_game_engine_contract.dart';
import 'package:duoplay/engines/turn_based_game/turn_based_game_engine_factory.dart';
import 'package:duoplay/models/tic_tac_toe/tic_tac_toe_game_logic.dart';

class TTTEngineFactory implements TurnBasedGameEngineFactory {
  @override
  TurnBasedGameEngineContract createEngine(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'beginner':
        return TTTBeginnerEngine(TTTGameLogic());
      case 'intermediate':
        return TTTIntermediateEngine(TTTGameLogic());
      case 'expert':
        return TTTExpertEngine(TTTGameLogic());
      default:
        throw ArgumentError('Invalid difficulty level: $difficulty');
    }
  }
}
