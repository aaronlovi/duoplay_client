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
  Widget getCellContents(int index) {
    final cellState = gameObject.board[index];
    final color = _getCellColor(cellState);
    return Container(
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
      ),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Container(
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
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
        return Colors.transparent;
    }
  }
}
