import 'package:duoplay/models/connect_4/connect_4_game_container.dart';
import 'package:duoplay/models/turn-based-game/turn_based_game_fsm_inputs.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Connect4SettingsScreen extends StatefulWidget {
  final String initialDifficulty;
  final int initialMoveDelay;
  final int initialGameDelay;

  const Connect4SettingsScreen({
    super.key,
    required this.initialDifficulty,
    this.initialMoveDelay = 1,
    this.initialGameDelay = 1,
  });

  @override
  State<Connect4SettingsScreen> createState() =>
      _Connect4SettingsScreenState();
}

class _Connect4SettingsScreenState extends State<Connect4SettingsScreen> {
  late String _selectedDifficulty;
  late int _moveDelay;
  late int _gameDelay;
  late Connect4GameContainer _gameContainer;

  @override
  void initState() {
    super.initState();
    _selectedDifficulty = widget.initialDifficulty;
    _moveDelay = widget.initialMoveDelay;
    _gameDelay = widget.initialGameDelay;
    _gameContainer = GetIt.I.get<Connect4GameContainer>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('AI Difficulty', style: TextStyle(fontSize: 18)),
            DropdownButton<String>(
              value: _selectedDifficulty,
              items: const [
                DropdownMenuItem(value: 'beginner', child: Text('Beginner')),
                DropdownMenuItem(
                  value: 'intermediate',
                  child: Text('Intermediate'),
                ),
                DropdownMenuItem(value: 'expert', child: Text('Expert')),
              ],
              onChanged: (value) async {
                if (value != null) {
                  setState(() => _selectedDifficulty = value);
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setString('connect4_ai_difficulty', value);
                  _gameContainer.postInput(
                    TurnBasedGameSettingsChangeFsmInput(
                      newDifficulty: value,
                      betweenMoveDelaySeconds: _moveDelay,
                      betweenGameDelaySeconds: _gameDelay,
                      nowUtc: DateTime.now().toUtc(),
                    ),
                  );
                }
              },
            ),
            const SizedBox(height: 24),
            const Text(
              'Time between moves (seconds)',
              style: TextStyle(fontSize: 18),
            ),
            DropdownButton<int>(
              value: _moveDelay,
              items: List.generate(
                11,
                (i) => DropdownMenuItem(value: i, child: Text(i.toString())),
              ),
              onChanged: (value) async {
                if (value != null) {
                  setState(() => _moveDelay = value);
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setInt('connect4_move_delay', value);
                  _gameContainer.postInput(
                    TurnBasedGameSettingsChangeFsmInput(
                      newDifficulty: _selectedDifficulty,
                      betweenMoveDelaySeconds: value,
                      betweenGameDelaySeconds: _gameDelay,
                      nowUtc: DateTime.now().toUtc(),
                    ),
                  );
                }
              },
            ),
            const SizedBox(height: 24),
            const Text(
              'Time between games (seconds)',
              style: TextStyle(fontSize: 18),
            ),
            DropdownButton<int>(
              value: _gameDelay,
              items: List.generate(
                11,
                (i) => DropdownMenuItem(value: i, child: Text(i.toString())),
              ),
              onChanged: (value) async {
                if (value != null) {
                  setState(() => _gameDelay = value);
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setInt('connect4_game_delay', value);
                  _gameContainer.postInput(
                    TurnBasedGameSettingsChangeFsmInput(
                      newDifficulty: _selectedDifficulty,
                      betweenMoveDelaySeconds: _moveDelay,
                      betweenGameDelaySeconds: value,
                      nowUtc: DateTime.now().toUtc(),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}