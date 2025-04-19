import 'package:duoplay/engines/connect_4/connect_4_game_logic.dart';
import 'package:duoplay/models/connect_4/connect_4_constants.dart';
import 'package:duoplay/models/result.dart';
import 'package:duoplay/models/turn_based_game/turn_based_game_configuration.dart';
import 'package:duoplay/models/turn_based_game/turn_based_game_utils.dart';

class Connect4GameState {
  final List<List<TurnBasedGameCellState>> board;
  TurnBasedGameCellState currentPlayer;
  TurnBasedGameCellState winner;
  int numberOfRed;
  int numberOfYellow;
  DateTime nowUtc;
  DateTime? nextGameTimeUtc;
  DateTime? engineMoveTimeUtc;
  TurnBasedGameConfiguration configuration;
  String nextGameEngineDifficulty;

  Connect4GameState(
    this.board,
    this.currentPlayer,
    this.winner,
    this.numberOfRed,
    this.numberOfYellow,
    this.nowUtc,
    this.configuration,
    this.nextGameEngineDifficulty,
  );

  Connect4GameState._(
    this.board,
    this.currentPlayer,
    this.winner,
    this.numberOfRed,
    this.numberOfYellow,
    this.nowUtc,
    this.configuration,
    this.nextGameEngineDifficulty,
  );

  factory Connect4GameState.initial(
    TurnBasedGameConfiguration cfg, {
    DateTime? nowUtc,
  }) => Connect4GameState._(
    List.generate(
      Connect4GameLogic.rows,
      (_) =>
          List.filled(Connect4GameLogic.columns, TurnBasedGameCellState.empty),
    ),
    TurnBasedGameCellState.player1,
    TurnBasedGameCellState.empty,
    0,
    0,
    nowUtc ?? DateTime.now().toUtc(),
    cfg,
    cfg.difficulty,
  );

  bool get isDraw => Connect4GameLogic.isDraw(board);
  bool get hasWinner => winner != TurnBasedGameCellState.empty;
  bool get isBetweenGames =>
      isGameOver || (numberOfRed == 0 && numberOfYellow == 0);
  bool get isGameOver => isDraw || hasWinner;
  bool get isHumanPlayerToMove =>
      currentPlayer != configuration.enginePlayer && !isGameOver;
  TurnBasedGameCellState get humanPlayer =>
      configuration.enginePlayer == TurnBasedGameCellState.player1
          ? TurnBasedGameCellState.player2
          : TurnBasedGameCellState.player1;
  TurnBasedGameCellState get enginePlayer => configuration.enginePlayer;

  Result makeMove(int column, TurnBasedGameCellState player) {
    Result res = _validateMove(column);
    if (res.isFailure) {
      return res;
    }

    final newBoard =
        board.map((row) => List<TurnBasedGameCellState>.from(row)).toList();
    Connect4GameLogic.applyMove(newBoard, column, player);

    final newNumberOfRed =
        player == TurnBasedGameCellState.player1
            ? numberOfRed + 1
            : numberOfRed;
    final newNumberOfYellow =
        player == TurnBasedGameCellState.player2
            ? numberOfYellow + 1
            : numberOfYellow;
    final TurnBasedGameCellState newWinner = Connect4GameLogic.getWinner(
      newBoard,
    );
    final TurnBasedGameCellState nextPlayersTurn = _getNextPlayer(player);

    _updateGameState(
      newBoard,
      newNumberOfRed,
      newNumberOfYellow,
      newWinner,
      nextPlayersTurn,
    );

    return Result.success();
  }

  Result _validateMove(int column) {
    if (column < 0 || column >= Connect4GameLogic.columns) {
      return Result.failure(ResultErrorCode.invalidMove);
    }

    if (_getAvailableRow(column) == -1) {
      return Result.failure(ResultErrorCode.invalidMove);
    }

    return Result.success();
  }

  int _getAvailableRow(int column) {
    for (int row = Connect4GameLogic.rows - 1; row >= 0; row--) {
      if (board[row][column] == TurnBasedGameCellState.empty) {
        return row;
      }
    }
    return -1;
  }

  TurnBasedGameCellState _getNextPlayer(TurnBasedGameCellState currentPlayer) {
    return currentPlayer == TurnBasedGameCellState.player1
        ? TurnBasedGameCellState.player2
        : TurnBasedGameCellState.player1;
  }

  void _updateGameState(
    List<List<TurnBasedGameCellState>> newBoard,
    int newNumberOfRed,
    int newNumberOfYellow,
    TurnBasedGameCellState newWinner,
    TurnBasedGameCellState nextPlayersTurn,
  ) {
    bool newIsDraw =
        newNumberOfRed + newNumberOfYellow ==
            Connect4GameLogic.rows * Connect4GameLogic.columns &&
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
        configuration.engineMoveWaitTime ?? Duration(seconds: 2),
      );
    }

    for (int row = 0; row < Connect4GameLogic.rows; row++) {
      for (int col = 0; col < Connect4GameLogic.columns; col++) {
        board[row][col] = newBoard[row][col];
      }
    }
    currentPlayer = nextPlayersTurn;
    winner = newWinner;
    numberOfRed = newNumberOfRed;
    numberOfYellow = newNumberOfYellow;
    nextGameTimeUtc = newNextGameTimeUtc;
    engineMoveTimeUtc = newEngineMoveTimeUtc;
  }

  TurnBasedGameCellState getWinner(List<List<TurnBasedGameCellState>> board) {
    return Connect4GameLogic.getWinner(board);
  }

  /// Checks if the game is over, and if the board is set with the expected
  /// number of X's and O's
  Result isLegalPositionReadyForMove() {
    if (isGameOver) return Result.failure(ResultErrorCode.gameOver);

    if (currentPlayer == TurnBasedGameCellState.player1 &&
        numberOfRed != numberOfYellow) {
      return Result.failure(ResultErrorCode.invalidState);
    }

    if (currentPlayer == TurnBasedGameCellState.player2 &&
        numberOfRed != numberOfYellow + 1) {
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
    numberOfRed = 0;
    numberOfYellow = 0;
    configuration.changeSides();
    configuration.difficulty = nextGameEngineDifficulty;
    clearBoard();
    nextGameTimeUtc = null;
    engineMoveTimeUtc =
        configuration.enginePlayer == currentPlayer
            ? nowUtc.add(
              configuration.engineMoveWaitTime ??
                  Connect4Constants.defaultEngineMoveWaitTime,
            )
            : null;
  }

  void clearBoard() {
    for (int row = 0; row < Connect4GameLogic.rows; row++) {
      for (int col = 0; col < Connect4GameLogic.columns; col++) {
        board[row][col] = TurnBasedGameCellState.empty;
      }
    }
  }

  @override
  String toString() {
    return 'Connect4GameState[curPlayer:$currentPlayer,winner:$winner,numRed:$numberOfRed,numYellow:$numberOfYellow,nextDifficulty:$nextGameEngineDifficulty]';
  }
}
