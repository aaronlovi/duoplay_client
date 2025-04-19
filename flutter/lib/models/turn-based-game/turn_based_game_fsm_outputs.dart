import 'package:duoplay/models/result.dart';
import 'package:duoplay/models/turn-based-game/turn_based_game_configuration.dart';
import 'package:duoplay/models/turn-based-game/turn_based_game_utils.dart';

abstract class TurnBasedGameFsmOutputBase {}

class TurnBasedGameStartGameFsmOutput implements TurnBasedGameFsmOutputBase {
  final TurnBasedGameConfiguration configuration;

  TurnBasedGameStartGameFsmOutput(this.configuration);

  @override
  String toString() => 'TurnBasedGameStartGameFsmOutput[configuration: $configuration]';
}

class TurnBasedGameGameOverFsmOutput implements TurnBasedGameFsmOutputBase {
  final TurnBasedGameCellState winner;
  final bool isDraw;

  TurnBasedGameGameOverFsmOutput({required this.winner, required this.isDraw}) {
    if (winner == TurnBasedGameCellState.empty && !isDraw) {
      throw ArgumentError('Game has no winner and is not a draw');
    }
    if (isDraw && winner != TurnBasedGameCellState.empty) {
      throw ArgumentError('Game is both a draw and has a winner');
    }
  }

  @override
  String toString() => 'TurnBasedGameGameOverFsmOutput[winner: $winner, isDraw: $isDraw]';
}

class TurnBasedGameDoEngineMoveFsmOutput implements TurnBasedGameFsmOutputBase {
  @override
  String toString() => 'TurnBasedGameDoEngineMoveFsmOutput[]';
}

class TurnBasedGameErrorFsmOutput implements TurnBasedGameFsmOutputBase {
  final Result results;

  TurnBasedGameErrorFsmOutput({required this.results}) {
    if (results.isSuccess) {
      throw ArgumentError('Result cannot be successful for this type');
    }
  }

  @override
  String toString() => 'TurnBasedGameErrorFsmOutput[results: $results]';
}
