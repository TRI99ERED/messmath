import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:messmath/main.dart';
import 'package:messmath/src/core/audio/sound_effects.dart';
import 'package:messmath/src/core/game/board.dart';
import 'package:messmath/src/core/game/cell_type.dart';
import 'package:messmath/src/core/game/direction.dart';
import 'package:messmath/src/core/game/engine.dart';
import 'package:messmath/src/features/themes/game_fonts.dart';
import 'package:messmath/src/features/themes/palette.dart';

class BoardComponent extends Component with HasGameReference<MessmathGame> {
  final Engine _engine;

  static const double cellSize = 64.0;
  static const double spacing = 1.0;
  static const double moveDuration = 0.12;
  static const double wiggleDuration = 0.12;
  static const double wiggleAmplitude = 0.12;
  static const double fontSize = 32.0;
  static const double fineOffset = -2.0;

  final List<_TileAnimation> _animations = [];

  BoardComponent(Engine engine) : _engine = engine;

  int get moveCount => _engine.moveCount;
  bool get isWon => _engine.won;
  VoidCallback? get onWin => _engine.onWin;
  set onWin(VoidCallback? callback) {
    _engine.onWin = callback;
  }

  @override
  void update(double dt) {
    if (_animations.isEmpty && game.directionQueue.isNotEmpty) {
      final direction = game.directionQueue.removeAt(0);
      _applyMove(direction);
    }
    _animations.removeWhere((animation) {
      animation.elapsed += dt;
      final duration = animation.wiggle
          ? moveDuration + wiggleDuration
          : moveDuration;
      return animation.elapsed >= duration;
    });
  }

  void _applyMove(Direction direction) {
    final before = Engine.cloneBoard(_engine.board);
    final result = _engine.move(direction);
    if (result == MoveResult.blocked) return;
    final animations = _diff(before, _engine.board);
    if (result == MoveResult.pushed) {
      for (final animation in animations) {
        animation.wiggle = true;
      }
    }
    _animations.addAll(animations);
    if (result == MoveResult.moved) {
      SoundEffects.instance.playMove();
    } else {
      SoundEffects.instance.playPush();
    }
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
    final originX = -board.width * cellSize / 2;
    final originY = -board.height * cellSize / 2;
    for (final row in board.cells) {
      for (final cell in row) {
        _drawCellBackground(canvas, cell, originX, originY);
        if (cell.type == CellType.empty) continue;
        if (_isAnimationTarget(cell)) continue;
        _drawContent(
          canvas,
          cell.type,
          cell.x.toDouble(),
          cell.y.toDouble(),
          originX,
          originY,
        );
      }
    }
    for (final animation in _animations) {
      final position = animation.position;
      _drawContent(
        canvas,
        animation.type,
        position.x,
        position.y,
        originX,
        originY,
      );
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

  void _drawCellBackground(
    Canvas canvas,
    Cell cell,
    double originX,
    double originY,
  ) {
    final rect = Rect.fromLTWH(
      cell.x * cellSize + spacing + originX,
      cell.y * cellSize + spacing + originY,
      cellSize - 2 * spacing,
      cellSize - 2 * spacing,
    );
    final paint = Paint()
      ..color = cell.isWall ? Palette.color25.color : Palette.color20.color;
    canvas.drawRect(rect, paint);
  }

  void _drawContent(
    Canvas canvas,
    CellType type,
    double col,
    double row,
    double originX,
    double originY,
  ) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: type.toDisplayString(),
        style: GameFonts.style(
          color: type.toColor(),
          fontSize: fontSize,
          fontWeight: FontWeight.w900,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        col * cellSize +
            spacing +
            originX +
            cellSize / 2 -
            textPainter.width / 2 +
            fineOffset,
        row * cellSize +
            spacing +
            originY +
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
  bool wiggle = false;

  _TileAnimation(this.type, this.from, this.to);

  Vector2 get position {
    final travel = (elapsed / BoardComponent.moveDuration).clamp(0.0, 1.0);
    final eased = 1 - (1 - travel) * (1 - travel); // ease-out quadratic
    final moved = from + (to - from) * eased;
    if (!wiggle) return moved;
    final settle = elapsed - BoardComponent.moveDuration;
    if (settle <= 0) return moved;
    final s = (settle / BoardComponent.wiggleDuration).clamp(0.0, 1.0);
    final direction = (to - from).normalized();
    final recoil =
        math.sin(s * math.pi * 2) * (1 - s) * BoardComponent.wiggleAmplitude;
    return to + direction * recoil;
  }
}
