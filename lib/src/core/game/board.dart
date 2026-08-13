import 'package:messmath/src/core/game/direction.dart';

enum MoveResult { moved, pushed, blocked }

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

  factory Board.fromAsciiString(String ascii) {
    ascii = ascii.trim();
    ascii = ascii.replaceAll(' ', '');

    if (ascii.isEmpty) {
      throw FormatException('ASCII board representation cannot be empty');
    }

    final lines = ascii.trim().split('\n');
    final height = lines.length;
    final width = lines.isNotEmpty ? lines[0].length : 0;

    final cells = <List<Cell>>[];

    for (int y = 0; y < height; y++) {
      final row = <Cell>[];

      var isWall = false;

      for (int x = 0; x < lines[y].length; x++) {
        final cell = lines[y][x];
        switch (cell) {
          case '.':
            row.add(Cell(x, y, type: CellType.empty));
            break;
          case '#':
            row.add(Cell(x, y, type: CellType.empty, isWall: true));
            break;
          case 'P':
            row.add(Cell(x, y, type: CellType.player));
            break;
          case '0':
            row.add(Cell(x, y, type: CellType.zero, isWall: isWall));
            break;
          case '1':
            row.add(Cell(x, y, type: CellType.one, isWall: isWall));
            break;
          case '2':
            row.add(Cell(x, y, type: CellType.two, isWall: isWall));
            break;
          case '3':
            row.add(Cell(x, y, type: CellType.three, isWall: isWall));
            break;
          case '4':
            row.add(Cell(x, y, type: CellType.four, isWall: isWall));
            break;
          case '5':
            row.add(Cell(x, y, type: CellType.five, isWall: isWall));
            break;
          case '6':
            row.add(Cell(x, y, type: CellType.six, isWall: isWall));
            break;
          case '7':
            row.add(Cell(x, y, type: CellType.seven, isWall: isWall));
            break;
          case '8':
            row.add(Cell(x, y, type: CellType.eight, isWall: isWall));
            break;
          case '9':
            row.add(Cell(x, y, type: CellType.nine, isWall: isWall));
            break;
          case '+':
            row.add(Cell(x, y, type: CellType.plus, isWall: isWall));
            break;
          case '-':
            row.add(Cell(x, y, type: CellType.minus, isWall: isWall));
            break;
          case '*':
            row.add(Cell(x, y, type: CellType.multiply, isWall: isWall));
            break;
          case '/':
            row.add(Cell(x, y, type: CellType.divide, isWall: isWall));
            break;
          case '=':
            row.add(Cell(x, y, type: CellType.equal, isWall: isWall));
            break;
          case '[':
            isWall = true;
            continue;
          case ']':
            isWall = false;
            continue;
          default:
            throw FormatException(
              'Invalid character in ASCII board representation',
            );
        }
      }
      cells.add(row);
    }

    if (cells.length != height) {
      throw FormatException('There should be exactly $height rows');
    }
    for (var row in cells) {
      if (row.length != width) {
        throw FormatException(
          'All rows must have the same length (expected $width, got ${row.length})',
        );
      }
    }

    if (cells
            .expand((row) => row)
            .where((cell) => cell.type == CellType.player)
            .length !=
        1) {
      throw FormatException('There must be exactly one player cell');
    }

    return Board(cells);
  }

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

  MoveResult movePlayerPushing(Direction direction) {
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
      return MoveResult.blocked;
    }

    final targetCell = getCell(newX, newY);
    if (targetCell.isWall) {
      return MoveResult.blocked;
    }

    var moveResult = MoveResult.moved;

    if (direction == Direction.up || direction == Direction.down) {
      int step = direction == Direction.up ? -1 : 1;
      for (int y = newY; y >= 0 && y < height; y += step) {
        final currentCell = getCell(newX, y);
        if (currentCell.isWall) return MoveResult.blocked;
        if (y == newY) {
          setCell(newX, y, CellType.player);
        } else {
          setCell(newX, y, getCell(newX, y - step).type);
          moveResult = MoveResult.pushed;
        }
      }
    } else {
      int step = direction == Direction.left ? -1 : 1;
      for (int x = newX; x >= 0 && x < width; x += step) {
        final currentCell = getCell(x, newY);
        if (currentCell.isWall) return MoveResult.blocked;
        if (x == newX) {
          setCell(x, newY, CellType.player);
        } else {
          setCell(x, newY, getCell(x - step, newY).type);
          moveResult = MoveResult.pushed;
        }
      }
    }
    return moveResult;
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
