import 'package:learning_coach/shared/models/models.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'study_controller.g.dart';

@Riverpod(keepAlive: true)
class StudyController extends _$StudyController {
  @override
  StudySession? build() {
    return null;
  }

  void startSession(String goalId, String goalTitle, int durationMinutes) {
    state = StudySession(
      goalId: goalId,
      durationMinutes: durationMinutes,
      startTime: DateTime.now(),
      questions: _generateMockQuestions(goalTitle),
      selectedAnswers: {},
    );
  }

  void finishSession(int actualSeconds) {
    if (state == null) return;
    state = state!.copyWith(actualDurationSeconds: actualSeconds);
  }

  void selectAnswer(String questionId, int optionIndex) {
    if (state == null) return;
    final updatedAnswers = Map<String, int>.from(state!.selectedAnswers ?? {});
    updatedAnswers[questionId] = optionIndex;
    state = state!.copyWith(selectedAnswers: updatedAnswers);
  }

  void calculateScore() {
    if (state == null || state!.questions == null) return;
    
    int correctCount = 0;
    final answers = state!.selectedAnswers ?? {};
    
    for (var question in state!.questions!) {
      if (answers[question.id] == question.correctOptionIndex) {
        correctCount++;
      }
    }
    
    final score = (correctCount / state!.questions!.length * 100).round();
    state = state!.copyWith(quizScore: score);
  }

  List<QuizQuestion> _generateMockQuestions(String goalTitle) {
    final title = goalTitle.toLowerCase();
    if (title.contains('flutter')) {
      return [
        QuizQuestion(
          question: "Flutter'da 'State' neyi temsil eder?",
          options: [
            'Uygulamanın o anki durumu',
            "Bir widget'ın rengi",
            'Veritabanı bağlantısı',
            'Sadece ağ istekleri'
          ],
          correctOptionIndex: 0,
        ),
        QuizQuestion(
          question: "Riverpod'da durum değiştiğinde widget'ı yeniden oluşturan nedir?",
          options: [
            'setState()',
            'ref.watch()',
            'ref.read()',
            'Provider.of()'
          ],
          correctOptionIndex: 1,
        ),
        QuizQuestion(
          question: "Hot Reload ve Hot Restart arasındaki fark nedir?",
          options: [
            'Fark yoktur',
            'Reload durum korur, Restart sıfırlar',
            'Restart durum korur, Reload sıfırlar',
            'Reload sadece webde çalışır'
          ],
          correctOptionIndex: 1,
        ),
      ];
    } else if (title.contains('ingilizce') || title.contains('english')) {
      return [
        QuizQuestion(
          question: "'Ubiquitous' kelimesinin Türkçe karşılığı nedir?",
          options: [
            'Nadir bulunan',
            'Her yerde bulunan',
            'Hızlı hareket eden',
            'Karmaşık olan'
          ],
          correctOptionIndex: 1,
        ),
        QuizQuestion(
          question: "Aşağıdakilerden hangisi 'Mitigate' kelimesinin eş anlamlısıdır?",
          options: [
            'Hızlandırmak',
            'Azaltmak/Hafifletmek',
            'Ağırlaştırmak',
            'Görmezden gelmek'
          ],
          correctOptionIndex: 1,
        ),
        QuizQuestion(
          question: "'Incentive' kelimesinin anlamı nedir?",
          options: [
            'Teşvik/Güdü',
            'Engel',
            'Ceza',
            'Sonuç'
          ],
          correctOptionIndex: 0,
        ),
      ];
    } else if (title.contains('algoritma') || title.contains('algorithm')) {
      return [
        QuizQuestion(
          question: "Binary Search algoritmasının zaman karmaşıklığı (Time Complexity) nedir?",
          options: [
            'O(n)',
            'O(n log n)',
            'O(log n)',
            'O(1)'
          ],
          correctOptionIndex: 2,
        ),
        QuizQuestion(
          question: "Hangisi 'Stable' (Kararlı) bir sıralama algoritmasıdır?",
          options: [
            'Quick Sort',
            'Heap Sort',
            'Merge Sort',
            'Selection Sort'
          ],
          correctOptionIndex: 2,
        ),
        QuizQuestion(
          question: "Hangi veri yapısı LIFO (Last In First Out) prensibiyle çalışır?",
          options: [
            'Queue',
            'Stack',
            'Linked List',
            'Tree'
          ],
          correctOptionIndex: 1,
        ),
      ];
    }
    
    return [
      QuizQuestion(
        question: "Çalıştığın konu hakkında hangisi doğrudur?",
        options: ['Çok önemli', 'Daha iyi olabilir', 'Harika gidiyor', 'Biraz zor'],
        correctOptionIndex: 2,
      ),
      QuizQuestion(
        question: "Öğrenme sürecinde en önemli faktör nedir?",
        options: ['Hız', 'Süreklilik', 'Sadece video izlemek', 'Sadece okumak'],
        correctOptionIndex: 1,
      ),
    ];
  }
}
