import 'board.dart';
import 'cell_type.dart';
import 'equation_parser.dart';

typedef WinCheckResult = ({bool solved, String? reason});

class WinChecker {
  static WinCheckResult check(Board board) {
    final tokens = <({int x, int y, CellType type})>[];
    for (final row in board.cells) {
      for (final cell in row) {
        if (_isToken(cell.type)) {
          tokens.add((x: cell.x, y: cell.y, type: cell.type));
        }
      }
    }

    if (tokens.isEmpty) {
      return (solved: false, reason: 'No tokens on the board');
    }

    final rows = tokens.map((t) => t.y).toSet();
    if (rows.length != 1) {
      return (solved: false, reason: 'Tokens are not in a single row');
    }

    tokens.sort((a, b) => a.x.compareTo(b.x));
    for (int i = 1; i < tokens.length; i++) {
      if (tokens[i].x != tokens[i - 1].x + 1) {
        return (solved: false, reason: 'Tokens are not contiguous');
      }
    }

    final result = EquationParser.evaluate(tokens.map((t) => t.type).toList());
    if (!result.valid) {
      return (solved: false, reason: result.reason);
    }
    if (!result.correct) {
      return (solved: false, reason: '${result.lhs} != ${result.rhs}');
    }
    return (solved: true, reason: null);
  }

  static bool isSolved(Board board) => check(board).solved;

  static bool _isToken(CellType type) =>
      type != CellType.empty && type != CellType.player;
}
