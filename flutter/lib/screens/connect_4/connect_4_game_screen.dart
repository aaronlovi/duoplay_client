import 'package:duoplay/engines/turn_based_game/turn_based_game_engine_contract.dart';
import 'package:duoplay/models/turn_based_game/turn_based_game_container.dart';
import 'package:duoplay/models/turn_based_game/turn_based_game_fsm_inputs.dart';
import 'package:duoplay/models/turn_based_game/turn_based_game_logic.dart';
import 'package:duoplay/models/turn_based_game/turn_based_game_output_container.dart';
import 'package:duoplay/models/turn_based_game/turn_based_game_utils.dart';
import 'package:duoplay/screens/turn_based_game_game_grid.dart';
import 'package:duoplay/screens/turn_based_game_screen_base.dart';
import 'package:flutter/material.dart';

class Connect4GameScreen extends StatefulWidget {
  final TurnBasedGameContainer gameObject;
  final TurnBasedGameEngineContract engine;
  final TurnBasedGameUtils gameUtils;
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

class Connect4GameScreenState
    extends TurnBasedGameScreenBase<Connect4GameScreen> {
  @override
  TurnBasedGameContainer get gameObject => widget.gameObject;
  @override
  TurnBasedGameEngineContract get engine => widget.engine;
  @override
  TurnBasedGameUtils get gameUtils => widget.gameUtils;
  TurnBasedGameLogic get gameLogic => widget.gameLogic;
  @override
  String get appBarTitle => 'Connect 4';

  @override
  Widget buildSettingsButton(BuildContext context) =>
      buildDefaultSettingsButton(
        context: context,
        settingsRoute: '/connect-4/settings',
        settingsKey: 'connect4_ai_difficulty',
        label: 'Settings',
        getNewDifficulty:
            (prefs, prevDifficulty) =>
                prefs.getString('connect4_ai_difficulty') ?? prevDifficulty,
      );

  @override
  Widget buildGameGrid(BuildContext context) => Center(
    child: GameGrid(
      rows: gameLogic.rows,
      columns: gameLogic.columns,
      aspectRatio: gameLogic.columns / gameLogic.rows,
      cellBuilder: (context, index) {
        return GestureDetector(
          onTap: () => _handleCellTap(index),
          child: _getCellContents(index),
        );
      },
    ),
  );

  @override
  Widget buildStatusBar(BuildContext context) {
    final difficulty = gameObject.gameState.configuration.difficulty;
    final playerColor =
        gameUtils.cellStateToShortString(gameObject.humanPlayer).toUpperCase();
    return Container(
      width: double.infinity,
      color: Colors.grey[200],
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Text(
        'Engine: $difficulty    You are: $playerColor',
        style: const TextStyle(fontSize: 16),
        textAlign: TextAlign.center,
      ),
    );
  }

  void _handleCellTap(int index) {
    if (!gameObject.isHumanPlayerToMove) return;
    final inp = TurnBasedGamePlayerMoveFsmInput(
      index: index,
      player: gameObject.humanPlayer,
      nowUtc: DateTime.now().toUtc(),
    );
    TurnBasedGameOutputContainer outputs = gameObject.postInput(inp);
    processOutputs(outputs);
  }

  Widget _getCellContents(int index) {
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
