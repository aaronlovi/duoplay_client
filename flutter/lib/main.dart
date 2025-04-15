import 'package:duoplay/engines/tic_tac_toe/tic_tac_toe_engine_factory.dart';
import 'package:duoplay/models/tic_tac_toe/tic_tac_toe_game_container.dart';
import 'package:duoplay/screens/connect_4_screen.dart';
import 'package:duoplay/screens/game_list_screen.dart';
import 'package:duoplay/screens/settings_screen.dart';
import 'package:duoplay/screens/tic_tac_toe_game_screen.dart';
import 'package:duoplay/services/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

void _noopOnDifficultyChanged(String _) {}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupLocator();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Two-Player Games',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: GameListScreen(),
      debugShowCheckedModeBanner: false,
      routes: {
        '/tic-tac-toe':
            (context) => TTTGameScreen(
              gameObject: GetIt.I<TTTGameContainer>(),
              engine: TTTEngineFactory.createEngine(
                GetIt.I<TTTGameContainer>().gameState.configuration.difficulty,
              ),
            ),
        '/connect-4': (context) => const Connect4Screen(),
        '/settings':
            (context) => const SettingsScreen(
              initialDifficulty: 'beginner',
              onDifficultyChanged: _noopOnDifficultyChanged,
            ),
      },
    );
  }
}
