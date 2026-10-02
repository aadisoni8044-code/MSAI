import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';

class CameraProvider extends ChangeNotifier {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  int _selectedCameraIndex = 0;
  bool _isInitialized = false;
  bool _isRecording = false;
  bool _isFlashOn = false;
  double _currentZoom = 1.0;
  double _maxZoom = 5.0;
  double _minZoom = 1.0;
  String? _capturedMediaPath;
  bool _isVideo = false;
  final ImagePicker _picker = ImagePicker();

  CameraController? get controller => _controller;
  bool get isInitialized => _isInitialized;
  bool get isRecording => _isRecording;
  bool get isFlashOn => _isFlashOn;
  double get currentZoom => _currentZoom;
  String? get capturedMediaPath => _capturedMediaPath;
  bool get isVideo => _isVideo;

  Future<void> initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isNotEmpty) {
        await _setupController(_cameras[_selectedCameraIndex]);
      } else {
        _isInitialized = false;
        notifyListeners();
      }
    } catch (e) {
      _isInitialized = false;
      notifyListeners();
    }
  }

  Future<void> _setupController(CameraDescription camera) async {
    await _controller?.dispose();
    _controller = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: true,
    );

    try {
      await _controller!.initialize();
      _maxZoom = await _controller!.getMaxZoomLevel();
      _minZoom = await _controller!.getMinZoomLevel();
      _isInitialized = true;
    } catch (e) {
      _isInitialized = false;
    }
    notifyListeners();
  }

  Future<void> switchCamera() async {
    if (_cameras.length <= 1) return;
    _selectedCameraIndex = (_selectedCameraIndex + 1) % _cameras.length;
    await _setupController(_cameras[_selectedCameraIndex]);
  }

  Future<void> toggleFlash() async {
    if (_controller == null || !_isInitialized) return;
    _isFlashOn = !_isFlashOn;
    await _controller!.setFlashMode(_isFlashOn ? FlashMode.torch : FlashMode.off);
    notifyListeners();
  }

  Future<void> setZoom(double zoom) async {
    if (_controller == null || !_isInitialized) return;
    _currentZoom = zoom.clamp(_minZoom, _maxZoom);
    await _controller!.setZoomLevel(_currentZoom);
    notifyListeners();
  }

  Future<String?> takePhoto() async {
    if (_controller == null || !_isInitialized) {
      // Hardware camera unavailable fallback
      _capturedMediaPath = 'simulated_photo_${DateTime.now().millisecondsSinceEpoch}.jpg';
      _isVideo = false;
      notifyListeners();
      return _capturedMediaPath;
    }

    try {
      final file = await _controller!.takePicture();
      _capturedMediaPath = file.path;
      _isVideo = false;
      notifyListeners();
      return file.path;
    } catch (e) {
      _capturedMediaPath = 'simulated_photo_${DateTime.now().millisecondsSinceEpoch}.jpg';
      _isVideo = false;
      notifyListeners();
      return _capturedMediaPath;
    }
  }

  Future<void> startVideoRecording() async {
    if (_controller == null || !_isInitialized) {
      _isRecording = true;
      notifyListeners();
      return;
    }
    try {
      await _controller!.startVideoRecording();
      _isRecording = true;
      notifyListeners();
    } catch (e) {
      _isRecording = true;
      notifyListeners();
    }
  }

  Future<String?> stopVideoRecording() async {
    _isRecording = false;
    if (_controller == null || !_isInitialized) {
      _capturedMediaPath = 'simulated_video_${DateTime.now().millisecondsSinceEpoch}.mp4';
      _isVideo = true;
      notifyListeners();
      return _capturedMediaPath;
    }
    try {
      final file = await _controller!.stopVideoRecording();
      _capturedMediaPath = file.path;
      _isVideo = true;
      notifyListeners();
      return file.path;
    } catch (e) {
      _capturedMediaPath = 'simulated_video_${DateTime.now().millisecondsSinceEpoch}.mp4';
      _isVideo = true;
      notifyListeners();
      return _capturedMediaPath;
    }
  }

  Future<String?> pickMediaFromGallery() async {
    final file = await _picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      _capturedMediaPath = file.path;
      _isVideo = false;
      notifyListeners();
      return file.path;
    }
    return null;
  }

  void clearCapturedMedia() {
    _capturedMediaPath = null;
    _isVideo = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}
