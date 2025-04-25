import 'dart:io';

import 'package:duoplay/engines/connect_4/connect_4_engine_factory.dart';
import 'package:duoplay/engines/tic_tac_toe/tic_tac_toe_engine_factory.dart';
import 'package:duoplay/models/connect_4/connect_4_game_container.dart';
import 'package:duoplay/models/connect_4/connect_4_game_utils.dart';
import 'package:duoplay/models/tic_tac_toe/tic_tac_toe_game_container.dart';
import 'package:duoplay/models/tic_tac_toe/tic_tac_toe_game_utils.dart';
import 'package:duoplay/screens/connect_4/connect_4_game_screen.dart';
import 'package:duoplay/screens/connect_4/connect_4_settings_loader.dart';
import 'package:duoplay/screens/game_list_screen.dart';
import 'package:duoplay/screens/tic_tac_toe/tic_tac_toe_game_screen.dart';
import 'package:duoplay/screens/tic_tac_toe/tic_tac_toe_settings_loader.dart';
import 'package:duoplay/services/service_locator.dart';
import 'package:duoplay/utils/development_http_overrides.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

Future<void> main() async {
  if (!kReleaseMode) {
    // Override SSL verification
    HttpOverrides.global = DevelopmentHttpOverrides();
  }
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
              gameObject: GetIt.I.get<TTTGameContainer>(),
              engine: TTTEngineFactory().createEngine(
                GetIt.I
                    .get<TTTGameContainer>()
                    .gameState
                    .configuration
                    .difficulty,
              ),
              gameUtils: GetIt.I.get<TTTGameUtils>(),
            ),
        '/tic-tac-toe/settings':
            (context) => TicTacToeSettingsLoader(
              gameContainer: GetIt.I.get<TTTGameContainer>(),
            ),
        '/connect-4':
            (context) => Connect4GameScreen(
              gameObject: GetIt.I.get<Connect4GameContainer>(),
              engine: Connect4EngineFactory().createEngine(
                GetIt.I
                    .get<Connect4GameContainer>()
                    .gameState
                    .configuration
                    .difficulty,
              ),
              gameUtils: GetIt.I.get<Connect4GameUtils>(),
            ),
        '/connect-4/settings':
            (context) => Connect4SettingsLoader(
              gameContainer: GetIt.I.get<Connect4GameContainer>(),
            ),
      },
    );
  }
}
