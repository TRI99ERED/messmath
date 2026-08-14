import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:messmath/src/core/game/engine.dart';
import 'package:messmath/src/features/gameplay/components/board_component.dart';
import 'package:messmath/src/features/gameplay/components/game_complete_overlay_component.dart';
import 'package:messmath/src/features/gameplay/components/win_overlay_component.dart';
import 'package:messmath/src/features/themes/palette.dart';
import 'package:window_manager/window_manager.dart';

import 'src/core/game/direction.dart';
import 'src/core/levels/level_loader.dart';
import 'src/core/utils/logger.dart';
import 'src/features/gameplay/components/hud_component.dart';

void main() {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);

      if (!kIsWeb &&
          (defaultTargetPlatform == TargetPlatform.windows ||
              defaultTargetPlatform == TargetPlatform.linux ||
              defaultTargetPlatform == TargetPlatform.macOS)) {
        await windowManager.ensureInitialized();
        const windowOptions = WindowOptions(
          size: Size(MessmathGame.kGameWidth, MessmathGame.kGameHeight),
          minimumSize: Size(MessmathGame.kGameWidth, MessmathGame.kGameHeight),
          center: true,
          backgroundColor: Color(0xFF181425),
          titleBarStyle: TitleBarStyle.normal,
        );
        await windowManager.waitUntilReadyToShow(windowOptions, () async {
          await windowManager.show();
          await windowManager.focus();
        });
      }

      runApp(GameWidget(game: MessmathGame()));
    },
    (error, stackTrace) {
      Logger.e('Uncaught error', 'Main', error, stackTrace);
    },
  );
}

class MessmathGame extends FlameGame with KeyboardEvents {
  static const double kGameWidth = 1280;
  static const double kGameHeight = 720;

  final List<Direction> directionQueue = [];

  @override
  Color backgroundColor() => Palette.color27.color;

  MessmathGame()
    : super(
        camera: CameraComponent.withFixedResolution(
          width: kGameWidth,
          height: kGameHeight,
          backdrop: RectangleComponent(
            size: Vector2(kGameWidth, kGameHeight),
            paint: Paint()..color = Palette.color27.color,
          ),
        ),
        world: MessmathWorld(),
      );

  @override
  KeyEventResult onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    super.onKeyEvent(event, keysPressed);

    if (event is KeyDownEvent) {
      if (keysPressed.contains(LogicalKeyboardKey.arrowUp) ||
          keysPressed.contains(LogicalKeyboardKey.keyW)) {
        directionQueue.add(Direction.up);
        return KeyEventResult.handled;
      } else if (keysPressed.contains(LogicalKeyboardKey.arrowDown) ||
          keysPressed.contains(LogicalKeyboardKey.keyS)) {
        directionQueue.add(Direction.down);
        return KeyEventResult.handled;
      } else if (keysPressed.contains(LogicalKeyboardKey.arrowLeft) ||
          keysPressed.contains(LogicalKeyboardKey.keyA)) {
        directionQueue.add(Direction.left);
        return KeyEventResult.handled;
      } else if (keysPressed.contains(LogicalKeyboardKey.arrowRight) ||
          keysPressed.contains(LogicalKeyboardKey.keyD)) {
        directionQueue.add(Direction.right);
        return KeyEventResult.handled;
      } else if (keysPressed.contains(LogicalKeyboardKey.keyR)) {
        (world as MessmathWorld).resetLevel();
        return KeyEventResult.handled;
      } else if (keysPressed.contains(LogicalKeyboardKey.enter)) {
        (world as MessmathWorld).nextLevel();
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }
}

class MessmathWorld extends World {
  int currentLevel = 1;

  late BoardComponent boardComponent;
  late HudComponent hudComponent;

  @override
  void onLoad() {
    super.onLoad();

    loadLevel(currentLevel);
  }

  void loadLevel(int levelNumber) {
    currentLevel = levelNumber;
    final level = LevelLoader.loadLevel(levelNumber);

    boardComponent = BoardComponent(Engine(level.initialBoard));
    boardComponent.reset();
    hudComponent = HudComponent(levelName: level.name);

    removeAll(children);
    add(boardComponent);
    add(hudComponent);

    boardComponent.onWin = () {
      add(WinOverlayComponent(moveCount: boardComponent.moveCount));
    };
  }

  void resetLevel() {
    loadLevel(currentLevel);
  }

  void nextLevel() {
    if (currentLevel < LevelLoader.levels.length) {
      loadLevel(currentLevel + 1);
    } else {
      removeAll(children);
      add(GameCompleteOverlayComponent());
    }
  }
}
