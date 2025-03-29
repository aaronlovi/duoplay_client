import 'package:duoplay/models/result.dart';

String ticTacToeErrorCodeToString(
  ResultErrorCode code,
  List<String> errorParams,
) {
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
