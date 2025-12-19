// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(goals)
const goalsProvider = GoalsProvider._();

final class GoalsProvider
    extends $FunctionalProvider<List<Goal>, List<Goal>, List<Goal>>
    with $Provider<List<Goal>> {
  const GoalsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'goalsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$goalsHash();

  @$internal
  @override
  $ProviderElement<List<Goal>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<Goal> create(Ref ref) {
    return goals(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Goal> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<Goal>>(value),
    );
  }
}

String _$goalsHash() => r'b7c490db673a14b8cc6b8f5c742402e4cd509656';

@ProviderFor(documents)
const documentsProvider = DocumentsProvider._();

final class DocumentsProvider
    extends $FunctionalProvider<List<Document>, List<Document>, List<Document>>
    with $Provider<List<Document>> {
  const DocumentsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'documentsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$documentsHash();

  @$internal
  @override
  $ProviderElement<List<Document>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<Document> create(Ref ref) {
    return documents(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Document> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<Document>>(value),
    );
  }
}

String _$documentsHash() => r'ba6c5d681432a3a917adec0d98e5f1842eb5a09f';

@ProviderFor(ChatMessages)
const chatMessagesProvider = ChatMessagesProvider._();

final class ChatMessagesProvider
    extends $NotifierProvider<ChatMessages, List<CoachMessage>> {
  const ChatMessagesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'chatMessagesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$chatMessagesHash();

  @$internal
  @override
  ChatMessages create() => ChatMessages();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<CoachMessage> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<CoachMessage>>(value),
    );
  }
}

String _$chatMessagesHash() => r'caddb75e427cd7a9ac6790126879081d69875a57';

abstract class _$ChatMessages extends $Notifier<List<CoachMessage>> {
  List<CoachMessage> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<List<CoachMessage>, List<CoachMessage>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<CoachMessage>, List<CoachMessage>>,
              List<CoachMessage>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
