import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:messmath/src/features/themes/palette.dart';
import 'package:window_manager/window_manager.dart';

import 'src/core/utils/logger.dart';

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

class MessmathGame extends FlameGame {
  static const double kGameWidth = 1280;
  static const double kGameHeight = 720;

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
  Color backgroundColor() => Palette.color27.color;
}

class MessmathWorld extends World {}
