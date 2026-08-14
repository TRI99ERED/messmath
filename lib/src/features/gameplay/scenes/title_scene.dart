import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:messmath/main.dart';
import 'package:messmath/src/core/game/cell_type.dart';
import 'package:messmath/src/features/themes/palette.dart';

class TitleScene extends Component {
  static const double _fontSize = 128;
  static const double _maxRotation = 0.06;
  static const double _rotationSpeed = 1.1;
  static const double _scaleAmplitude = 0.02;
  static const double _scaleSpeed = 1.5;

  double _elapsed = 0;

  @override
  void update(double dt) {
    _elapsed += dt;
  }

  @override
  void render(Canvas canvas) {
    final overlayRect = Rect.fromLTWH(
      -MessmathGame.kGameWidth / 2,
      -MessmathGame.kGameHeight / 2,
      MessmathGame.kGameWidth,
      MessmathGame.kGameHeight,
    );
    final overlayPaint = Palette.color27.paint();
    canvas.drawRect(overlayRect, overlayPaint);

    final textPainter = TextPainter(
      text: TextSpan(
        text: 'M',
        style: TextStyle(
          color: Palette.color20.color,
          fontSize: _fontSize,
          fontWeight: FontWeight.w900,
        ),
        children: [
          TextSpan(
            text: '3',
            style: TextStyle(color: CellType.three.toColor()),
          ),
          TextSpan(text: 'SSM'),
          TextSpan(
            text: '4',
            style: TextStyle(color: CellType.four.toColor()),
          ),
          TextSpan(text: 'TH'),
        ],
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    final angle = math.sin(_elapsed * _rotationSpeed) * _maxRotation;
    final scale = 1.0 + math.sin(_elapsed * _scaleSpeed) * _scaleAmplitude;

    final creditPainter = TextPainter(
      text: TextSpan(
        text: 'by TRI99ER',
        style: TextStyle(
          color: Palette.color20.color,
          fontSize: 32,
          fontWeight: FontWeight.w900,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    creditPainter.layout();

    canvas.save();
    canvas.rotate(angle);
    canvas.scale(scale, scale);
    textPainter.paint(
      canvas,
      Offset(-textPainter.width / 2, -textPainter.height / 2),
    );
    creditPainter.paint(
      canvas,
      Offset(-creditPainter.width / 2, textPainter.height / 2 + 16),
    );
    canvas.restore();

    final hintPainter = TextPainter(
      text: TextSpan(
        text: 'Press [Enter] to select level',
        style: TextStyle(
          color: Palette.color20.color,
          fontSize: 24,
          fontWeight: FontWeight.w400,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    hintPainter.layout();
    hintPainter.paint(
      canvas,
      Offset(-hintPainter.width / 2, MessmathGame.kGameHeight / 2 - 64),
    );
  }
}
