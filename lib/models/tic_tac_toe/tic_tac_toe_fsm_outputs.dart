import 'package:duoplay/models/result.dart';
import 'package:duoplay/models/tic_tac_toe/tic_tac_toe_cell_state.dart';
import 'package:duoplay/models/tic_tac_toe/tic_tac_toe_game_state.dart';
import 'package:duoplay/models/unit.dart';

abstract class TicTacToeOutput {}

class TicTacToeNewBoardOutput implements TicTacToeOutput {
  TicTacToeGameState gameState;

  TicTacToeNewBoardOutput({required this.gameState});
}

class TicTacToeGameOverOutput implements TicTacToeOutput {
  TicTacToeCellState winner;
  bool isDraw;

  TicTacToeGameOverOutput({required this.winner, required this.isDraw}) {
    if (winner == TicTacToeCellState.empty && !isDraw) {
      throw ArgumentError('Game has no winner and is not a draw');
    }
    if (isDraw && winner != TicTacToeCellState.empty) {
      throw ArgumentError('Game is both a draw and has a winner');
    }
  }
}

class TicTacToeErrorOutput implements TicTacToeOutput {
  Result<Unit> results;

  TicTacToeErrorOutput({required this.results}) {
    if (results.isSuccess) {
      throw ArgumentError('Result cannot be successful for this type');
    }
  }
}
