import 'package:duoplay/screens/views/sign_in_button.dart';
import 'package:duoplay/services/game_service_contract.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../models/game.dart';

class GameListScreen extends StatelessWidget {
  final GameServiceContract gameService = GetIt.I.get<GameServiceContract>();

  GameListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Game> games = gameService.fetchGames();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Two-Player Games'),
        actions: const [
          Padding(padding: EdgeInsets.only(right: 12.0), child: SignInButton()),
        ],
        // Removed settings icon button (G.1.9.1)
      ),
      body: ListView.builder(
        itemCount: games.length,
        itemBuilder: (context, index) {
          final game = games[index];
          return ListTile(
            title: Text(game.name),
            subtitle: Text(game.description),
            onTap: () => Navigator.pushNamed(context, game.route),
          );
        },
      ),
    );
  }
}
