import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:messmath/main.dart';
import 'package:messmath/src/core/game/board.dart';
import 'package:messmath/src/core/game/cell_type.dart';
import 'package:messmath/src/core/game/direction.dart';
import 'package:messmath/src/core/levels/level_loader.dart';
import 'package:messmath/src/features/themes/game_fonts.dart';
import 'package:messmath/src/features/themes/palette.dart';

class LevelSelectScene extends Component {
  static const int _columns = 5;
  static const int _rows = 3;
  static const double _slotWidth = 230.0;
  static const double _slotHeight = 180.0;
  static const double _gap = 24.0;
  static const double _selectorPadding = 12.0;
  static const double _selectorRadius = 16.0;
  static const double _previewPadding = 10.0;
  static const double _labelSpace = 28.0;
  static const double _gridCenterY = -50.0;

  static const double _boardCellSize = 64.0;
  static const double _boardSpacing = 1.0;
  static const double _boardFontSize = 32.0;
  static const double _boardFineOffset = -2.0;

  int _selectedIndex = 0;
  final Set<int> _unlockedLevels = {};
  Vector2 _selectorCenter = Vector2.zero();
  Vector2 _selectorTarget = Vector2.zero();
  bool _selectorInitialized = false;

  double get _gridWidth => _columns * _slotWidth + (_columns - 1) * _gap;
  double get _gridHeight => _rows * _slotHeight + (_rows - 1) * _gap;

  Vector2 _slotCenter(int index) {
    final col = index % _columns;
    final row = index ~/ _columns;
    final x = -_gridWidth / 2 + _slotWidth / 2 + col * (_slotWidth + _gap);
    final y =
        _gridCenterY -
        _gridHeight / 2 +
        _slotHeight / 2 +
        row * (_slotHeight + _gap);
    return Vector2(x, y);
  }

  @override
  Future<void> onLoad() async {
    final progress = (parent as MessmathWorld).levelProgress;
    await progress.load();
    _unlockedLevels.clear();
    for (var i = 1; i <= LevelLoader.levels.length; i++) {
      if (i == 1 || progress.isCompleted(i - 1)) {
        _unlockedLevels.add(i);
      }
    }
  }

  void _ensureSelectorInitialized() {
    if (!_selectorInitialized) {
      _selectorCenter = _slotCenter(_selectedIndex);
      _selectorTarget = _selectorCenter.clone();
      _selectorInitialized = true;
    }
  }

  @override
  void update(double dt) {
    _ensureSelectorInitialized();
    final t = 1 - math.pow(0.000001, dt).toDouble();
    _selectorCenter = _selectorCenter + (_selectorTarget - _selectorCenter) * t;
  }

  void navigate(Direction direction) {
    final total = LevelLoader.levels.length;
    if (total == 0) return;
    var index = _selectedIndex;
    for (var i = 0; i < total; i++) {
      index = _neighborIndex(index, direction, total);
      if (_unlockedLevels.contains(index + 1)) {
        _selectedIndex = index;
        _selectorTarget = _slotCenter(index);
        return;
      }
    }
  }

  int _neighborIndex(int index, Direction direction, int total) {
    final col = index % _columns;
    final row = index ~/ _columns;
    var newRow = row;
    var newCol = col;
    switch (direction) {
      case Direction.up:
        newRow = (row - 1 + _rows) % _rows;
        break;
      case Direction.down:
        newRow = (row + 1) % _rows;
        break;
      case Direction.left:
        newCol = (col - 1 + _columns) % _columns;
        break;
      case Direction.right:
        newCol = (col + 1) % _columns;
        break;
    }
    var newIndex = newRow * _columns + newCol;
    if (newIndex >= total) {
      newIndex = 0;
    }
    return newIndex;
  }

  void selectLevel() {
    if (!_unlockedLevels.contains(_selectedIndex + 1)) return;
    (parent as MessmathWorld).loadLevel(_selectedIndex + 1);
  }

  @override
  void render(Canvas canvas) {
    _ensureSelectorInitialized();

    final overlayRect = Rect.fromLTWH(
      -MessmathGame.kGameWidth / 2,
      -MessmathGame.kGameHeight / 2,
      MessmathGame.kGameWidth,
      MessmathGame.kGameHeight,
    );
    canvas.drawRect(overlayRect, Palette.color27.paint());

    final selectorRect = Rect.fromCenter(
      center: Offset(_selectorCenter.x, _selectorCenter.y),
      width: _slotWidth + _selectorPadding * 2,
      height: _slotHeight + _selectorPadding * 2,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        selectorRect,
        const Radius.circular(_selectorRadius),
      ),
      Palette.color22.paint(),
    );

    final progress = (parent as MessmathWorld).levelProgress;
    for (var i = 0; i < LevelLoader.levels.length; i++) {
      final levelNumber = i + 1;
      final slotCenter = _slotCenter(i);
      _drawPreview(
        canvas,
        LevelLoader.levels[i].initialBoard,
        slotCenter,
        isUnlocked: _unlockedLevels.contains(levelNumber),
      );
      final bestMoves = progress.bestMoves(levelNumber);
      if (bestMoves != null) {
        _drawBestMoves(canvas, bestMoves, slotCenter);
      }
    }

    _drawHint(canvas);
  }

  void _drawPreview(
    Canvas canvas,
    Board board,
    Vector2 slotCenter, {
    required bool isUnlocked,
  }) {
    final boardWidth = board.width * _boardCellSize;
    final boardHeight = board.height * _boardCellSize;
    final maxWidth = _slotWidth - _previewPadding * 2;
    final maxHeight = _slotHeight - _previewPadding * 2 - _labelSpace;
    final scale = math.min(maxWidth / boardWidth, maxHeight / boardHeight);

    canvas.save();
    canvas.translate(slotCenter.x, slotCenter.y - _labelSpace / 2);
    canvas.scale(scale, scale);
    canvas.translate(-boardWidth / 2, -boardHeight / 2);

    for (final row in board.cells) {
      for (final cell in row) {
        final rect = Rect.fromLTWH(
          cell.x * _boardCellSize + _boardSpacing,
          cell.y * _boardCellSize + _boardSpacing,
          _boardCellSize - 2 * _boardSpacing,
          _boardCellSize - 2 * _boardSpacing,
        );
        final paint = Paint()
          ..color = cell.isWall
              ? Palette.color25.color
              : (isUnlocked ? Palette.color20.color : Palette.color24.color);
        canvas.drawRect(rect, paint);
      }
    }

    for (final row in board.cells) {
      for (final cell in row) {
        if (cell.type == CellType.empty) continue;
        final textPainter = TextPainter(
          text: TextSpan(
            text: cell.type.toDisplayString(),
            style: GameFonts.style(
              color: cell.type.toColor(),
              fontSize: _boardFontSize,
              fontWeight: FontWeight.w900,
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(
            cell.x * _boardCellSize +
                _boardSpacing +
                _boardCellSize / 2 -
                textPainter.width / 2 +
                _boardFineOffset,
            cell.y * _boardCellSize +
                _boardSpacing +
                _boardCellSize / 2 -
                textPainter.height / 2 +
                _boardFineOffset,
          ),
        );
      }
    }

    canvas.restore();
  }

  void _drawBestMoves(Canvas canvas, int bestMoves, Vector2 slotCenter) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'Best: $bestMoves',
        style: GameFonts.style(
          color: Palette.color12.color,
          fontSize: 20,
          fontWeight: FontWeight.w400,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        slotCenter.x - textPainter.width / 2,
        slotCenter.y +
            _slotHeight / 2 -
            _labelSpace +
            (_labelSpace - textPainter.height) / 2,
      ),
    );
  }

  void _drawHint(Canvas canvas) {
    final hintRRect = RRect.fromRectAndCorners(
      Rect.fromLTWH(-512, MessmathGame.kGameHeight / 2 - 16 - 64, 1024, 64),
      topLeft: const Radius.circular(8),
      topRight: const Radius.circular(8),
      bottomLeft: const Radius.circular(8),
      bottomRight: const Radius.circular(8),
    );
    canvas.drawRRect(hintRRect, Palette.color20.paint());

    final hintTextPainter = TextPainter(
      text: TextSpan(
        text: '←↑↓→ or WASD to navigate. [Enter] to select level.',
        style: GameFonts.style(
          color: Palette.color27.color,
          fontSize: 24,
          fontWeight: FontWeight.w400,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    hintTextPainter.layout();
    hintTextPainter.paint(
      canvas,
      Offset(
        -512 + (1024 - hintTextPainter.width) / 2,
        MessmathGame.kGameHeight / 2 -
            16 -
            64 +
            (64 - hintTextPainter.height) / 2,
      ),
    );
  }
}
