import 'package:duoplay/models/result.dart';
import 'package:duoplay/models/tic_tac_toe/tic_tac_toe_constants.dart';
import 'package:duoplay/models/tic_tac_toe/tic_tac_toe_game_configuration.dart';
import 'package:duoplay/models/turn-based-game/turn_based_game_utils.dart';

class TicTacToeGameState {
  static final int numSquares = 9;

  final List<TurnBasedGameCellState> board;
  TurnBasedGameCellState currentPlayer;
  TurnBasedGameCellState winner;
  int numberOfX;
  int numberOfO;
  DateTime nowUtc;
  DateTime? nextGameTimeUtc;
  DateTime? engineMoveTimeUtc;
  TTTGameConfiguration configuration;
  String nextGameEngineDifficulty;

  // Made the constructor public to allow external instantiation for simulation purposes
  TicTacToeGameState(
    this.board,
    this.currentPlayer,
    this.winner,
    this.numberOfX,
    this.numberOfO,
    this.nowUtc,
    this.configuration,
    this.nextGameEngineDifficulty,
  );

  TicTacToeGameState._(
    this.board,
    this.currentPlayer,
    this.winner,
    this.numberOfX,
    this.numberOfO,
    this.nowUtc,
    this.configuration,
    this.nextGameEngineDifficulty,
  );

  factory TicTacToeGameState.initial(
    TTTGameConfiguration cfg, {
    DateTime? nowUtc,
  }) => TicTacToeGameState._(
    List<TurnBasedGameCellState>.filled(
      numSquares,
      TurnBasedGameCellState.empty,
    ),
    TurnBasedGameCellState.player1,
    TurnBasedGameCellState.empty,
    0,
    0,
    nowUtc ?? DateTime.now().toUtc(),
    cfg,
    cfg.difficulty,
  );

  bool get isDraw =>
      numberOfX + numberOfO == numSquares &&
      winner == TurnBasedGameCellState.empty;
  bool get hasWinner => winner != TurnBasedGameCellState.empty;
  bool get isBetweenGames => isGameOver || (numberOfX == 0 && numberOfO == 0);
  bool get isGameOver => isDraw || hasWinner;
  bool get isHumanPlayerToMove =>
      currentPlayer != configuration.enginePlayer && !isGameOver;
  TurnBasedGameCellState get humanPlayer =>
      configuration.enginePlayer == TurnBasedGameCellState.player1
          ? TurnBasedGameCellState.player2
          : TurnBasedGameCellState.player1;
  TurnBasedGameCellState get enginePlayer => configuration.enginePlayer;

  Result makeMove(int index, TurnBasedGameCellState player) {
    Result res = _validateMove(index);
    if (res.isFailure) {
      return res;
    }

    // Create a new board for winner detection
    final newBoard = List<TurnBasedGameCellState>.from(board);
    newBoard[index] = player;
    final newNumberOfX =
        player == TurnBasedGameCellState.player1 ? numberOfX + 1 : numberOfX;
    final newNumberOfO =
        player == TurnBasedGameCellState.player2 ? numberOfO + 1 : numberOfO;
    final TurnBasedGameCellState newWinner = getWinner(newBoard);
    final TurnBasedGameCellState nextPlayersTurn = _getNextPlayer(player);

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

    if (board[index] != TurnBasedGameCellState.empty) {
      return Result.failure(ResultErrorCode.invalidMove);
    }

    return Result.success();
  }

  TurnBasedGameCellState _getNextPlayer(TurnBasedGameCellState currentPlayer) {
    return currentPlayer == TurnBasedGameCellState.player1
        ? TurnBasedGameCellState.player2
        : TurnBasedGameCellState.player1;
  }

  void _updateGameState(
    List<TurnBasedGameCellState> newBoard,
    int newNumberOfX,
    int newNumberOfO,
    TurnBasedGameCellState newWinner,
    TurnBasedGameCellState nextPlayersTurn,
  ) {
    bool newIsDraw =
        newNumberOfX + newNumberOfO == numSquares &&
        newWinner == TurnBasedGameCellState.empty;
    bool newHasWinner = newWinner != TurnBasedGameCellState.empty;
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

  TurnBasedGameCellState getWinner(List<TurnBasedGameCellState> board) {
    // Cache the winning combinations to avoid redundant checks
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

  /// Checks if the game is over, and if the board is set with the expected
  /// number of X's and O's
  Result isLegalPositionReadyForMove() {
    if (isGameOver) return Result.failure(ResultErrorCode.gameOver);

    if (currentPlayer == TurnBasedGameCellState.player1 &&
        numberOfX != numberOfO) {
      return Result.failure(ResultErrorCode.invalidState);
    }

    if (currentPlayer == TurnBasedGameCellState.player2 &&
        numberOfX != numberOfO + 1) {
      return Result.failure(ResultErrorCode.invalidState);
    }

    return Result.success();
  }

  void processNewGameConfiguration(TTTGameConfiguration cfg, DateTime nowUtc) {
    configuration = cfg;
    this.nowUtc = nowUtc;
  }

  void setupNextGame() {
    currentPlayer = TurnBasedGameCellState.player1;
    winner = TurnBasedGameCellState.empty;
    numberOfX = 0;
    numberOfO = 0;
    configuration.changeSides();
    configuration.difficulty = nextGameEngineDifficulty;
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
      board[i] = TurnBasedGameCellState.empty;
    }
  }

  // @override
  // String toString() {
  //   String currentPlayerStr = _gameUtils.cellStateToShortString(currentPlayer);
  //   String winnerStr = _gameUtils.cellStateToShortString(winner);
  //   return 'TTTGameState[curPlayer:$currentPlayerStr,winner:$winnerStr,numX:$numberOfX,numO:$numberOfO,nextDifficulty:$nextGameEngineDifficulty]';
  // }

  // Add unit tests for invalid moves
  Result validateMove(int index) {
    if (index < 0 || index >= numSquares) {
      return Result.failure(ResultErrorCode.invalidMove);
    }
    if (board[index] != TurnBasedGameCellState.empty) {
      return Result.failure(ResultErrorCode.invalidMove);
    }
    return Result.success();
  }
}
