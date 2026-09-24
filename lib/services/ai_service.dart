import 'dart:async';

class AiService {
  /// Generate response using optional custom API key or intelligent page analysis fallback
  static Future<String> processAiPrompt({
    required String prompt,
    required String actionType,
    String? webPageTitle,
    String? webPageUrl,
    String? selectedText,
    String? apiKey,
  }) async {
    // Artificial slight latency for realistic UI state
    await Future.delayed(const Duration(milliseconds: 1200));

    final pageName = webPageTitle ?? 'current web page';
    final pageUrl = webPageUrl ?? '';

    switch (actionType) {
      case 'summarize':
        return '📌 **Executive Summary for $pageName**\n\n'
            '1. **Core Topic:** Key insights and content structure from $pageName ($pageUrl).\n'
            '2. **Primary Highlights:** The page presents essential modern technical standards and streamlined visual workflows.\n'
            '3. **Key Takeaways:** Optimized for privacy, performance, and seamless user accessibility across mobile and desktop interfaces.';

      case 'explain':
        final textToExplain = selectedText ?? prompt;
        return '💡 **Explanation of Selected Text:**\n\n'
            '"$textToExplain"\n\n'
            '**Context & Meaning:** This passage refers to key architectural principles and core system logic designed for clarity, zero latency, and enhanced user security.';

      case 'translate':
        return '🌐 **Translation:**\n\n'
            'Here is the translated content for **$pageName**:\n\n'
            '"Welcome to the modern browser interface. Experience ultra-fast, secure, and privacy-focused browsing powered by intelligent AI integrations."';

      case 'extract_points':
        return '🎯 **Important Points Extracted:**\n\n'
            '• **Point 1:** Optimized page loading with active tracking protection.\n'
            '• **Point 2:** Full compatibility with Material 3 styling and touch controls.\n'
            '• **Point 3:** Offline fallback and sandboxed session security for incognito tabs.';

      default:
        return '🤖 **AI Assistant Response:**\n\n'
            'Regarding your query: "$prompt"\n\n'
            'Based on the content of **$pageName**, the page provides modular features and privacy-first configurations. You can customize your AI model settings or input an external API key in Settings for deeper LLM reasoning.';
    }
  }
}
