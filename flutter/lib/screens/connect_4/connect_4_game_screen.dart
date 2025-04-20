import 'package:duoplay/engines/turn_based_game/turn_based_game_engine_contract.dart';
import 'package:duoplay/models/turn_based_game/turn_based_game_container.dart';
import 'package:duoplay/models/turn_based_game/turn_based_game_utils.dart';
import 'package:duoplay/screens/turn_based_game_screen_base.dart';
import 'package:flutter/material.dart';

class Connect4GameScreen extends StatefulWidget {
  final TurnBasedGameContainer gameObject;
  final TurnBasedGameEngineContract engine;
  final TurnBasedGameUtils gameUtils;

  const Connect4GameScreen({
    super.key,
    required this.gameObject,
    required this.engine,
    required this.gameUtils,
  });

  @override
  Connect4GameScreenState createState() => Connect4GameScreenState();
}

class Connect4GameScreenState
    extends TurnBasedGameScreenBase<Connect4GameScreen> {
  final Color gridColor = const Color(
    0xFFFFF9C4,
  ); // Pale yellow background color

  @override
  TurnBasedGameContainer get gameObject => widget.gameObject;
  @override
  TurnBasedGameEngineContract get engine => widget.engine;
  @override
  TurnBasedGameUtils get gameUtils => widget.gameUtils;
  @override
  String get appBarTitle => 'Connect 4';
  @override
  String get settingsRoute => '/connect-4/settings';
  @override
  String get settingsDifficultyKey => 'connect4_ai_difficulty';

  @override
  Widget buildGameGrid(BuildContext context) {
    final rows = gameLogic.rows;
    final columns = gameLogic.columns;

    return Center(
      child: Container(
        color: gridColor, // Set the pale yellow grid background color
        padding: const EdgeInsets.all(
          8.0,
        ), // Add padding to extend beyond cells
        child: AspectRatio(
          aspectRatio: columns / rows, // Maintain the grid's aspect ratio
          child: super.buildGameGrid(context), // Call the base grid builder
        ),
      ),
    );
  }

  @override
  int calculateAdjustedIndex(int index) {
    final column =
        index % gameLogic.columns; // Get the column from the tapped index
    final rows = gameLogic.rows;

    // Find the lowest available cell in the column
    for (int row = rows - 1; row >= 0; row--) {
      final adjustedIndex = row * gameLogic.columns + column;
      if (gameObject.board[adjustedIndex] == TurnBasedGameCellState.empty) {
        return adjustedIndex; // Return the lowest available index
      }
    }

    return -1; // No available cell in the column
  }

  @override
  Widget getCellContents(int index) {
    final cellState = gameObject.board[index];
    final isMostRecentMove = index == mostRecentMoveIndex;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300), // Animation duration
      decoration: BoxDecoration(
        gradient:
            isMostRecentMove
                ? RadialGradient(
                  colors: [
                    Colors.yellow.withValues(
                      alpha: 0.3,
                      red: 0.3,
                      green: 0.3,
                      blue: 0.3,
                    ),
                    Colors.transparent,
                  ],
                  center: Alignment.center,
                  radius: 0.8,
                )
                : null,
        color: Colors.white, // Cell background color
        shape: BoxShape.circle,
        border: Border.all(
          color: gridColor,
          width: 2.0, // Standard border width
        ),
      ),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final tokenSize =
              constraints.biggest.shortestSide * 0.8; // Dynamic token size
          return _getCellInnerContents(cellState, tokenSize);
        },
      ),
    );
  }

  Widget _getCellInnerContents(
    TurnBasedGameCellState cellState,
    double tokenSize,
  ) {
    final color = _getCellColor(cellState);
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Container(
        width: tokenSize,
        height: tokenSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color, // Token color
        ),
      ),
    );
  }

  Color _getCellColor(TurnBasedGameCellState state) {
    switch (state) {
      case TurnBasedGameCellState.player1:
        return Colors.red; // Player 1 token color
      case TurnBasedGameCellState.player2:
        return Colors.yellow; // Player 2 token color
      default:
        return Colors.transparent; // Empty cell
    }
  }
}
