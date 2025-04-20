import 'package:duoplay/models/turn_based_game/turn_based_game_utils.dart';

class TurnBasedGameBoard {
  final List<TurnBasedGameCellState> board;

  TurnBasedGameBoard(int rows, int columns)
    : board = List.filled(rows * columns, TurnBasedGameCellState.empty);

  TurnBasedGameBoard.copy(TurnBasedGameBoard board)
    : board = List.from(board.board);

  TurnBasedGameBoard.fromList(List<TurnBasedGameCellState> board)
    : board = List.from(board);

  TurnBasedGameCellState operator [](int index) => board[index];

  void operator []=(int index, TurnBasedGameCellState value) {
    board[index] = value;
  }

  int get length => board.length;

  bool get isFull =>
      board.every((cell) => cell != TurnBasedGameCellState.empty);

  void reset() {
    for (int i = 0; i < board.length; i++) {
      board[i] = TurnBasedGameCellState.empty;
    }
  }

  void setAll(TurnBasedGameBoard newBoard) {
    if (newBoard.length != board.length) {
      throw ArgumentError("New board size does not match current board size.");
    }
    for (int i = 0; i < newBoard.length; i++) {
      board[i] = newBoard[i];
    }
  }
}
