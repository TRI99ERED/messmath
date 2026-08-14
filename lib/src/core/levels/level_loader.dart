import 'package:messmath/src/core/levels/levels.dart';

class LevelLoader {
  static final List<Level> levels = [
    level1,
    // Add more levels here
  ];

  static Level loadLevel(int levelIndex) {
    if (levelIndex >= 1 && levelIndex <= levels.length) {
      return levels[levelIndex - 1];
    }
    throw ArgumentError('Level not found');
  }
}
