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
  Container getCellContents(int index) => Container(
    decoration: _getCellBorder(),
    child: _getCellInnerContents(index),
  );

  BoxDecoration _getCellBorder() =>
      BoxDecoration(border: Border.all(color: Colors.black));

  Widget _getCellInnerContents(int index) => Center(
    child: Text(
      gameUtils.cellStateToShortString(gameObject.board[index]),
      style: const TextStyle(fontSize: 32),
    ),
  );
}
