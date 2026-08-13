class Board {
  final int width;
  final int height;
  final List<List<Cell>> cells;

  Board(this.width, this.height)
    : cells = List.generate(
        height,
        (y) => List.generate(width, (x) => Cell(x, y)),
      );

  Board.fromCells(this.cells)
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
