import 'package:duoplay/models/connect_4/connect_4_enums.dart';

class Connect4GameLogic {
  /// A helper method to determine the target position for a chip in a given column.
  /// 
  /// This method calculates the lowest available row in the specified column
  /// where a chip can be placed. It assumes a 2D list `board` representing the
  /// current state of the game, where `Connect4SquareState.empty` indicates an empty slot.
  static int? getTargetRow(List<List<Connect4SquareState>> board, int column) {
    const int rows = 6; // Number of rows in the Connect 4 board

    for (int row = rows - 1; row >= 0; row--) {
      if (board[row][column] == Connect4SquareState.empty) {
        return row;
      }
    }
    return null; // Column is full
  }

  /// Checks if a move is legal in the given column.
  static bool isLegalMove(List<List<Connect4SquareState>> board, int column) {
    return getTargetRow(board, column) != null;
  }

  /// Applies a move to the board by placing the chip in the lowest available row.
  static void applyMove(List<List<Connect4SquareState>> board, int column, Connect4SquareState chipColor) {
    final row = getTargetRow(board, column);
    if (row != null) {
      board[row][column] = chipColor;
    }
  }

  /// Checks if there is a winner on the board.
  /// If no winner is found, it returns `Connect4SquareState.empty`.
  static Connect4SquareState getWinner(List<List<Connect4SquareState>> board) {
    // Check horizontal, vertical, and diagonal lines for a winner.
    for (int row = 0; row < board.length; row++) {
      for (int col = 0; col < board[row].length; col++) {
        final winner = _checkWinnerFromCell(board, row, col);
        if (winner != Connect4SquareState.empty) {
          return winner;
        }
      }
    }
    return Connect4SquareState.empty; // No winner found
  }

  /// Checks if the board is completely filled and there is no winner, resulting in a draw.
  static bool isDraw(List<List<Connect4SquareState>> board) {
    // Check if the board is completely filled
    if (!board.every((row) => row.every((cell) => cell != Connect4SquareState.empty))) {
      return false;
    }

    // Check if there is a winner
    return getWinner(board) == Connect4SquareState.empty;
  }

  /// Helper method to check for a winner starting from a specific cell.
  /// If no winner is found, it returns `Connect4SquareState.empty`.
  static Connect4SquareState _checkWinnerFromCell(List<List<Connect4SquareState>> board, int row, int col) {
    final directions = [
      [0, 1], // Horizontal
      [1, 0], // Vertical
      [1, 1], // Diagonal down-right
      [1, -1] // Diagonal down-left
    ];

    for (final direction in directions) {
      final winner = _checkDirection(board, row, col, direction[0], direction[1]);
      if (winner != Connect4SquareState.empty) {
        return winner;
      }
    }
    return Connect4SquareState.empty;
  }

  /// Helper method to check a specific direction for four consecutive chips.
  /// If no winner is found, it returns `Connect4SquareState.empty`.
  static Connect4SquareState _checkDirection(
    List<List<Connect4SquareState>> board,
    int startRow,
    int startCol,
    int rowDelta,
    int colDelta,
  ) {
    final initial = board[startRow][startCol];
    if (initial == Connect4SquareState.empty) {
      return Connect4SquareState.empty;
    }

    for (int i = 1; i < 4; i++) {
      final newRow = startRow + i * rowDelta;
      final newCol = startCol + i * colDelta;

      if (newRow < 0 || newRow >= board.length || newCol < 0 || newCol >= board[0].length) {
        return Connect4SquareState.empty; // Out of bounds
      }

      if (board[newRow][newCol] != initial) {
        return Connect4SquareState.empty; // Not a match
      }
    }

    return initial; // Found a winner
  }
}
