import 'package:duoplay/models/result.dart';
import 'package:duoplay/models/turn_based_game/turn_based_game_board.dart';
import 'package:duoplay/models/turn_based_game/turn_based_game_configuration.dart';
import 'package:duoplay/models/turn_based_game/turn_based_game_logic.dart';
import 'package:duoplay/models/turn_based_game/turn_based_game_state.dart';
import 'package:duoplay/models/turn_based_game/turn_based_game_utils.dart';

class Connect4GameState extends TurnBasedGameState {
  Connect4GameState(
    super.board,
    super.gameLogic,
    super.currentPlayer,
    super.winner,
    super.numberOfPlayer1,
    super.numberOfPlayer2,
    super.nowUtc,
    super.configuration,
    super.nextGameEngineDifficulty,
  );

  Connect4GameState._(
    super.board,
    super.gameLogic,
    super.currentPlayer,
    super.winner,
    super.numberOfPlayer1,
    super.numberOfPlayer2,
    super.nowUtc,
    super.configuration,
    super.nextGameEngineDifficulty,
  );

  factory Connect4GameState.initial(
    TurnBasedGameConfiguration cfg,
    TurnBasedGameLogic gameLogic, {
    DateTime? nowUtc,
  }) => Connect4GameState._(
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

  @override
  Result validateMove(int index) {
    if (index < 0 || index >= gameLogic.numCells) {
      return Result.failure(ResultErrorCode.invalidMove);
    }

    if (_getAvailableRow(index) == -1) {
      return Result.failure(ResultErrorCode.invalidMove);
    }

    return Result.success();
  }

  int _getAvailableRow(int index) {
    int column = index % gameLogic.columns;
    for (int row = gameLogic.rows - 1; row >= 0; row--) {
      int thisRowIndex = row * gameLogic.columns + column;
      if (board[thisRowIndex] == TurnBasedGameCellState.empty) {
        return row;
      }
    }
    return -1;
  }
}
