import 'dart:io';

import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app_state.dart';
import '../config.dart';
import '../l10n/gen/app_localizations.dart';
import '../models/profile.dart';
import '../widgets/labels.dart';
import 'onboarding_screen.dart';
import 'paywall_screen.dart';

void openLegalPage(String path) =>
    launchUrl(Uri.parse('${AppConfig.legalBaseUrl}/$path'), mode: LaunchMode.externalApplication);

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static Route<void> route() => MaterialPageRoute(builder: (_) => const SettingsScreen());

  Future<void> _deleteData(BuildContext context) async {
    final state = AppScope.of(context);
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(l.deleteData),
        content: Text(l.deleteDataConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: Text(l.cancel)),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Theme.of(c).colorScheme.error),
            onPressed: () => Navigator.pop(c, true),
            child: Text(l.delete),
          ),
        ],
      ),
    );
    if (ok != true) return;
    navigator.popUntil((r) => r.isFirst);
    await state.deleteLocalData(); // the app returns to the first-launch screen
    messenger.showSnackBar(SnackBar(content: Text(l.deleteDataDone)));
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final l = AppLocalizations.of(context);
    final p = state.profile;
    if (p == null) return const SizedBox.shrink();

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
          if (state.premium)
            ListTile(
              leading: const Icon(Icons.workspace_premium_outlined),
              title: Text(l.manageSubscription),
              subtitle: Text(l.premiumActive),
              onTap: () => launchUrl(
                Uri.parse(Platform.isIOS ? AppConfig.manageSubscriptionIos : AppConfig.manageSubscriptionAndroid),
                mode: LaunchMode.externalApplication,
              ),
            )
          else
            ListTile(
              leading: const Icon(Icons.workspace_premium_outlined),
              title: Text(l.upgrade),
              onTap: () => Navigator.of(context).push(PaywallScreen.route()),
            ),
          ListTile(
            leading: const Icon(Icons.restore),
            title: Text(l.restorePurchases),
            onTap: () async {
              final messenger = ScaffoldMessenger.of(context);
              final ok = await state.purchases.restore();
              if (ok) state.setPremium();
              messenger.showSnackBar(SnackBar(content: Text(ok ? l.restored : l.nothingToRestore)));
            },
          ),
          _Header(l.legalSection),
          ListTile(title: Text(l.imprint), onTap: () => openLegalPage('impressum')),
          ListTile(title: Text(l.privacy), onTap: () => openLegalPage('datenschutz')),
          ListTile(title: Text(l.terms), onTap: () => openLegalPage('agb')),
          const Divider(),
          ListTile(
            leading: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.error),
            title: Text(l.deleteData, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            onTap: () => _deleteData(context),
          ),
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
