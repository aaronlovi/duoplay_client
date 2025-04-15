import 'package:duoplay/models/tic_tac_toe/tic_tac_toe_fsm.dart';
import 'package:duoplay/models/tic_tac_toe/tic_tac_toe_game_configuration.dart';
import 'package:duoplay/models/tic_tac_toe/tic_tac_toe_game_container.dart';
import 'package:duoplay/services/game_service_contract.dart';
import 'package:duoplay/services/mock_game_service.dart';
import 'package:get_it/get_it.dart';

final GetIt getIt = GetIt.instance;

void setupLocator() {
  getIt.registerLazySingleton<GameServiceContract>(() => MockGameService());
  getIt.registerLazySingleton<TTTFsm>(
    () => TTTFsm(TTTGameConfiguration.defaults()),
  );
  getIt.registerLazySingleton<TTTGameContainer>(
    () => TTTGameContainer(fsm: getIt.get<TTTFsm>()),
  );
}
