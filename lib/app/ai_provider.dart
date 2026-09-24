import 'package:flutter/foundation.dart';
import '../models/ai_message.dart';
import '../services/ai_service.dart';

class AiProvider extends ChangeNotifier {
  final List<AiMessage> _messages = [];
  bool _isProcessing = false;

  List<AiMessage> get messages => List.unmodifiable(_messages);
  bool get isProcessing => _isProcessing;

  AiProvider() {
    _messages.add(
      AiMessage(
        id: 'welcome',
        text: 'Hello! I am your AI Web Assistant. Ask me anything about your current web page, summarize articles, explain selected text, or translate content.',
        isUser: false,
      ),
    );
  }

  void addMessage(String text, {required bool isUser, String? type}) {
    _messages.add(
      AiMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: text,
        isUser: isUser,
        type: type ?? 'general',
      ),
    );
    notifyListeners();
  }

  Future<void> askQuestion({
    required String prompt,
    String? webPageTitle,
    String? webPageUrl,
    String? apiKey,
  }) async {
    if (prompt.trim().isEmpty) return;

    addMessage(prompt, isUser: true);
    _isProcessing = true;
    notifyListeners();

    try {
      final responseText = await AiService.processAiPrompt(
        prompt: prompt,
        actionType: 'general',
        webPageTitle: webPageTitle,
        webPageUrl: webPageUrl,
        apiKey: apiKey,
      );

      addMessage(responseText, isUser: false);
    } catch (e) {
      addMessage('Sorry, I encountered an error processing your request: $e', isUser: false);
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  Future<void> summarizeWebPage({
    required String webPageTitle,
    required String webPageUrl,
    String? apiKey,
  }) async {
    addMessage('Please summarize this web page ($webPageTitle).', isUser: true, type: 'summary');
    _isProcessing = true;
    notifyListeners();

    final responseText = await AiService.processAiPrompt(
      prompt: 'Summarize webpage',
      actionType: 'summarize',
      webPageTitle: webPageTitle,
      webPageUrl: webPageUrl,
      apiKey: apiKey,
    );

    addMessage(responseText, isUser: false, type: 'summary');
    _isProcessing = false;
    notifyListeners();
  }

  Future<void> explainSelectedText({
    required String selectedText,
    required String webPageTitle,
    String? apiKey,
  }) async {
    addMessage('Explain this selected text: "$selectedText"', isUser: true, type: 'explain');
    _isProcessing = true;
    notifyListeners();

    final responseText = await AiService.processAiPrompt(
      prompt: selectedText,
      actionType: 'explain',
      selectedText: selectedText,
      webPageTitle: webPageTitle,
      apiKey: apiKey,
    );

    addMessage(responseText, isUser: false, type: 'explain');
    _isProcessing = false;
    notifyListeners();
  }

  Future<void> translateWebPage({
    required String webPageTitle,
    required String webPageUrl,
    String? apiKey,
  }) async {
    addMessage('Translate the text on this web page.', isUser: true, type: 'translate');
    _isProcessing = true;
    notifyListeners();

    final responseText = await AiService.processAiPrompt(
      prompt: 'Translate page',
      actionType: 'translate',
      webPageTitle: webPageTitle,
      webPageUrl: webPageUrl,
      apiKey: apiKey,
    );

    addMessage(responseText, isUser: false, type: 'translate');
    _isProcessing = false;
    notifyListeners();
  }

  Future<void> extractKeyPoints({
    required String webPageTitle,
    required String webPageUrl,
    String? apiKey,
  }) async {
    addMessage('Extract the key important points from this page.', isUser: true, type: 'extract');
    _isProcessing = true;
    notifyListeners();

    final responseText = await AiService.processAiPrompt(
      prompt: 'Extract key points',
      actionType: 'extract_points',
      webPageTitle: webPageTitle,
      webPageUrl: webPageUrl,
      apiKey: apiKey,
    );

    addMessage(responseText, isUser: false, type: 'extract');
    _isProcessing = false;
    notifyListeners();
  }

  void clearConversation() {
    _messages.clear();
    _messages.add(
      AiMessage(
        id: 'welcome',
        text: 'Conversation cleared. Ready for your next query or page analysis!',
        isUser: false,
      ),
    );
    notifyListeners();
  }
}
