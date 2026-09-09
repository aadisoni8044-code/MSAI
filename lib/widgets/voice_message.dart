import 'package:flutter/material.dart';

class VoiceMessageWidget extends StatefulWidget {
  final String audioUrl;
  final int durationSeconds;
  final bool isSelf;

  const VoiceMessageWidget({
    super.key,
    required this.audioUrl,
    required this.durationSeconds,
    required this.isSelf,
  });

  @override
  State<VoiceMessageWidget> createState() => _VoiceMessageWidgetState();
}

class _VoiceMessageWidgetState extends State<VoiceMessageWidget> {
  bool _isPlaying = false;
  double _playbackProgress = 0.0;

  void _togglePlayback() {
    setState(() {
      _isPlaying = !_isPlaying;
      if (_isPlaying) {
        _simulateProgress();
      }
    });
  }

  void _simulateProgress() async {
    while (_isPlaying && _playbackProgress < 1.0) {
      await Future.delayed(const Duration(milliseconds: 200));
      if (!mounted) return;
      setState(() {
        _playbackProgress += 0.05;
        if (_playbackProgress >= 1.0) {
          _isPlaying = false;
          _playbackProgress = 0.0;
        }
      });
    }
  }

  String _formatDuration(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
              size: 36,
              color: widget.isSelf ? Colors.white : Theme.of(context).primaryColor,
            ),
            onPressed: _togglePlayback,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LinearProgressIndicator(
                  value: _playbackProgress,
                  backgroundColor: Colors.white24,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    widget.isSelf ? Colors.greenAccent : Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDuration(widget.durationSeconds),
                  style: TextStyle(
                    fontSize: 11,
                    color: widget.isSelf ? Colors.white70 : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class VoiceRecordBar extends StatefulWidget {
  final Function(String path, int duration) onSendRecording;
  final VoidCallback onCancel;

  const VoiceRecordBar({
    super.key,
    required this.onSendRecording,
    required this.onCancel,
  });

  @override
  State<VoiceRecordBar> createState() => _VoiceRecordBarState();
}

class _VoiceRecordBarState extends State<VoiceRecordBar> {
  int _seconds = 0;
  bool _isRecording = true;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() async {
    while (_isRecording) {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      setState(() {
        _seconds++;
      });
    }
  }

  @override
  void dispose() {
    _isRecording = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Theme.of(context).cardColor,
      child: Row(
        children: [
          const Icon(Icons.mic, color: Colors.red, size: 24),
          const SizedBox(width: 8),
          Text(
            '${(_seconds ~/ 60).toString().padLeft(2, '0')}:${(_seconds % 60).toString().padLeft(2, '0')}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          TextButton(
            onPressed: widget.onCancel,
            child: const Text('Cancel', style: TextStyle(color: Colors.red)),
          ),
          IconButton(
            icon: const Icon(Icons.send, color: Colors.green),
            onPressed: () {
              widget.onSendRecording('demo_voice.aac', _seconds);
            },
          ),
        ],
      ),
    );
  }
}
