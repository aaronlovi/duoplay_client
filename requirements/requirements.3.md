# Shared Game Screen Refactoring Requirements

<!--
Relevant Context Files:
- flutter/lib/models/connect_4/connect_4_game_container.dart
- flutter/lib/models/tic_tac_toe/tic_tac_toe_game_container.dart
- flutter/lib/screens/tic_tac_toe/tic_tac_toe_game_screen.dart
- flutter/lib/screens/tic_tac_toe/tic_tac_toe_settings_screen.dart
- flutter/lib/screens/tic_tac_toe/tic_tac_toe_settings_loader.dart
- flutter/lib/screens/connect_4/connect_4_game_screen.dart
- flutter/lib/screens/connect_4/connect_4_settings_screen.dart
- flutter/lib/screens/connect_4/connect_4_settings_loader.dart
- flutter/lib/screens/turn_based_game_game_grid.dart
- flutter/lib/screens/turn_based_game_screen_base.dart
- flutter/lib/screens/turn_based_game_settings_button.dart
- flutter/lib/models/turn_based_game/turn_based_game_container.dart
- flutter/lib/models/turn_based_game_fsm.dart
- requirements/requirements.3.md

These files contain the main UI, FSM, settings, and requirements context for both games and the shared refactoring effort.
-->

<!--
Relevant Game Screen Files:
- flutter/lib/screens/tic_tac_toe/tic_tac_toe_game_screen.dart (TTTGameScreen)
- flutter/lib/screens/connect_4/connect_4_game_screen.dart (Connect4GameScreen)

These files contain the duplicated logic and are the primary targets for refactoring into a shared base class and reusable widgets as described below.
-->

This document outlines the requirements for refactoring shared logic from the Connect 4 and Tic-Tac-Toe game screens into reusable components. The goal is to enable faster iteration and development of new games by leveraging shared code for game screens. The refactoring effort focuses on creating a base class for turn-based game screens, extracting shared widgets, and ensuring the structure supports adding new games efficiently.

## Project Overview

### High-Level Goals

- Create a reusable framework for turn-based games.
- Enable faster iteration and development of new games.
- Reduce code duplication and improve maintainability.

### Current Challenges

- Duplicated logic in Connect 4 and Tic-Tac-Toe game screens.
- Difficulty in adding new games due to lack of shared components.

### Dependencies

- Flutter framework.
- SharedPreferences for persistent storage.

### Key Architectural Decisions

- Use a finite-state machine (FSM) for game logic.
- Separate engines, models, and screens for modularity.
- Extract shared widgets for common UI components.

### Testing Strategy

- Unit tests for game logic and FSM transitions.
- Integration tests for game screens and settings.
- Golden tests for UI consistency.

### Future Plans

- Add support for new turn-based games.
- Enhance AI engines for existing games.
- Improve UI/UX with animations and accessibility features.

## Workflow for Addressing Requirements

When working on the requirements in this document, follow this workflow:

1. **Analyze the Requirements**
   - Review the requirements to identify which ones are completed and which are still pending.
   - Understand the context and dependencies of the next requirement to be worked on.

2. **Pick the Next Requirement**
   - Select the next pending requirement to work on, ensuring it aligns with the project priorities.

3. **Begin Work on the Requirement**
   - Implement the necessary changes to fulfill the requirement.

4. **Iterative Analysis and Testing**
   - **Run `flutter analyze` first.**
     - If there are any errors or warnings, STOP and fix them before proceeding.
     - Only continue when `flutter analyze` reports no issues.
   - **Then run `flutter test`.**
     - If any tests fail, STOP and fix the issues.
     - Repeat running `flutter analyze` and `flutter test` after each fix until both pass with no errors or warnings.

5. **Review and Finalize**
   - Once both analysis and tests pass, stop and allow the human to review the changes.
   - Ensure the human checks in the code to the git repository.

| Requirement id | Description | Status |
|----------------|-------------|--------|
| **R.1** | Refactor shared logic from Tic-Tac-Toe and Connect 4 game screens into a reusable base class. | Complete |
| **R.1.1** | Create a `TurnBasedGameScreenBase` class. | Complete |
| **R.1.1.1** | Move FSM handling logic (`postInput`, `_processOutputs`) to the base class. | Complete |
| **R.1.1.1.1** | Refactor `postInput` to handle generic FSM inputs. | Complete |
| **R.1.1.1.2** | Refactor `_processOutputs` to handle generic FSM outputs. | Complete |
| **R.1.1.2** | Add hooks for game-specific configurations (e.g., grid size, cell rendering). | Complete |
| **R.1.1.2.1** | Define abstract methods for grid size and cell rendering. | Complete |
| **R.1.1.2.2** | Ensure the base class supports dynamic grid dimensions. | Complete |
| **R.1.1.3** | Ensure the base class supports both human and AI players. | Complete |
| **R.1.1.3.1** | Add methods to handle AI moves. | Complete |
| **R.1.1.3.2** | Add methods to handle human moves. | Complete |
| **R.1.2** | Extract shared widgets. | Complete |
| **R.1.2.1** | Create a reusable `GameGrid` widget. | Complete |
| **R.1.2.1.1** | Define a generic grid layout. | Complete |
| **R.1.2.1.2** | Add support for custom cell rendering via a callback. | Complete |
| **R.1.2.1.3** | Ensure the widget is responsive and adaptable to different grid sizes. | Complete |
| **R.1.2.2** | Create a reusable `SettingsButton` widget. | Complete |
| **R.1.2.2.1** | Add navigation logic to the settings screen. | Complete |
| **R.1.2.2.2** | Ensure the button supports customizable labels and styles. | Complete |
| **R.1.3** | Refactor Tic-Tac-Toe and Connect 4 game screens. | Complete |
| **R.1.3.1** | Update `TTTGameScreen` to extend `TurnBasedGameScreenBase`. | Complete |
| **R.1.3.1.1** | Implement game-specific configurations (e.g., 3x3 grid, cell rendering). | Complete |
| **R.1.3.1.2** | Test the refactored screen for functionality and UI consistency. | Complete |
| **R.1.3.2** | Update `Connect4GameScreen` to extend `TurnBasedGameScreenBase`. | Complete |
| **R.1.3.2.1** | Implement game-specific configurations (e.g., 7x6 grid, cell rendering). | Complete |
| **R.1.3.2.2** | Test the refactored screen for functionality and UI consistency. | Complete |
| **R.1.4** | Ensure the refactored structure supports adding new games. | Complete |
| **R.1.4.1** | Define clear interfaces for game-specific logic in the base class. | Complete |
| **R.1.4.1.1** | Document the required methods and properties for new games. | Complete |
| **R.1.4.1.2** | Provide examples of how to implement a new game using the base class. | Complete |
| **R.1.4.2** | Test the refactored screens to ensure functionality is preserved. | Complete |
| **R.1.4.2.1** | Write unit tests for the base class. | Complete |
| **R.1.4.2.2** | Write integration tests for the refactored game screens. | Complete |
| **R.1.5** | Ensure all timers and async callbacks in game screens are safe if the widget is disposed (not mounted). | Complete |
| **R.1.5.1** | Cancel all timers in dispose() and check mounted before calling setState or accessing context. | Complete |
| **R.1.5.2** | Always check mounted after await in async functions before calling setState or using context. | Complete |
| **R.1.5.3** | Add unit/widget tests to verify timer cancellation and mounted checks in game screens. | Pending |

## Example: Implementing a New Game Using the Base Class

To add a new turn-based game using the shared framework, follow these steps:

1. **Create Game Logic and Models**
   - Implement your game logic by extending `TurnBasedGameLogic`.
   - Create any game-specific models or containers as needed.

2. **Create the Game Screen**
   - Create a new screen in `lib/screens/<your_game>/<your_game>_game_screen.dart`.
   - Extend `TurnBasedGameScreenBase` in your screen's State class.
   - Implement the required abstract methods:
     - `buildSettingsButton(BuildContext context)`
     - `buildGameGrid(BuildContext context)`
     - `buildStatusBar(BuildContext context)`

    ```dart
    // Example: MyGameScreen
    import 'package:flutter/material.dart';
    import '../turn_based_game_screen_base.dart';
    import '../turn_based_game_game_grid.dart';
    import '../turn_based_game_settings_button.dart';
    // ... import your game logic, container, and utils ...

    class MyGameScreen extends StatefulWidget {
    final TurnBasedGameContainer gameObject;
    final TurnBasedGameEngineContract engine;
    final TurnBasedGameUtils gameUtils;
    final TurnBasedGameLogic gameLogic;

    const MyGameScreen({
        super.key,
        required this.gameObject,
        required this.engine,
        required this.gameUtils,
        required this.gameLogic,
    });

    @override
    MyGameScreenState createState() => MyGameScreenState();
    }

    class MyGameScreenState extends TurnBasedGameScreenBase<MyGameScreen> {
    @override
    TurnBasedGameContainer get gameObject => widget.gameObject;
    @override
    TurnBasedGameEngineContract get engine => widget.engine;
    @override
    TurnBasedGameUtils get gameUtils => widget.gameUtils;
    TurnBasedGameLogic get gameLogic => widget.gameLogic;

    @override
    Widget build(BuildContext context) {
        return Scaffold(
        appBar: AppBar(title: const Text('My Game')),
        body: Column(
            children: [
            Padding(
                padding: const EdgeInsets.all(8.0),
                child: buildSettingsButton(context),
            ),
            Expanded(child: buildGameGrid(context)),
            buildStatusBar(context),
            ],
        ),
        );
    }

    @override
    Widget buildSettingsButton(BuildContext context) => SettingsButton(
        onPressed: () async {
        // ...settings navigation and update logic...
        },
        label: 'Settings',
    );

    @override
    Widget buildGameGrid(BuildContext context) => Center(
        child: GameGrid(
        rows: gameLogic.rows,
        columns: gameLogic.columns,
        aspectRatio: gameLogic.columns / gameLogic.rows,
        cellBuilder: (context, index) {
            // ...return your cell widget...
            return Container();
        },
        ),
    );

    @override
    Widget buildStatusBar(BuildContext context) {
        // ...return your status bar widget...
        return Container();
    }
    }
    ```

3. **Register the New Game**

   - Add your new game screen to the app's navigation/routes in `main.dart`.
   - Register any required services or containers in your service locator.

4. **Test and Iterate**

   - Run `flutter analyze` and `flutter test` to ensure your new game integrates cleanly.
