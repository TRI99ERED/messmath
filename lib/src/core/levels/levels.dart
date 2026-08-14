import 'package:messmath/src/core/game/board.dart';

class Level {
  final String name;
  final Board initialBoard;

  Level({required this.name, required this.initialBoard});
}

final level1 = Level(
  name: 'First Steps',
  initialBoard: Board.fromAsciiString('''
    #######
    #[1+].[=3]#
    ###2###
    .......
    ...P...
    '''),
);

final level2 = Level(
  name: 'Push It',
  initialBoard: Board.fromAsciiString('''
    #########
    #.1..[5=6]#
    #.#+#####
    #...P...#
    #########
    '''),
);

final level3 = Level(
  name: 'The Swap',
  initialBoard: Board.fromAsciiString('''
    ########
    #......#
    #......#
    #[2+]4[=]2.#
    #..P...#
    ########
    '''),
);

final level4 = Level(
  name: 'Tight Squeeze',
  initialBoard: Board.fromAsciiString('''
    ##.#####
    ....[+8=9]
    .#.#####
    ...#####
    ##1#####
    #P.#####
    '''),
);

final level5 = Level(
  name: 'Big Numbers',
  initialBoard: Board.fromAsciiString('''
    ##########
    #P1..[+9=19]
    #.#0######
    #........#
    ##########
    '''),
);

final level6 = Level(
  name: 'Take Away',
  initialBoard: Board.fromAsciiString('''
    ##########
    #........#
    #........#
    #.-4[2=2]..#
    #P.......#
    ##########
    '''),
);

final level7 = Level(
  name: 'In the Red',
  initialBoard: Board.fromAsciiString('''
    ##########
    #........#
    #........#
    #P9[-]3[=]6-.#
    #........#
    ##########
    '''),
);

final level8 = Level(
  name: 'Times Tables',
  initialBoard: Board.fromAsciiString('''
    ##########
    #........#
    #........#
    #[3]+[3=3]*[6]P#
    #........#
    ##########
    '''),
);

final level9 = Level(
  name: 'Divide and Conquer',
  initialBoard: Board.fromAsciiString('''
    ###...####
    ###.=.####
    ##[8].[2].[4]###
    ###.#.####
    #P../....#
    ###...####
    '''),
);

final level10 = Level(
  name: 'Order of Ops',
  initialBoard: Board.fromAsciiString('''
    ############
    #..........#
    #..........#
    #.[2]*[3]4[4=1]+.#
    #..........#
    #......P...#
    ############
    '''),
);

final level11 = Level(
  name: 'Labyrinth',
  initialBoard: Board.fromAsciiString('''
    ....#.#..........
    .#.......########
    ..#.###.......###
    #.#.[00-]1=[99]##....
    #.#####.......###
    P.1......####....
    ########......###
    '''),
);

final level12 = Level(
  name: 'Double Trouble',
  initialBoard: Board.fromAsciiString('''
    ############
    #..........#
    #..........#
    #[1]3/[1]+[64]=[2].#
    #..........#
    #....P.....#
    ############
    '''),
);

final level13 = Level(
  name: 'Chain Reaction',
  initialBoard: Board.fromAsciiString('''
    #########
    #.......#
    #.#.....#
    #..5....#
    ##.5.[=2].#
    #.*5....#
    #P......#
    #########
    '''),
);

final level14 = Level(
  name: 'House of Mirrors',
  initialBoard: Board.fromAsciiString('''
    ###############
    #.............#
    #.[9]9-[9]0[=]0[9]-99.#
    #.............#
    #.............#
    #......P......#
    ###############
    '''),
);

final level15 = Level(
  name: 'The Final Equation',
  initialBoard: Board.fromAsciiString('''
    ##...............##
    ...................
    .7#......-......#3.
    #.#.............#.#
    #...##.+.[=].*......#
    #.#.............#.#
    .1#......1......#5.
    ...................
    ##.......P.......##
    '''),
);
