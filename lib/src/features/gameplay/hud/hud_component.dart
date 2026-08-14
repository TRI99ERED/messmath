import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:messmath/main.dart';
import 'package:messmath/src/features/themes/game_fonts.dart';
import 'package:messmath/src/features/themes/palette.dart';

class HudComponent extends Component {
  final String levelName;

  HudComponent({required this.levelName});

  @override
  void render(Canvas canvas) {
    final levelNamePanelRRect = RRect.fromRectAndCorners(
      Rect.fromLTWH(
        -MessmathGame.kGameWidth / 2 + 16,
        -MessmathGame.kGameHeight / 2 + 16,
        512,
        64,
      ),
      topLeft: const Radius.circular(8),
      topRight: const Radius.circular(8),
      bottomLeft: const Radius.circular(8),
      bottomRight: const Radius.circular(8),
    );
    final levelNamePanelPaint = Palette.color20.paint();

    canvas.drawRRect(levelNamePanelRRect, levelNamePanelPaint);

    final textPainter = TextPainter(
      text: TextSpan(
        text: levelName,
        style: GameFonts.style(
          color: Palette.color27.color,
          fontSize: 32,
          fontWeight: FontWeight.w400,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        -MessmathGame.kGameWidth / 2 + 16 + (512 - textPainter.width) / 2,
        -MessmathGame.kGameHeight / 2 + 16 + (64 - textPainter.height) / 2,
      ),
    );

    final moveCountPanelRRect = RRect.fromRectAndCorners(
      Rect.fromLTWH(
        MessmathGame.kGameWidth / 2 - 16 - 512,
        -MessmathGame.kGameHeight / 2 + 16,
        512,
        64,
      ),
      topLeft: const Radius.circular(8),
      topRight: const Radius.circular(8),
      bottomLeft: const Radius.circular(8),
      bottomRight: const Radius.circular(8),
    );
    final moveCountPanelPaint = Palette.color20.paint();

    canvas.drawRRect(moveCountPanelRRect, moveCountPanelPaint);

    final moveCountTextPainter = TextPainter(
      text: TextSpan(
        text: 'Moves: ${(parent as MessmathWorld).boardComponent.moveCount}',
        style: GameFonts.style(
          color: Palette.color27.color,
          fontSize: 32,
          fontWeight: FontWeight.w400,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    moveCountTextPainter.layout();
    moveCountTextPainter.paint(
      canvas,
      Offset(
        MessmathGame.kGameWidth / 2 -
            16 -
            512 +
            (512 - moveCountTextPainter.width) / 2,
        -MessmathGame.kGameHeight / 2 +
            16 +
            (64 - moveCountTextPainter.height) / 2,
      ),
    );

    final moveHintPanelRRect = RRect.fromRectAndCorners(
      Rect.fromLTWH(-512, MessmathGame.kGameHeight / 2 - 16 - 64, 1024, 64),
      topLeft: const Radius.circular(8),
      topRight: const Radius.circular(8),
      bottomLeft: const Radius.circular(8),
      bottomRight: const Radius.circular(8),
    );
    final moveHintPanelPaint = Palette.color20.paint();

    canvas.drawRRect(moveHintPanelRRect, moveHintPanelPaint);

    final moveHintTextPainter = TextPainter(
      text: TextSpan(
        text: '←↑↓→ or WASD to move. [R] to reset. [Esc] to exit',
        style: GameFonts.style(
          color: Palette.color27.color,
          fontSize: 24,
          fontWeight: FontWeight.w400,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    moveHintTextPainter.layout();
    moveHintTextPainter.paint(
      canvas,
      Offset(
        -512 + (1024 - moveHintTextPainter.width) / 2,
        MessmathGame.kGameHeight / 2 -
            16 -
            64 +
            (64 - moveHintTextPainter.height) / 2,
      ),
    );
  }
}
