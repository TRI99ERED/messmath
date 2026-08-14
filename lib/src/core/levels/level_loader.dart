import 'package:messmath/src/core/levels/levels.dart';

class LevelLoader {
  static final List<Level> levels = [
    level1,
    level2,
    level3,
    level4,
    level5,
    level6,
    level7,
    level8,
    level9,
    level10,
    level11,
    level12,
    level13,
    level14,
    level15,
  ];

  static Level loadLevel(int levelIndex) {
    if (levelIndex >= 1 && levelIndex <= levels.length) {
      return levels[levelIndex - 1];
    }
    throw ArgumentError('Level not found');
  }
}
