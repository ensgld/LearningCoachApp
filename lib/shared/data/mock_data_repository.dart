import 'package:learning_coach/shared/models/models.dart';

class MockDataRepository {
  // Goals
  static final List<Goal> goals = [
    Goal(
      title: 'Flutter İleri Seviye Öğrenme',
      description: 'Clean Architecture ve Riverpod ile derinleşme',
      progress: 0.45,
      tasks: [
        GoalTask(title: 'Riverpod 2.0 dokümanlarını oku', isCompleted: true),
        GoalTask(title: 'GoRouter deep linking pratik yap', isCompleted: true),
        GoalTask(title: 'Unit test yazımı öğren', isCompleted: false),
      ],
    ),
    Goal(
      title: 'İngilizce Kelime Çalışması',
      description: 'Her gün 20 yeni akademik kelime',
      progress: 0.20,
      tasks: [
        GoalTask(title: 'Flashcards set 1', isCompleted: true),
        GoalTask(title: 'Flashcards set 2', isCompleted: false),
      ],
    ),
    Goal(
      title: 'Algoritma Analizi',
      description: 'Big O notation ve sorting algoritmaları',
      progress: 0.10,
      tasks: [
        GoalTask(title: 'Bubble Sort implementasyonu', isCompleted: false),
        GoalTask(title: 'Merge Sort analizi', isCompleted: false),
      ],
    ),
  ];

  // Documents
  static final List<Document> documents = [
    Document(
      title: 'Flutter_Architecture_Guide.pdf',
      summary:
          'Flutter uygulamalarında Clean Architecture kullanımı, katmanların ayrılması ve bağımlılık yönetimi hakkında detaylı rehber.',
      status: DocStatus.ready,
      uploadedAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    Document(
      title: 'Ders_Notlari_Vize.pdf',
      summary:
          'Vize konuları özet: Matematik, Fizik ve Lineer Cebir formülleri.',
      status: DocStatus.ready,
      uploadedAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    Document(
      title: 'Proje_Gereksinimleri_v2.docx',
      summary:
          'Bitirme projesi için güncel gereksinim listesi ve teslim tarihleri.',
      status: DocStatus.processing,
      processingProgress: 0.42,
      uploadedAt: DateTime.now().subtract(const Duration(minutes: 10)),
    ),
    Document(
      title: 'Hatali_Dosya.txt',
      summary: '',
      status: DocStatus.failed,
      uploadedAt: DateTime.now().subtract(const Duration(hours: 1)),
    ),
  ];

  // Chat
  static final List<CoachMessage> initialChat = [
    CoachMessage(
      text:
          'Merhaba! Bugün çalışma planın nasıl gidiyor? Yardımcı olabileceğim bir konu var mı?',
      isUser: false,
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
    ),
  ];

  static final List<Source> mockSources = [
    const Source(
      docTitle: 'Flutter_Architecture_Guide.pdf',
      excerpt:
          'Data layer should implement repositories defined in the domain layer to invert dependencies.',
      pageLabel: 'Sayfa 12',
    ),
    const Source(
      docTitle: 'Flutter_Architecture_Guide.pdf',
      excerpt:
          'Use UseCases to encapsulate business logic for specific features.',
      pageLabel: 'Sayfa 14',
    ),
  ];
}
