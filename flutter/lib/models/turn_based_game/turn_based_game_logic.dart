import 'package:duoplay/models/turn_based_game/turn_based_game_board.dart';
import 'package:duoplay/models/turn_based_game/turn_based_game_utils.dart';

abstract class TurnBasedGameLogic {
  int get columns;
  int get rows;
  int get numCells => columns * rows;

  bool isLegalMove(TurnBasedGameBoard board, int index);
  void applyMove(
    TurnBasedGameBoard board,
    int index,
    TurnBasedGameCellState chipColor,
  );
  TurnBasedGameCellState getWinner(TurnBasedGameBoard board);
  bool isDraw(TurnBasedGameBoard board);
  void debugPrintBoard(TurnBasedGameBoard board);
  TurnBasedGameBoard parseBoard(String boardString);

  List<int> getWinningIndices(TurnBasedGameBoard board);
}
