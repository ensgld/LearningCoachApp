import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'locale_provider.g.dart';

@Riverpod(keepAlive: true)
class Locale extends _$Locale {
  @override
  String build() => 'tr';

  void toggle() {
    state = state == 'tr' ? 'en' : 'tr';
  }
}
