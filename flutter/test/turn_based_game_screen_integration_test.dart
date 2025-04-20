// Integration tests for the refactored game screens using TurnBasedGameScreenBase.
// These tests verify that the Tic-Tac-Toe and Connect 4 screens can be pumped into a widget tree
// and that their main UI elements (settings button, grid, status bar) are present.

import 'package:duoplay/engines/turn_based_game/turn_based_game_engine_contract.dart';
import 'package:duoplay/models/turn_based_game/turn_based_game_board.dart';
import 'package:duoplay/models/turn_based_game/turn_based_game_configuration.dart';
import 'package:duoplay/models/turn_based_game/turn_based_game_container.dart';
import 'package:duoplay/models/turn_based_game/turn_based_game_logic.dart';
import 'package:duoplay/models/turn_based_game/turn_based_game_utils.dart';
import 'package:duoplay/models/turn_based_game_fsm.dart';
import 'package:duoplay/screens/connect_4/connect_4_game_screen.dart';
import 'package:duoplay/screens/tic_tac_toe/tic_tac_toe_game_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class DummyContainer extends TurnBasedGameContainer {
  DummyContainer()
    : super(
        fsm: TurnBasedGameFsm(
          TurnBasedGameConfiguration(
            enginePlayer: TurnBasedGameCellState.player1,
            betweenGamesWaitTime: Duration.zero,
            engineMoveWaitTime: Duration.zero,
            difficulty: 'beginner', // Use a valid difficulty
          ),
          DummyLogic(),
        ),
      );
}

class DummyEngine implements TurnBasedGameEngineContract {
  @override
  getNextMove(_) => throw UnimplementedError();
}

class DummyUtils extends TurnBasedGameUtils {
  @override
  String cellStateToShortString(_) => '';
}

class DummyLogic extends TurnBasedGameLogic {
  @override
  int get columns => 3;
  @override
  int get rows => 3;
  @override
  void applyMove(board, index, state) {}
  @override
  void debugPrintBoard(board) {}
  @override
  getWinner(board) => TurnBasedGameCellState.empty;
  @override
  bool isDraw(board) => false;
  @override
  bool isLegalMove(board, index) => true;
  @override
  parseBoard(boardString) => TurnBasedGameBoard(0, 0);
}

void main() {
  testWidgets('TTTGameScreen renders main UI elements', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: TTTGameScreen(
          gameObject: DummyContainer(),
          engine: DummyEngine(),
          gameUtils: DummyUtils(),
          gameLogic: DummyLogic(),
        ),
      ),
    );
    expect(find.text('Settings'), findsOneWidget);
    expect(find.byType(GridView), findsOneWidget);
    expect(find.textContaining('Engine:'), findsOneWidget);
  });

  testWidgets('Connect4GameScreen renders main UI elements', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Connect4GameScreen(
          gameObject: DummyContainer(),
          engine: DummyEngine(),
          gameUtils: DummyUtils(),
          gameLogic: DummyLogic(),
        ),
      ),
    );
    expect(find.text('Settings'), findsOneWidget);
    expect(find.byType(GridView), findsOneWidget);
    expect(find.textContaining('Engine:'), findsOneWidget);
  });
}
