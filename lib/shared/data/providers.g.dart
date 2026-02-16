// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(apiGoalRepository)
const apiGoalRepositoryProvider = ApiGoalRepositoryProvider._();

final class ApiGoalRepositoryProvider
    extends
        $FunctionalProvider<
          ApiGoalRepository,
          ApiGoalRepository,
          ApiGoalRepository
        >
    with $Provider<ApiGoalRepository> {
  const ApiGoalRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'apiGoalRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$apiGoalRepositoryHash();

  @$internal
  @override
  $ProviderElement<ApiGoalRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ApiGoalRepository create(Ref ref) {
    return apiGoalRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ApiGoalRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ApiGoalRepository>(value),
    );
  }
}

String _$apiGoalRepositoryHash() => r'ef6e0d95bfd842355f7bea14ae0bbbc53660f41a';

@ProviderFor(apiStudySessionRepository)
const apiStudySessionRepositoryProvider = ApiStudySessionRepositoryProvider._();

final class ApiStudySessionRepositoryProvider
    extends
        $FunctionalProvider<
          ApiStudySessionRepository,
          ApiStudySessionRepository,
          ApiStudySessionRepository
        >
    with $Provider<ApiStudySessionRepository> {
  const ApiStudySessionRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'apiStudySessionRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$apiStudySessionRepositoryHash();

  @$internal
  @override
  $ProviderElement<ApiStudySessionRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ApiStudySessionRepository create(Ref ref) {
    return apiStudySessionRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ApiStudySessionRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ApiStudySessionRepository>(value),
    );
  }
}

String _$apiStudySessionRepositoryHash() =>
    r'2fd3b43b46f1c8e32208854d7e3dbeb3d5c7aba9';

@ProviderFor(apiDocumentRepository)
const apiDocumentRepositoryProvider = ApiDocumentRepositoryProvider._();

final class ApiDocumentRepositoryProvider
    extends
        $FunctionalProvider<
          ApiDocumentRepository,
          ApiDocumentRepository,
          ApiDocumentRepository
        >
    with $Provider<ApiDocumentRepository> {
  const ApiDocumentRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'apiDocumentRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$apiDocumentRepositoryHash();

  @$internal
  @override
  $ProviderElement<ApiDocumentRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ApiDocumentRepository create(Ref ref) {
    return apiDocumentRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ApiDocumentRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ApiDocumentRepository>(value),
    );
  }
}

String _$apiDocumentRepositoryHash() =>
    r'e5f9e104539dc9063b251764d125b09d35177d30';

@ProviderFor(apiChatRepository)
const apiChatRepositoryProvider = ApiChatRepositoryProvider._();

final class ApiChatRepositoryProvider
    extends
        $FunctionalProvider<
          ApiChatRepository,
          ApiChatRepository,
          ApiChatRepository
        >
    with $Provider<ApiChatRepository> {
  const ApiChatRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'apiChatRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$apiChatRepositoryHash();

  @$internal
  @override
  $ProviderElement<ApiChatRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ApiChatRepository create(Ref ref) {
    return apiChatRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ApiChatRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ApiChatRepository>(value),
    );
  }
}

String _$apiChatRepositoryHash() => r'fb762bd93eaaf4d819d0ba0b9ae238c183dc2685';

@ProviderFor(apiStatsRepository)
const apiStatsRepositoryProvider = ApiStatsRepositoryProvider._();

final class ApiStatsRepositoryProvider
    extends
        $FunctionalProvider<
          ApiStatsRepository,
          ApiStatsRepository,
          ApiStatsRepository
        >
    with $Provider<ApiStatsRepository> {
  const ApiStatsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'apiStatsRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$apiStatsRepositoryHash();

  @$internal
  @override
  $ProviderElement<ApiStatsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ApiStatsRepository create(Ref ref) {
    return apiStatsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ApiStatsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ApiStatsRepository>(value),
    );
  }
}

String _$apiStatsRepositoryHash() =>
    r'ead9e3885045b2ea25ea10e96a8df7c0d383997a';

@ProviderFor(goals)
const goalsProvider = GoalsProvider._();

final class GoalsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Goal>>,
          List<Goal>,
          FutureOr<List<Goal>>
        >
    with $FutureModifier<List<Goal>>, $FutureProvider<List<Goal>> {
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
  $FutureProviderElement<List<Goal>> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<Goal>> create(Ref ref) {
    return goals(ref);
  }
}

String _$goalsHash() => r'f98eb78e69a482461b34f59f0da099f80dfcbb55';

@ProviderFor(documents)
const documentsProvider = DocumentsProvider._();

final class DocumentsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Document>>,
          List<Document>,
          FutureOr<List<Document>>
        >
    with $FutureModifier<List<Document>>, $FutureProvider<List<Document>> {
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
  $FutureProviderElement<List<Document>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Document>> create(Ref ref) {
    return documents(ref);
  }
}

String _$documentsHash() => r'222eafa13c7aee18a28753a842c26e618e6d0d5b';

@ProviderFor(userProgress)
const userProgressProvider = UserProgressProvider._();

final class UserProgressProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<String, dynamic>>,
          Map<String, dynamic>,
          FutureOr<Map<String, dynamic>>
        >
    with
        $FutureModifier<Map<String, dynamic>>,
        $FutureProvider<Map<String, dynamic>> {
  const UserProgressProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userProgressProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userProgressHash();

  @$internal
  @override
  $FutureProviderElement<Map<String, dynamic>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<Map<String, dynamic>> create(Ref ref) {
    return userProgress(ref);
  }
}

String _$userProgressHash() => r'65aa67d8835984e0ed76c80914f37024baca8247';

@ProviderFor(dailyStats)
const dailyStatsProvider = DailyStatsProvider._();

final class DailyStatsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<DailyStats>>,
          List<DailyStats>,
          FutureOr<List<DailyStats>>
        >
    with $FutureModifier<List<DailyStats>>, $FutureProvider<List<DailyStats>> {
  const DailyStatsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dailyStatsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dailyStatsHash();

  @$internal
  @override
  $FutureProviderElement<List<DailyStats>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<DailyStats>> create(Ref ref) {
    return dailyStats(ref);
  }
}

String _$dailyStatsHash() => r'5ad40b64c301b07c3865e598998d84bbfb3cc50a';

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
        isAutoDispose: false,
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

String _$chatMessagesHash() => r'b89ccea6e1b989ec90d5100beebd06656fde9fd9';

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

@ProviderFor(CoachTipMessages)
const coachTipMessagesProvider = CoachTipMessagesProvider._();

final class CoachTipMessagesProvider
    extends $NotifierProvider<CoachTipMessages, List<CoachMessage>> {
  const CoachTipMessagesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'coachTipMessagesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$coachTipMessagesHash();

  @$internal
  @override
  CoachTipMessages create() => CoachTipMessages();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<CoachMessage> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<CoachMessage>>(value),
    );
  }
}

String _$coachTipMessagesHash() => r'ec55018ca2ff534979927773bac1e3f633160a22';

abstract class _$CoachTipMessages extends $Notifier<List<CoachMessage>> {
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

@ProviderFor(UserStatsNotifier)
const userStatsProvider = UserStatsNotifierProvider._();

final class UserStatsNotifierProvider
    extends $NotifierProvider<UserStatsNotifier, UserStats> {
  const UserStatsNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userStatsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userStatsNotifierHash();

  @$internal
  @override
  UserStatsNotifier create() => UserStatsNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UserStats value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UserStats>(value),
    );
  }
}

String _$userStatsNotifierHash() => r'3c654f1827cb5bd9748609c88dd3d6db9ca94822';

abstract class _$UserStatsNotifier extends $Notifier<UserStats> {
  UserStats build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<UserStats, UserStats>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<UserStats, UserStats>,
              UserStats,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
