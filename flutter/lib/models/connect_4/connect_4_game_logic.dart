import 'package:duoplay/models/turn_based_game/turn_based_game_utils.dart';
import 'package:flutter/material.dart';

class Connect4GameLogic {
  /// Number of columns in the Connect 4 board.
  static const int columns = 7;

  /// Number of rows in the Connect 4 board.
  static const int rows = 6;

  static const int numCells = columns * rows;

  /// A helper method to determine the target position for a chip in a given column.
  ///
  /// This method calculates the lowest available row in the specified column
  /// where a chip can be placed. It assumes a 2D list `board` representing the
  /// current state of the game, where `TurnBasedGameCellState.empty` indicates an empty slot.
  static int? getTargetIndex(List<TurnBasedGameCellState> board, int index) {
    final column = index % columns;
    final row = index ~/ columns;
    // Check if the column is within bounds
    if (column < 0 || column >= columns) {
      return null; // Invalid column
    }
    // Check if the row is within bounds
    if (row < 0 || row >= rows) {
      return null; // Invalid row
    }
    // Check the column for the lowest available row
    for (int r = rows - 1; r >= 0; r--) {
      int thisRowIndex = r * columns + column;
      if (board[thisRowIndex] == TurnBasedGameCellState.empty) {
        return r * columns + column; // Return the index of the available cell
      }
    }
    return null; // Column is full
  }

  /// Checks if a move is legal in the given column.
  static bool isLegalMove(List<TurnBasedGameCellState> board, int index) {
    return getTargetIndex(board, index) != null;
  }

  /// Applies a move to the board by placing the chip in the lowest available row.
  static void applyMove(
    List<TurnBasedGameCellState> board,
    int index,
    TurnBasedGameCellState chipColor,
  ) {
    final targetIndex = getTargetIndex(board, index);
    if (targetIndex != null) {
      board[targetIndex] = chipColor;
    }
  }

  /// Checks if there is a winner on the board.
  /// If no winner is found, it returns `TurnBasedGameCellState.empty`.
  static TurnBasedGameCellState getWinner(List<TurnBasedGameCellState> board) {
    // Check horizontal, vertical, and diagonal lines for a winner.
    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < columns; col++) {
        final winner = _checkWinnerFromCell(board, row, col);
        if (winner != TurnBasedGameCellState.empty) {
          return winner;
        }
      }
    }
    return TurnBasedGameCellState.empty; // No winner found
  }

  /// Checks if the board is completely filled and there is no winner, resulting in a draw.
  static bool isDraw(List<TurnBasedGameCellState> board) {
    // Check if the board is completely filled
    if (!board.every((cell) => cell != TurnBasedGameCellState.empty)) {
      return false;
    }

    // Check if there is a winner
    return getWinner(board) == TurnBasedGameCellState.empty;
  }

  static void debugPrintBoard(List<TurnBasedGameCellState> board) {
    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < columns; col++) {
        final cell = board[row * columns + col];
        debugPrint(
          cell == TurnBasedGameCellState.empty
              ? '.'
              : (cell == TurnBasedGameCellState.player1 ? 'R' : 'Y'),
        );
      }
      debugPrint('\n');
    }
    debugPrint('------------------');
  }

  /// Converts a string representation of a board into a 2D list of TurnBasedGameCellState.
  static List<TurnBasedGameCellState> parseBoard(String boardString) =>
      boardString
          .trim()
          .split('\n')
          .expand(
            (row) => row.trim().split(RegExp(r'\s+')).map((cell) {
              switch (cell) {
                case 'R':
                case 'r':
                  return TurnBasedGameCellState.player1;
                case 'Y':
                case 'y':
                  return TurnBasedGameCellState.player2;
                default:
                  return TurnBasedGameCellState.empty;
              }
            }),
          )
          .toList();

  /// Helper method to check for a winner starting from a specific cell.
  /// If no winner is found, it returns `TurnBasedGameCellState.empty`.
  static TurnBasedGameCellState _checkWinnerFromCell(
    List<TurnBasedGameCellState> board,
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
    List<TurnBasedGameCellState> board,
    int startRow,
    int startCol,
    int rowDelta,
    int colDelta,
  ) {
    int initialIndex = startRow * columns + startCol;
    if (initialIndex < 0 ||
        initialIndex >= board.length ||
        startRow < 0 ||
        startRow >= rows ||
        startCol < 0 ||
        startCol >= columns) {
      return TurnBasedGameCellState.empty; // Out of bounds
    }
    final initial = board[initialIndex];
    if (initial == TurnBasedGameCellState.empty) {
      return TurnBasedGameCellState.empty;
    }

    for (int i = 1; i < 4; i++) {
      final newRow = startRow + i * rowDelta;
      final newCol = startCol + i * colDelta;
      final newIndex = newRow * columns + newCol;

      if (newRow < 0 ||
          newRow >= rows ||
          newCol < 0 ||
          newCol >= columns ||
          newIndex < 0 ||
          newIndex >= board.length) {
        return TurnBasedGameCellState.empty; // Out of bounds
      }

      if (board[newIndex] != initial) {
        return TurnBasedGameCellState.empty; // Not a match
      }
    }

    return initial; // Found a winner
  }
}
