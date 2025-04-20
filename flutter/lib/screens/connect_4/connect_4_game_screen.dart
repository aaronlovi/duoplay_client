import 'dart:async';

import 'package:duoplay/engines/turn_based_game/turn_based_game_engine_contract.dart';
import 'package:duoplay/models/connect_4/connect_4_game_container.dart';
import 'package:duoplay/models/connect_4/connect_4_game_utils.dart';
import 'package:duoplay/models/result.dart';
import 'package:duoplay/models/turn_based_game/turn_based_game_fsm_inputs.dart';
import 'package:duoplay/models/turn_based_game/turn_based_game_fsm_outputs.dart';
import 'package:duoplay/models/turn_based_game/turn_based_game_logic.dart';
import 'package:duoplay/models/turn_based_game/turn_based_game_output_container.dart';
import 'package:duoplay/models/turn_based_game/turn_based_game_utils.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Connect4GameScreen extends StatefulWidget {
  final Connect4GameContainer gameObject;
  final TurnBasedGameEngineContract engine;
  final Connect4GameUtils gameUtils;
  final TurnBasedGameLogic gameLogic;

  const Connect4GameScreen({
    super.key,
    required this.gameObject,
    required this.engine,
    required this.gameUtils,
    required this.gameLogic,
  });

  @override
  Connect4GameScreenState createState() => Connect4GameScreenState();
}

class Connect4GameScreenState extends State<Connect4GameScreen> {
  Connect4GameContainer get _gameObject => widget.gameObject;
  TurnBasedGameEngineContract get _engine => widget.engine;
  Connect4GameUtils get _gameUtils => widget.gameUtils;
  TurnBasedGameLogic get _gameLogic => widget.gameLogic;
  bool get isPlayerRedTheEngine => _gameObject.isPlayer1Engine;
  bool get isPlayerYellowTheEngine => _gameObject.isPlayer2Engine;
  bool get isHumanPlayerToMove => _gameObject.isHumanPlayerToMove;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final difficulty = _gameObject.gameState.configuration.difficulty;
    final playerColor =
        _gameUtils
            .cellStateToShortString(_gameObject.humanPlayer)
            .toUpperCase();
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
        // Update FSM for next game using postInput and TurnBasedGameSettingsChangeFsmInput
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
      aspectRatio:
          _gameLogic.columns /
          _gameLogic.rows, // Use constants for aspect ratio
      child: _getGameGrid(),
    ),
  );

  Widget _getGameGrid() => Container(
    color: const Color(0xFFFFE082), // Softer yellow for the grid background
    padding: const EdgeInsets.all(8.0), // Add padding for the margin effect
    child: LayoutBuilder(
      builder: (context, constraints) {
        final cellSize =
            (constraints.maxWidth - (_gameLogic.columns - 1) * 4) /
            _gameLogic.columns; // Calculate cell size
        final gridHeight =
            cellSize * _gameLogic.rows +
            (_gameLogic.rows - 1) * 4; // Rows + spacing

        return SizedBox(
          height: gridHeight, // Constrain the height to the grid's content
          child: ScrollConfiguration(
            behavior: const ScrollBehavior().copyWith(
              scrollbars: false,
            ), // Disable scrollbars
            child: GridView.builder(
              physics:
                  const NeverScrollableScrollPhysics(), // Prevent scrolling
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount:
                    _gameLogic.columns, // Columns for the Connect 4 board
                crossAxisSpacing: 4, // Space between columns
                mainAxisSpacing: 4, // Space between rows
              ),
              itemCount: _gameLogic.rows * _gameLogic.columns, // Total cells
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

    final inp = TurnBasedGamePlayerMoveFsmInput(
      index: index, // Use the calculated column
      player: _gameObject.humanPlayer,
      nowUtc: DateTime.now().toUtc(),
    );
    TurnBasedGameOutputContainer outputs = _gameObject.postInput(inp);
    _processOutputs(outputs);
  }

  Widget _getCellContents(int index) {
    final cellState = _gameObject.board[index];
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

  Color _getCellColor(TurnBasedGameCellState state) {
    switch (state) {
      case TurnBasedGameCellState.player1:
        return Colors.red;
      case TurnBasedGameCellState.player2:
        return Colors.yellow;
      default:
        return Colors.transparent; // Empty cells
    }
  }

  void _processOutputs(TurnBasedGameOutputContainer outputs) {
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
        } else if (item is TurnBasedGameStartGameFsmOutput) {
          // Show some start game stuff here
        } else if (item is TurnBasedGameNewBoardFsmOutput) {
          // Not much to do here. New state will redraw the screen
        } else if (item is TurnBasedGameGameOverFsmOutput) {
          // Show some game over stuff here
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
      final updateTimeInput = TurnBasedGameUpdateTimeFsmInput(
        nowUtc: DateTime.now().toUtc(),
      );
      final newOutputs = _gameObject.postInput(updateTimeInput);
      _processOutputs(newOutputs); // Process the outputs from the timer
    });
  }
}
