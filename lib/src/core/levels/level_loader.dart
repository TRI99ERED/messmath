import 'package:messmath/src/core/levels/levels.dart';

class LevelLoader {
  static Level loadLevel(int levelIndex) {
    switch (levelIndex) {
      case 1:
        return level1;
      // Add more cases for other levels
      default:
        throw ArgumentError('Level not found');
    }
  }
}
