import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learning_coach/core/constants/app_strings.dart';
import 'package:learning_coach/core/providers/locale_provider.dart';
import 'package:learning_coach/shared/data/providers.dart';
import 'package:learning_coach/shared/models/models.dart';

class DocumentChatScreen extends ConsumerStatefulWidget {
  final Document document;

  const DocumentChatScreen({super.key, required this.document});

  @override
  ConsumerState<DocumentChatScreen> createState() => _DocumentChatScreenState();
}

class _DocumentChatScreenState extends ConsumerState<DocumentChatScreen> {
  final List<CoachMessage> _messages = [];
  final TextEditingController _controller = TextEditingController();
  bool _isSending = false;
  bool _historyLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    if (_historyLoaded) return;
    _historyLoaded = true;

    try {
      final history = await ref
          .read(apiDocumentRepositoryProvider)
          .getDocumentChatHistory(widget.document.id);

      if (!mounted) return;

      if (history.isNotEmpty) {
        setState(() {
          _messages.addAll(history);
        });
        return;
      }
    } catch (_) {
      if (!mounted) return;
    }

    if (mounted) {
      setState(() {
        _messages.add(
          CoachMessage(
            text:
                "Merhaba! '${widget.document.title}' hakkında ne bilmek istersiniz?",
            isUser: false,
          ),
        );
      });
    }
  }

  Future<void> _sendMessage() async {
    if (_controller.text.isEmpty || _isSending) return;

    final text = _controller.text;
    setState(() {
      _isSending = true;
      _messages.add(CoachMessage(text: text, isUser: true));
    });
    _controller.clear();

    try {
      final response = await ref
          .read(apiDocumentRepositoryProvider)
          .chatWithDocument(widget.document.id, text);

      if (!mounted) return;
      setState(() {
        _messages.add(response);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Hata: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final locale = ref.watch(localeProvider);
    final canChat = widget.document.status == DocStatus.ready;

    return Scaffold(
      appBar: AppBar(title: Text(widget.document.title)),
      body: Column(
        children: [
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                return _buildChatBubble(_messages[index]);
              },
            ),
          ),
          if (!canChat)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  AppStrings.getDocProcessingNotice(locale),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ),
          Divider(height: 1, color: scheme.outlineVariant),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: AppStrings.askDocHint,
                    ),
                    enabled: canChat && !_isSending,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: canChat && !_isSending ? _sendMessage : null,
                  icon: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatBubble(CoachMessage message) {
    final scheme = Theme.of(context).colorScheme;
    final isUser = message.isUser;
    final align = isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final bg = isUser
        ? scheme.primaryContainer
        : scheme.surfaceContainerHighest;
    final fg = isUser ? scheme.onPrimaryContainer : scheme.onSurface;

    return Column(
      crossAxisAlignment: align,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(16).copyWith(
              bottomRight: isUser ? Radius.zero : const Radius.circular(16),
              bottomLeft: isUser ? const Radius.circular(16) : Radius.zero,
            ),
          ),
          child: Text(message.text, style: TextStyle(color: fg)),
        ),
        if (!isUser && message.sources != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: ActionChip(
              avatar: const Icon(Icons.source, size: 16),
              label: Text(
                '${AppStrings.sourcesTitle} (${message.sources!.length})',
              ),
              onPressed: () {
                showModalBottomSheet<void>(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) => _SourcesSheet(sources: message.sources!),
                );
              },
            ),
          ),
      ],
    );
  }
}

class _SourcesSheet extends StatelessWidget {
  final List<Source> sources;

  const _SourcesSheet({required this.sources});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final sheetHeight = MediaQuery.of(context).size.height * 0.7;

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(16),
        height: sheetHeight,
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(top: BorderSide(color: scheme.outlineVariant)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.sourcesTitle,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                itemCount: sources.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, index) {
                  final s = sources[index];
                  return Card(
                    elevation: 0,
                    color: scheme.surface,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                s.pageLabel,
                                style: Theme.of(context).textTheme.labelLarge
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                              IconButton(
                                icon: const Icon(Icons.copy, size: 16),
                                onPressed: () {},
                                visualDensity: VisualDensity.compact,
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            s.excerpt,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
