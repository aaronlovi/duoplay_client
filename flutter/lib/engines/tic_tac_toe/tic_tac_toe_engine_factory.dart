import 'package:duoplay/engines/tic_tac_toe/tic_tac_toe_beginner_engine.dart';
import 'package:duoplay/engines/tic_tac_toe/tic_tac_toe_engine_contract.dart';
import 'package:duoplay/engines/tic_tac_toe/tic_tac_toe_expert_engine.dart';
import 'package:duoplay/engines/tic_tac_toe/tic_tac_toe_intermediate_engine.dart';

class TTTEngineFactory {
  static TTTEngineContract createEngine(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'beginner':
        return TTTBeginnerEngine();
      case 'intermediate':
        return TTTIntermediateEngine();
      case 'expert':
        return TTTExpertEngine();
      default:
        throw ArgumentError('Invalid difficulty level: $difficulty');
    }
  }
}
