import 'package:duoplay/models/result.dart';
import 'package:duoplay/models/turn_based_game/turn_based_game_board.dart';
import 'package:duoplay/models/turn_based_game/turn_based_game_configuration.dart';
import 'package:duoplay/models/turn_based_game/turn_based_game_logic.dart';
import 'package:duoplay/models/turn_based_game/turn_based_game_state.dart';
import 'package:duoplay/models/turn_based_game/turn_based_game_utils.dart';

class TTTGameState extends TurnBasedGameState {
  // Made the constructor public to allow external instantiation for simulation purposes
  TTTGameState(
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

  TTTGameState._(
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

  factory TTTGameState.initial(
    TurnBasedGameConfiguration cfg,
    TurnBasedGameLogic gameLogic, {
    DateTime? nowUtc,
  }) => TTTGameState._(
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
}
