import 'package:duoplay/models/connect_4/connect_4_game_state.dart';
import 'package:duoplay/models/result.dart';
import 'package:duoplay/models/turn-based-game/turn_based_game_fsm_outputs.dart';

class Connect4NewBoardOutput implements TurnBasedGameFsmOutputBase {
  Connect4GameState gameState;

  Connect4NewBoardOutput({required this.gameState});

  @override
  String toString() => 'Connect4NewBoardOutput[gameState: $gameState]';
}

class Connect4DoEngineMoveOutput implements TurnBasedGameFsmOutputBase {
  @override
  String toString() => 'Connect4DoEngineMoveOutput[]';
}

class Connect4ErrorOutput implements TurnBasedGameFsmOutputBase {
  final Result results;

  Connect4ErrorOutput({required this.results}) {
    if (results.isSuccess) {
      throw ArgumentError('Result cannot be successful for this type');
    }
  }

  @override
  String toString() => 'Connect4ErrorOutput[results: $results]';
}