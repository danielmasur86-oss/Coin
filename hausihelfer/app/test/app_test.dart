import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:hausihelfer/app_state.dart';
import 'package:hausihelfer/l10n/gen/app_localizations.dart';
import 'package:hausihelfer/main.dart';
import 'package:hausihelfer/models/explanation.dart';
import 'package:hausihelfer/models/profile.dart';
import 'package:hausihelfer/screens/result_screen.dart';
import 'package:hausihelfer/screens/settings_screen.dart';
import 'package:hausihelfer/services/api_client.dart';
import 'package:hausihelfer/services/purchases.dart';
import 'package:hausihelfer/services/storage.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Example answer in the shape the backend returns (parent language: Polish).
final sampleJson = {
  'readable': true,
  'task_original_de': 'Rechne schriftlich: 456 : 3',
  'task_translation': 'Policz pisemnie: 456 podzielić przez 3.',
  'topic': 'Dzielenie pisemne',
  'topic_de': 'Schriftliche Division',
  'how_to_explain': 'Dzielimy od lewej, cyfra po cyfrze.',
  'steps': [
    {
      'parent_hint': 'Zacznij od pierwszej cyfry: 4.',
      'ask_child_de': 'Wie oft passt die 3 in die 4?',
      'ask_child_translation': 'Ile razy 3 mieści się w 4?',
    },
    {
      'parent_hint': 'Zapisz resztę i dopisz następną cyfrę.',
      'ask_child_de': 'Welche Zahl schreibst du jetzt herunter?',
      'ask_child_translation': 'Jaką liczbę teraz przepisujesz w dół?',
    },
  ],
  'german_vocabulary': [
    {'de': 'der Rest', 'translation': 'reszta'},
  ],
  'solution': '456 : 3 = 152',
  'check': {'is_correct': null, 'feedback': ''},
  'confidence': 'high',
};

Future<AppState> makeState({Profile? profile}) async {
  SharedPreferences.setMockInitialValues(
    profile == null ? {} : {'profile': jsonEncode(profile.toJson())},
  );
  final storage = await Storage.open();
  final api = ApiClient(
    userId: storage.userId,
    client: MockClient((req) async => http.Response(
          jsonEncode({'premium': false, 'remainingFree': 3, 'freePerWeek': 3}),
          200,
        )),
  );
  return AppState(storage: storage, api: api, purchases: PurchaseService());
}

void main() {
  test('Explanation survives a JSON round trip', () {
    final e = Explanation.fromJson(sampleJson);
    final again = Explanation.fromJson(jsonDecode(jsonEncode(e.toJson())) as Map<String, dynamic>);
    expect(again.steps.length, 2);
    expect(again.steps.first.askChildDe, 'Wie oft passt die 3 in die 4?');
    expect(again.isCorrect, isNull);
    expect(again.vocabulary.single.translation, 'reszta');
  });

  test('every language has all strings', () {
    expect(AppLocalizations.supportedLocales.map((l) => l.languageCode).toSet(),
        supportedLanguages.keys.toSet());
  });

  testWidgets('first launch shows onboarding', (tester) async {
    final state = await makeState();
    await tester.pumpWidget(HausiHelferApp(state: state));
    await tester.pumpAndSettle();
    expect(find.byType(DropdownButtonFormField<String>), findsNWidgets(3));
    expect(find.byType(FilledButton), findsOneWidget);
  });

  testWidgets('home screen in Polish shows the free quota', (tester) async {
    final state = await makeState(
      profile: const Profile(language: 'pl', bundesland: 'NW', schoolType: 'grundschule', grade: 3),
    );
    await state.refreshStatus();
    await tester.pumpWidget(HausiHelferApp(state: state));
    await tester.pumpAndSettle();
    expect(find.text('Zrób zdjęcie'), findsOneWidget);
    expect(find.text('Zostały 3 darmowe zadania w tym tygodniu'), findsOneWidget);
  });

  testWidgets('result screen reveals steps one by one and hides the solution', (tester) async {
    // Tall phone-like viewport so the whole result fits without scrolling.
    tester.view.physicalSize = const Size(1170, 4000);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final entry = HistoryEntry(
      createdAt: DateTime(2026, 11, 26),
      subject: 'mathe',
      mode: 'explain',
      explanation: Explanation.fromJson(sampleJson),
    );
    await tester.pumpWidget(MaterialApp(
      locale: const Locale('pl'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: appLocalizationsDelegates,
      home: ResultScreen(entry: entry),
    ));
    await tester.pumpAndSettle();

    final solutionText =
        find.byWidgetPredicate((w) => w is SelectableText && w.data == '456 : 3 = 152');
    expect(find.text('Krok 1'), findsOneWidget);
    expect(find.text('Krok 2'), findsNothing);
    expect(solutionText, findsNothing);

    await tester.tap(find.text('Pokaż następny krok'));
    await tester.pumpAndSettle();
    expect(find.text('Krok 2'), findsOneWidget);

    final showSolution = find.widgetWithText(FilledButton, 'Pokaż rozwiązanie (tylko dla Ciebie)');
    await tester.tap(showSolution);
    await tester.pumpAndSettle();
    expect(solutionText, findsOneWidget);
  });

  testWidgets('Arabic layout is right-to-left', (tester) async {
    final state = await makeState(
      profile: const Profile(language: 'ar', bundesland: 'BE', schoolType: 'gymnasium', grade: 7),
    );
    await tester.pumpWidget(HausiHelferApp(state: state));
    await tester.pumpAndSettle();
    final ctx = tester.element(find.text('التقط صورة'));
    expect(Directionality.of(ctx), TextDirection.rtl);
  });

  test('API maps 429 daily limit and 402 free limit to the right errors', () async {
    Future<ApiErrorKind?> kindFor(int status, String body) async {
      final api = ApiClient(userId: 'test-user-123', client: MockClient((_) async => http.Response(body, status)));
      try {
        await api.quota();
        return null;
      } on ApiException catch (e) {
        return e.kind;
      }
    }

    expect(await kindFor(429, '{"error":"daily_limit_reached"}'), ApiErrorKind.dailyLimit);
    expect(await kindFor(429, '{"error":"too_many_requests"}'), ApiErrorKind.busy);
    expect(await kindFor(402, '{"error":"free_limit_reached"}'), ApiErrorKind.limitReached);
    expect(await kindFor(500, '{}'), ApiErrorKind.generic);
  });

  testWidgets('"Delete my data" clears history and returns to onboarding', (tester) async {
    tester.view.physicalSize = const Size(1170, 4000);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final state = await makeState(
      profile: const Profile(language: 'en', bundesland: 'BY', schoolType: 'grundschule', grade: 2),
    );
    await state.addHistory(HistoryEntry(
      createdAt: DateTime(2026, 11, 26),
      subject: 'mathe',
      mode: 'explain',
      explanation: Explanation.fromJson(sampleJson),
    ));
    await tester.pumpWidget(HausiHelferApp(state: state));
    await tester.pumpAndSettle();
    expect(find.text('Dzielenie pisemne'), findsOneWidget); // history entry

    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();
    expect(find.byType(SettingsScreen), findsOneWidget);
    await tester.tap(find.text('Delete my data'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
    await tester.pumpAndSettle();

    expect(state.profile, isNull);
    expect(state.history, isEmpty);
    expect(find.byType(DropdownButtonFormField<String>), findsNWidgets(3)); // onboarding again
  });

  testWidgets('"Report a mistake" sends the task and comment to the backend', (tester) async {
    tester.view.physicalSize = const Size(1170, 4000);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    Map<String, dynamic>? sent;
    SharedPreferences.setMockInitialValues({});
    final storage = await Storage.open();
    final api = ApiClient(
      userId: storage.userId,
      client: MockClient((req) async {
        if (req.url.path == '/v1/feedback') sent = jsonDecode(req.body) as Map<String, dynamic>;
        return http.Response('{"ok":true}', 200);
      }),
    );
    final state = AppState(storage: storage, api: api, purchases: PurchaseService());
    final entry = HistoryEntry(
      createdAt: DateTime(2026, 11, 26),
      subject: 'mathe',
      mode: 'explain',
      explanation: Explanation.fromJson(sampleJson),
    );
    await tester.pumpWidget(AppScope(
      state: state,
      child: MaterialApp(
        localizationsDelegates: appLocalizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: ResultScreen(entry: entry),
      ),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Report a mistake'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Wrong result');
    await tester.tap(find.widgetWithText(FilledButton, 'Send'));
    await tester.pumpAndSettle();

    expect(sent?['comment'], 'Wrong result');
    expect(sent?['taskDe'], 'Rechne schriftlich: 456 : 3');
    expect(find.text('Thank you! We will look at it.'), findsOneWidget);
  });
}
