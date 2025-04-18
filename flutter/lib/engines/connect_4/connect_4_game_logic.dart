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
}