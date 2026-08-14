import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:messmath/main.dart';
import 'package:messmath/src/features/themes/game_fonts.dart';
import 'package:messmath/src/features/themes/palette.dart';

class GameCompleteOverlayComponent extends Component {
  @override
  void render(Canvas canvas) {
    final overlayRect = Rect.fromLTWH(
      -MessmathGame.kGameWidth / 2,
      -MessmathGame.kGameHeight / 2,
      MessmathGame.kGameWidth,
      MessmathGame.kGameHeight,
    );
    final overlayPaint = Palette.color25.paint();
    canvas.drawRect(overlayRect, overlayPaint);

    final titlePainter = TextPainter(
      text: TextSpan(
        text: 'Congratulations!',
        style: GameFonts.style(
          color: Palette.color20.color,
          fontSize: 48,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    titlePainter.layout();
    titlePainter.paint(
      canvas,
      Offset(-titlePainter.width / 2, -titlePainter.height / 2),
    );

    final messagePainter = TextPainter(
      text: TextSpan(
        text: 'You have completed all levels.',
        style: GameFonts.style(
          color: Palette.color20.color,
          fontSize: 32,
          fontWeight: FontWeight.w400,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    messagePainter.layout();
    messagePainter.paint(
      canvas,
      Offset(
        -messagePainter.width / 2,
        titlePainter.height / 2 + messagePainter.height,
      ),
    );
  }
}
