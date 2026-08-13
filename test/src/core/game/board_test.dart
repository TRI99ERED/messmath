import 'package:flutter_test/flutter_test.dart';
import 'package:messmath/src/core/game/board.dart';
import 'package:messmath/src/core/game/cell_type.dart';

void main() {
  group('Board from ASCII tests', () {
    test('Valid board', () {
      final ascii = '''
        123
        456
        78P
      ''';
      final board = Board.fromAsciiString(ascii);
      expect(board.width, equals(3));
      expect(board.height, equals(3));
    });

    test('Board with spaces', () {
      final ascii = '''
        1 2 3
        4 5 6
        7 8 P
      ''';
      final board = Board.fromAsciiString(ascii);
      expect(board.width, equals(3));
      expect(board.height, equals(3));
    });

    test('Board with walls', () {
      final ascii = '''
        1#2
        4#6
        7#P
      ''';
      final board = Board.fromAsciiString(ascii);
      expect(board.width, equals(3));
      expect(board.height, equals(3));
    });

    test('Board with no player', () {
      final ascii = '''
        123
        456
        789
      ''';
      expect(
        () => Board.fromAsciiString(ascii),
        throwsA(isA<FormatException>()),
      );
    });

    test('Board with multiple players', () {
      final ascii = '''
        1P2
        4P6
        7P9
      ''';
      expect(
        () => Board.fromAsciiString(ascii),
        throwsA(isA<FormatException>()),
      );
    });

    test('Board with invalid characters', () {
      final ascii = '''
        1A2
        4B6
        7C9
      ''';
      expect(
        () => Board.fromAsciiString(ascii),
        throwsA(isA<FormatException>()),
      );
    });

    test('Board with inconsistent row lengths', () {
      final ascii = '''
        123
        45
        789
      ''';
      expect(
        () => Board.fromAsciiString(ascii),
        throwsA(isA<FormatException>()),
      );
    });

    test('Empty board', () {
      final ascii = '';
      expect(
        () => Board.fromAsciiString(ascii),
        throwsA(isA<FormatException>()),
      );
    });

    test('Full board', () {
      final ascii = '''
        ###########
        #.1.+.[2]...#
        #[5]P.......#
        ###########
      ''';
      final board = Board.fromAsciiString(ascii);
      expect(board.width, equals(11));
      expect(board.height, equals(4));
      expect(board.cells[0][0].isWall, equals(true));
      expect(board.cells[1][1].type, equals(CellType.empty));
      expect(board.cells[1][1].isWall, equals(false));
      expect(board.cells[2][1].type, equals(CellType.five));
      expect(board.cells[2][1].isWall, equals(true));
      expect(board.cells[1][2].type, equals(CellType.one));
      expect(board.cells[1][2].isWall, equals(false));
    });
  });

  group('Board to Ascii tests', () {
    test('Convert board to ASCII string', () {
      final ascii = '''
###########
#.1.+.[2]...#
#[5]P.......#
###########
      ''';
      final board = Board.fromAsciiString(ascii);
      final convertedAscii = board.toAsciiString();
      expect(convertedAscii, equals(ascii.trim()));
    });
  });
}
