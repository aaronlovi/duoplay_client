import 'package:duoplay/engines/tic_tac_toe/tic_tac_toe_engine_factory.dart';
import 'package:duoplay/models/tic_tac_toe/tic_tac_toe_game_container.dart';
import 'package:duoplay/screens/connect_4_screen.dart';
import 'package:duoplay/screens/game_list_screen.dart';
import 'package:duoplay/screens/settings_screen.dart';
import 'package:duoplay/screens/tic_tac_toe_game_screen.dart';
import 'package:duoplay/services/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setupLocator();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _difficulty = 'beginner';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadDifficulty();
  }

  Future<void> _loadDifficulty() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _difficulty = prefs.getString('ai_difficulty') ?? 'beginner';
      _loading = false;
    });
  }

  Future<void> _saveDifficulty(String difficulty) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('ai_difficulty', difficulty);
    setState(() {
      _difficulty = difficulty;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }
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
              engine: TTTEngineFactory.createEngine(_difficulty),
            ),
        '/connect-4': (context) => const Connect4Screen(),
        '/settings':
            (context) => SettingsScreen(
              initialDifficulty: _difficulty,
              onDifficultyChanged: _saveDifficulty,
            ),
      },
    );
  }
}
