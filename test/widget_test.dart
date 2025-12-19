import 'package:flutter_test/flutter_test.dart';
import 'package:learning_coach/shared/data/mock_data_repository.dart';
import 'package:learning_coach/shared/models/models.dart';

void main() {
  group('Mock Data Repository Tests', () {
    test('Goals data is not empty', () {
      expect(MockDataRepository.goals, isNotEmpty);
      expect(MockDataRepository.goals.length, greaterThan(0));
    });

    test('Documents data is not empty', () {
      expect(MockDataRepository.documents, isNotEmpty);
      expect(MockDataRepository.documents.length, greaterThan(0));
    });

    test('Goal model has correct structure', () {
      final goal = MockDataRepository.goals.first;
      expect(goal.title, isNotEmpty);
      expect(goal.description, isNotEmpty);
      expect(goal.progress, isA<double>());
      expect(goal.progress, greaterThanOrEqualTo(0.0));
      expect(goal.progress, lessThanOrEqualTo(1.0));
    });

    test('Document model has correct structure', () {
      final doc = MockDataRepository.documents.first;
      expect(doc.title, isNotEmpty);
      expect(doc.status, isA<DocStatus>());
      expect(doc.uploadedAt, isA<DateTime>());
    });

    test('Initial chat messages exist', () {
      expect(MockDataRepository.initialChat, isNotEmpty);
      final message = MockDataRepository.initialChat.first;
      expect(message.text, isNotEmpty);
      expect(message.isUser, isFalse); // First message is from coach
    });
  });
}
