import 'package:messmath/src/features/data/repositories/shared_preferences/ishared_preferences_repository.dart';

class LevelProgressRepository {
  static const String _progressKey = 'level_progress';

  final ISharedPreferencesRepository _repository;
  final Map<int, int> _bestMovesByLevel = {};

  LevelProgressRepository(this._repository);

  Future<void> load() async {
    _bestMovesByLevel.clear();
    final entries =
        await _repository.getStringList(_progressKey) ?? const <String>[];
    for (final entry in entries) {
      final parts = entry.split(':');
      if (parts.length != 2) continue;
      final level = int.tryParse(parts[0]);
      final moves = int.tryParse(parts[1]);
      if (level == null || moves == null) continue;
      _bestMovesByLevel[level] = moves;
    }
  }

  bool isCompleted(int level) => _bestMovesByLevel.containsKey(level);

  int? bestMoves(int level) => _bestMovesByLevel[level];

  Future<void> saveResult(int level, int moveCount) async {
    final current = _bestMovesByLevel[level];
    if (current != null && current <= moveCount) return;
    _bestMovesByLevel[level] = moveCount;
    final entries = _bestMovesByLevel.entries
        .map((entry) => '${entry.key}:${entry.value}')
        .toList();
    await _repository.setStringList(_progressKey, entries);
  }
}
