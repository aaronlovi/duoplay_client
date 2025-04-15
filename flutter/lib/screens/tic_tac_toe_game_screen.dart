import 'dart:async';

import 'package:duoplay/engines/tic_tac_toe/tic_tac_toe_engine_contract.dart';
import 'package:duoplay/models/result.dart';
import 'package:duoplay/models/tic_tac_toe/tic_tac_toe_cell_state.dart';
import 'package:duoplay/models/tic_tac_toe/tic_tac_toe_error_handling.dart';
import 'package:duoplay/models/tic_tac_toe/tic_tac_toe_fsm_inputs.dart';
import 'package:duoplay/models/tic_tac_toe/tic_tac_toe_fsm_outputs.dart';
import 'package:duoplay/models/tic_tac_toe/tic_tac_toe_game_container.dart';
import 'package:duoplay/models/tic_tac_toe/tic_tac_toe_output_container.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TTTGameScreen extends StatefulWidget {
  final TTTGameContainer gameObject;
  final TTTEngineContract engine;

  const TTTGameScreen({
    super.key,
    required this.gameObject,
    required this.engine,
  });

  @override
  TTTGameScreenState createState() => TTTGameScreenState();
}

class TTTGameScreenState extends State<TTTGameScreen> {
  TTTGameContainer get _gameObject => widget.gameObject;
  TTTEngineContract get _engine => widget.engine;
  bool get isPlayerXEngine => _gameObject.isPlayerXEngine;
  bool get isPlayerOEngine => _gameObject.isPlayerOEngine;
  bool get isHumanPlayerToMove => _gameObject.isHumanPlayerToMove;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tic-Tac-Toe')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () async {
                final prevDifficulty =
                    _gameObject.gameState.configuration.difficulty;
                final navigator = Navigator.of(context);
                final scaffoldMessenger = ScaffoldMessenger.of(context);
                await navigator.pushNamed('/settings');
                if (!mounted) return;
                final prefs = await SharedPreferences.getInstance();
                final newDifficulty =
                    prefs.getString('ai_difficulty') ?? prevDifficulty;
                if (newDifficulty != prevDifficulty) {
                  // Update FSM for next game
                  _gameObject.updateEngineDifficulty(newDifficulty);
                  // Show toast if game is in progress
                  if (!_gameObject.gameState.isGameOver) {
                    final current = prevDifficulty;
                    final next = newDifficulty;
                    final msg =
                        'Current engine: $current\nNext game: $next\nEngine will change at next game.';
                    scaffoldMessenger.showSnackBar(
                      SnackBar(content: Text(msg)),
                    );
                  }
                }
              },
              child: const Text('Settings'),
            ),
          ),
          Expanded(child: _getBody()),
        ],
      ),
    );
  }

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

    final inp = TTTPlayerMoveInput(
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
      _gameObject.board[index].toShortString(),
      style: const TextStyle(fontSize: 32),
    ),
  );

  void _processOutputs(TTTOutputContainer outputs) {
    setState(() {
      for (var item in outputs.outputs) {
        if (item is TTTErrorOutput) {
          String errorMessage = tttErrorCodeToString(
            item.results.errorCode,
            item.results.errorParameters,
          );
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(errorMessage)));
        } else if (item is TTTNewBoardOutput) {
          // Not much to do here. New state will redraw the screen
        } else if (item is TTTGameOverOutput) {
          // Show some game over stuff here
        } else if (item is TTTStartGameOutput) {
          // Show some start game stuff here
        } else if (item is TTTDoEngineMoveOutput) {
          GenericResult<int> res = _engine.getNextMove(_gameObject.gameState);
          if (res.isFailure) {
            String errorMessage = tttErrorCodeToString(
              res.errorCode,
              res.errorParameters,
            );
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(errorMessage)));
            continue;
          }
          final newOutputs = _gameObject.postInput(
            TTTEngineMoveInput(
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
      final updateTimeInput = TTTUpdateTime(nowUtc: DateTime.now().toUtc());
      final newOutputs = _gameObject.postInput(updateTimeInput);
      _processOutputs(newOutputs); // Process the outputs from the timer
    });
  }
}
