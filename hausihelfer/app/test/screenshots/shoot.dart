import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hausihelfer/app_state.dart';
import 'package:hausihelfer/main.dart';
import 'package:hausihelfer/models/explanation.dart';
import 'package:hausihelfer/models/profile.dart';
import 'package:hausihelfer/screens/result_screen.dart';
import 'package:hausihelfer/services/api_client.dart';
import 'package:hausihelfer/services/purchases.dart';
import 'package:hausihelfer/services/storage.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'sample_data.dart';

/// Store screenshot sizes: iPhone 6.9" (App Store) and a 2:1 phone (Google Play).
const devices = {
  'ios-6.9': (size: Size(1290, 2796), dpr: 3.0),
  'android-phone': (size: Size(1080, 2160), dpr: 2.625),
};

final enabled = Platform.environment.containsKey('FONT_DIR');

Future<void> loadFont(String family, List<String> files) async {
  final loader = FontLoader(family);
  for (final f in files) {
    loader.addFont(Future.value(ByteData.sublistView(File(f).readAsBytesSync())));
  }
  await loader.load();
}

Future<void> loadIcons() async {
  final dir = Platform.environment['FONT_DIR']!;
  await loadFont('MaterialIcons', ['$dir/MaterialIcons-Regular.otf']);
}

Future<AppState> _state(String lang) async {
  final profile = Profile(language: lang, bundesland: 'NW', schoolType: 'grundschule', grade: 4);
  SharedPreferences.setMockInitialValues({'profile': jsonEncode(profile.toJson())});
  final storage = await Storage.open();
  final api = ApiClient(
    userId: storage.userId,
    client: MockClient((_) async => http.Response('{"premium":false,"remainingFree":2,"freePerWeek":3}', 200)),
  );
  final state = AppState(storage: storage, api: api, purchases: PurchaseService());
  await state.refreshStatus();
  final e = Explanation.fromJson(sampleExplanations[lang]!);
  await state.addHistory(HistoryEntry(createdAt: DateTime(2026, 11, 24), subject: 'mathe', mode: 'check', explanation: e));
  await state.addHistory(HistoryEntry(createdAt: DateTime(2026, 11, 26), subject: 'mathe', mode: 'explain', explanation: e));
  return state;
}

/// Renders the home, result and settings-free onboarding screens for one language.
void shootLanguage(String lang) {
  for (final device in devices.entries) {
    final out = '../../../store-assets/screenshots/${device.key}/$lang';

    testWidgets('$lang ${device.key}', (tester) async {
      tester.view.physicalSize = device.value.size;
      tester.view.devicePixelRatio = device.value.dpr;
      addTearDown(tester.view.reset);

      final state = await tester.runAsync(() => _state(lang));
      await tester.pumpWidget(HausiHelferApp(state: state!));
      await tester.pumpAndSettle();
      await expectLater(find.byType(MaterialApp), matchesGoldenFile('$out/1_home.png'));

      final entry = state.history.first;
      Navigator.of(tester.element(find.byType(Scaffold).first)).push(ResultScreen.route(entry));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.arrow_downward));
      await tester.pumpAndSettle();
      await expectLater(find.byType(MaterialApp), matchesGoldenFile('$out/2_explanation.png'));

      await tester.drag(find.byType(ListView), const Offset(0, -900));
      await tester.pumpAndSettle();
      await expectLater(find.byType(MaterialApp), matchesGoldenFile('$out/3_words.png'));
    }, skip: !enabled);
  }
}
