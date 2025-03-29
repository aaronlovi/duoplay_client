import 'package:duoplay/models/result.dart';
import 'package:duoplay/models/tic_tac_toe/tic_tac_toe_cell_state.dart';
import 'package:duoplay/models/tic_tac_toe/tic_tac_toe_constants.dart';

class TicTacToeGameState {
  static final int numSquares = 9;

  final List<TicTacToeCellState> board;
  final TicTacToeCellState currentPlayer;
  final TicTacToeCellState winner;
  final int? lastMoveIndex;
  final int numberOfX;
  final int numberOfO;

  TicTacToeGameState._(
    this.board,
    this.currentPlayer,
    this.winner,
    this.lastMoveIndex,
    this.numberOfX,
    this.numberOfO,
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
      numberOfX + numberOfO == numSquares && winner == TicTacToeCellState.empty;
  bool get hasWinner => winner != TicTacToeCellState.empty;
  bool get isGameOver => isDraw || hasWinner;

  GenericResult<TicTacToeGameState> makeMove(
    int index,
    TicTacToeCellState player,
  ) {
    Result res = isLegalPositionReadyForMove();
    if (res.isFailure) {
      return GenericResult.failure(
        res.errorCode,
        errorParameters: res.errorParameters,
      );
    }

    if (index < 0 || index >= TicTacToeGameState.numSquares) {
      return GenericResult.failure(ResultErrorCode.invalidMove);
    }

    if (board[index] != TicTacToeCellState.empty) {
      return GenericResult.failure(ResultErrorCode.invalidMove);
    }

    final newBoard = List<TicTacToeCellState>.from(board);
    newBoard[index] = player;

    final newNumberOfX =
        player == TicTacToeCellState.x ? numberOfX + 1 : numberOfX;
    final newNumberOfO =
        player == TicTacToeCellState.o ? numberOfO + 1 : numberOfO;
    final TicTacToeCellState newWinner =
        winner == TicTacToeCellState.empty ? getWinner(newBoard) : winner;
    final TicTacToeCellState nextPlayersTurn =
        player == TicTacToeCellState.x
            ? TicTacToeCellState.o
            : TicTacToeCellState.x;

    return GenericResult.success(
      TicTacToeGameState._(
        newBoard,
        nextPlayersTurn,
        newWinner,
        index,
        newNumberOfX,
        newNumberOfO,
      ),
    );
  }

  TicTacToeCellState getWinner(List<TicTacToeCellState> board) {
    // Check each winning combination
    for (var combination in TicTacToeConstants.winningCombinations) {
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

  Result isLegalPositionReadyForMove() {
    if (isGameOver) return Result.failure(ResultErrorCode.gameOver);

    if (currentPlayer == TicTacToeCellState.x && numberOfX != numberOfO) {
      return Result.failure(ResultErrorCode.invalidState);
    }

    if (currentPlayer == TicTacToeCellState.o && numberOfX != numberOfO + 1) {
      return Result.failure(ResultErrorCode.invalidState);
    }

    return Result.success();
  }

  @override
  String toString() {
    return 'TicTacToeGameState[curPlayer:${currentPlayer.toShortString()},winner:${winner.toShortString()},lastMoveIndex:$lastMoveIndex,numX:$numberOfX,numO:$numberOfO]';
  }
}
