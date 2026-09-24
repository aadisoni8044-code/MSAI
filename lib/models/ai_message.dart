class AiMessage {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final String? type; // 'summary', 'explain', 'translate', 'general'

  AiMessage({
    required this.id,
    required this.text,
    required this.isUser,
    DateTime? timestamp,
    this.type = 'general',
  }) : timestamp = timestamp ?? DateTime.now();
}
