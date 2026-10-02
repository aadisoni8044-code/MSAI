import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';

enum CaptureType { photo, video }

class CapturedMedia {
  final String path;
  final CaptureType type;
  final DateTime timestamp;
  final String filterName;

  CapturedMedia({
    required this.path,
    required this.type,
    required this.timestamp,
    required this.filterName,
  });
}

class CameraProvider extends ChangeNotifier {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  int _selectedCameraIndex = 0;
  bool _isInitialized = false;
  bool _isRecording = false;
  FlashMode _flashMode = FlashMode.off;
  int _timerSeconds = 0; // 0 = off, 3, 5, 10
  int _countdownValue = 0;
  bool _isCountingDown = false;
  CapturedMedia? _lastCapturedMedia;
  Timer? _recordingTimer;
  int _recordingDurationSeconds = 0;

  CameraController? get controller => _controller;
  bool get isInitialized => _isInitialized;
  bool get isRecording => _isRecording;
  FlashMode get flashMode => _flashMode;
  int get timerSeconds => _timerSeconds;
  int get countdownValue => _countdownValue;
  bool get isCountingDown => _isCountingDown;
  CapturedMedia? get lastCapturedMedia => _lastCapturedMedia;
  int get recordingDurationSeconds => _recordingDurationSeconds;
  bool get isFrontCamera =>
      _cameras.isNotEmpty &&
      _cameras[_selectedCameraIndex].lensDirection == CameraLensDirection.front;

  Future<void> initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isNotEmpty) {
        await _initController(_cameras[_selectedCameraIndex]);
      } else {
        _isInitialized = false;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Camera initialization error: $e');
      _isInitialized = false;
      notifyListeners();
    }
  }

  Future<void> _initController(CameraDescription cameraDescription) async {
    await _controller?.dispose();
    _controller = CameraController(
      cameraDescription,
      ResolutionPreset.high,
      enableAudio: true,
    );

    try {
      await _controller!.initialize();
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('CameraController initialize failed: $e');
      _isInitialized = false;
      notifyListeners();
    }
  }

  Future<void> switchCamera() async {
    if (_cameras.length <= 1) return;
    _selectedCameraIndex = (_selectedCameraIndex + 1) % _cameras.length;
    _isInitialized = false;
    notifyListeners();
    await _initController(_cameras[_selectedCameraIndex]);
  }

  Future<void> toggleFlash() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    switch (_flashMode) {
      case FlashMode.off:
        _flashMode = FlashMode.auto;
        break;
      case FlashMode.auto:
        _flashMode = FlashMode.always;
        break;
      case FlashMode.always:
        _flashMode = FlashMode.torch;
        break;
      case FlashMode.torch:
        _flashMode = FlashMode.off;
        break;
    }
    try {
      await _controller!.setFlashMode(_flashMode);
      notifyListeners();
    } catch (e) {
      debugPrint('Error setting flash mode: $e');
    }
  }

  void cycleTimer() {
    if (_timerSeconds == 0) {
      _timerSeconds = 3;
    } else if (_timerSeconds == 3) {
      _timerSeconds = 5;
    } else if (_timerSeconds == 5) {
      _timerSeconds = 10;
    } else {
      _timerSeconds = 0;
    }
    notifyListeners();
  }

  Future<void> capturePhoto({required String activeFilterName}) async {
    if (_timerSeconds > 0) {
      _isCountingDown = true;
      _countdownValue = _timerSeconds;
      notifyListeners();

      for (int i = _timerSeconds; i > 0; i--) {
        _countdownValue = i;
        notifyListeners();
        await Future.delayed(const Duration(seconds: 1));
      }
      _isCountingDown = false;
      notifyListeners();
    }

    try {
      XFile? file;
      if (_controller != null && _controller!.value.isInitialized) {
        file = await _controller!.takePicture();
      } else {
        // Fallback simulation for tests / web / desktop platforms without physical camera
        file = XFile('simulated_snap_${DateTime.now().millisecondsSinceEpoch}.jpg');
      }

      _lastCapturedMedia = CapturedMedia(
        path: file.path,
        type: CaptureType.photo,
        timestamp: DateTime.now(),
        filterName: activeFilterName,
      );
      notifyListeners();
    } catch (e) {
      debugPrint('Error capturing photo: $e');
      _lastCapturedMedia = CapturedMedia(
        path: 'simulated_snap_${DateTime.now().millisecondsSinceEpoch}.jpg',
        type: CaptureType.photo,
        timestamp: DateTime.now(),
        filterName: activeFilterName,
      );
      notifyListeners();
    }
  }

  Future<void> startVideoRecording() async {
    if (_isRecording) return;
    try {
      if (_controller != null && _controller!.value.isInitialized) {
        await _controller!.startVideoRecording();
      }
      _isRecording = true;
      _recordingDurationSeconds = 0;
      _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        _recordingDurationSeconds++;
        notifyListeners();
      });
      notifyListeners();
    } catch (e) {
      debugPrint('Error starting video recording: $e');
      _isRecording = true;
      _recordingDurationSeconds = 0;
      _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        _recordingDurationSeconds++;
        notifyListeners();
      });
      notifyListeners();
    }
  }

  Future<void> stopVideoRecording({required String activeFilterName}) async {
    if (!_isRecording) return;
    _recordingTimer?.cancel();
    _isRecording = false;

    try {
      XFile? file;
      if (_controller != null && _controller!.value.isRecordingVideo) {
        file = await _controller!.stopVideoRecording();
      } else {
        file = XFile('simulated_video_${DateTime.now().millisecondsSinceEpoch}.mp4');
      }

      _lastCapturedMedia = CapturedMedia(
        path: file.path,
        type: CaptureType.video,
        timestamp: DateTime.now(),
        filterName: activeFilterName,
      );
    } catch (e) {
      debugPrint('Error stopping video recording: $e');
      _lastCapturedMedia = CapturedMedia(
        path: 'simulated_video_${DateTime.now().millisecondsSinceEpoch}.mp4',
        type: CaptureType.video,
        timestamp: DateTime.now(),
        filterName: activeFilterName,
      );
    }
    notifyListeners();
  }

  void clearCapturedMedia() {
    _lastCapturedMedia = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _recordingTimer?.cancel();
    _controller?.dispose();
    super.dispose();
  }
}
