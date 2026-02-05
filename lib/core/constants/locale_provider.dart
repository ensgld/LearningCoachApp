import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'locale_provider.g.dart';

@Riverpod(keepAlive: true)
class LocaleNotifier extends _$LocaleNotifier {
  @override
  Locale build() {
    return const Locale('tr', 'TR'); // Default Turkish
  }

  void setLocale(Locale locale) {
    state = locale;
  }

  void toggleLanguage() {
    if (state.languageCode == 'tr') {
      state = const Locale('en', 'US');
    } else {
      state = const Locale('tr', 'TR');
    }
  }
}
