import 'package:duoplay/models/result.dart';
import 'package:duoplay/models/tic_tac_toe/tic_tac_toe_cell_state.dart';
import 'package:duoplay/models/tic_tac_toe/tic_tac_toe_constants.dart';
import 'package:duoplay/models/tic_tac_toe/tic_tac_toe_game_configuration.dart';

class TicTacToeGameState {
  static final int numSquares = 9;

  final List<TTTCellState> board;
  TTTCellState currentPlayer;
  TTTCellState winner;
  int numberOfX;
  int numberOfO;
  DateTime nowUtc;
  DateTime? nextGameTimeUtc;
  DateTime? engineMoveTimeUtc;
  TTTGameConfiguration configuration;

  // Made the constructor public to allow external instantiation for simulation purposes
  TicTacToeGameState(
    this.board,
    this.currentPlayer,
    this.winner,
    this.numberOfX,
    this.numberOfO,
    this.nowUtc,
    this.configuration,
  );

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
    List<TTTCellState>.filled(numSquares, TTTCellState.empty),
    TTTCellState.x,
    TTTCellState.empty,
    0,
    0,
    nowUtc ?? DateTime.now().toUtc(),
    cfg,
  );

  bool get isDraw =>
      numberOfX + numberOfO == numSquares && winner == TTTCellState.empty;
  bool get hasWinner => winner != TTTCellState.empty;
  bool get isBetweenGames => isGameOver || (numberOfX == 0 && numberOfO == 0);
  bool get isGameOver => isDraw || hasWinner;
  bool get isHumanPlayerToMove =>
      currentPlayer != configuration.enginePlayer && !isGameOver;
  TTTCellState get humanPlayer =>
      configuration.enginePlayer == TTTCellState.x
          ? TTTCellState.o
          : TTTCellState.x;
  TTTCellState get enginePlayer => configuration.enginePlayer;

  Result makeMove(int index, TTTCellState player) {
    Result res = _validateMove(index);
    if (res.isFailure) {
      return res;
    }

    // Create a new board for winner detection
    final newBoard = List<TTTCellState>.from(board);
    newBoard[index] = player;
    final newNumberOfX = player == TTTCellState.x ? numberOfX + 1 : numberOfX;
    final newNumberOfO = player == TTTCellState.o ? numberOfO + 1 : numberOfO;
    final TTTCellState newWinner = getWinner(newBoard);
    final TTTCellState nextPlayersTurn = _getNextPlayer(player);

    _updateGameState(
      newBoard,
      newNumberOfX,
      newNumberOfO,
      newWinner,
      nextPlayersTurn,
    );

    return Result.success();
  }

  Result _validateMove(int index) {
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

    if (board[index] != TTTCellState.empty) {
      return Result.failure(ResultErrorCode.invalidMove);
    }

    return Result.success();
  }

  TTTCellState _getNextPlayer(TTTCellState currentPlayer) {
    return currentPlayer == TTTCellState.x ? TTTCellState.o : TTTCellState.x;
  }

  void _updateGameState(
    List<TTTCellState> newBoard,
    int newNumberOfX,
    int newNumberOfO,
    TTTCellState newWinner,
    TTTCellState nextPlayersTurn,
  ) {
    bool newIsDraw =
        newNumberOfX + newNumberOfO == numSquares &&
        newWinner == TTTCellState.empty;
    bool newHasWinner = newWinner != TTTCellState.empty;
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
            TTTConstants.defaultEngineMoveWaitTime,
      );
    }

    for (int i = 0; i < board.length; ++i) {
      board[i] = newBoard[i];
    }
    currentPlayer = nextPlayersTurn;
    winner = newWinner;
    numberOfX = newNumberOfX;
    numberOfO = newNumberOfO;
    nextGameTimeUtc = newNextGameTimeUtc;
    engineMoveTimeUtc = newEngineMoveTimeUtc;
  }

  TTTCellState getWinner(List<TTTCellState> board) {
    // Cache the winning combinations to avoid redundant checks
    for (var combination in TTTConstants.winningCombinations) {
      final a = combination[0];
      final b = combination[1];
      final c = combination[2];

      // If all three cells in the combination are the same and not empty, we have a winner
      if (board[a] != TTTCellState.empty &&
          board[a] == board[b] &&
          board[a] == board[c]) {
        return board[a]; // Return the winner (TicTacToeCellState.x or TicTacToeCellState.o)
      }
    }

    return TTTCellState.empty;
  }

  /// Checks if the game is over, and if the board is set with the expected
  /// number of X's and O's
  Result isLegalPositionReadyForMove() {
    if (isGameOver) return Result.failure(ResultErrorCode.gameOver);

    if (currentPlayer == TTTCellState.x && numberOfX != numberOfO) {
      return Result.failure(ResultErrorCode.invalidState);
    }

    if (currentPlayer == TTTCellState.o && numberOfX != numberOfO + 1) {
      return Result.failure(ResultErrorCode.invalidState);
    }

    return Result.success();
  }

  void processNewGameConfiguration(TTTGameConfiguration cfg, DateTime nowUtc) {
    configuration = cfg;
    this.nowUtc = nowUtc;
  }

  void setupNextGame() {
    currentPlayer = TTTCellState.x;
    winner = TTTCellState.empty;
    numberOfX = 0;
    numberOfO = 0;
    configuration.changeSides();
    clearBoard();
    nextGameTimeUtc = null;
    engineMoveTimeUtc =
        configuration.enginePlayer == currentPlayer
            ? nowUtc.add(
              configuration.engineMoveWaitTime ??
                  TTTConstants.defaultEngineMoveWaitTime,
            )
            : null;
  }

  void clearBoard() {
    for (int i = 0; i < board.length; ++i) {
      board[i] = TTTCellState.empty;
    }
  }

  @override
  String toString() {
    return 'TTTGameState[curPlayer:${currentPlayer.toShortString()},winner:${winner.toShortString()},numX:$numberOfX,numO:$numberOfO]';
  }

  // Add unit tests for invalid moves
  Result validateMove(int index) {
    if (index < 0 || index >= numSquares) {
      return Result.failure(ResultErrorCode.invalidMove);
    }
    if (board[index] != TTTCellState.empty) {
      return Result.failure(ResultErrorCode.invalidMove);
    }
    return Result.success();
  }
}
