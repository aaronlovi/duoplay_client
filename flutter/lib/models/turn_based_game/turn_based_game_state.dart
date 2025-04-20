import 'package:duoplay/models/result.dart';
import 'package:duoplay/models/turn_based_game/turn_based_game_board.dart';
import 'package:duoplay/models/turn_based_game/turn_based_game_configuration.dart';
import 'package:duoplay/models/turn_based_game/turn_based_game_constants.dart';
import 'package:duoplay/models/turn_based_game/turn_based_game_logic.dart';
import 'package:duoplay/models/turn_based_game/turn_based_game_utils.dart';

abstract class TurnBasedGameState {
  final TurnBasedGameBoard board;
  final TurnBasedGameLogic gameLogic;
  TurnBasedGameCellState currentPlayer;
  TurnBasedGameCellState winner;
  int numberOfPlayer1;
  int numberOfPlayer2;
  DateTime nowUtc;
  DateTime? nextGameTimeUtc;
  DateTime? engineMoveTimeUtc;
  TurnBasedGameConfiguration configuration;
  String nextGameEngineDifficulty;

  TurnBasedGameState(
    this.board,
    this.gameLogic,
    this.currentPlayer,
    this.winner,
    this.numberOfPlayer1,
    this.numberOfPlayer2,
    this.nowUtc,
    this.configuration,
    this.nextGameEngineDifficulty,
  );

  bool get isDraw => gameLogic.isDraw(board);
  bool get hasWinner => winner != TurnBasedGameCellState.empty;
  bool get isBetweenGames =>
      isGameOver || (numberOfPlayer1 == 0 && numberOfPlayer2 == 0);
  bool get isGameOver => isDraw || hasWinner;
  bool get isHumanPlayerToMove =>
      currentPlayer != configuration.enginePlayer && !isGameOver;
  TurnBasedGameCellState get humanPlayer =>
      configuration.enginePlayer.getOpponent();
  TurnBasedGameCellState get enginePlayer => configuration.enginePlayer;

  Result makeMove(int index, TurnBasedGameCellState player) {
    Result res = validateMove(index);
    if (res.isFailure) return res;

    final newBoard = TurnBasedGameBoard.copy(board);
    gameLogic.applyMove(newBoard, index, player);

    final newNumberOfPlayer1 =
        player == TurnBasedGameCellState.player1
            ? numberOfPlayer1 + 1
            : numberOfPlayer1;
    final newNumberOfPlayer2 =
        player == TurnBasedGameCellState.player2
            ? numberOfPlayer2 + 1
            : numberOfPlayer2;
    final TurnBasedGameCellState newWinner = gameLogic.getWinner(newBoard);
    final TurnBasedGameCellState nextPlayersTurn = player.getOpponent();

    updateGameState(
      newBoard,
      newNumberOfPlayer1,
      newNumberOfPlayer2,
      newWinner,
      nextPlayersTurn,
    );

    return Result.success();
  }

  Result validateMove(int index);

  void updateGameState(
    TurnBasedGameBoard newBoard,
    int newNumberOfPlayer1,
    int newNumberOfPlayer2,
    TurnBasedGameCellState newWinner,
    TurnBasedGameCellState nextPlayersTurn,
  ) {
    bool newIsDraw =
        newNumberOfPlayer1 + newNumberOfPlayer2 == gameLogic.numCells &&
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

    board.setAll(newBoard);
    currentPlayer = nextPlayersTurn;
    winner = newWinner;
    numberOfPlayer1 = newNumberOfPlayer1;
    numberOfPlayer2 = newNumberOfPlayer2;
    nextGameTimeUtc = newNextGameTimeUtc;
    engineMoveTimeUtc = newEngineMoveTimeUtc;
  }

  Result isLegalPositionReadyForMove() {
    if (isGameOver) return Result.failure(ResultErrorCode.gameOver);

    if (currentPlayer == TurnBasedGameCellState.player1 &&
        numberOfPlayer1 != numberOfPlayer2) {
      return Result.failure(ResultErrorCode.invalidState);
    }

    if (currentPlayer == TurnBasedGameCellState.player2 &&
        numberOfPlayer1 != numberOfPlayer2 + 1) {
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
    numberOfPlayer1 = 0;
    numberOfPlayer2 = 0;
    configuration.changeSides();
    configuration.difficulty = nextGameEngineDifficulty;
    clearBoard();
    nextGameTimeUtc = null;
    engineMoveTimeUtc =
        configuration.enginePlayer == currentPlayer
            ? nowUtc.add(
              configuration.engineMoveWaitTime ??
                  TurnBasedGameConstants.defaultEngineMoveWaitTime,
            )
            : null;
  }

  void clearBoard() => board.reset();
}
