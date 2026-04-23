import 'package:audioplayers/audioplayers.dart';

class AudioManager {
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;
  AudioManager._internal();

  final AudioPlayer _bgmPlayer = AudioPlayer();
  final AudioPlayer _sePlayer = AudioPlayer();

  bool _isMuted = false;

  // BGMの再生
  Future<void> playBGM() async {
    if (_isMuted) return;
    await _bgmPlayer.setReleaseMode(ReleaseMode.loop);
    await _bgmPlayer.setVolume(0.5); // 音量を半分に設定
    await _bgmPlayer.play(AssetSource('sounds/bgm_main.wav'));
  }

  // BGMの停止
  Future<void> stopBGM() async {
    await _bgmPlayer.stop();
  }

  // 効果音の再生
  Future<void> playSE(String fileName) async {
    if (_isMuted) return;
    // 新しいAudioPlayerインスタンスを作成して同時再生を可能にする
    final player = AudioPlayer();
    await player.play(AssetSource('sounds/$fileName'));
    // 再生終了後にリソースを解放
    player.onPlayerComplete.listen((_) => player.dispose());
  }

  // ミュート設定の切り替え
  void toggleMute() {
    _isMuted = !_isMuted;
    if (_isMuted) {
      _bgmPlayer.pause();
    } else {
      _bgmPlayer.resume();
    }
  }

  bool get isMuted => _isMuted;
}
