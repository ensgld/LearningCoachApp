import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learning_coach/core/constants/app_strings.dart';
import 'package:learning_coach/core/providers/locale_provider.dart';
import 'package:learning_coach/shared/data/providers.dart';
import 'package:learning_coach/shared/models/models.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String? initialPrompt;

  const ChatScreen({super.key, this.initialPrompt});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialPrompt != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _sendInitialMessage(widget.initialPrompt!);
      });
    }
  }

  Future<void> _sendInitialMessage(String text) async {
    setState(() => _isSending = true);
    try {
      // Add user message first (optional, maybe we don't want to show the long prompt?)
      // For now let's show it so user knows context is sent.
      // Alternatively, we could send it as a "system" message or just directly call provider.
      await ref.read(chatMessagesProvider.notifier).sendMessage(text);
      Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _isSending) return;

    _controller.clear();
    setState(() => _isSending = true);

    try {
      await ref.read(chatMessagesProvider.notifier).sendMessage(text);
      // Wait a bit for list to update then scroll
      Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(chatMessagesProvider);
    final locale = ref.watch(localeProvider);
    final scheme = Theme.of(context).colorScheme;

    final topPadding = MediaQuery.of(context).viewPadding.top;
    final safeTop = topPadding > 0 ? topPadding : 44.0;

    // Auto-scroll on new messages
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    return Scaffold(
      body: Column(
        children: [
          SizedBox(height: safeTop),
          // Custom Header
          Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      'AI Koç',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                ),
                const SizedBox(width: 48), // Balance for left icon
              ],
            ),
          ),
          Expanded(
            child: messages.isEmpty
                ? Center(
                    child: Text(
                      'Henüz mesaj yok. Merhaba de!',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final msg = messages[index];
                      return _buildChatBubble(context, msg);
                    },
                  ),
          ),
          Divider(height: 1, color: scheme.outlineVariant),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                if (messages.isEmpty)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 0),
                    child: Row(
                      children: [
                        _buildQuickPrompt(
                          context,
                          AppStrings.getCreatePlan(locale),
                        ),
                        const SizedBox(width: 8),
                        _buildQuickPrompt(
                          context,
                          AppStrings.getGenerateQuiz(locale),
                        ),
                        const SizedBox(width: 8),
                        _buildQuickPrompt(
                          context,
                          AppStrings.getStruggledToday(locale),
                        ),
                        const SizedBox(width: 8),
                        _buildQuickPrompt(
                          context,
                          AppStrings.getMotivateMe(locale),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: InputDecoration(
                          hintText: AppStrings.getAskCoachHint(locale),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: scheme.surfaceContainerHighest.withValues(alpha: 
                            0.5,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                        ),
                        enabled: !_isSending,
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filled(
                      onPressed: _isSending ? null : _sendMessage,
                      icon: _isSending
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.send),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickPrompt(BuildContext context, String text) {
    return ActionChip(
      label: Text(text),
      onPressed: () {
        _controller.text = text;
        _sendMessage();
      },
    );
  }

  Widget _buildChatBubble(BuildContext context, CoachMessage message) {
    final scheme = Theme.of(context).colorScheme;
    final isUser = message.isUser;
    final align = isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final bg = isUser
        ? scheme.primaryContainer
        : scheme.surfaceContainerHighest;
    final fg = isUser ? scheme.onPrimaryContainer : scheme.onSurface;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: align,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(20).copyWith(
                bottomRight: isUser ? Radius.zero : const Radius.circular(20),
                bottomLeft: isUser ? const Radius.circular(20) : Radius.zero,
              ),
            ),
            child: Text(
              message.text,
              style: TextStyle(color: fg, fontSize: 15),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _formatTime(message.timestamp),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: scheme.outline,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
