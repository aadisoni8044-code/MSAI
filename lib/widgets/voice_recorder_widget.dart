import 'package:flutter/material.dart';
import '../../core/services/audio_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/date_formatter.dart';

class VoiceRecorderWidget extends StatefulWidget {
  final AudioService audioService;
  final Function(String path, int durationSeconds) onRecordingComplete;
  final VoidCallback onCancel;

  const VoiceRecorderWidget({
    super.key,
    required this.audioService,
    required this.onRecordingComplete,
    required this.onCancel,
  });

  @override
  State<VoiceRecorderWidget> createState() => _VoiceRecorderWidgetState();
}

class _VoiceRecorderWidgetState extends State<VoiceRecorderWidget> {
  int _seconds = 0;
  bool _isRecording = false;

  @override
  void initState() {
    super.initState();
    _startRecording();
  }

  Future<void> _startRecording() async {
    await widget.audioService.startRecording();
    setState(() {
      _isRecording = true;
      _seconds = 0;
    });
    _tick();
  }

  void _tick() {
    if (!_isRecording || !mounted) return;
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && _isRecording) {
        setState(() {
          _seconds++;
        });
        _tick();
      }
    });
  }

  Future<void> _stopAndSend() async {
    final result = await widget.audioService.stopRecording();
    setState(() {
      _isRecording = false;
    });
    final path = result?.split('|').first ?? 'voice_note.aac';
    final duration = _seconds > 0 ? _seconds : 1;
    widget.onRecordingComplete(path, duration);
  }

  Future<void> _cancel() async {
    await widget.audioService.stopRecording();
    setState(() {
      _isRecording = false;
    });
    widget.onCancel();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Theme.of(context).cardColor,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.delete, color: AppColors.error),
            onPressed: _cancel,
          ),
          const SizedBox(width: 8),
          const Icon(Icons.mic, color: AppColors.error),
          const SizedBox(width: 8),
          Text(
            DateFormatter.formatDuration(Duration(seconds: _seconds)),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const Spacer(),
          TextButton(
            onPressed: _cancel,
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          const SizedBox(width: 8),
          FloatingActionButton.small(
            onPressed: _stopAndSend,
            backgroundColor: AppColors.accentGreen,
            child: const Icon(Icons.send, color: Colors.white, size: 18),
          ),
        ],
      ),
    );
  }
}
