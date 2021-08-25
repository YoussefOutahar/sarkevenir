import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart';

class PlayerYT {
  final _player = AudioPlayer();
  Future<void> init(String link) async {
    final session = await AudioSession.instance;
    await session.configure(AudioSessionConfiguration.speech());
    _player.playbackEventStream.listen((event) {},
        onError: (Object e, StackTrace stackTrace) {
      print('A stream error occurred: $e');
    });
    try {
      await _player.setAudioSource(AudioSource.uri(Uri.parse(link)));
    } catch (e) {
      print("Error loading audio source: $e");
    }
  }

  void initAsset(String asset) async {
    final session = await AudioSession.instance;
    await session.configure(AudioSessionConfiguration.speech());
    _player.playbackEventStream.listen((event) {},
        onError: (Object e, StackTrace stackTrace) {
      print('A stream error occurred: $e');
    });
    try {
      await _player.setAsset(asset);
      await _player.setLoopMode(LoopMode.all);
    } catch (e) {
      print("Error loading audio source: $e");
    }
  }

  getPosition() {
    return _player.position;
  }

  void play() {
    if (_player.playing) {
      stopPlayer();
      _player.play();
    } else {
      _player.play();
    }
  }

  stopPlayer() => _player.stop();
  void pause() => _player.pause();
  void dispose() => _player.dispose();
}
