// Arabic store screenshots. Roboto has no Arabic letters, so this file (its own process)
// renders with an Arabic-capable font set in ARABIC_FONT (e.g. DejaVuSans.ttf).
@Tags(['screenshots'])
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'shoot.dart';

void main() {
  setUpAll(() async {
    if (!enabled) return;
    await loadFont('Roboto', [Platform.environment['ARABIC_FONT'] ?? '/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf']);
    await loadIcons();
  });
  shootLanguage('ar');
}
