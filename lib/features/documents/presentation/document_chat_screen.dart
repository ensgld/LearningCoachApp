import 'package:flutter/material.dart';
import 'package:learning_coach/core/constants/app_strings.dart';
import 'package:learning_coach/shared/models/models.dart';

class DocumentChatScreen extends StatefulWidget {
  final Document document;

  const DocumentChatScreen({super.key, required this.document});

  @override
  State<DocumentChatScreen> createState() => _DocumentChatScreenState();
}

class _DocumentChatScreenState extends State<DocumentChatScreen> {
  final List<CoachMessage> _messages = [];
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initial greeting
    _messages.add(
      CoachMessage(
        text:
            "Merhaba! '${widget.document.title}' hakkında ne bilmek istersiniz?",
        isUser: false,
      ),
    );
  }

  void _sendMessage() {
    if (_controller.text.isEmpty) return;

    final text = _controller.text;
    setState(() {
      _messages.add(CoachMessage(text: text, isUser: true));
    });
    _controller.clear();

    // Mock response with delay
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _messages.add(
            CoachMessage(
              text:
                  'Bu konuda dokümanda şunlar geçiyor: Clean Architecture, bağımlılıkları dışarıdan içeriye doğru düzenler...',
              isUser: false,
              sources: const [
                Source(
                  docTitle: 'Flutter_Architecture.pdf',
                  excerpt: 'Excerpt text 1...',
                  pageLabel: 'p. 10',
                ),
                Source(
                  docTitle: 'Flutter_Architecture.pdf',
                  excerpt: 'Excerpt text 2...',
                  pageLabel: 'p. 12',
                ),
              ],
            ),
          );
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
          Divider(height: 1, color: Colors.grey.shade300),
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
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _sendMessage,
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
    final isUser = message.isUser;
    final align = isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final bg = isUser
        ? Theme.of(context).colorScheme.primaryContainer
        : Colors.grey.shade200;

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
          child: Text(message.text),
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.sourcesTitle,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          ...sources.map(
            (s) => Card(
              elevation: 0,
              color: Colors.grey.shade50,
              shape: RoundedRectangleBorder(
                side: BorderSide(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
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
                          style: const TextStyle(fontWeight: FontWeight.bold),
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
            ),
          ),
        ],
      ),
    );
  }
}
