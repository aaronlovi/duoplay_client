import 'dart:async';

import 'package:duoplay/engines/turn_based_game/turn_based_game_engine_contract.dart';
import 'package:duoplay/models/turn_based_game/turn_based_game_container.dart';
import 'package:duoplay/models/turn_based_game/turn_based_game_fsm_inputs.dart';
import 'package:duoplay/models/turn_based_game/turn_based_game_fsm_outputs.dart';
import 'package:duoplay/models/turn_based_game/turn_based_game_output_container.dart';
import 'package:duoplay/models/turn_based_game/turn_based_game_utils.dart';
import 'package:flutter/material.dart';

/// Abstract base class for turn-based game screens.
abstract class TurnBasedGameScreenBase<T extends StatefulWidget>
    extends State<T> {
  TurnBasedGameContainer get gameObject;
  TurnBasedGameEngineContract get engine;
  TurnBasedGameUtils get gameUtils;

  /// Abstract: must return the settings button widget.
  Widget buildSettingsButton(BuildContext context);

  /// Abstract: must return the main game grid widget.
  Widget buildGameGrid(BuildContext context);

  /// Abstract: must return the status bar widget.
  Widget buildStatusBar(BuildContext context);

  /// Shared FSM output processing logic.
  @protected
  void processOutputs(TurnBasedGameOutputContainer outputs) {
    setState(() {
      for (var item in outputs.outputs) {
        if (item is TurnBasedGameErrorFsmOutput) {
          String errorMessage = TurnBasedGameUtils.errorCodeToString(
            item.results.errorCode,
            item.results.errorParameters,
          );
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(errorMessage)));
        } else if (item is TurnBasedGameNewBoardFsmOutput) {
          // New state will redraw the screen
        } else if (item is TurnBasedGameGameOverFsmOutput) {
          // Show game over UI if needed
        } else if (item is TurnBasedGameStartGameFsmOutput) {
          // Show start game UI if needed
        } else if (item is TurnBasedGameDoEngineMoveFsmOutput) {
          final res = engine.getNextMove(gameObject.gameState);
          if (res.isFailure) {
            String errorMessage = TurnBasedGameUtils.errorCodeToString(
              res.errorCode,
              res.errorParameters,
            );
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(errorMessage)));
            continue;
          }
          final newOutputs = gameObject.postInput(
            TurnBasedGameEngineMoveFsmInput(
              nowUtc: DateTime.now().toUtc(),
              index: res.value!,
              enginePlayer: gameObject.enginePlayer,
            ),
          );
          processOutputs(newOutputs);
        }
      }
    });

    if (outputs.nextTimeout == null) return;
    final now = DateTime.now().toUtc();
    Duration duration = outputs.nextTimeout!.difference(now);
    if (duration == Duration.zero || duration.isNegative) {
      duration = Duration(seconds: 1);
    }
    Timer(duration, () {
      final updateTimeInput = TurnBasedGameUpdateTimeFsmInput(
        nowUtc: DateTime.now().toUtc(),
      );
      final newOutputs = gameObject.postInput(updateTimeInput);
      processOutputs(newOutputs);
    });
  }
}
