import 'package:duoplay/services/game_service_contract.dart';

import '../models/game.dart';

class MockGameService implements GameServiceContract {
  @override
  List<Game> fetchGames() {
    return [
      Game(
        name: "Tic-Tac-Toe",
        description:
            "A classic two-player game where players take turns marking spaces in a 3×3 grid.",
      ),
      Game(
        name: "Connect 4",
        description:
            "A two-player connection game where players take turns dropping colored discs into a grid.",
      ),
    ];
  }
}
