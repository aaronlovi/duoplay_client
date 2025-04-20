import 'package:duoplay/models/result.dart';
import 'package:duoplay/models/tic_tac_toe/tic_tac_toe_constants.dart';
import 'package:duoplay/models/turn_based_game/turn_based_game_board.dart';
import 'package:duoplay/models/turn_based_game/turn_based_game_configuration.dart';
import 'package:duoplay/models/turn_based_game/turn_based_game_logic.dart';
import 'package:duoplay/models/turn_based_game/turn_based_game_utils.dart';

class TicTacToeGameState {
  final TurnBasedGameBoard board;
  final TurnBasedGameLogic gameLogic;
  TurnBasedGameCellState currentPlayer;
  TurnBasedGameCellState winner;
  int numberOfX;
  int numberOfO;
  DateTime nowUtc;
  DateTime? nextGameTimeUtc;
  DateTime? engineMoveTimeUtc;
  TurnBasedGameConfiguration configuration;
  String nextGameEngineDifficulty;

  // Made the constructor public to allow external instantiation for simulation purposes
  TicTacToeGameState(
    this.board,
    this.gameLogic,
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
    this.gameLogic,
    this.currentPlayer,
    this.winner,
    this.numberOfX,
    this.numberOfO,
    this.nowUtc,
    this.configuration,
    this.nextGameEngineDifficulty,
  );

  factory TicTacToeGameState.initial(
    TurnBasedGameConfiguration cfg,
    TurnBasedGameLogic gameLogic, {
    DateTime? nowUtc,
  }) => TicTacToeGameState._(
    TurnBasedGameBoard(gameLogic.rows, gameLogic.columns),
    gameLogic,
    TurnBasedGameCellState.player1,
    TurnBasedGameCellState.empty,
    0,
    0,
    nowUtc ?? DateTime.now().toUtc(),
    cfg,
    cfg.difficulty,
  );

  bool get isDraw => gameLogic.isDraw(board);
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
    final newBoard = TurnBasedGameBoard.copy(board);
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

    return gameLogic.isLegalMove(board, index)
        ? Result.success()
        : Result.failure(ResultErrorCode.invalidMove);
  }

  TurnBasedGameCellState _getNextPlayer(TurnBasedGameCellState currentPlayer) {
    return currentPlayer == TurnBasedGameCellState.player1
        ? TurnBasedGameCellState.player2
        : TurnBasedGameCellState.player1;
  }

  void _updateGameState(
    TurnBasedGameBoard newBoard,
    int newNumberOfX,
    int newNumberOfO,
    TurnBasedGameCellState newWinner,
    TurnBasedGameCellState nextPlayersTurn,
  ) {
    bool newIsDraw =
        newNumberOfX + newNumberOfO == gameLogic.numCells &&
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

  TurnBasedGameCellState getWinner(TurnBasedGameBoard board) =>
      gameLogic.getWinner(board);

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

  void processNewGameConfiguration(
    TurnBasedGameConfiguration cfg,
    DateTime nowUtc,
  ) {
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

  void clearBoard() => board.reset();

  // Add unit tests for invalid moves
  Result validateMove(int index) {
    if (index < 0 || index >= gameLogic.numCells) {
      return Result.failure(ResultErrorCode.invalidMove);
    }
    if (board[index] != TurnBasedGameCellState.empty) {
      return Result.failure(ResultErrorCode.invalidMove);
    }
    return Result.success();
  }
}
