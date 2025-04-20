import 'dart:async';

import 'package:duoplay/engines/turn_based_game/turn_based_game_engine_contract.dart';
import 'package:duoplay/models/turn_based_game/turn_based_game_container.dart';
import 'package:duoplay/models/turn_based_game/turn_based_game_fsm_inputs.dart';
import 'package:duoplay/models/turn_based_game/turn_based_game_fsm_outputs.dart';
import 'package:duoplay/models/turn_based_game/turn_based_game_logic.dart';
import 'package:duoplay/models/turn_based_game/turn_based_game_output_container.dart';
import 'package:duoplay/models/turn_based_game/turn_based_game_utils.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:duoplay/screens/turn_based_game_settings_button.dart';

/// Abstract base class for turn-based game screens.
abstract class TurnBasedGameScreenBase<T extends StatefulWidget>
    extends State<T> {
  TurnBasedGameContainer get gameObject;
  TurnBasedGameEngineContract get engine;
  TurnBasedGameUtils get gameUtils;
  TurnBasedGameLogic get gameLogic => gameObject.gameState.gameLogic;

  /// Abstract: must return the main game grid widget.
  Widget buildGameGrid(BuildContext context);

  /// Abstract: must return the status bar widget.
  Widget buildStatusBar(BuildContext context);

  /// Abstract: must return the app bar title for the game screen.
  String get appBarTitle;

  /// Abstract: must return the settings route for the game screen.
  String get settingsRoute;

  /// Abstract: must return the settings key for the game screen.
  String get settingsDifficultyKey;

  /// Default build method for shared game screen layout.
  @mustCallSuper
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(appBarTitle)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: buildSettingsButton(context),
          ),
          Expanded(child: buildGameGrid(context)),
          buildStatusBar(context),
        ],
      ),
    );
  }

  /// Shared logic for building a settings button.
  /// Subclasses should call this with their own parameters.
  @protected
  Widget buildDefaultSettingsButton({
    required BuildContext context,
    required String settingsRoute,
    required String settingsKey,
    required String label,
    required String Function(SharedPreferences prefs, String prevDifficulty)
    getNewDifficulty,
  }) {
    return SettingsButton(
      onPressed: () async {
        final prevDifficulty = gameObject.gameState.configuration.difficulty;
        final int prevBetweenMoveDelay =
            gameObject.gameState.configuration.engineMoveWaitTime?.inSeconds ??
            1;
        final int prevBetweenGameDelay =
            gameObject.gameState.configuration.betweenGamesWaitTime.inSeconds;
        final navigator = Navigator.of(context);
        final scaffoldMessenger = ScaffoldMessenger.of(context);
        await navigator.pushNamed(settingsRoute);
        if (!mounted) return;
        final prefs = await SharedPreferences.getInstance();
        final newDifficulty = getNewDifficulty(prefs, prevDifficulty);
        if (newDifficulty != prevDifficulty) {
          gameObject.postInput(
            TurnBasedGameSettingsChangeFsmInput(
              newDifficulty: newDifficulty,
              betweenMoveDelaySeconds: prevBetweenMoveDelay,
              betweenGameDelaySeconds: prevBetweenGameDelay,
              nowUtc: DateTime.now().toUtc(),
            ),
          );
          if (!gameObject.gameState.isGameOver) {
            final current = prevDifficulty;
            final next = newDifficulty;
            final msg =
                'Current engine: $current\nNext game: $next\nEngine will change at next game.';
            scaffoldMessenger.showSnackBar(SnackBar(content: Text(msg)));
          }
          setState(() => {});
        }
      },
      label: label,
    );
  }

  /// Default implementation for the settings button.
  Widget buildSettingsButton(BuildContext context) =>
      buildDefaultSettingsButton(
        context: context,
        settingsRoute: settingsRoute,
        settingsKey: settingsDifficultyKey,
        label: 'Settings',
        getNewDifficulty:
            (prefs, prevDifficulty) =>
                prefs.getString(settingsDifficultyKey) ?? prevDifficulty,
      );

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
