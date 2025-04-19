import 'dart:async';

import 'package:duoplay/engines/tic_tac_toe/tic_tac_toe_engine_contract.dart';
import 'package:duoplay/models/result.dart';
import 'package:duoplay/models/tic_tac_toe/tic_tac_toe_fsm_outputs.dart';
import 'package:duoplay/models/tic_tac_toe/tic_tac_toe_game_container.dart';
import 'package:duoplay/models/tic_tac_toe/tic_tac_toe_game_utils.dart';
import 'package:duoplay/models/tic_tac_toe/tic_tac_toe_output_container.dart';
import 'package:duoplay/models/turn_based_game/turn_based_game_fsm_inputs.dart';
import 'package:duoplay/models/turn_based_game/turn_based_game_fsm_outputs.dart';
import 'package:duoplay/models/turn_based_game/turn_based_game_utils.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TTTGameScreen extends StatefulWidget {
  final TTTGameContainer gameObject;
  final TTTEngineContract engine;
  final TTTGameUtils gameUtils;

  const TTTGameScreen({
    super.key,
    required this.gameObject,
    required this.engine,
    required this.gameUtils,
  });

  @override
  TTTGameScreenState createState() => TTTGameScreenState();
}

class TTTGameScreenState extends State<TTTGameScreen> {
  TTTGameContainer get _gameObject => widget.gameObject;
  TTTEngineContract get _engine => widget.engine;
  TTTGameUtils get _gameUtils => widget.gameUtils;
  bool get isPlayerXEngine => _gameObject.isPlayerXEngine;
  bool get isPlayerOEngine => _gameObject.isPlayerOEngine;
  bool get isHumanPlayerToMove => _gameObject.isHumanPlayerToMove;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final difficulty = _gameObject.gameState.configuration.difficulty;
    final playerLetter = _gameUtils.cellStateToShortString(_gameObject.humanPlayer).toUpperCase();
    return Scaffold(
      appBar: AppBar(title: const Text('Tic-Tac-Toe')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: _getSettingsButton(context),
          ),
          Expanded(child: _getBody()),
          Container(
            width: double.infinity,
            color: Colors.grey[200],
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Text(
              'Engine: $difficulty    You are: $playerLetter',
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  ElevatedButton _getSettingsButton(BuildContext context) => ElevatedButton(
    onPressed: () async {
      final prevDifficulty = _gameObject.gameState.configuration.difficulty;
      final int prevBetweenMoveDelay =
          _gameObject.gameState.configuration.engineMoveWaitTime?.inSeconds ??
          1;
      final int prevBetweenGameDelay =
          _gameObject.gameState.configuration.betweenGamesWaitTime.inSeconds;

      final navigator = Navigator.of(context);
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      await navigator.pushNamed('/tic-tac-toe/settings');
      if (!mounted) return;
      final prefs = await SharedPreferences.getInstance();
      final newDifficulty =
          prefs.getString('ttt_ai_difficulty') ?? prevDifficulty;
      if (newDifficulty != prevDifficulty) {
        // Update FSM for next game using postInput and TTTSetEngineDifficultyInput
        _gameObject.postInput(
          TurnBasedGameSettingsChangeFsmInput(
            newDifficulty: newDifficulty,
            betweenMoveDelaySeconds: prevBetweenMoveDelay,
            betweenGameDelaySeconds: prevBetweenGameDelay,
            nowUtc: DateTime.now().toUtc(),
          ),
        );
        // Show toast if game is in progress
        if (!_gameObject.gameState.isGameOver) {
          final current = prevDifficulty;
          final next = newDifficulty;
          final msg =
              'Current engine: $current\nNext game: $next\nEngine will change at next game.';
          scaffoldMessenger.showSnackBar(SnackBar(content: Text(msg)));
        }
        setState(() => {});
      }
    },
    child: const Text('Settings'),
  );

  Widget _getBody() => Center(
    child: AspectRatio(
      aspectRatio: 1, // Ensures the grid is square
      child: _getGameGrid(),
    ),
  );

  Widget _getGameGrid() => GridView.builder(
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 3, // 3 columns for the Tic-Tac-Toe board
      crossAxisSpacing: 4, // Space between columns
      mainAxisSpacing: 4, // Space between rows
    ),
    itemCount: 9, // 3x3 grid = 9 cells
    itemBuilder: (context, index) {
      return GestureDetector(
        onTap: () => _handleCellTap(index),
        child: Container(
          decoration: _getCellBorder(),
          child: _getCellContents(index),
        ),
      );
    },
  );

  void _handleCellTap(int index) {
    // Handle the tap using the FSM
    if (!_gameObject.isHumanPlayerToMove) return;

    final inp = TurnBasedGamePlayerMoveFsmInput(
      index: index,
      player: _gameObject.humanPlayer,
      nowUtc: DateTime.now().toUtc(),
    );
    TTTOutputContainer outputs = _gameObject.postInput(inp);
    _processOutputs(outputs);
  }

  BoxDecoration _getCellBorder() => BoxDecoration(
    border: Border.all(color: Colors.black), // Cell borders
  );

  Widget _getCellContents(int index) => Center(
    child: Text(
      _gameUtils.cellStateToShortString(_gameObject.board[index]),
      style: const TextStyle(fontSize: 32),
    ),
  );

  void _processOutputs(TTTOutputContainer outputs) {
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
        } else if (item is TTTNewBoardOutput) {
          // Not much to do here. New state will redraw the screen
        } else if (item is TurnBasedGameGameOverFsmOutput) {
          // Show some game over stuff here
        } else if (item is TurnBasedGameStartGameFsmOutput) {
          // Show some start game stuff here
        } else if (item is TurnBasedGameDoEngineMoveFsmOutput) {
          GenericResult<int> res = _engine.getNextMove(_gameObject.gameState);
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
          final newOutputs = _gameObject.postInput(
            TurnBasedGameEngineMoveFsmInput(
              nowUtc: DateTime.now().toUtc(),
              index: res.value!,
              enginePlayer: _gameObject.enginePlayer,
            ),
          );
          _processOutputs(newOutputs);
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
      final updateTimeInput = TurnBasedGameUpdateTimeFsmInput(nowUtc: DateTime.now().toUtc());
      final newOutputs = _gameObject.postInput(updateTimeInput);
      _processOutputs(newOutputs); // Process the outputs from the timer
    });
  }
}
