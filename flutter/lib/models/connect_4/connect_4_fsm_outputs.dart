import 'package:duoplay/models/connect_4/connect_4_game_state.dart';
import 'package:duoplay/models/result.dart';
import 'package:duoplay/models/turn-based-game/turn_based_game_configuration.dart';
import 'package:duoplay/models/turn-based-game/turn_based_game_fsm_outputs.dart';
import 'package:duoplay/models/turn-based-game/turn_based_game_utils.dart';

class Connect4StartGameOutput implements TurnBasedGameFsmOutputBase {
  final TurnBasedGameConfiguration configuration;

  Connect4StartGameOutput(this.configuration);

  @override
  String toString() => 'Connect4StartGameOutput[configuration: $configuration]';
}

class Connect4NewBoardOutput implements TurnBasedGameFsmOutputBase {
  Connect4GameState gameState;

  Connect4NewBoardOutput({required this.gameState});

  @override
  String toString() => 'Connect4NewBoardOutput[gameState: $gameState]';
}

class Connect4GameOverOutput implements TurnBasedGameFsmOutputBase {
  final TurnBasedGameCellState winner;
  final bool isDraw;

  Connect4GameOverOutput({required this.winner, required this.isDraw}) {
    if (winner == TurnBasedGameCellState.empty && !isDraw) {
      throw ArgumentError('Game has no winner and is not a draw');
    }
    if (isDraw && winner != TurnBasedGameCellState.empty) {
      throw ArgumentError('Game is both a draw and has a winner');
    }
  }

  @override
  String toString() => 'Connect4GameOverOutput[winner: $winner, isDraw: $isDraw]';
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