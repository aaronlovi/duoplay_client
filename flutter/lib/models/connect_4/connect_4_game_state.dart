import 'package:duoplay/models/result.dart';
import 'package:duoplay/models/connect_4/connect_4_enums.dart';
import 'package:duoplay/models/connect_4/connect_4_game_configuration.dart';
import 'package:duoplay/engines/connect_4/connect_4_game_logic.dart';

class Connect4GameState {
  static const int rows = 6;
  static const int columns = 7;

  final List<List<Connect4SquareState>> board;
  Connect4SquareState currentPlayer;
  Connect4SquareState winner;
  int numberOfRed;
  int numberOfYellow;
  DateTime nowUtc;
  DateTime? nextGameTimeUtc;
  DateTime? engineMoveTimeUtc;
  Connect4GameConfiguration configuration;
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
    Connect4GameConfiguration cfg, {
    DateTime? nowUtc,
  }) => Connect4GameState._(
    List.generate(rows, (_) => List.filled(columns, Connect4SquareState.empty)),
    Connect4SquareState.red,
    Connect4SquareState.empty,
    0,
    0,
    nowUtc ?? DateTime.now().toUtc(),
    cfg,
    cfg.difficulty,
  );

  bool get isDraw => Connect4GameLogic.isDraw(board);
  bool get hasWinner => winner != Connect4SquareState.empty;
  bool get isBetweenGames => isGameOver || (numberOfRed == 0 && numberOfYellow == 0);
  bool get isGameOver => isDraw || hasWinner;
  bool get isHumanPlayerToMove =>
      currentPlayer != configuration.enginePlayer && !isGameOver;
  Connect4SquareState get humanPlayer =>
      configuration.enginePlayer == Connect4SquareState.red
          ? Connect4SquareState.yellow
          : Connect4SquareState.red;
  Connect4SquareState get enginePlayer => configuration.enginePlayer;

  Result makeMove(int column, Connect4SquareState player) {
    Result res = _validateMove(column);
    if (res.isFailure) {
      return res;
    }

    final newBoard = board.map((row) => List<Connect4SquareState>.from(row)).toList();
    Connect4GameLogic.applyMove(newBoard, column, player);

    final newNumberOfRed = player == Connect4SquareState.red ? numberOfRed + 1 : numberOfRed;
    final newNumberOfYellow = player == Connect4SquareState.yellow ? numberOfYellow + 1 : numberOfYellow;
    final Connect4SquareState newWinner = Connect4GameLogic.getWinner(newBoard);
    final Connect4SquareState nextPlayersTurn = _getNextPlayer(player);

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
    if (column < 0 || column >= columns) {
      return Result.failure(ResultErrorCode.invalidMove);
    }

    if (_getAvailableRow(column) == -1) {
      return Result.failure(ResultErrorCode.invalidMove);
    }

    return Result.success();
  }

  int _getAvailableRow(int column) {
    for (int row = rows - 1; row >= 0; row--) {
      if (board[row][column] == Connect4SquareState.empty) {
        return row;
      }
    }
    return -1;
  }

  Connect4SquareState _getNextPlayer(Connect4SquareState currentPlayer) {
    return currentPlayer == Connect4SquareState.red
        ? Connect4SquareState.yellow
        : Connect4SquareState.red;
  }

  void _updateGameState(
    List<List<Connect4SquareState>> newBoard,
    int newNumberOfRed,
    int newNumberOfYellow,
    Connect4SquareState newWinner,
    Connect4SquareState nextPlayersTurn,
  ) {
    bool newIsDraw =
        newNumberOfRed + newNumberOfYellow == rows * columns &&
        newWinner == Connect4SquareState.empty;
    bool newHasWinner = newWinner != Connect4SquareState.empty;
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

    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < columns; col++) {
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

  Connect4SquareState getWinner(List<List<Connect4SquareState>> board) {
    return Connect4GameLogic.getWinner(board);
  }

  void processNewGameConfiguration(Connect4GameConfiguration cfg, DateTime nowUtc) {
    configuration = cfg;
    this.nowUtc = nowUtc;
  }

  void setupNextGame() {
    currentPlayer = Connect4SquareState.red;
    winner = Connect4SquareState.empty;
    numberOfRed = 0;
    numberOfYellow = 0;
    configuration.changeSides();
    configuration.difficulty = nextGameEngineDifficulty;
    clearBoard();
    nextGameTimeUtc = null;
    engineMoveTimeUtc =
        configuration.enginePlayer == currentPlayer
            ? nowUtc.add(
                configuration.engineMoveWaitTime ?? Duration(seconds: 2),
              )
            : null;
  }

  void clearBoard() {
    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < columns; col++) {
        board[row][col] = Connect4SquareState.empty;
      }
    }
  }

  @override
  String toString() {
    return 'Connect4GameState[curPlayer:$currentPlayer,winner:$winner,numRed:$numberOfRed,numYellow:$numberOfYellow,nextDifficulty:$nextGameEngineDifficulty]';
  }
}