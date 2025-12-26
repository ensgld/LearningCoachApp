// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'study_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(StudyController)
const studyControllerProvider = StudyControllerProvider._();

final class StudyControllerProvider
    extends $NotifierProvider<StudyController, StudySession?> {
  const StudyControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'studyControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$studyControllerHash();

  @$internal
  @override
  StudyController create() => StudyController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(StudySession? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<StudySession?>(value),
    );
  }
}

String _$studyControllerHash() => r'82decf2fb1b88424966cf0e18eaf971ce4ab45f5';

abstract class _$StudyController extends $Notifier<StudySession?> {
  StudySession? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<StudySession?, StudySession?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<StudySession?, StudySession?>,
              StudySession?,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
