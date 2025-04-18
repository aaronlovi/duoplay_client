import 'package:duoplay/engines/connect_4/connect_4_beginner_engine.dart';
import 'package:duoplay/engines/connect_4/connect_4_engine_contract.dart';

class Connect4EngineFactory {
  static Connect4EngineContract createEngine(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'beginner':
      case 'intermediate':
      case 'expert':
        return Connect4BeginnerEngine(); // Currently all difficulties return the beginner engine
      default:
        throw ArgumentError('Invalid difficulty level: $difficulty');
    }
  }
}