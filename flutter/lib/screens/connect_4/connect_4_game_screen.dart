import 'dart:async';

import 'package:duoplay/engines/connect_4/connect_4_engine_contract.dart';
import 'package:duoplay/engines/connect_4/connect_4_game_logic.dart';
import 'package:duoplay/models/connect_4/connect_4_enums.dart';
import 'package:duoplay/models/connect_4/connect_4_error_handling.dart';
import 'package:duoplay/models/connect_4/connect_4_fsm_inputs.dart';
import 'package:duoplay/models/connect_4/connect_4_fsm_outputs.dart';
import 'package:duoplay/models/connect_4/connect_4_game_container.dart';
import 'package:duoplay/models/connect_4/connect_4_output_container.dart';
import 'package:duoplay/models/result.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Connect4GameScreen extends StatefulWidget {
  final Connect4GameContainer gameObject;
  final Connect4EngineContract engine;

  const Connect4GameScreen({
    super.key,
    required this.gameObject,
    required this.engine,
  });

  @override
  Connect4GameScreenState createState() => Connect4GameScreenState();
}

class Connect4GameScreenState extends State<Connect4GameScreen> {
  Connect4GameContainer get _gameObject => widget.gameObject;
  Connect4EngineContract get _engine => widget.engine;
  bool get isPlayerRedTheEngine => _gameObject.isPlayerRedEngine;
  bool get isPlayerYellowTheEngine => _gameObject.isPlayerYellowEngine;
  bool get isHumanPlayerToMove => _gameObject.isHumanPlayerToMove;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final difficulty = _gameObject.gameState.configuration.difficulty;
    final playerColor = _gameObject.humanPlayer.toShortString().toUpperCase();
    return Scaffold(
      appBar: AppBar(title: const Text('Connect 4')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: _getSettingsButton(),
          ),
          Expanded(child: _getBody()),
          Container(
            width: double.infinity,
            color: Colors.grey[200],
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Text(
              'Engine: $difficulty    You are: $playerColor',
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _getSettingsButton() => ElevatedButton(
    onPressed: () async {
      final prevDifficulty = _gameObject.gameState.configuration.difficulty;
      final int prevBetweenMoveDelay =
          _gameObject.gameState.configuration.engineMoveWaitTime?.inSeconds ??
          1;
      final int prevBetweenGameDelay =
          _gameObject.gameState.configuration.betweenGamesWaitTime.inSeconds;

      final navigator = Navigator.of(context);
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      await navigator.pushNamed('/connect-4/settings');
      if (!mounted) return;
      final prefs = await SharedPreferences.getInstance();
      final newDifficulty =
          prefs.getString('connect4_ai_difficulty') ?? prevDifficulty;
      if (newDifficulty != prevDifficulty) {
        // Update FSM for next game using postInput and Connect4SettingsChangeInput
        _gameObject.postInput(
          Connect4SettingsChangeInput(
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
      aspectRatio: 7 / 6, // 7 columns and 6 rows for the Connect 4 board
      child: _getGameGrid(),
    ),
  );

  Widget _getGameGrid() => Container(
    color: const Color(0xFFFFE082), // Softer yellow for the grid background
    padding: const EdgeInsets.all(8.0), // Add padding for the margin effect
    child: LayoutBuilder(
      builder: (context, constraints) {
        final cellSize = (constraints.maxWidth - 6 * 4) / 7; // Calculate cell size
        final gridHeight = cellSize * 6 + 5 * 4; // 6 rows + spacing

        return SizedBox(
          height: gridHeight, // Constrain the height to the grid's content
          child: ScrollConfiguration(
            behavior: const ScrollBehavior().copyWith(scrollbars: false), // Disable scrollbars
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(), // Prevent scrolling
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7, // 7 columns for the Connect 4 board
                crossAxisSpacing: 4, // Space between columns
                mainAxisSpacing: 4, // Space between rows
              ),
              itemCount: 42, // 6x7 grid = 42 cells
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => _handleCellTap(index),
                  child: _getCellContents(index),
                );
              },
            ),
          ),
        );
      },
    ),
  );

  void _handleCellTap(int index) {
    // Handle the tap using the FSM
    if (!_gameObject.isHumanPlayerToMove) return;

    // Calculate the column from the index
    final column = index % Connect4GameLogic.columns;

    final inp = Connect4PlayerMoveInput(
      column: column, // Use the calculated column
      player: _gameObject.humanPlayer,
      nowUtc: DateTime.now().toUtc(),
    );
    Connect4OutputContainer outputs = _gameObject.postInput(inp);
    _processOutputs(outputs);
  }

  Widget _getCellContents(int index) {
    final cellState = _gameObject.board[index ~/ 7][index % 7];
    final color = _getCellColor(cellState);

    return Container(
      decoration: const BoxDecoration(
        shape: BoxShape.circle, // Circular cells
        color: Colors.white, // Background color for empty cells
      ),
      child: Padding(
        padding: const EdgeInsets.all(4.0), // Padding inside the circle
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color, // Color based on the cell state
          ),
        ),
      ),
    );
  }

  Color _getCellColor(Connect4SquareState state) {
    switch (state) {
      case Connect4SquareState.red:
        return Colors.red;
      case Connect4SquareState.yellow:
        return Colors.yellow;
      default:
        return Colors.transparent; // Empty cells
    }
  }

  void _processOutputs(Connect4OutputContainer outputs) {
    setState(() {
      for (var item in outputs.outputs) {
        if (item is Connect4ErrorOutput) {
          String errorMessage = connect4ErrorCodeToString(
            item.results.errorCode,
            item.results.errorParameters,
          );
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(errorMessage)));
        } else if (item is Connect4StartGameOutput) {
          // Show some start game stuff here
        } else if (item is Connect4NewBoardOutput) {
          // Not much to do here. New state will redraw the screen
        } else if (item is Connect4GameOverOutput) {
          // Show some game over stuff here
        } else if (item is Connect4DoEngineMoveOutput) {
          GenericResult<int> res = _engine.getNextMove(_gameObject.gameState);
          if (res.isFailure) {
            String errorMessage = connect4ErrorCodeToString(
              res.errorCode,
              res.errorParameters,
            );
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(errorMessage)));
            continue;
          }
          final newOutputs = _gameObject.postInput(
            Connect4EngineMoveInput(
              nowUtc: DateTime.now().toUtc(),
              column: res.value!,
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
      final updateTimeInput = Connect4UpdateTime(nowUtc: DateTime.now().toUtc());
      final newOutputs = _gameObject.postInput(updateTimeInput);
      _processOutputs(newOutputs); // Process the outputs from the timer
    });
  }
}
