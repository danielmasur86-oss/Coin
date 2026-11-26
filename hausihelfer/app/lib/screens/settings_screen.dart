import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app_state.dart';
import '../config.dart';
import '../l10n/gen/app_localizations.dart';
import '../models/profile.dart';
import '../widgets/labels.dart';
import 'onboarding_screen.dart';
import 'paywall_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static Route<void> route() => MaterialPageRoute(builder: (_) => const SettingsScreen());

  void _open(String path) =>
      launchUrl(Uri.parse('${AppConfig.legalBaseUrl}/$path'), mode: LaunchMode.externalApplication);

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final l = AppLocalizations.of(context);
    final p = state.profile!;

    return Scaffold(
      appBar: AppBar(title: Text(l.settingsTitle)),
      body: ListView(
        children: [
          _Header(l.profileSection),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: Text(supportedLanguages[p.language] ?? p.language),
            subtitle: Text('${bundeslaender[p.bundesland]} · ${schoolTypeLabel(l, p.schoolType)} · ${l.gradeLabel(p.grade)}'),
            trailing: const Icon(Icons.edit_outlined),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const OnboardingScreen(editing: true)),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.workspace_premium_outlined),
            title: Text(state.premium ? l.premiumActive : l.upgrade),
            onTap: state.premium ? null : () => Navigator.of(context).push(PaywallScreen.route()),
          ),
          _Header(l.legalSection),
          ListTile(title: Text(l.imprint), onTap: () => _open('impressum')),
          ListTile(title: Text(l.privacy), onTap: () => _open('datenschutz')),
          ListTile(title: Text(l.terms), onTap: () => _open('agb')),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
        child: Text(text,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Theme.of(context).colorScheme.primary)),
      );
}
