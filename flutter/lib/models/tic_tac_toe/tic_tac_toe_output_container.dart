import 'package:duoplay/models/tic_tac_toe/tic_tac_toe_fsm_outputs.dart';

class TTTOutputContainer {
  final List<TTTOutputBase> outputs;
  DateTime? nextTimeout;

  TTTOutputContainer({required this.outputs, this.nextTimeout});

  void clear() {
    outputs.clear();
    nextTimeout = null;
  }
}
