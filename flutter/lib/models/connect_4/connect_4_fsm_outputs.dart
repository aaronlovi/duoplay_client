import 'package:duoplay/models/connect_4/connect_4_game_state.dart';
import 'package:duoplay/models/result.dart';
import 'package:duoplay/models/connect_4/connect_4_enums.dart';
import 'package:duoplay/models/connect_4/connect_4_game_configuration.dart';

abstract class Connect4OutputBase {}

class Connect4StartGameOutput implements Connect4OutputBase {
  final Connect4GameConfiguration configuration;

  Connect4StartGameOutput(this.configuration);

  @override
  String toString() => 'Connect4StartGameOutput[configuration: $configuration]';
}

class Connect4NewBoardOutput implements Connect4OutputBase {
  Connect4GameState gameState;

  Connect4NewBoardOutput({required this.gameState});

  @override
  String toString() => 'Connect4NewBoardOutput[gameState: $gameState]';
}

class Connect4GameOverOutput implements Connect4OutputBase {
  final Connect4SquareState winner;
  final bool isDraw;

  Connect4GameOverOutput({required this.winner, required this.isDraw}) {
    if (winner == Connect4SquareState.empty && !isDraw) {
      throw ArgumentError('Game has no winner and is not a draw');
    }
    if (isDraw && winner != Connect4SquareState.empty) {
      throw ArgumentError('Game is both a draw and has a winner');
    }
  }

  @override
  String toString() => 'Connect4GameOverOutput[winner: $winner, isDraw: $isDraw]';
}

class Connect4DoEngineMoveOutput implements Connect4OutputBase {
  @override
  String toString() => 'Connect4DoEngineMoveOutput[]';
}

class Connect4ErrorOutput implements Connect4OutputBase {
  final Result results;

  Connect4ErrorOutput({required this.results}) {
    if (results.isSuccess) {
      throw ArgumentError('Result cannot be successful for this type');
    }
  }

  @override
  String toString() => 'Connect4ErrorOutput[results: $results]';
}