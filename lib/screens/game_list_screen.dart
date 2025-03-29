import 'package:duoplay/services/game_service_contract.dart';
import 'package:duoplay/services/service_locator.dart';
import 'package:flutter/material.dart';

import '../models/game.dart';

class GameListScreen extends StatelessWidget {
  final GameServiceContract gameService = getIt<GameServiceContract>();

  GameListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Game> games = gameService.fetchGames();

    return Scaffold(
      appBar: AppBar(title: const Text('Two-Player Games')),
      body: ListView.builder(
        itemCount: games.length,
        itemBuilder: (context, index) {
          final game = games[index];
          return ListTile(
            title: Text(game.name),
            subtitle: Text(game.description),
          );
        },
      ),
    );
  }
}
