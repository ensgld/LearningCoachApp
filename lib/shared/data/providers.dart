import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:learning_coach/shared/data/mock_data_repository.dart';
import 'package:learning_coach/shared/models/models.dart';

part 'providers.g.dart';

// Goals
@riverpod
List<Goal> goals(Ref ref) {
  return MockDataRepository.goals;
}

// Documents
@riverpod
List<Document> documents(Ref ref) {
  return MockDataRepository.documents;
}

// Chat
@riverpod
class ChatMessages extends _$ChatMessages {
  @override
  List<CoachMessage> build() {
    return List.from(MockDataRepository.initialChat);
  }

  void addMessage(CoachMessage message) {
    state = [...state, message];
  }
}
