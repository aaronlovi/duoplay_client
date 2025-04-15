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
  final moveDelay = prefs.getInt('ttt_move_delay') ?? 1;
  final gameDelay = prefs.getInt('ttt_game_delay') ?? 1;
  final difficulty = prefs.getString('ttt_ai_difficulty') ?? 'beginner';
  getIt.registerLazySingleton<GameServiceContract>(() => MockGameService());
  getIt.registerLazySingleton<TTTFsm>(
    () => TTTFsm(
      TTTGameConfiguration(
        enginePlayer: TTTCellState.o,
        betweenGamesWaitTime: Duration(seconds: gameDelay),
        engineMoveWaitTime: Duration(seconds: moveDelay),
        difficulty: difficulty,
      ),
    ),
  );
  getIt.registerLazySingleton<TTTGameContainer>(
    () => TTTGameContainer(fsm: getIt.get<TTTFsm>()),
  );
}
