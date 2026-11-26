// Generates store screenshots (not a normal test; skipped unless FONT_DIR is set).
//   FONT_DIR=<flutter>/bin/cache/artifacts/material_fonts \
//   flutter test --update-goldens test/screenshots
@Tags(['screenshots'])
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'shoot.dart';

void main() {
  setUpAll(() async {
    if (!enabled) return;
    final dir = Platform.environment['FONT_DIR']!;
    await loadFont('Roboto', ['$dir/Roboto-Regular.ttf', '$dir/Roboto-Medium.ttf', '$dir/Roboto-Bold.ttf']);
    await loadIcons();
  });
  for (final lang in ['de', 'pl', 'en', 'tr', 'uk', 'ru']) {
    shootLanguage(lang);
  }
}
