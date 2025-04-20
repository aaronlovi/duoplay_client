import 'package:duoplay/models/turn_based_game/turn_based_game_board.dart';
import 'package:duoplay/models/turn_based_game/turn_based_game_utils.dart';

class TTTGameLogic {
  static const int rows = 3;
  static const int columns = 3;

  /// Converts a string representation of a board into a 2D list of TurnBasedGameCellState.
  static TurnBasedGameBoard parseBoard(String boardString) =>
      TurnBasedGameBoard.fromList(
        boardString
            .trim()
            .split('\n')
            .expand(
              (row) => row.trim().split(RegExp(r'\s+')).map((cell) {
                switch (cell) {
                  case 'X':
                  case 'x':
                    return TurnBasedGameCellState.player1;
                  case 'O':
                  case 'o':
                    return TurnBasedGameCellState.player2;
                  default:
                    return TurnBasedGameCellState.empty;
                }
              }),
            )
            .toList(),
      );
}
