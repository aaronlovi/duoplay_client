import 'package:duoplay/models/connect_4/connect_4_fsm_outputs.dart';

class Connect4OutputContainer {
  final List<Connect4OutputBase> outputs;
  DateTime? nextTimeout;

  Connect4OutputContainer({required this.outputs, this.nextTimeout});

  void clear() {
    outputs.clear();
    nextTimeout = null;
  }
}