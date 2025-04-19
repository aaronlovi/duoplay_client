import 'package:duoplay/models/turn_based_game/turn_based_game_fsm_outputs.dart';

class Connect4OutputContainer {
  final List<TurnBasedGameFsmOutputBase> outputs;
  DateTime? nextTimeout;

  Connect4OutputContainer({required this.outputs, this.nextTimeout});

  void clear() {
    outputs.clear();
    nextTimeout = null;
  }
}