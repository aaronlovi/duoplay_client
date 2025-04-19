import 'package:duoplay/engines/connect_4/connect_4_beginner_engine.dart';
import 'package:duoplay/engines/connect_4/connect_4_engine_contract.dart';
import 'package:duoplay/engines/connect_4/connect_4_expert_engine.dart';
import 'package:duoplay/engines/connect_4/connect_4_intermediate_engine.dart';

class Connect4EngineFactory {
  static Connect4EngineContract createEngine(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'beginner':
        return Connect4BeginnerEngine();
      case 'intermediate':
        return Connect4IntermediateEngine();
      case 'expert':
        return Connect4ExpertEngine();
      default:
        throw ArgumentError('Invalid difficulty level: $difficulty');
    }
  }
}
