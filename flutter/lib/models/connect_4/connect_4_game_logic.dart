import 'package:duoplay/models/turn_based_game/turn_based_game_utils.dart';
import 'package:flutter/material.dart';

class Connect4GameLogic {
  /// Number of columns in the Connect 4 board.
  static const int columns = 7;

  /// Number of rows in the Connect 4 board.
  static const int rows = 6;

  /// A helper method to determine the target position for a chip in a given column.
  ///
  /// This method calculates the lowest available row in the specified column
  /// where a chip can be placed. It assumes a 2D list `board` representing the
  /// current state of the game, where `TurnBasedGameCellState.empty` indicates an empty slot.
  static int? getTargetRow(List<List<TurnBasedGameCellState>> board, int column) {
    const int rows = 6; // Number of rows in the Connect 4 board

    for (int row = rows - 1; row >= 0; row--) {
      if (board[row][column] == TurnBasedGameCellState.empty) {
        return row;
      }
    }
    return null; // Column is full
  }

  /// Checks if a move is legal in the given column.
  static bool isLegalMove(List<List<TurnBasedGameCellState>> board, int column) {
    return getTargetRow(board, column) != null;
  }

  /// Applies a move to the board by placing the chip in the lowest available row.
  static void applyMove(
    List<List<TurnBasedGameCellState>> board,
    int column,
    TurnBasedGameCellState chipColor,
  ) {
    final row = getTargetRow(board, column);
    if (row != null) {
      board[row][column] = chipColor;
    }
  }

  /// Checks if there is a winner on the board.
  /// If no winner is found, it returns `TurnBasedGameCellState.empty`.
  static TurnBasedGameCellState getWinner(List<List<TurnBasedGameCellState>> board) {
    // Check horizontal, vertical, and diagonal lines for a winner.
    for (int row = 0; row < board.length; row++) {
      for (int col = 0; col < board[row].length; col++) {
        final winner = _checkWinnerFromCell(board, row, col);
        if (winner != TurnBasedGameCellState.empty) {
          return winner;
        }
      }
    }
    return TurnBasedGameCellState.empty; // No winner found
  }

  /// Checks if the board is completely filled and there is no winner, resulting in a draw.
  static bool isDraw(List<List<TurnBasedGameCellState>> board) {
    // Check if the board is completely filled
    if (!board.every(
      (row) => row.every((cell) => cell != TurnBasedGameCellState.empty),
    )) {
      return false;
    }

    // Check if there is a winner
    return getWinner(board) == TurnBasedGameCellState.empty;
  }

  static void debugPrintBoard(List<List<TurnBasedGameCellState>> board) {
    // Print the board for debugging
    for (final row in board) {
      debugPrint(
        row
            .map(
              (cell) =>
                  cell == TurnBasedGameCellState.empty
                      ? '.'
                      : (cell == TurnBasedGameCellState.player1 ? 'R' : 'Y'),
            )
            .join(' '),
      );
    }
  }

  /// Converts a string representation of a board into a 2D list of TurnBasedGameCellState.
  static List<List<TurnBasedGameCellState>> parseBoard(String boardString) {
    return boardString
        .trim()
        .split('\n')
        .map(
          (row) =>
              row.trim().split(RegExp(r'\s+')).map((cell) {
                switch (cell) {
                  case 'R':
                    return TurnBasedGameCellState.player1;
                  case 'r':
                    return TurnBasedGameCellState.player1;
                  case 'Y':
                    return TurnBasedGameCellState.player2;
                  case 'y':
                    return TurnBasedGameCellState.player2;
                  default:
                    return TurnBasedGameCellState.empty;
                }
              }).toList(),
        )
        .toList();
  }

  /// Helper method to check for a winner starting from a specific cell.
  /// If no winner is found, it returns `TurnBasedGameCellState.empty`.
  static TurnBasedGameCellState _checkWinnerFromCell(
    List<List<TurnBasedGameCellState>> board,
    int row,
    int col,
  ) {
    final directions = [
      [0, 1], // Horizontal
      [1, 0], // Vertical
      [1, 1], // Diagonal down-right
      [1, -1], // Diagonal down-left
    ];

    for (final direction in directions) {
      final winner = _checkDirection(
        board,
        row,
        col,
        direction[0],
        direction[1],
      );
      if (winner != TurnBasedGameCellState.empty) {
        return winner;
      }
    }
    return TurnBasedGameCellState.empty;
  }

  /// Helper method to check a specific direction for four consecutive chips.
  /// If no winner is found, it returns `TurnBasedGameCellState.empty`.
  static TurnBasedGameCellState _checkDirection(
    List<List<TurnBasedGameCellState>> board,
    int startRow,
    int startCol,
    int rowDelta,
    int colDelta,
  ) {
    final initial = board[startRow][startCol];
    if (initial == TurnBasedGameCellState.empty) {
      return TurnBasedGameCellState.empty;
    }

    for (int i = 1; i < 4; i++) {
      final newRow = startRow + i * rowDelta;
      final newCol = startCol + i * colDelta;

      if (newRow < 0 ||
          newRow >= board.length ||
          newCol < 0 ||
          newCol >= board[0].length) {
        return TurnBasedGameCellState.empty; // Out of bounds
      }

      if (board[newRow][newCol] != initial) {
        return TurnBasedGameCellState.empty; // Not a match
      }
    }

    return initial; // Found a winner
  }
}
