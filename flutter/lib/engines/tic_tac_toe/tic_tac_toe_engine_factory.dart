import 'package:duoplay/engines/tic_tac_toe/tic_tac_toe_engine_contract.dart';
import 'package:duoplay/models/tic_tac_toe/tic_tac_toe_game_logic.dart';

class TTTEngineFactory {
  static TTTEngineContract createEngine(String difficulty) {
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
