import 'package:duoplay/models/result.dart';
import 'package:duoplay/models/tic_tac_toe/tic_tac_toe_cell_state.dart';
import 'package:duoplay/models/tic_tac_toe/tic_tac_toe_constants.dart';
import 'package:duoplay/models/tic_tac_toe/tic_tac_toe_game_configuration.dart';

class TicTacToeGameState {
  static final int numSquares = 9;

  final List<TicTacToeCellState> board;
  TicTacToeCellState currentPlayer;
  TicTacToeCellState winner;
  int numberOfX;
  int numberOfO;
  DateTime nowUtc;
  DateTime? nextGameTimeUtc;
  DateTime? engineMoveTimeUtc;
  TTTGameConfiguration configuration;

  TicTacToeGameState._(
    this.board,
    this.currentPlayer,
    this.winner,
    this.numberOfX,
    this.numberOfO,
    this.nowUtc,
    this.configuration,
  );

  factory TicTacToeGameState.initial(
    TTTGameConfiguration cfg, {
    DateTime? nowUtc,
  }) => TicTacToeGameState._(
    List<TicTacToeCellState>.filled(numSquares, TicTacToeCellState.empty),
    TicTacToeCellState.x,
    TicTacToeCellState.empty,
    0,
    0,
    nowUtc ?? DateTime.now().toUtc(),
    cfg,
  );

  bool get isDraw =>
      numberOfX + numberOfO == numSquares && winner == TicTacToeCellState.empty;
  bool get hasWinner => winner != TicTacToeCellState.empty;
  bool get isGameOver => isDraw || hasWinner;
  bool get isHumanPlayerToMove =>
      currentPlayer != configuration.enginePlayer && !isGameOver;
  TicTacToeCellState get humanPlayer =>
      configuration.enginePlayer == TicTacToeCellState.x
          ? TicTacToeCellState.o
          : TicTacToeCellState.x;
  TicTacToeCellState get enginePlayer => configuration.enginePlayer;

  Result makeMove(int index, TicTacToeCellState player) {
    Result res = isLegalPositionReadyForMove();
    if (res.isFailure) {
      return Result.failure(
        res.errorCode,
        errorParameters: res.errorParameters,
      );
    }

    if (index < 0 || index >= TicTacToeGameState.numSquares) {
      return Result.failure(ResultErrorCode.invalidMove);
    }

    if (board[index] != TicTacToeCellState.empty) {
      return Result.failure(ResultErrorCode.invalidMove);
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

    bool newIsDraw =
        newNumberOfX + newNumberOfO == numSquares &&
        newWinner == TicTacToeCellState.empty;
    bool newHasWinner = newWinner != TicTacToeCellState.empty;
    bool newIsEnginesTurn =
        configuration.enginePlayer == nextPlayersTurn &&
        !newIsDraw &&
        !newHasWinner;
    DateTime? newNextGameTimeUtc;
    DateTime? newEngineMoveTimeUtc;
    if (newIsDraw || newHasWinner) {
      newNextGameTimeUtc = nowUtc.add(configuration.betweenGamesWaitTime);
    }
    if (newIsEnginesTurn) {
      newEngineMoveTimeUtc = nowUtc.add(
        configuration.engineMoveWaitTime ??
            TicTacToeConstants.defaultEngineMoveWaitTime,
      );
    }

    // Update game state
    for (int i = 0; i < board.length; ++i) {
      board[i] = newBoard[i];
    }
    currentPlayer = nextPlayersTurn;
    winner = newWinner;
    numberOfX = newNumberOfX;
    numberOfO = newNumberOfO;
    nextGameTimeUtc = newNextGameTimeUtc;
    engineMoveTimeUtc = newEngineMoveTimeUtc;

    return Result.success();
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

  /// Checks if the game is over, and if the board is set with the expected
  /// number of X's and O's
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

  void processNewGameConfiguration(TTTGameConfiguration cfg, DateTime nowUtc) {
    configuration = cfg;
    this.nowUtc = nowUtc;
  }

  void setupNextGame() {
    currentPlayer = TicTacToeCellState.x;
    winner = TicTacToeCellState.empty;
    numberOfX = 0;
    numberOfO = 0;
    configuration.changeSides();
    clearBoard();
    nextGameTimeUtc = null;
    engineMoveTimeUtc =
        configuration.enginePlayer == currentPlayer
            ? nowUtc.add(
              configuration.engineMoveWaitTime ??
                  TicTacToeConstants.defaultEngineMoveWaitTime,
            )
            : null;
  }

  void clearBoard() {
    for (int i = 0; i < board.length; ++i) {
      board[i] = TicTacToeCellState.empty;
    }
  }

  @override
  String toString() {
    return 'TicTacToeGameState[curPlayer:${currentPlayer.toShortString()},winner:${winner.toShortString()},numX:$numberOfX,numO:$numberOfO]';
  }
}
