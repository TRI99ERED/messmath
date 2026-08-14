import 'package:messmath/src/core/game/board.dart';

class Level {
  final String name;
  final Board initialBoard;

  Level({required this.name, required this.initialBoard});
}

final level1 = Level(
  name: 'First Step',
  initialBoard: Board.fromAsciiString('''
    #######
    #[1+].[=3]#
    ###2###
    ...P...
    .......
    '''),
);
