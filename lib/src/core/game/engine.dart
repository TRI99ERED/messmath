import 'board.dart';
import 'direction.dart';
import 'win_checker.dart';

/// Pure-Dart game state machine. No Flutter/Flame dependencies.
class Engine {
  Board _board;
  final Board _initialBoard;
  int _moveCount = 0;
  bool _won = false;

  /// Called once when a move completes the level.
  void Function()? onWin;

  Board get board => _board;
  int get moveCount => _moveCount;
  bool get won => _won;

  Engine(Board board) : _board = board, _initialBoard = cloneBoard(board) {
    _won = WinChecker.isSolved(_board);
  }

  MoveResult move(Direction direction) {
    if (_won) return MoveResult.blocked;
    final result = _board.movePlayerPushing(direction);
    if (result == MoveResult.blocked) return result;

    _moveCount++;
    if (WinChecker.isSolved(_board)) {
      _won = true;
      onWin?.call();
    }
    return result;
  }

  void reset() {
    _board = cloneBoard(_initialBoard);
    _moveCount = 0;
    _won = false;
  }

  /// Cell is immutable and setCell replaces list entries, so sharing Cell
  /// instances across clones is safe — only the row lists need copying.
  static Board cloneBoard(Board board) =>
      Board(board.cells.map((row) => List<Cell>.of(row)).toList());
}
