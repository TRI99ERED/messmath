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
import 'package:messmath/src/features/gameplay/scenes/level_select_scene.dart';
import 'package:messmath/src/features/gameplay/scenes/title_scene.dart';
import 'package:messmath/src/features/themes/game_fonts.dart';
import 'package:messmath/src/features/themes/palette.dart';
import 'package:window_manager/window_manager.dart';

import 'src/core/game/direction.dart';
import 'src/core/levels/level_loader.dart';
import 'src/core/utils/logger.dart';
import 'src/features/gameplay/hud/hud_component.dart';

void main() {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      GameFonts.disableRuntimeFetching();
      GameFonts.preload();
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
      final world = this.world as MessmathWorld;
      final levelSelectScene = world.levelSelectScene;
      if (levelSelectScene != null) {
        if (keysPressed.contains(LogicalKeyboardKey.arrowUp) ||
            keysPressed.contains(LogicalKeyboardKey.keyW)) {
          levelSelectScene.navigate(Direction.up);
          return KeyEventResult.handled;
        } else if (keysPressed.contains(LogicalKeyboardKey.arrowDown) ||
            keysPressed.contains(LogicalKeyboardKey.keyS)) {
          levelSelectScene.navigate(Direction.down);
          return KeyEventResult.handled;
        } else if (keysPressed.contains(LogicalKeyboardKey.arrowLeft) ||
            keysPressed.contains(LogicalKeyboardKey.keyA)) {
          levelSelectScene.navigate(Direction.left);
          return KeyEventResult.handled;
        } else if (keysPressed.contains(LogicalKeyboardKey.arrowRight) ||
            keysPressed.contains(LogicalKeyboardKey.keyD)) {
          levelSelectScene.navigate(Direction.right);
          return KeyEventResult.handled;
        } else if (keysPressed.contains(LogicalKeyboardKey.enter)) {
          levelSelectScene.selectLevel();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      }
      if (world.isOnTitleScreen) {
        if (keysPressed.contains(LogicalKeyboardKey.enter)) {
          world.showLevelSelect();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      }
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
        world.resetLevel();
        return KeyEventResult.handled;
      } else if (keysPressed.contains(LogicalKeyboardKey.enter)) {
        world.nextLevel();
        return KeyEventResult.handled;
      } else if (keysPressed.contains(LogicalKeyboardKey.escape)) {
        world.showLevelSelect();
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

    add(TitleScene());
  }

  bool get isOnTitleScreen =>
      children.any((component) => component is TitleScene);

  LevelSelectScene? get levelSelectScene {
    for (final component in children) {
      if (component is LevelSelectScene) return component;
    }
    return null;
  }

  void showLevelSelect() {
    removeAll(children);
    add(LevelSelectScene());
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
    if (!boardComponent.isWon) return;
    if (currentLevel < LevelLoader.levels.length) {
      loadLevel(currentLevel + 1);
    } else {
      removeAll(children);
      add(GameCompleteOverlayComponent());
    }
  }
}
