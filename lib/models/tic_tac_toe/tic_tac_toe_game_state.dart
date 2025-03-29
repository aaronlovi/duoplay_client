import 'package:duoplay/models/result.dart';
import 'package:duoplay/models/tic_tac_toe/tic_tac_toe_cell_state.dart';

class TicTacToeGameState {
  static final int numSquares = 9;

  final List<TicTacToeCellState> board;
  final TicTacToeCellState currentPlayer;
  final TicTacToeCellState winner;
  final int? lastMoveIndex;
  final int numberOfX;
  final int numberOfY;

  TicTacToeGameState._(
    this.board,
    this.currentPlayer,
    this.winner,
    this.lastMoveIndex,
    this.numberOfX,
    this.numberOfY,
  );

  factory TicTacToeGameState.initial() {
    return TicTacToeGameState._(
      List<TicTacToeCellState>.filled(numSquares, TicTacToeCellState.empty),
      TicTacToeCellState.x,
      TicTacToeCellState.empty,
      null,
      0,
      0,
    );
  }

  bool get isDraw =>
      numberOfX + numberOfY == numSquares && winner == TicTacToeCellState.empty;
  bool get hasWinner => winner != TicTacToeCellState.empty;
  bool get isGameOver => isDraw || hasWinner;

  Result<TicTacToeGameState> makeMove(int index, TicTacToeCellState player) {
    if (index < 0 || index >= TicTacToeGameState.numSquares) {
      return Result.failure(ResultErrorCode.invalidMove);
    }

    if (winner != TicTacToeCellState.empty) {
      return Result.failure(ResultErrorCode.gameOver);
    }

    if (board[index] != TicTacToeCellState.empty) {
      return Result.failure(ResultErrorCode.invalidMove);
    }

    if (player == TicTacToeCellState.x && numberOfX != numberOfY) {
      return Result.failure(ResultErrorCode.invalidMove);
    }

    if (player == TicTacToeCellState.o && numberOfX <= numberOfY) {
      return Result.failure(ResultErrorCode.invalidMove);
    }

    final newBoard = List<TicTacToeCellState>.from(board);
    newBoard[index] = player;

    final newNumberOfX =
        player == TicTacToeCellState.x ? numberOfX + 1 : numberOfX;
    final newNumberOfY =
        player == TicTacToeCellState.o ? numberOfY + 1 : numberOfY;
    final TicTacToeCellState newWinner = getWinner();
    final TicTacToeCellState nextPlayersTurn =
        player == TicTacToeCellState.x
            ? TicTacToeCellState.o
            : TicTacToeCellState.x;

    return Result.success(
      TicTacToeGameState._(
        newBoard,
        nextPlayersTurn,
        newWinner,
        index,
        newNumberOfX,
        newNumberOfY,
      ),
    );
  }

  TicTacToeCellState getWinner() {
    const winningCombinations = [
      [0, 1, 2], // Top row
      [3, 4, 5], // Middle row
      [6, 7, 8], // Bottom row
      [0, 3, 6], // Left column
      [1, 4, 7], // Middle column
      [2, 5, 8], // Right column
      [0, 4, 8], // Diagonal top-left to bottom-right
      [2, 4, 6], // Diagonal top-right to bottom-left
    ];

    // Check each winning combination
    for (var combination in winningCombinations) {
      final a = combination[0];
      final b = combination[1];
      final c = combination[2];

      // If all three cells in the combination are the same and not empty, we have a winner
      if (board[a] != TicTacToeCellState.empty &&
          board[a] == board[b] &&
          board[a] == board[c]) {
        return board[a]; // Return the winner (TicTacToeCellState.x or TicTacToeCellState.o)
      }
    }

    return TicTacToeCellState.empty;
  }
}
