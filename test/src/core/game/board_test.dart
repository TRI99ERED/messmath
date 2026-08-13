import 'package:flutter_test/flutter_test.dart';
import 'package:messmath/src/core/game/board.dart';
import 'package:messmath/src/core/game/cell_type.dart';
import 'package:messmath/src/core/game/direction.dart';

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

  group('Board movement tests', () {
    test('walk into an empty cell moves the player', () {
      final board = Board.fromAsciiString('...\n.P.\n...');
      expect(board.movePlayerPushing(Direction.right), MoveResult.moved);
      expect(board.toAsciiString(), '...\n..P\n...');
    });

    test('push a single token into a gap', () {
      final board = Board.fromAsciiString('.5P');
      expect(board.movePlayerPushing(Direction.left), MoveResult.pushed);
      expect(board.toAsciiString(), '5P.');
    });

    test('push a chain of tokens into a gap', () {
      final board = Board.fromAsciiString('.12P');
      expect(board.movePlayerPushing(Direction.left), MoveResult.pushed);
      expect(board.toAsciiString(), '12P.');
    });

    test('push right shifts the chain', () {
      final board = Board.fromAsciiString('P15.');
      expect(board.movePlayerPushing(Direction.right), MoveResult.pushed);
      expect(board.toAsciiString(), '.P15');
    });

    test('push down shifts the chain', () {
      final board = Board.fromAsciiString('.\nP\n5\n.');
      expect(board.movePlayerPushing(Direction.down), MoveResult.pushed);
      expect(board.toAsciiString(), '.\n.\nP\n5');
    });

    test('push up shifts the chain', () {
      final board = Board.fromAsciiString('.\n1\n2\nP');
      expect(board.movePlayerPushing(Direction.up), MoveResult.pushed);
      expect(board.toAsciiString(), '1\n2\nP\n.');
    });

    test('push into a static token-wall is blocked', () {
      final board = Board.fromAsciiString('[5]P');
      expect(board.movePlayerPushing(Direction.left), MoveResult.blocked);
      expect(board.toAsciiString(), '[5]P');
    });

    test('walk into a static token-wall is blocked', () {
      final board = Board.fromAsciiString('P[5]');
      expect(board.movePlayerPushing(Direction.right), MoveResult.blocked);
      expect(board.toAsciiString(), 'P[5]');
    });

    test('push a chain against a plain wall is blocked', () {
      final board = Board.fromAsciiString('#12P');
      expect(board.movePlayerPushing(Direction.left), MoveResult.blocked);
      expect(board.toAsciiString(), '#12P');
    });

    test('push off the board edge is blocked', () {
      final board = Board.fromAsciiString('P.');
      expect(board.movePlayerPushing(Direction.left), MoveResult.blocked);
      expect(board.toAsciiString(), 'P.');
    });
  });
}
