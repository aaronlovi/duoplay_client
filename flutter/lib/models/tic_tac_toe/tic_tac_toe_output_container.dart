import 'package:duoplay/models/turn_based_game/turn_based_game_fsm_outputs.dart';

class TTTOutputContainer {
  final List<TurnBasedGameFsmOutputBase> outputs;
  DateTime? nextTimeout;

  TTTOutputContainer({required this.outputs, this.nextTimeout});

  void clear() {
    outputs.clear();
    nextTimeout = null;
  }
}
