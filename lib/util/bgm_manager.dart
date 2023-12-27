import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';

class SoundPlayer with WidgetsBindingObserver{
  static final SoundPlayer _instance = SoundPlayer._internal();

  factory SoundPlayer() => _instance;

  SoundPlayer._internal();

  // 싱글톤 클래스가 생성될 때 WidgetsBindingObserver 등록
  void initialize() {
    WidgetsBinding.instance?.addObserver(this);
  }

  final AudioPlayer _audioPlayer = AudioPlayer();

  final AudioPlayer _backgroundAudioPlayer = AudioPlayer();
  bool isBackgroundPlaying = false; // 배경음 재생 여부를 저장하는 변수


  /// 배경음
  Future<void> playBackgroundSound() async {
    if (!isBackgroundPlaying) {
        _backgroundAudioPlayer.onPlayerComplete.listen((event) {
        _backgroundAudioPlayer.play(AssetSource('sound/background.mp3'));

      });
      await _backgroundAudioPlayer.play(AssetSource('sound/background.mp3'));
      isBackgroundPlaying = true;

        _backgroundAudioPlayer.setVolume(0.3);
    }
  }

  bool isPlaying() => _audioPlayer.state == PlayerState.playing;


  /// 버튼 클릭음
  Future<void> clickedSound() async {
    try {
      if (!isPlaying()) {
        await _audioPlayer.play(AssetSource('sound/water_drop_1.mp3'));
      }
    } catch (e) {
      print('오디오 재생 중 오류가 발생했습니다: $e');
    }
  }

  /// 이펙트 충돌 음
  Future<void> effectSound() async {
    try {
      if (!isPlaying()) {
        await _audioPlayer.play(AssetSource('sound/effect.mp3'));
      }
    } catch (e) {
      print('오디오 재생 중 오류가 발생했습니다: $e');
    }
  }
}
