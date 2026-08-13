import 'cell_type.dart';
import 'direction.dart';

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
    int step;
    bool vertical;

    switch (direction) {
      case Direction.up:
        newY--;
        step = -1;
        vertical = true;
        break;
      case Direction.down:
        newY++;
        step = 1;
        vertical = true;
        break;
      case Direction.left:
        newX--;
        step = -1;
        vertical = false;
        break;
      case Direction.right:
        newX++;
        step = 1;
        vertical = false;
        break;
    }

    if (newX < 0 || newX >= width || newY < 0 || newY >= height) {
      return MoveResult.blocked;
    }
    if (getCell(newX, newY).isWall) {
      return MoveResult.blocked;
    }

    int gap = -1;
    for (int i = 0; i < width + height; i++) {
      final x = vertical ? newX : newX + i * step;
      final y = vertical ? newY + i * step : newY;
      if (x < 0 || x >= width || y < 0 || y >= height) break;
      final c = getCell(x, y);
      if (c.isWall) break;
      if (c.isEmpty) {
        gap = i;
        break;
      }
    }
    if (gap == -1) return MoveResult.blocked;

    for (int i = gap; i > 0; i--) {
      final toX = vertical ? newX : newX + i * step;
      final toY = vertical ? newY + i * step : newY;
      final fromX = vertical ? newX : newX + (i - 1) * step;
      final fromY = vertical ? newY + (i - 1) * step : newY;
      setCell(toX, toY, getCell(fromX, fromY).type);
    }

    setCell(newX, newY, CellType.player);
    setCell(player.x, player.y, CellType.empty);

    return gap == 0 ? MoveResult.moved : MoveResult.pushed;
  }

  String toAsciiString() {
    final buffer = StringBuffer();
    for (var row in cells) {
      for (var cell in row) {
        if (cell.isWall && cell.type == CellType.empty) {
          buffer.write('#');
        } else {
          switch (cell.type) {
            case CellType.empty:
              buffer.write('.');
              break;
            case CellType.player:
              buffer.write('P');
              break;
            case CellType.zero:
              if (cell.isWall) {
                buffer.write('[0]');
              } else {
                buffer.write('0');
              }
              break;
            case CellType.one:
              if (cell.isWall) {
                buffer.write('[1]');
              } else {
                buffer.write('1');
              }
              break;
            case CellType.two:
              if (cell.isWall) {
                buffer.write('[2]');
              } else {
                buffer.write('2');
              }
              break;
            case CellType.three:
              if (cell.isWall) {
                buffer.write('[3]');
              } else {
                buffer.write('3');
              }
              break;
            case CellType.four:
              if (cell.isWall) {
                buffer.write('[4]');
              } else {
                buffer.write('4');
              }
              break;
            case CellType.five:
              if (cell.isWall) {
                buffer.write('[5]');
              } else {
                buffer.write('5');
              }
              break;
            case CellType.six:
              if (cell.isWall) {
                buffer.write('[6]');
              } else {
                buffer.write('6');
              }
              break;
            case CellType.seven:
              if (cell.isWall) {
                buffer.write('[7]');
              } else {
                buffer.write('7');
              }
              break;
            case CellType.eight:
              if (cell.isWall) {
                buffer.write('[8]');
              } else {
                buffer.write('8');
              }
              break;
            case CellType.nine:
              if (cell.isWall) {
                buffer.write('[9]');
              } else {
                buffer.write('9');
              }
              break;
            case CellType.plus:
              if (cell.isWall) {
                buffer.write('[+]');
              } else {
                buffer.write('+');
              }
              break;
            case CellType.minus:
              if (cell.isWall) {
                buffer.write('[-]');
              } else {
                buffer.write('-');
              }
              break;
            case CellType.multiply:
              if (cell.isWall) {
                buffer.write('[*]');
              } else {
                buffer.write('*');
              }
              break;
            case CellType.divide:
              if (cell.isWall) {
                buffer.write('[/]');
              } else {
                buffer.write('/');
              }
              break;
            case CellType.equal:
              if (cell.isWall) {
                buffer.write('[=]');
              } else {
                buffer.write('=');
              }
              break;
          }
        }
      }
      buffer.writeln();
    }
    return buffer.toString().trim();
  }
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
