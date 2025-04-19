import 'package:duoplay/models/connect_4/connect_4_enums.dart';
import 'package:duoplay/models/connect_4/connect_4_fsm.dart';
import 'package:duoplay/models/connect_4/connect_4_game_configuration.dart';
import 'package:duoplay/models/connect_4/connect_4_game_container.dart';
import 'package:duoplay/models/tic_tac_toe/tic_tac_toe_cell_state.dart';
import 'package:duoplay/models/tic_tac_toe/tic_tac_toe_fsm.dart';
import 'package:duoplay/models/tic_tac_toe/tic_tac_toe_game_configuration.dart';
import 'package:duoplay/models/tic_tac_toe/tic_tac_toe_game_container.dart';
import 'package:duoplay/services/game_service_contract.dart';
import 'package:duoplay/services/mock_game_service.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

final GetIt getIt = GetIt.instance;

Future<void> setupLocator() async {
  final prefs = await SharedPreferences.getInstance();
  final tttMoveDelay = prefs.getInt('ttt_move_delay') ?? 1;
  final tttGameDelay = prefs.getInt('ttt_game_delay') ?? 1;
  final tttDifficulty = prefs.getString('ttt_ai_difficulty') ?? 'beginner';
  final connect4MoveDelay = prefs.getInt('connect4_move_delay') ?? 1;
  final connect4GameDelay = prefs.getInt('connect4_game_delay') ?? 1;
  final connect4Difficulty =
      prefs.getString('connect4_ai_difficulty') ?? 'beginner';
  getIt.registerLazySingleton<GameServiceContract>(() => MockGameService());
  getIt.registerLazySingleton<TTTFsm>(
    () => TTTFsm(
      TTTGameConfiguration(
        enginePlayer: TTTCellState.o,
        betweenGamesWaitTime: Duration(seconds: tttGameDelay),
        engineMoveWaitTime: Duration(seconds: tttMoveDelay),
        difficulty: tttDifficulty,
      ),
    ),
  );
  getIt.registerLazySingleton<TTTGameContainer>(
    () => TTTGameContainer(fsm: getIt.get<TTTFsm>()),
  );
  getIt.registerLazySingleton<Connect4FSM>(
    () => Connect4FSM(
      Connect4GameConfiguration(
        enginePlayer: Connect4SquareState.yellow,
        betweenGamesWaitTime: Duration(seconds: connect4GameDelay),
        engineMoveWaitTime: Duration(seconds: connect4MoveDelay),
        difficulty: connect4Difficulty,
      ),
    ),
  );
  getIt.registerLazySingleton<Connect4GameContainer>(
    () => Connect4GameContainer(fsm: getIt.get<Connect4FSM>()),
  );
}
