import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

class PlayerYT {
  final _player = AudioPlayer();
  Future<void> init() async {
    final session = await AudioSession.instance;
    await session.configure(AudioSessionConfiguration.speech());
    _player.playbackEventStream.listen((event) {},
        onError: (Object e, StackTrace stackTrace) {
      print('A stream error occurred: $e');
    });
  }

  Future<void> setAudioLink(
      String link, String imgLink, String songName) async {
    _player.pause();
    try {
      await _player.setAudioSource(
        AudioSource.uri(
          Uri.parse(link),
          tag: MediaItem(
              // Specify a unique ID for each media item:
              id: '1',
              // Metadata to display in the notification:
              title: songName,
              artUri: Uri.parse(imgLink),
              duration: getTotalTime()),
        ),
      );
    } catch (e) {
      print("Error loading audio source: $e");
    }
  }

  void initAsset(String asset) async {
    final session = await AudioSession.instance;
    await session.configure(AudioSessionConfiguration.music());
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

  Duration getTotalTime() => _player.duration;
  isPlayerDoneLoading() => _player.playerState.playing;
  Duration getBufferPosition() => _player.bufferedPosition;
  seek(Duration duration) => _player.seek(duration);

  void play() => _player.play();

  forward() {
    if (!(_player.position >= getTotalTime() - Duration(seconds: 10))) {
      _player.seek(_player.position + Duration(seconds: 10));
    } else if (_player.position < getTotalTime()) {
      _player.seek(getTotalTime());
    }
  }

  rewind() {
    if (!(_player.position <= Duration(seconds: 10))) {
      _player.seek(_player.position - Duration(seconds: 10));
    } else if (_player.position > Duration.zero) {
      _player.seek(Duration.zero);
    }
  }

  Stream<Duration> getPosition() => _player.positionStream;

  void stopPlayer() => _player.stop();
  void pause() => _player.pause();
  void dispose() => _player.dispose();
  isActive() => _player.playerState.playing;
}
