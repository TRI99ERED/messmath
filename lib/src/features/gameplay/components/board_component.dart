import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:messmath/main.dart';
import 'package:messmath/src/core/game/board.dart';
import 'package:messmath/src/core/game/cell_type.dart';
import 'package:messmath/src/core/game/direction.dart';
import 'package:messmath/src/core/game/engine.dart';
import 'package:messmath/src/features/themes/palette.dart';

class BoardComponent extends Component with HasGameReference<MessmathGame> {
  final Engine _engine;

  static const double cellSize = 64.0;
  static const double spacing = 4.0;
  static const double moveDuration = 0.12;
  static const double fontSize = 32.0;
  static const double fineOffset = -4.0;

  final List<_TileAnimation> _animations = [];

  BoardComponent(Engine engine) : _engine = engine;

  @override
  void update(double dt) {
    if (_animations.isEmpty && game.directionQueue.isNotEmpty) {
      final direction = game.directionQueue.removeAt(0);
      _applyMove(direction);
    }
    _animations.removeWhere((animation) {
      animation.elapsed += dt;
      return animation.elapsed >= moveDuration;
    });
  }

  void _applyMove(Direction direction) {
    final before = Engine.cloneBoard(_engine.board);
    final result = _engine.move(direction);
    if (result == MoveResult.blocked) return;
    _animations.addAll(_diff(before, _engine.board));
  }

  List<_TileAnimation> _diff(Board before, Board after) {
    final moves = <_TileAnimation>[];
    for (final type in CellType.values) {
      if (type == CellType.empty) continue;
      final from = _positionsOf(before, type);
      final to = _positionsOf(after, type);
      final count = math.min(from.length, to.length);
      for (var i = 0; i < count; i++) {
        final a = from[i];
        final b = to[i];
        if (a != b) {
          moves.add(
            _TileAnimation(
              type,
              Vector2(a.$1.toDouble(), a.$2.toDouble()),
              Vector2(b.$1.toDouble(), b.$2.toDouble()),
            ),
          );
        }
      }
    }
    return moves;
  }

  List<(int, int)> _positionsOf(Board board, CellType type) {
    final positions = <(int, int)>[];
    for (final row in board.cells) {
      for (final cell in row) {
        if (cell.type == type && !cell.isWall) {
          positions.add((cell.x, cell.y));
        }
      }
    }
    return positions;
  }

  @override
  void render(Canvas canvas) {
    final board = _engine.board;
    for (final row in board.cells) {
      for (final cell in row) {
        _drawCellBackground(canvas, cell);
        if (cell.type == CellType.empty) continue;
        if (_isAnimationTarget(cell)) continue;
        _drawContent(canvas, cell.type, cell.x.toDouble(), cell.y.toDouble());
      }
    }
    for (final animation in _animations) {
      final position = animation.position;
      _drawContent(canvas, animation.type, position.x, position.y);
    }
  }

  bool _isAnimationTarget(Cell cell) {
    for (final animation in _animations) {
      if (animation.to.x.round() == cell.x &&
          animation.to.y.round() == cell.y) {
        return true;
      }
    }
    return false;
  }

  void _drawCellBackground(Canvas canvas, Cell cell) {
    final rect = RRect.fromRectAndCorners(
      Rect.fromLTWH(
        cell.x * cellSize + spacing - MessmathGame.kGameWidth / 2,
        cell.y * cellSize + spacing - MessmathGame.kGameHeight / 2,
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
  }

  void _drawContent(Canvas canvas, CellType type, double col, double row) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: type.toDisplayString(),
        style: TextStyle(
          color: type.toColor(),
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

  void reset() {
    _animations.clear();
    _engine.reset();
  }
}

class _TileAnimation {
  final CellType type;
  final Vector2 from;
  final Vector2 to;
  double elapsed = 0;

  _TileAnimation(this.type, this.from, this.to);

  Vector2 get position {
    final t = (elapsed / BoardComponent.moveDuration).clamp(0.0, 1.0);
    final eased = 1 - (1 - t) * (1 - t); // ease-out quadratic
    return from + (to - from) * eased;
  }
}
