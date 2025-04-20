import 'package:duoplay/models/tic_tac_toe/tic_tac_toe_constants.dart';
import 'package:duoplay/models/turn_based_game/turn_based_game_board.dart';
import 'package:duoplay/models/turn_based_game/turn_based_game_logic.dart';
import 'package:duoplay/models/turn_based_game/turn_based_game_utils.dart';
import 'package:flutter/foundation.dart';

class TTTGameLogic extends TurnBasedGameLogic {
  @override
  int get rows => 3;

  @override
  int get columns => 3;

  @override
  TurnBasedGameBoard parseBoard(String boardString) =>
      TurnBasedGameBoard.fromList(
        boardString
            .trim()
            .split('\n')
            .expand(
              (row) => row.trim().split(RegExp(r'\s+')).map((cell) {
                switch (cell) {
                  case 'X':
                  case 'x':
                    return TurnBasedGameCellState.player1;
                  case 'O':
                  case 'o':
                    return TurnBasedGameCellState.player2;
                  default:
                    return TurnBasedGameCellState.empty;
                }
              }),
            )
            .toList(),
      );

  @override
  void applyMove(
    TurnBasedGameBoard board,
    int index,
    TurnBasedGameCellState chipColor,
  ) {
    if (!isLegalMove(board, index)) {
      throw Exception('Illegal move at index $index');
    }

    board[index] = chipColor;
  }

  @override
  void debugPrintBoard(TurnBasedGameBoard board) {
    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < columns; col++) {
        final cell = board[row * columns + col];
        debugPrint(
          cell == TurnBasedGameCellState.empty
              ? '.'
              : (cell == TurnBasedGameCellState.player1 ? 'X' : 'O'),
        );
      }
      debugPrint('\n');
    }
    debugPrint('------------------');
  }

  @override
  TurnBasedGameCellState getWinner(TurnBasedGameBoard board) {
    for (var combination in TTTConstants.winningCombinations) {
      final a = combination[0];
      final b = combination[1];
      final c = combination[2];

      // If all three cells in the combination are the same and not empty, we have a winner
      if (board[a] != TurnBasedGameCellState.empty &&
          board[a] == board[b] &&
          board[a] == board[c]) {
        return board[a]; // Return the winner (TicTacToeCellState.x or TicTacToeCellState.o)
      }
    }

    return TurnBasedGameCellState.empty;
  }

  @override
  bool isDraw(TurnBasedGameBoard board) {
    if (!board.isFull) return false;

    return getWinner(board) == TurnBasedGameCellState.empty;
  }

  @override
  bool isLegalMove(TurnBasedGameBoard board, int index) =>
      index >= 0 &&
      index < numCells &&
      board[index] == TurnBasedGameCellState.empty;
}
