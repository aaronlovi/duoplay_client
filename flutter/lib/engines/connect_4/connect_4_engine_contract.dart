import 'package:duoplay/models/connect_4/connect_4_enums.dart';

abstract class Connect4EngineContract {
  /// Returns the column index for the next move.
  int getMove(List<List<Connect4SquareState>> board, Connect4SquareState chipColor);
}
