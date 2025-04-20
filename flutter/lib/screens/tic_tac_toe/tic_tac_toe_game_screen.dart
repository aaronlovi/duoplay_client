import 'package:duoplay/engines/turn_based_game/turn_based_game_engine_contract.dart';
import 'package:duoplay/models/turn_based_game/turn_based_game_container.dart';
import 'package:duoplay/models/turn_based_game/turn_based_game_utils.dart';
import 'package:duoplay/screens/turn_based_game_screen_base.dart';
import 'package:flutter/material.dart';

class TTTGameScreen extends StatefulWidget {
  final TurnBasedGameContainer gameObject;
  final TurnBasedGameEngineContract engine;
  final TurnBasedGameUtils gameUtils;

  const TTTGameScreen({
    super.key,
    required this.gameObject,
    required this.engine,
    required this.gameUtils,
  });

  @override
  TTTGameScreenState createState() => TTTGameScreenState();
}

class TTTGameScreenState extends TurnBasedGameScreenBase<TTTGameScreen> {
  final Color gridColor = Colors.grey[300]!; // Configurable grid color

  @override
  TurnBasedGameContainer get gameObject => widget.gameObject;
  @override
  TurnBasedGameEngineContract get engine => widget.engine;
  @override
  TurnBasedGameUtils get gameUtils => widget.gameUtils;
  @override
  String get appBarTitle => 'Tic-Tac-Toe';
  @override
  String get settingsRoute => '/tic-tac-toe/settings';
  @override
  String get settingsDifficultyKey => 'ttt_ai_difficulty';

  @override
  Widget buildGameGrid(BuildContext context) {
    final rows = gameLogic.rows;
    final columns = gameLogic.columns;

    return Center(
      child: Container(
        color: gridColor, // Set the grid background color
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
    final isMostRecentMove = index == mostRecentMoveIndex;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300), // Animation duration
      decoration: BoxDecoration(
        color:
            isMostRecentMove
                ? Colors.yellow[100]
                : Colors.white, // Highlight background
        border: Border.all(
          color: gridColor, // Highlight border
          width:
              isMostRecentMove
                  ? 4.0
                  : 2.0, // Thicker border for the most recent move
        ),
      ),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final iconSize = constraints.biggest.shortestSide * 0.6;
          return _getCellInnerContents(cellState, iconSize);
        },
      ),
    );
  }

  Widget _getCellInnerContents(
    TurnBasedGameCellState cellState,
    double iconSize,
  ) {
    switch (cellState) {
      case TurnBasedGameCellState.player1:
        return Icon(
          Icons.close, // Use an "X" icon for player 1
          color: Colors.red,
          size: iconSize * 1.2,
        );
      case TurnBasedGameCellState.player2:
        return Icon(
          Icons.circle_outlined, // Use a circle icon for player 2
          color: Colors.blue,
          size: iconSize,
        );
      default:
        return const SizedBox.shrink(); // Empty cell
    }
  }
}
