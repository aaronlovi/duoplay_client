import 'package:duoplay/models/tic_tac_toe/tic_tac_toe_fsm.dart';
import 'package:duoplay/screens/connect_4_screen.dart';
import 'package:duoplay/screens/game_list_screen.dart';
import 'package:duoplay/screens/tic_tac_toe_screen.dart';
import 'package:duoplay/services/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

void main() {
  setupLocator();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Two-Player Games',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: GameListScreen(),
      debugShowCheckedModeBanner: false,
      routes: {
        '/tic-tac-toe':
            (context) => TicTacToeScreen(fsm: GetIt.I<TicTacToeFSM>()),
        '/connect-4': (context) => const Connect4Screen(),
      },
    );
  }
}
