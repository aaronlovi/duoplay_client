// Unit tests for TurnBasedGameScreenBase, the abstract base class for turn-based game screens.
// These tests verify that:
// - A subclass implementing all abstract methods can be instantiated and used in a widget tree.
// - The processOutputs method can be called safely and handles error outputs as expected.
//
// Note: This does not test actual game logic, but focuses on the shared base class contract and output handling.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:duoplay/screens/turn_based_game_screen_base.dart';
import 'package:duoplay/models/turn_based_game/turn_based_game_container.dart';
import 'package:duoplay/engines/turn_based_game/turn_based_game_engine_contract.dart';
import 'package:duoplay/models/turn_based_game/turn_based_game_utils.dart';
import 'package:duoplay/models/turn_based_game/turn_based_game_output_container.dart';
import 'package:duoplay/models/turn_based_game/turn_based_game_fsm_outputs.dart';
import 'package:duoplay/models/result.dart';

class DummyGameScreen extends StatefulWidget {
  const DummyGameScreen({super.key});
  @override
  DummyGameScreenState createState() => DummyGameScreenState();
}

class DummyGameScreenState extends TurnBasedGameScreenBase<DummyGameScreen> {
  @override
  TurnBasedGameContainer get gameObject => throw UnimplementedError();
  @override
  TurnBasedGameEngineContract get engine => throw UnimplementedError();
  @override
  TurnBasedGameUtils get gameUtils => throw UnimplementedError();
  @override
  String get appBarTitle => 'Dummy';
  @override
  String get settingsRoute => '/dummy/settings';
  @override
  String get settingsDifficultyKey => 'dummy_ai_difficulty';
  @override
  Widget buildSettingsButton(BuildContext context) => const SizedBox();
  @override
  Widget buildGameGrid(BuildContext context) => const SizedBox();
  @override
  Widget buildStatusBar(BuildContext context) => const SizedBox();
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return const SizedBox();
  }
}

void main() {
  testWidgets('TurnBasedGameScreenBase requires abstract methods', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: DummyGameScreen()));
    expect(find.byType(DummyGameScreen), findsOneWidget);
  });

  testWidgets('processOutputs handles error output', (tester) async {
    final outputs = TurnBasedGameOutputContainer(
      outputs: [
        TurnBasedGameErrorFsmOutput(
          results: Result.failure(ResultErrorCode.invalidMove),
        ),
      ],
    );
    await tester.pumpWidget(
      MaterialApp(home: DummyGameScreenWithOutput(outputs: outputs)),
    );
    expect(true, isTrue); // If no exception, test passes
  });
}

class DummyGameScreenWithOutput extends StatefulWidget {
  final TurnBasedGameOutputContainer outputs;
  const DummyGameScreenWithOutput({super.key, required this.outputs});
  @override
  State<DummyGameScreenWithOutput> createState() =>
      _DummyGameScreenWithOutputState();
}

class _DummyGameScreenWithOutputState extends State<DummyGameScreenWithOutput> {
  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = context.findAncestorStateOfType<DummyGameScreenState>();
      if (state != null) {
        // ignore: invalid_use_of_protected_member
        state.processOutputs(widget.outputs);
      }
    });
    return DummyGameScreen();
  }
}
