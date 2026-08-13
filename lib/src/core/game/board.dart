import 'package:messmath/src/core/game/direction.dart';

class Board {
  final int width;
  final int height;
  final List<List<Cell>> cells;

  Cell get playerCell => cells
      .expand((row) => row)
      .firstWhere(
        (cell) => cell.type == CellType.player,
        orElse: () => throw StateError('No player cell found in the board'),
      );

  Board(this.cells)
    : width = cells.isNotEmpty ? cells[0].length : 0,
      height = cells.length;

  Cell getCell(int x, int y) {
    if (x < 0 || x >= width || y < 0 || y >= height) {
      throw RangeError('Cell coordinates out of bounds: ($x, $y)');
    }
    return cells[y][x];
  }

  void setCell(int x, int y, CellType type, {bool isWall = false}) {
    if (x < 0 || x >= width || y < 0 || y >= height) {
      throw RangeError('Cell coordinates out of bounds: ($x, $y)');
    }
    cells[y][x] = Cell(x, y, type: type, isWall: isWall);
  }

  void movePlayerPushing(Direction direction) {
    final player = playerCell;
    int newX = player.x;
    int newY = player.y;

    switch (direction) {
      case Direction.up:
        newY--;
        break;
      case Direction.down:
        newY++;
        break;
      case Direction.left:
        newX--;
        break;
      case Direction.right:
        newX++;
        break;
    }

    if (newX < 0 || newX >= width || newY < 0 || newY >= height) {
      throw RangeError('Move out of bounds: ($newX, $newY)');
    }

    final targetCell = getCell(newX, newY);
    if (targetCell.isWall) {
      throw StateError('Cannot move to a wall cell: ($newX, $newY)');
    }

    if (direction == Direction.up || direction == Direction.down) {
      int step = direction == Direction.up ? -1 : 1;
      for (int y = newY; y >= 0 && y < height; y += step) {
        final currentCell = getCell(newX, y);
        if (currentCell.isWall) break;
        if (y == newY) {
          setCell(newX, y, CellType.player);
        } else {
          setCell(newX, y, getCell(newX, y - step).type);
        }
      }
    } else {
      int step = direction == Direction.left ? -1 : 1;
      for (int x = newX; x >= 0 && x < width; x += step) {
        final currentCell = getCell(x, newY);
        if (currentCell.isWall) break;
        if (x == newX) {
          setCell(x, newY, CellType.player);
        } else {
          setCell(x, newY, getCell(x - step, newY).type);
        }
      }
    }
  }
}

enum CellType {
  empty,
  player,
  zero,
  one,
  two,
  three,
  four,
  five,
  six,
  seven,
  eight,
  nine,
  plus,
  minus,
  multiply,
  divide,
  equal,
}

class Cell {
  final int x;
  final int y;
  final CellType type;
  final bool isWall;

  const Cell(this.x, this.y, {this.type = CellType.empty, this.isWall = false})
    : assert(x >= 0 && y >= 0, 'Cell coordinates must be non-negative'),
      assert(
        type != CellType.player || !isWall,
        'Player cells cannot be walls',
      );

  bool get isEmpty => type == CellType.empty && !isWall;
  bool get isOccupied => type != CellType.empty || isWall;
}
