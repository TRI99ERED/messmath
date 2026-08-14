import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:messmath/main.dart';
import 'package:messmath/src/features/themes/game_fonts.dart';
import 'package:messmath/src/features/themes/palette.dart';

class WinOverlayComponent extends Component {
  final int moveCount;

  WinOverlayComponent({required this.moveCount});

  static const double _cycleDuration = 1.0;

  late int _colorIndex;
  double _elapsed = 0;

  @override
  void onLoad() {
    _colorIndex = Random().nextInt(Palette.levelBackgrounds.length);
  }

  @override
  void update(double dt) {
    _elapsed += dt;
    if (_elapsed >= _cycleDuration) {
      _elapsed = 0;
      _colorIndex = (_colorIndex + 1) % Palette.levelBackgrounds.length;
    }
  }

  @override
  void render(Canvas canvas) {
    final overlayRect = Rect.fromLTWH(
      -MessmathGame.kGameWidth / 2,
      -MessmathGame.kGameHeight / 2,
      MessmathGame.kGameWidth,
      MessmathGame.kGameHeight,
    );
    final overlayPaint = Paint()
      ..color = Palette.levelBackgrounds[_colorIndex].color;
    canvas.drawRect(overlayRect, overlayPaint);

    final messagePainter = TextPainter(
      text: TextSpan(
        text: 'Equation Solved!',
        style: GameFonts.style(
          color: Palette.color20.color,
          fontSize: 48,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    messagePainter.layout();
    messagePainter.paint(
      canvas,
      Offset(-messagePainter.width / 2, -messagePainter.height / 2),
    );

    final moveCountPainter = TextPainter(
      text: TextSpan(
        text: 'Moves: $moveCount',
        style: GameFonts.style(
          color: Palette.color20.color,
          fontSize: 32,
          fontWeight: FontWeight.w400,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    moveCountPainter.layout();
    moveCountPainter.paint(
      canvas,
      Offset(
        -moveCountPainter.width / 2,
        messagePainter.height / 2 + moveCountPainter.height,
      ),
    );

    final retryPainter = TextPainter(
      text: TextSpan(
        text: 'Press [R] to Retry',
        style: GameFonts.style(
          color: Palette.color20.color,
          fontSize: 24,
          fontWeight: FontWeight.w400,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    retryPainter.layout();
    retryPainter.paint(
      canvas,
      Offset(
        -retryPainter.width / 2,
        messagePainter.height / 2 +
            moveCountPainter.height +
            retryPainter.height +
            8,
      ),
    );

    final nextLevelPainter = TextPainter(
      text: TextSpan(
        text: 'Press [Enter] for Next Level',
        style: GameFonts.style(
          color: Palette.color20.color,
          fontSize: 24,
          fontWeight: FontWeight.w400,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    nextLevelPainter.layout();
    nextLevelPainter.paint(
      canvas,
      Offset(
        -nextLevelPainter.width / 2,
        messagePainter.height / 2 +
            moveCountPainter.height +
            retryPainter.height +
            nextLevelPainter.height +
            8,
      ),
    );
  }
}
