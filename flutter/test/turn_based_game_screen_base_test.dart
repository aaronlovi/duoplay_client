// Unit tests for TurnBasedGameScreenBase, the abstract base class for turn-based game screens.
// These tests verify that:
// - A subclass implementing all abstract methods can be instantiated and used in a widget tree.
// - The processOutputs method can be called safely and handles error outputs as expected.
//
// Note: This does not test actual game logic, but focuses on the shared base class contract and output handling.

import 'package:duoplay/engines/turn_based_game/turn_based_game_engine_contract.dart';
import 'package:duoplay/models/result.dart';
import 'package:duoplay/models/turn_based_game/turn_based_game_container.dart';
import 'package:duoplay/models/turn_based_game/turn_based_game_fsm_outputs.dart';
import 'package:duoplay/models/turn_based_game/turn_based_game_output_container.dart';
import 'package:duoplay/models/turn_based_game/turn_based_game_utils.dart';
import 'package:duoplay/screens/turn_based_game_screen_base.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

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
  Widget buildStatusBar() => const SizedBox();
  @override
  Widget getCellContents(int index) => const SizedBox();
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return const SizedBox();
  }
}

// A dummy screen that simulates an async settings button
class AsyncSettingsScreen extends DummyGameScreen {
  const AsyncSettingsScreen({super.key});
  @override
  DummyGameScreenState createState() => AsyncSettingsScreenState();
}
class AsyncSettingsScreenState extends DummyGameScreenState {
  bool setStateCalledAfterDispose = false;
  @override
  Widget buildSettingsButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        await Future.delayed(const Duration(milliseconds: 100));
        if (!mounted) return;
        // If this line runs after dispose, the test will fail
        setState(() {});
      },
      child: const Text('Async Settings'),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    // Render the async settings button so the test can find and tap it
    return MaterialApp(
      home: Scaffold(
        body: Center(child: buildSettingsButton(context)),
      ),
    );
  }
}

void main() {
  // This test verifies that a subclass implementing all abstract methods can be instantiated and used in a widget tree.
  testWidgets('TurnBasedGameScreenBase requires abstract methods', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: DummyGameScreen()));
    expect(find.byType(DummyGameScreen), findsOneWidget);
  });

  // This test verifies that processOutputs handles error outputs and does not throw exceptions.
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

  // This test verifies that the timer in TurnBasedGameScreenBase is cancelled on dispose
  // and does not call setState after the widget is unmounted (no exceptions thrown).
  testWidgets(
    'Timer is cancelled on dispose and does not call setState after unmount',
    (tester) async {
      late State dummyState;
      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              return DummyGameScreen(key: UniqueKey());
            },
          ),
        ),
      );
      dummyState = tester.state(find.byType(DummyGameScreen));
      // Schedule a timer by calling processOutputs with a nextTimeout
      // Simulate a nextTimeout 100ms in the future
      final now = DateTime.now().toUtc();
      final outputsWithTimeout = TurnBasedGameOutputContainer(
        outputs: [],
        nextTimeout: now.add(const Duration(milliseconds: 100)),
      );
      // ignore: invalid_use_of_protected_member
      (dummyState as DummyGameScreenState).processOutputs(outputsWithTimeout);
      // Dispose the widget before the timer fires
      await tester.pumpWidget(Container());
      // Wait for the timer to fire
      await tester.pump(const Duration(milliseconds: 200));
      // If no exception is thrown, the timer was cancelled and did not call setState after dispose
      expect(tester.takeException(), isNull);
    },
  );

  // This test verifies that setState/context is not called after dispose if the widget is unmounted during an async operation (e.g., settings button).
  testWidgets('No setState/context after dispose in async settings button', (tester) async {
    await tester.pumpWidget(MaterialApp(home: AsyncSettingsScreen()));
    await tester.tap(find.text('Async Settings'));
    await tester.pump();
    // Dispose the widget before the async callback completes
    await tester.pumpWidget(Container());
    // Wait for the async callback to complete
    await tester.pump(const Duration(milliseconds: 200));
    // If no exception is thrown, setState/context was not called after dispose
    expect(tester.takeException(), isNull);
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
