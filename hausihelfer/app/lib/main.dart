import 'package:material_ui/material_ui.dart';

import 'app_state.dart';
import 'l10n/gen/app_localizations.dart';
import 'screens/home_screen.dart';
import 'screens/onboarding_screen.dart';
import 'services/api_client.dart';
import 'services/purchases.dart';
import 'services/storage.dart';

/// App strings plus Material/Cupertino/Widgets strings (from material_ui) for every locale.
const appLocalizationsDelegates = <LocalizationsDelegate<dynamic>>[
  AppLocalizations.delegate,
  ...GlobalMaterialLocalizations.delegates,
];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storage = await Storage.open();
  final purchases = PurchaseService();
  await purchases.init(storage.userId);
  final state = AppState(
    storage: storage,
    api: ApiClient(userId: storage.userId),
    purchases: purchases,
  );
  state.refreshStatus();
  runApp(HausiHelferApp(state: state));
}

class HausiHelferApp extends StatelessWidget {
  const HausiHelferApp({super.key, required this.state});
  final AppState state;

  @override
  Widget build(BuildContext context) {
    return AppScope(
      state: state,
      child: ListenableBuilder(
        listenable: state,
        builder: (context, _) => MaterialApp(
          onGenerateTitle: (c) => AppLocalizations.of(c).appTitle,
          debugShowCheckedModeBanner: false,
          locale: state.locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: appLocalizationsDelegates,
          theme: _theme(Brightness.light),
          darkTheme: _theme(Brightness.dark),
          home: state.profile == null ? const OnboardingScreen() : const HomeScreen(),
        ),
      ),
    );
  }

  ThemeData _theme(Brightness b) {
    final scheme = ColorScheme.fromSeed(seedColor: const Color(0xFF2E7D5B), brightness: b);
    return ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      cardTheme: CardThemeData(
        elevation: 0,
        color: scheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: scheme.outlineVariant),
        ),
      ),
    );
  }
}
