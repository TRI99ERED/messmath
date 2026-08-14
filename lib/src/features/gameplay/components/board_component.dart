import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:messmath/main.dart';
import 'package:messmath/src/core/game/engine.dart';
import 'package:messmath/src/features/themes/palette.dart';

class BoardComponent extends Component with HasGameReference<MessmathGame> {
  final Engine _engine;

  BoardComponent(Engine engine) : _engine = engine;

  @override
  void update(double dt) {
    for (var direction in game.directionQueue) {
      _engine.move(direction);
    }
    game.directionQueue.clear();
  }

  @override
  void render(Canvas canvas) {
    final board = _engine.board;
    const cellSize = 64.0;
    const spacing = 4.0;
    for (int row = 0; row < board.cells.length; row++) {
      for (int col = 0; col < board.cells[row].length; col++) {
        final cell = board.cells[row][col];
        final rect = RRect.fromRectAndCorners(
          Rect.fromLTWH(
            col * cellSize + spacing - MessmathGame.kGameWidth / 2,
            row * cellSize + spacing - MessmathGame.kGameHeight / 2,
            cellSize - 2 * spacing,
            cellSize - 2 * spacing,
          ),
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
          bottomLeft: Radius.circular(8),
          bottomRight: Radius.circular(8),
        );
        final paint = Paint()
          ..color = cell.isWall ? Palette.color25.color : Palette.color20.color;
        canvas.drawRRect(rect, paint);

        const fontSize = 32.0;
        const fineOffset = -4.0;

        final textPainter = TextPainter(
          text: TextSpan(
            text: cell.type.toDisplayString(),
            style: TextStyle(
              color: cell.type.toColor(),
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(
            col * cellSize +
                spacing -
                MessmathGame.kGameWidth / 2 +
                cellSize / 2 -
                textPainter.width / 2 +
                fineOffset,
            row * cellSize +
                spacing -
                MessmathGame.kGameHeight / 2 +
                cellSize / 2 -
                textPainter.height / 2 +
                fineOffset,
          ),
        );
      }
    }
  }
}
