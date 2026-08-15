import 'dart:async';

import 'package:flame_audio/bgm.dart';
import 'package:flame_audio/flame_audio.dart';

class SoundEffects {
  SoundEffects._() {
    FlameAudio.updatePrefix('assets/sfx/');
  }

  static final SoundEffects instance = SoundEffects._();

  static const double _volume = 0.5;

  AudioPool? _movePool;
  AudioPool? _pushPool;

  final Bgm _musicBgm = Bgm(
    audioCache: AudioCache(prefix: 'assets/music/'),
  );

  Future<void> init() async {
    _movePool = await FlameAudio.createPool('move.wav', maxPlayers: 4);
    _pushPool = await FlameAudio.createPool('push.wav', maxPlayers: 4);
    await _musicBgm.initialize();
  }

  void playMove() {
    final pool = _movePool;
    if (pool != null) unawaited(pool.start(volume: _volume));
  }

  void playPush() {
    final pool = _pushPool;
    if (pool != null) unawaited(pool.start(volume: _volume));
  }

  void playNavigate() {
    unawaited(FlameAudio.play('navigate_menu.wav', volume: _volume));
  }

  void playWin() {
    unawaited(FlameAudio.play('win.wav', volume: _volume));
  }

  void playMainTheme() {
    unawaited(_musicBgm.play('main.wav', volume: 0.5));
  }
}
