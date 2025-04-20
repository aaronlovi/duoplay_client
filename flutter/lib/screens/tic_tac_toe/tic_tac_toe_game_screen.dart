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
  Container getCellContents(int index) => Container(
    decoration: BoxDecoration(
      color: Colors.white, // Set the cell background color
      border: Border.all(
        color: gridColor,
        width: 2.0,
      ), // Add border to create grid effect
    ),
    child: _getCellInnerContents(index), // Add cell content
  );

  Widget _getCellInnerContents(int index) => Center(
    child: Text(
      gameUtils.cellStateToShortString(gameObject.board[index]),
      style: const TextStyle(fontSize: 32),
    ),
  );
}
