import 'package:duoplay/models/result.dart';

enum TurnBasedGameCellState {
  empty,
  player1,
  player2,
}

extension TurnBasedGameCellStateExtensions on TurnBasedGameCellState {
  TurnBasedGameCellState getOpponent() {
    switch (this) {
      case TurnBasedGameCellState.empty:
        return TurnBasedGameCellState.empty;
      case TurnBasedGameCellState.player1:
        return TurnBasedGameCellState.player2;
      case TurnBasedGameCellState.player2:
        return TurnBasedGameCellState.player1;
    }
  }
}

abstract class TurnBasedGameUtils {
  static String errorCodeToString(ResultErrorCode code, List<String> errorParams) {
    switch (code) {
      case ResultErrorCode.none:
        return '';
      case ResultErrorCode.unknown:
        return 'Unknown error';
      case ResultErrorCode.invalidMove:
        return 'Invalid move, please try again.';
      case ResultErrorCode.gameOver:
        return 'Game is already over';
      case ResultErrorCode.invalidTime:
        return errorParams.length == 2
            ? 'Cannot change time from ${errorParams[0]} => ${errorParams[1]}'
            : 'Invalid time';
      case ResultErrorCode.invalidState:
        return 'Game is in invalid state for this operation';
    }
  }

  String cellStateToShortString(TurnBasedGameCellState state);
}
