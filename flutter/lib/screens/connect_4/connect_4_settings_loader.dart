import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'connect_4_settings_screen.dart';

class Connect4SettingsLoader extends StatelessWidget {
  const Connect4SettingsLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<({String difficulty, int moveDelay, int gameDelay})>(
      future: _loadSettings(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final data = snapshot.data!;
        return Connect4SettingsScreen(
          initialDifficulty: data.difficulty,
          initialMoveDelay: data.moveDelay,
          initialGameDelay: data.gameDelay,
        );
      },
    );
  }

  Future<({String difficulty, int moveDelay, int gameDelay})>
  _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final difficulty = prefs.getString('connect4_ai_difficulty') ?? 'beginner';
    final moveDelay = prefs.getInt('connect4_move_delay') ?? 1;
    final gameDelay = prefs.getInt('connect4_game_delay') ?? 1;
    return (difficulty: difficulty, moveDelay: moveDelay, gameDelay: gameDelay);
  }
}