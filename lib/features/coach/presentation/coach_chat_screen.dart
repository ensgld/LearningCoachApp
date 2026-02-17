import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learning_coach/core/constants/app_strings.dart';
import 'package:learning_coach/shared/data/providers.dart';
import 'package:learning_coach/shared/models/models.dart';

class CoachChatScreen extends ConsumerStatefulWidget {
  final String? initialPrompt;

  const CoachChatScreen({super.key, this.initialPrompt});

  @override
  ConsumerState<CoachChatScreen> createState() => _CoachChatScreenState();
}

class _CoachChatScreenState extends ConsumerState<CoachChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // 1. Loading durumunu tutan değişken
  bool _isLoading = false;

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
    // Check if the last message is already this prompt (deduplication)
    final messages = ref.read(coachTipMessagesProvider);
    if (messages.isNotEmpty) {
      final lastUserMessage = messages.lastWhere(
        (m) => m.isUser,
        orElse: () =>
            CoachMessage(text: '', isUser: true, timestamp: DateTime(0)),
      );
      if (lastUserMessage.text == text) {
        // Already sent, just scroll to bottom
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.jumpTo(
              _scrollController.position.maxScrollExtent,
            );
          }
        });
        return;
      }
    }

    setState(() => _isLoading = true);
    try {
      await ref.read(coachTipMessagesProvider.notifier).sendMessage(text);
      // Scroll to bottom after delay
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // 2. Fonksiyonu güncelle: async/await ve loading kontrolü
  Future<void> _handleSend() async {
    final text = _textController.text;

    // Eğer boşsa veya zaten yükleniyorsa işlem yapma
    if (text.trim().isEmpty || _isLoading) return;

    // Loading'i başlat ve klavyeyi kapatma (isteğe bağlı)
    setState(() {
      _isLoading = true;
    });

    try {
      // Mesajı gönder ve cevabı bekle
      // (Provider'daki sendMessage fonksiyonunun Future<void> döndürdüğünden emin ol)
      await ref.read(coachTipMessagesProvider.notifier).sendMessage(text);

      // Mesaj gittikten sonra text alanını temizle
      if (mounted) {
        _textController.clear();
      }

      // En aşağı kaydır
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (e) {
      // Hata olursa kullanıcıya snackbar ile gösterilebilir
      debugPrint('Hata: $e');
    } finally {
      // İşlem bitince (başarılı veya hatalı) loading'i kapat
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(coachTipMessagesProvider);
    final scheme = Theme.of(context).colorScheme;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark, // iOS
        systemNavigationBarColor: scheme.surface,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: scheme.surface,
        body: Column(
          children: [
            // --- HEADER KISMI ---
            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(
                24,
                MediaQuery.of(context).padding.top + 16,
                16,
                16,
              ),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6366F1).withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                    spreadRadius: -4,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.psychology_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.coachChatTitle,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: -0.5,
                              ),
                        ),
                        Text(
                          'AI öğrenme asistanı',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // --- CHAT LISTESI ---
            Expanded(
              child: messages.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  scheme.primaryContainer.withValues(
                                    alpha: 0.3,
                                  ),
                                  scheme.secondaryContainer.withValues(
                                    alpha: 0.3,
                                  ),
                                ],
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.chat_bubble_outline_rounded,
                              size: 48,
                              color: scheme.primary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Merhaba! Size nasıl yardımcı olabilirim?',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(20),
                      itemCount: messages.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final msg = messages[index];
                        return _ChatBubble(message: msg);
                      },
                    ),
            ),

            // --- INPUT ALANI ---
            Container(
              padding: EdgeInsets.fromLTRB(
                16,
                16,
                16,
                MediaQuery.of(context).padding.bottom + 16,
              ),
              decoration: BoxDecoration(
                color: scheme.surface,
                border: Border(
                  top: BorderSide(
                    color: scheme.outlineVariant.withValues(alpha: 0.3),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: scheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextField(
                        controller: _textController,
                        onSubmitted: _isLoading ? null : (_) => _handleSend(),
                        enabled: !_isLoading,
                        decoration: const InputDecoration(
                          hintText: AppStrings.askCoachHint,
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: _isLoading
                            ? [Colors.grey.shade400, Colors.grey.shade500]
                            : [
                                const Color(0xFF6366F1),
                                const Color(0xFF8B5CF6),
                              ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color:
                              (_isLoading
                                      ? Colors.grey
                                      : const Color(0xFF6366F1))
                                  .withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: IconButton(
                      onPressed: _isLoading ? null : _handleSend,
                      icon: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.send_rounded, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final CoachMessage message;

  const _ChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isUser = message.isUser;
    final align = isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start;

    return Column(
      crossAxisAlignment: align,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            gradient: isUser
                ? const LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: isUser ? null : scheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(20).copyWith(
              bottomRight: isUser ? Radius.zero : const Radius.circular(20),
              bottomLeft: isUser ? const Radius.circular(20) : Radius.zero,
            ),
            boxShadow: [
              BoxShadow(
                color: isUser
                    ? const Color(0xFF6366F1).withValues(alpha: 0.2)
                    : Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            message.text,
            style: TextStyle(
              color: isUser ? Colors.white : scheme.onSurface,
              fontSize: 15,
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        // Eğer backend kaynak dönerse burası çalışır
        if (!isUser && message.sources != null && message.sources!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Container(
              // ... Sources UI kısmı (orijinal koddaki gibi) ...
            ),
          ),
      ],
    );
  }
}
