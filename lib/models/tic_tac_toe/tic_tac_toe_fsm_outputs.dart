import 'package:duoplay/models/result.dart';
import 'package:duoplay/models/tic_tac_toe/tic_tac_toe_cell_state.dart';
import 'package:duoplay/models/tic_tac_toe/tic_tac_toe_game_configuration.dart';
import 'package:duoplay/models/tic_tac_toe/tic_tac_toe_game_state.dart';

abstract class TTTOutputBase {}

class TTTStartGameOutput implements TTTOutputBase {
  TTTGameConfiguration configuration;

  TTTStartGameOutput(this.configuration);

  @override
  String toString() => 'TTTStartGameOutput[configuration: $configuration]';
}

class TTTNewBoardOutput implements TTTOutputBase {
  TicTacToeGameState gameState;

  TTTNewBoardOutput({required this.gameState});

  @override
  String toString() => 'TTTNewBoardOutput[gameState: $gameState]';
}

class TTTGameOverOutput implements TTTOutputBase {
  TicTacToeCellState winner;
  bool isDraw;

  TTTGameOverOutput({required this.winner, required this.isDraw}) {
    if (winner == TicTacToeCellState.empty && !isDraw) {
      throw ArgumentError('Game has no winner and is not a draw');
    }
    if (isDraw && winner != TicTacToeCellState.empty) {
      throw ArgumentError('Game is both a draw and has a winner');
    }
  }

  @override
  String toString() => 'TTTGameOverOutput[winner: $winner, isDraw: $isDraw]';
}

class TTTDoEngineMoveOutput implements TTTOutputBase {
  @override
  String toString() => 'TTTDoEngineMoveOutput[]';
}

class TTTErrorOutput implements TTTOutputBase {
  Result results;

  TTTErrorOutput({required this.results}) {
    if (results.isSuccess) {
      throw ArgumentError('Result cannot be successful for this type');
    }
  }

  @override
  String toString() => 'TTTErrorOutput[results: $results]';
}
