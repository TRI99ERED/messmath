import 'package:flutter_test/flutter_test.dart';
import 'package:messmath/src/core/game/board.dart';
import 'package:messmath/src/core/game/win_checker.dart';

void main() {
  group('WinChecker solved', () {
    test('a single row that evaluates correctly wins', () {
      final board = Board.fromAsciiString('1+2=3.\n.P....');
      expect(WinChecker.isSolved(board), isTrue);
    });

    test('static token-walls participate in the equation', () {
      final board = Board.fromAsciiString('1+[5]=6\n.P...');
      expect(WinChecker.isSolved(board), isTrue);
    });

    test('an all-static equation can be solved', () {
      final board = Board.fromAsciiString('[5]+[3]=[8]\n.P...');
      expect(WinChecker.isSolved(board), isTrue);
    });
  });

  group('WinChecker not solved', () {
    test('token outside the single row', () {
      final board = Board.fromAsciiString('1+2=3.\n.5P...');
      final result = WinChecker.check(board);
      expect(result.solved, isFalse);
      expect(result.reason, 'Tokens are not in a single row');
    });

    test('gap inside the row', () {
      final board = Board.fromAsciiString('1+2.=3\n.P....');
      expect(WinChecker.isSolved(board), isFalse);
    });

    test('plain wall inside the row', () {
      final board = Board.fromAsciiString('1#+2=3\n.P....');
      expect(WinChecker.isSolved(board), isFalse);
    });

    test('contiguous but wrong math', () {
      final board = Board.fromAsciiString('1+2=4.\n.P....');
      final result = WinChecker.check(board);
      expect(result.solved, isFalse);
      expect(result.reason, '3 != 4');
    });

    test('missing equal sign', () {
      final board = Board.fromAsciiString('1+2....\n.P.....');
      expect(WinChecker.isSolved(board), isFalse);
    });

    test('no tokens at all', () {
      final board = Board.fromAsciiString('#####\n#.P.#\n#####');
      final result = WinChecker.check(board);
      expect(result.solved, isFalse);
      expect(result.reason, 'No tokens on the board');
    });
  });
}
