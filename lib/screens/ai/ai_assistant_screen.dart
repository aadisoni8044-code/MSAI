import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/ai_provider.dart';
import '../../app/browser_provider.dart';
import '../../app/settings_provider.dart';
import '../../models/ai_message.dart';

class AiAssistantScreen extends StatefulWidget {
  const AiAssistantScreen({super.key});

  @override
  State<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends State<AiAssistantScreen> {
  final TextEditingController _promptController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _promptController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendPrompt(AiProvider aiProvider, BrowserProvider browserProvider, SettingsProvider settingsProvider) {
    final text = _promptController.text.trim();
    if (text.isEmpty) return;

    final activeTab = browserProvider.activeTab;
    aiProvider.askQuestion(
      prompt: text,
      webPageTitle: activeTab?.title,
      webPageUrl: activeTab?.url,
      apiKey: settingsProvider.settings.aiApiKey,
    );
    _promptController.clear();
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final aiProvider = Provider.of<AiProvider>(context);
    final browserProvider = Provider.of<BrowserProvider>(context);
    final settingsProvider = Provider.of<SettingsProvider>(context);

    final activeTab = browserProvider.activeTab;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.auto_awesome_rounded, color: theme.colorScheme.primary, size: 20),
            ),
            const SizedBox(width: 8),
            const Text('AI Web Assistant', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded),
            tooltip: 'Clear Chat',
            onPressed: () => aiProvider.clearConversation(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Current Web Page Banner Context
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFEEF2FF),
            child: Row(
              children: [
                Icon(Icons.public_rounded, size: 18, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    activeTab != null && activeTab.url != 'msai://home'
                        ? 'Active Page: ${activeTab.title}'
                        : 'Active Page: Home Dashboard',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          // Quick Action Chips Row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                _buildActionChip(
                  icon: Icons.article_rounded,
                  label: 'Summarize Page',
                  onTap: () {
                    aiProvider.summarizeWebPage(
                      webPageTitle: activeTab?.title ?? 'Home',
                      webPageUrl: activeTab?.url ?? 'msai://home',
                      apiKey: settingsProvider.settings.aiApiKey,
                    );
                    _scrollToBottom();
                  },
                ),
                _buildActionChip(
                  icon: Icons.checklist_rounded,
                  label: 'Extract Key Points',
                  onTap: () {
                    aiProvider.extractKeyPoints(
                      webPageTitle: activeTab?.title ?? 'Home',
                      webPageUrl: activeTab?.url ?? 'msai://home',
                      apiKey: settingsProvider.settings.aiApiKey,
                    );
                    _scrollToBottom();
                  },
                ),
                _buildActionChip(
                  icon: Icons.g_translate_rounded,
                  label: 'Translate Page',
                  onTap: () {
                    aiProvider.translateWebPage(
                      webPageTitle: activeTab?.title ?? 'Home',
                      webPageUrl: activeTab?.url ?? 'msai://home',
                      apiKey: settingsProvider.settings.aiApiKey,
                    );
                    _scrollToBottom();
                  },
                ),
                _buildActionChip(
                  icon: Icons.find_in_page_rounded,
                  label: 'Explain Text',
                  onTap: () {
                    aiProvider.explainSelectedText(
                      selectedText: activeTab?.selectedText ?? 'Modern web standards & responsive layouts',
                      webPageTitle: activeTab?.title ?? 'Home',
                      apiKey: settingsProvider.settings.aiApiKey,
                    );
                    _scrollToBottom();
                  },
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Chat Messages Feed
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: aiProvider.messages.length,
              itemBuilder: (context, index) {
                final msg = aiProvider.messages[index];
                return _buildMessageBubble(msg, isDark, theme);
              },
            ),
          ),

          if (aiProvider.isProcessing)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: theme.colorScheme.primary),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'AI is analyzing web page content...',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),

          // Bottom Prompt Input Bar
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              border: Border(top: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0))),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _promptController,
                    onSubmitted: (_) => _sendPrompt(aiProvider, browserProvider, settingsProvider),
                    decoration: InputDecoration(
                      hintText: 'Ask AI about this webpage...',
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: () => _sendPrompt(aiProvider, browserProvider, settingsProvider),
                  icon: const Icon(Icons.send_rounded),
                  style: IconButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionChip({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ActionChip(
        avatar: Icon(icon, size: 16, color: theme.colorScheme.primary),
        label: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        onPressed: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: theme.colorScheme.primary.withOpacity(0.08),
        side: BorderSide.none,
      ),
    );
  }

  Widget _buildMessageBubble(AiMessage msg, bool isDark, ThemeData theme) {
    return Align(
      alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
        decoration: BoxDecoration(
          color: msg.isUser
              ? theme.colorScheme.primary
              : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(msg.isUser ? 16 : 4),
            bottomRight: Radius.circular(msg.isUser ? 4 : 16),
          ),
        ),
        child: SelectableText(
          msg.text,
          style: TextStyle(
            color: msg.isUser
                ? Colors.white
                : (isDark ? Colors.grey[200] : Colors.grey[900]),
            fontSize: 14,
            height: 1.4,
          ),
        ),
      ),
    );
  }
}
