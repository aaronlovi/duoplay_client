import 'dart:async';

import 'package:duoplay/engines/turn_based_game/turn_based_game_engine_contract.dart';
import 'package:duoplay/models/turn_based_game/turn_based_game_container.dart';
import 'package:duoplay/models/turn_based_game/turn_based_game_fsm_inputs.dart';
import 'package:duoplay/models/turn_based_game/turn_based_game_fsm_outputs.dart';
import 'package:duoplay/models/turn_based_game/turn_based_game_logic.dart';
import 'package:duoplay/models/turn_based_game/turn_based_game_output_container.dart';
import 'package:duoplay/models/turn_based_game/turn_based_game_utils.dart';
import 'package:duoplay/screens/turn_based_game_game_grid.dart';
import 'package:duoplay/screens/turn_based_game_settings_button.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Abstract base class for turn-based game screens.
abstract class TurnBasedGameScreenBase<T extends StatefulWidget>
    extends State<T> {
  TurnBasedGameContainer get gameObject;
  TurnBasedGameEngineContract get engine;
  TurnBasedGameUtils get gameUtils;
  TurnBasedGameLogic get gameLogic => gameObject.gameState.gameLogic;

  Timer? _fsmTimer;

  /// Abstract: must return the app bar title for the game screen.
  String get appBarTitle;

  /// Abstract: must return the settings route for the game screen.
  String get settingsRoute;

  /// Abstract: must return the settings key for the game screen.
  String get settingsDifficultyKey;

  /// Most recent move index for the game.
  int? mostRecentMoveIndex;

  @override
  void dispose() {
    _fsmTimer?.cancel();
    super.dispose();
  }

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
          buildStatusBar(),
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
        final prefs = await SharedPreferences.getInstance();
        final newDifficulty = getNewDifficulty(prefs, prevDifficulty);

        if (!mounted) return;

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

  /// Default implementation for the status bar.
  @protected
  Widget buildStatusBar() {
    final difficulty = gameObject.gameState.configuration.difficulty;
    final player =
        gameUtils.cellStateToShortString(gameObject.humanPlayer).toUpperCase();
    return Container(
      width: double.infinity,
      color: Colors.grey[200],
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Text(
        'Engine: $difficulty    You are: $player',
        style: const TextStyle(fontSize: 16),
        textAlign: TextAlign.center,
      ),
    );
  }

  /// Default implementation for handling cell taps.
  @protected
  void handleCellTap(int index) {
    if (!gameObject.isHumanPlayerToMove) return;

    final inp = TurnBasedGamePlayerMoveFsmInput(
      index: index,
      player: gameObject.humanPlayer,
      nowUtc: DateTime.now().toUtc(),
    );
    TurnBasedGameOutputContainer outputs = gameObject.postInput(inp);
    setState(() {
      mostRecentMoveIndex = index;
      processOutputs(outputs);
    });
  }

  @protected
  Widget buildGameGrid(BuildContext context) => buildDefaultGameGrid(
    cellBuilder: (context, index) {
      return GestureDetector(
        onTap: () => handleCellTap(index),
        child: getCellContents(index),
      );
    },
  );

  /// Default implementation for the game grid.
  /// Subclasses only need to provide a cellBuilder.
  @protected
  Widget buildDefaultGameGrid({
    required Widget Function(BuildContext, int) cellBuilder,
    double? aspectRatio,
  }) {
    final rows = gameLogic.rows;
    final columns = gameLogic.columns;
    final ratio = aspectRatio ?? (columns / rows);
    return Center(
      child: GameGrid(
        rows: rows,
        columns: columns,
        aspectRatio: ratio,
        cellBuilder: cellBuilder,
      ),
    );
  }

  /// Shared FSM output processing logic.
  @protected
  void processOutputs(TurnBasedGameOutputContainer outputs) {
    try {
      setState(() {
        try {
          for (var item in outputs.outputs) {
            _processOutputItem(item);
          }
        } catch (e, stackTrace) {
          _handleSetStateError(e, stackTrace);
        }
      });

      _scheduleNextTimeout(outputs);
    } catch (e, stackTrace) {
      _handleProcessOutputsError(e, stackTrace);
    }
  }

  /// Processes a single FSM output item.
  void _processOutputItem(TurnBasedGameFsmOutputBase item) {
    if (item is TurnBasedGameErrorFsmOutput) {
      _handleErrorOutput(item);
    } else if (item is TurnBasedGameNewBoardFsmOutput) {
      _handleNewBoardOutput();
    } else if (item is TurnBasedGameGameOverFsmOutput) {
      _handleGameOverOutput();
    } else if (item is TurnBasedGameStartGameFsmOutput) {
      _handleStartGameOutput();
    } else if (item is TurnBasedGameDoEngineMoveFsmOutput) {
      _handleEngineMoveOutput();
    }
  }

  /// Handles error outputs.
  void _handleErrorOutput(TurnBasedGameErrorFsmOutput item) {
    String errorMessage = TurnBasedGameUtils.errorCodeToString(
      item.results.errorCode,
      item.results.errorParameters,
    );
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(errorMessage)));
  }

  /// Handles new board outputs.
  void _handleNewBoardOutput() {
    // New state will redraw the screen
  }

  /// Handles game over outputs.
  void _handleGameOverOutput() {
    // Show game over UI if needed
  }

  /// Handles start game outputs.
  void _handleStartGameOutput() {
    // Show start game UI if needed
    mostRecentMoveIndex = null;
  }

  /// Handles engine move outputs.
  void _handleEngineMoveOutput() {
    final res = engine.getNextMove(gameObject.gameState);
    if (res.isFailure) {
      String errorMessage = TurnBasedGameUtils.errorCodeToString(
        res.errorCode,
        res.errorParameters,
      );
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorMessage)));
      return;
    }
    final newOutputs = gameObject.postInput(
      TurnBasedGameEngineMoveFsmInput(
        nowUtc: DateTime.now().toUtc(),
        index: res.value!,
        enginePlayer: gameObject.enginePlayer,
      ),
    );

    setState(() {
      mostRecentMoveIndex = res.value;
      processOutputs(newOutputs);
    });
  }

  /// Handles errors during setState.
  void _handleSetStateError(Object e, StackTrace stackTrace) {
    debugPrint('Error during setState: $e\n$stackTrace');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('An error occurred while updating the game state.'),
      ),
    );
  }

  /// Handles errors during processOutputs.
  void _handleProcessOutputsError(Object e, StackTrace stackTrace) {
    debugPrint('Error in processOutputs: $e\n$stackTrace');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('An unexpected error occurred. Please try again.'),
      ),
    );
  }

  /// Schedules the next timeout for FSM processing.
  void _scheduleNextTimeout(TurnBasedGameOutputContainer outputs) {
    _fsmTimer?.cancel();
    if (outputs.nextTimeout == null) return;

    final now = DateTime.now().toUtc();
    Duration duration = outputs.nextTimeout!.difference(now);
    if (duration == Duration.zero || duration.isNegative) {
      duration = Duration(seconds: 1);
    }

    _fsmTimer = Timer(duration, () {
      if (!mounted) return;
      final updateTimeInput = TurnBasedGameUpdateTimeFsmInput(
        nowUtc: DateTime.now().toUtc(),
      );
      final newOutputs = gameObject.postInput(updateTimeInput);
      processOutputs(newOutputs);
    });
  }

  @protected
  Widget getCellContents(int index);
}
