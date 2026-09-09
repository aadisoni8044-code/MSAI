import 'dart:async';

abstract class AudioService {
  Future<void> startRecording();
  Future<String?> stopRecording();
  Future<void> playAudio(String pathOrUrl);
  Future<void> pauseAudio();
  Future<void> resumeAudio();
  Future<void> stopAudio();
  Stream<Duration> get onPositionChanged;
  Stream<bool> get onPlayerStateChanged;
  bool get isRecording;
  bool get isPlaying;
}

class MockAudioService implements AudioService {
  bool _isRecording = false;
  bool _isPlaying = false;
  Timer? _recordingTimer;
  Timer? _playbackTimer;
  int _recordingSeconds = 0;
  Duration _currentPosition = Duration.zero;

  final StreamController<Duration> _positionController = StreamController<Duration>.broadcast();
  final StreamController<bool> _playerStateController = StreamController<bool>.broadcast();

  @override
  bool get isRecording => _isRecording;

  @override
  bool get isPlaying => _isPlaying;

  @override
  Stream<Duration> get onPositionChanged => _positionController.stream;

  @override
  Stream<bool> get onPlayerStateChanged => _playerStateController.stream;

  @override
  Future<void> startRecording() async {
    _isRecording = true;
    _recordingSeconds = 0;
    _recordingTimer?.cancel();
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _recordingSeconds++;
    });
  }

  @override
  Future<String?> stopRecording() async {
    _recordingTimer?.cancel();
    _isRecording = false;
    final durationSec = _recordingSeconds;
    _recordingSeconds = 0;
    return 'mock_voice_note_${DateTime.now().millisecondsSinceEpoch}.aac|$durationSec';
  }

  @override
  Future<void> playAudio(String pathOrUrl) async {
    _isPlaying = true;
    _playerStateController.add(true);
    _currentPosition = Duration.zero;

    _playbackTimer?.cancel();
    _playbackTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      _currentPosition += const Duration(milliseconds: 500);
      _positionController.add(_currentPosition);
      if (_currentPosition.inSeconds >= 10) {
        stopAudio();
      }
    });
  }

  @override
  Future<void> pauseAudio() async {
    _playbackTimer?.cancel();
    _isPlaying = false;
    _playerStateController.add(false);
  }

  @override
  Future<void> resumeAudio() async {
    _isPlaying = true;
    _playerStateController.add(true);
    _playbackTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      _currentPosition += const Duration(milliseconds: 500);
      _positionController.add(_currentPosition);
      if (_currentPosition.inSeconds >= 10) {
        stopAudio();
      }
    });
  }

  @override
  Future<void> stopAudio() async {
    _playbackTimer?.cancel();
    _isPlaying = false;
    _currentPosition = Duration.zero;
    _playerStateController.add(false);
    _positionController.add(Duration.zero);
  }

  void dispose() {
    _recordingTimer?.cancel();
    _playbackTimer?.cancel();
    _positionController.close();
    _playerStateController.close();
  }
}
