import 'dart:math';
import 'dart:async';
import 'package:duoplay/engines/connect_4/connect_4_engine_contract.dart';
import 'package:duoplay/models/connect_4/connect_4_error_handling.dart';
import 'package:duoplay/models/connect_4/connect_4_fsm_inputs.dart';
import 'package:duoplay/models/connect_4/connect_4_fsm_outputs.dart';
import 'package:duoplay/models/connect_4/connect_4_output_container.dart';
import 'package:duoplay/models/result.dart';
import 'package:flutter/foundation.dart';

import 'package:duoplay/engines/connect_4/connect_4_game_logic.dart';
import 'package:duoplay/models/connect_4/connect_4_enums.dart';
import 'package:duoplay/models/connect_4/connect_4_game_container.dart';
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
            child: ElevatedButton(
              onPressed: () async {
                final prevDifficulty =
                    _gameObject.gameState.configuration.difficulty;
                final int prevBetweenMoveDelay =
                    _gameObject
                        .gameState
                        .configuration
                        .engineMoveWaitTime
                        ?.inSeconds ??
                    1;
                final int prevBetweenGameDelay =
                    _gameObject
                        .gameState
                        .configuration
                        .betweenGamesWaitTime
                        .inSeconds;

                final navigator = Navigator.of(context);
                final scaffoldMessenger = ScaffoldMessenger.of(context);
                await navigator.pushNamed('/connect-4/settings');
                if (!mounted) return;
                final prefs = await SharedPreferences.getInstance();
                final newDifficulty =
                    prefs.getString('connect4_ai_difficulty') ?? prevDifficulty;
                if (newDifficulty != prevDifficulty) {
                  _gameObject.postInput(
                    Connect4SettingsChangeInput(
                      newDifficulty: newDifficulty,
                      betweenMoveDelaySeconds: prevBetweenMoveDelay,
                      betweenGameDelaySeconds: prevBetweenGameDelay,
                      nowUtc: DateTime.now().toUtc(),
                    ),
                  );
                  if (!_gameObject.gameState.isGameOver) {
                    final current = prevDifficulty;
                    final next = newDifficulty;
                    final msg =
                        'Current engine: $current\nNext game: $next\nEngine will change at next game.';
                    scaffoldMessenger.showSnackBar(
                      SnackBar(content: Text(msg)),
                    );
                  }
                  setState(() => {});
                }
              },
              child: const Text('Settings'),
            ),
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

  Widget _getBody() => Center(
    child: AspectRatio(
      aspectRatio: 1, // Ensures the grid is square
      child: _getGameGrid(),
    ),
  );

  Widget _getGameGrid() => GridView.builder(
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 7, // 7 columns for the Connect 4 board
      crossAxisSpacing: 4, // Space between columns
      mainAxisSpacing: 4, // Space between rows
    ),
    itemCount: 42, // 6x7 grid = 42 cells
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

    final inp = Connect4PlayerMoveInput(
      column: index,
      player: _gameObject.humanPlayer,
      nowUtc: DateTime.now().toUtc(),
    );
    Connect4OutputContainer outputs = _gameObject.postInput(inp);
    _processOutputs(outputs);
  }

  BoxDecoration _getCellBorder() => BoxDecoration(
    border: Border.all(color: Colors.black), // Cell borders
  );

  Widget _getCellContents(int index) => Center(
    child: Text(
      _gameObject.board[index ~/ 7][index % 7].toString(),
      style: const TextStyle(fontSize: 32),
    ),
  );

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
  }
}

class _BoardDimensions {
  final double cellSize;
  final double boardWidth;
  final double boardHeight;

  _BoardDimensions({
    required this.cellSize,
    required this.boardWidth,
    required this.boardHeight,
  });

  static _BoardDimensions calculateBoardDimensions(BoxConstraints constraints) {
    final cellSize = min(
      constraints.maxWidth / Connect4Board.columns,
      constraints.maxHeight / Connect4Board.rows,
    );
    return _BoardDimensions(
      cellSize: cellSize,
      boardWidth: cellSize * Connect4Board.columns,
      boardHeight: cellSize * Connect4Board.rows,
    );
  }
}

/// A stateful widget that represents the Connect 4 game board.
/// 
/// This widget creates a 7 × 6 grid layout with circular placeholders
/// for empty slots. It supports animated chip drops and updates the
/// board state dynamically. The widget is reusable and manages its
/// own state for animations and board updates.
class Connect4Board extends StatefulWidget {
  static const int columns = 7; // Number of columns in the grid
  static const int rows = 6; // Number of rows in the grid
  static const double spacing = 4.0; // Spacing between grid cells
  static const int droppingChipAnimationMs = 50; // Animation duration for each step of the dropping chip

  const Connect4Board({super.key});

  @override
  State<Connect4Board> createState() => _Connect4BoardState();
}

class _Connect4BoardState extends State<Connect4Board> {
  final List<List<Connect4SquareState>> board = List.generate(
    Connect4Board.rows,
    (_) => List.filled(Connect4Board.columns, Connect4SquareState.empty),
  );

  int? _droppingChipColumn;
  int? _droppingChipRow;
  Connect4SquareState? _droppingChipColor;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final dimensions = _BoardDimensions.calculateBoardDimensions(constraints);

        return Column(
          children: [
            Expanded(
              child: Center(
                child: SizedBox(
                  width: dimensions.boardWidth,
                  height: dimensions.boardHeight,
                  child: Stack(
                    children: [
                      _buildGrid(dimensions.cellSize),
                      _buildAnimatedChip(dimensions.cellSize),
                    ],
                  ),
                ),
              ),
            ),
            if (kDebugMode) _buildDebugControls(dimensions.cellSize),
          ],
        );
      },
    );
  }
  
  Widget _buildGrid(double cellSize) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: Connect4Board.columns,
        mainAxisSpacing: Connect4Board.spacing,
        crossAxisSpacing: Connect4Board.spacing,
      ),
      itemCount: Connect4Board.columns * Connect4Board.rows,
      itemBuilder: (context, index) {
        final row = index ~/ Connect4Board.columns;
        final column = index % Connect4Board.columns;
        return Container(
          decoration: BoxDecoration(
            color: _getSquareColor(board[row][column]),
            border: Border.all(color: Colors.black),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }

  Widget _buildAnimatedChip(double cellSize) {
    if (_droppingChipColumn == null || _droppingChipRow == null || _droppingChipColor == null) {
      return const SizedBox.shrink();
    }

    return AnimatedPositioned(
      duration: Duration(milliseconds: Connect4Board.droppingChipAnimationMs),
      curve: Curves.easeIn,
      left: _droppingChipColumn! * cellSize,
      top: _droppingChipRow! * cellSize,
      child: Container(
        width: cellSize,
        height: cellSize,
        decoration: BoxDecoration(
          color: _getSquareColor(_droppingChipColor!), // Use the correct chip color
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  Widget _buildDebugControls(double cellSize) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(Connect4Board.columns, (column) {
            return Column(
              children: [
                ElevatedButton(
                  onPressed: () => _dropChip(column, Connect4SquareState.red),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    minimumSize: Size(cellSize, cellSize / 2),
                  ),
                  child: const Text('R'),
                ),
                ElevatedButton(
                  onPressed: () => _dropChip(column, Connect4SquareState.yellow),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.yellow,
                    minimumSize: Size(cellSize, cellSize / 2),
                  ),
                  child: const Text('Y'),
                ),
              ],
            );
          }),
        ),
        const SizedBox(height: 8),
        const Text(
          'Debug Mode: Use buttons to drop chips',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  void _dropChip(int column, Connect4SquareState chipColor) {
    final row = Connect4GameLogic.getTargetRow(board, column);
    if (row == null) return;

    setState(() {
      _droppingChipColumn = column;
      _droppingChipRow = 0; // Start animation from the top
      _droppingChipColor = chipColor; // Set the color of the dropping chip
    });

    // Simulate the falling animation by incrementally updating the row
    Future.doWhile(() async {
      await Future.delayed(Duration(milliseconds: Connect4Board.droppingChipAnimationMs));
      if (_droppingChipRow! < row) {
        setState(() {
          _droppingChipRow = _droppingChipRow! + 1;
        });
        return true; // Continue the animation
      } else {
        return false; // Stop the animation
      }
    }).then((_) {
      // Finalize the chip placement
      setState(() {
        board[row][column] = chipColor;
        _droppingChipColumn = null;
        _droppingChipRow = null;
        _droppingChipColor = null;
      });
    });
  }

  Color _getSquareColor(Connect4SquareState state) {
    switch (state) {
      case Connect4SquareState.empty:
        return Colors.blue[100]!;
      case Connect4SquareState.red:
        return Colors.red;
      case Connect4SquareState.yellow:
        return Colors.yellow;
    }
  }
}
