import 'package:duoplay/engines/turn_based_game/turn_based_game_engine_contract.dart';
import 'package:duoplay/models/turn_based_game/turn_based_game_container.dart';
import 'package:duoplay/models/turn_based_game/turn_based_game_fsm_inputs.dart';
import 'package:duoplay/models/turn_based_game/turn_based_game_output_container.dart';
import 'package:duoplay/models/turn_based_game/turn_based_game_utils.dart';
import 'package:duoplay/screens/turn_based_game_game_grid.dart';
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
  @override
  TurnBasedGameContainer get gameObject => widget.gameObject;
  @override
  TurnBasedGameEngineContract get engine => widget.engine;
  @override
  TurnBasedGameUtils get gameUtils => widget.gameUtils;
  @override
  String get appBarTitle => 'Tic-Tac-Toe';

  @override
  Widget buildSettingsButton(BuildContext context) =>
      buildDefaultSettingsButton(
        context: context,
        settingsRoute: '/tic-tac-toe/settings',
        settingsKey: 'ttt_ai_difficulty',
        label: 'Settings',
        getNewDifficulty:
            (prefs, prevDifficulty) =>
                prefs.getString('ttt_ai_difficulty') ?? prevDifficulty,
      );

  @override
  Widget buildGameGrid(BuildContext context) => Center(
    child: GameGrid(
      rows: 3,
      columns: 3,
      aspectRatio: 1,
      cellBuilder: (context, index) {
        return GestureDetector(
          onTap: () => _handleCellTap(index),
          child: Container(
            decoration: _getCellBorder(),
            child: _getCellContents(index),
          ),
        );
      },
    ),
  );

  @override
  Widget buildStatusBar(BuildContext context) {
    final difficulty = gameObject.gameState.configuration.difficulty;
    final playerLetter =
        gameUtils.cellStateToShortString(gameObject.humanPlayer).toUpperCase();
    return Container(
      width: double.infinity,
      color: Colors.grey[200],
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Text(
        'Engine: $difficulty    You are: $playerLetter',
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

  BoxDecoration _getCellBorder() =>
      BoxDecoration(border: Border.all(color: Colors.black));

  Widget _getCellContents(int index) => Center(
    child: Text(
      gameUtils.cellStateToShortString(gameObject.board[index]),
      style: const TextStyle(fontSize: 32),
    ),
  );
}
