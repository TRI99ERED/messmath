import 'package:flutter_test/flutter_test.dart';
import 'package:messmath/src/core/game/board.dart';
import 'package:messmath/src/core/game/direction.dart';
import 'package:messmath/src/core/game/engine.dart';

const _solvable = '1+.=3\n..2..\n..P..';

void main() {
  group('Engine solving a level', () {
    test('pushing the token into place wins the level', () {
      final engine = Engine(Board.fromAsciiString(_solvable));
      expect(engine.won, isFalse);
      expect(engine.move(Direction.up), MoveResult.pushed);
      expect(engine.won, isTrue);
      expect(engine.board.toAsciiString(), '1+2=3\n..P..\n.....');
    });

    test('onWin fires exactly once per solve', () {
      var fired = 0;
      final engine = Engine(Board.fromAsciiString(_solvable));
      engine.onWin = () => fired++;

      engine.move(Direction.up);
      expect(fired, 1);

      engine.move(Direction.left);
      expect(fired, 1);

      engine.reset();
      engine.move(Direction.up);
      expect(fired, 2);
    });

    test('moves are blocked after winning', () {
      final engine = Engine(Board.fromAsciiString(_solvable));
      engine.move(Direction.up);
      final board = engine.board.toAsciiString();
      final count = engine.moveCount;

      expect(engine.move(Direction.up), MoveResult.blocked);
      expect(engine.board.toAsciiString(), board);
      expect(engine.moveCount, count);
    });
  });

  group('Engine move counting', () {
    test('only effective moves count', () {
      final engine = Engine(Board.fromAsciiString('..P.'));

      expect(engine.move(Direction.right), MoveResult.moved);
      expect(engine.moveCount, 1);
      expect(engine.board.toAsciiString(), '...P');

      expect(engine.move(Direction.right), MoveResult.blocked);
      expect(engine.moveCount, 1);
    });

    test('blocked move leaves the board unchanged', () {
      final engine = Engine(Board.fromAsciiString('.#P'));

      expect(engine.move(Direction.left), MoveResult.blocked);
      expect(engine.moveCount, 0);
      expect(engine.board.toAsciiString(), '.#P');
    });
  });

  group('Engine reset', () {
    test('reset restores the initial layout and clears state', () {
      final engine = Engine(Board.fromAsciiString(_solvable));
      engine.move(Direction.up);
      expect(engine.won, isTrue);

      engine.reset();
      expect(engine.won, isFalse);
      expect(engine.moveCount, 0);
      expect(engine.board.toAsciiString(), _solvable);
    });
  });

  group('Engine construction', () {
    test('an already solved board is won immediately', () {
      final engine = Engine(Board.fromAsciiString('1+2=3\n..P..'));
      expect(engine.won, isTrue);
      expect(engine.moveCount, 0);
    });
  });
}
