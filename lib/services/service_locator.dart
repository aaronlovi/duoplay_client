import 'package:duoplay/services/game_service_contract.dart';
import 'package:duoplay/services/mock_game_service.dart';
import 'package:get_it/get_it.dart';

final GetIt getIt = GetIt.instance;

void setupLocator() {
  getIt.registerLazySingleton<GameServiceContract>(() => MockGameService());
}
