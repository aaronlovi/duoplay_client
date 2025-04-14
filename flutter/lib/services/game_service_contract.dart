import 'package:duoplay/models/game.dart';

abstract class GameServiceContract {
  List<Game> fetchGames();
}
