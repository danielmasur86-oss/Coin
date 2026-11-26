import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../app_state.dart';
import '../l10n/gen/app_localizations.dart';
import '../models/explanation.dart';
import '../models/profile.dart';
import '../services/api_client.dart';
import '../widgets/labels.dart';
import 'paywall_screen.dart';
import 'result_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _mode = 'explain';
  String _subject = 'mathe';
  bool _busy = false;

  Future<void> _pick(ImageSource source) async {
    final state = AppScope.of(context);
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    if (!state.premium && state.remainingFree == 0) {
      navigator.push(PaywallScreen.route(limitReached: true));
      return;
    }

    // Downscale on the device: smaller upload, lower AI cost, still readable.
    final file = await ImagePicker().pickImage(
      source: source,
      maxWidth: 1600,
      maxHeight: 1600,
      imageQuality: 80,
      requestFullMetadata: false,
    );
    if (file == null) return;

    setState(() => _busy = true);
    try {
      final result = await state.api.explain(
        jpegBytes: await file.readAsBytes(),
        profile: state.profile!,
        subject: _subject,
        mode: _mode,
      );
      state.updateRemaining(result.remainingFree);
      final entry = HistoryEntry(
        createdAt: DateTime.now(),
        subject: _subject,
        mode: _mode,
        explanation: result.explanation,
      );
      if (result.explanation.readable) await state.addHistory(entry);
      navigator.push(ResultScreen.route(entry));
    } on ApiException catch (e) {
      switch (e.kind) {
        case ApiErrorKind.limitReached:
          state.updateRemaining(0);
          navigator.push(PaywallScreen.route(limitReached: true));
        case ApiErrorKind.dailyLimit:
          messenger.showSnackBar(SnackBar(content: Text(l.errorDailyLimit)));
        case ApiErrorKind.busy:
          messenger.showSnackBar(SnackBar(content: Text(l.errorBusy)));
        case ApiErrorKind.network:
          messenger.showSnackBar(SnackBar(content: Text(l.errorNetwork)));
        case ApiErrorKind.generic:
          messenger.showSnackBar(SnackBar(content: Text(l.errorGeneric)));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final dateFormat = DateFormat.yMMMd(state.locale.languageCode);

    return Scaffold(
      appBar: AppBar(
        title: Text(l.appTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: l.settingsTitle,
            onPressed: () => Navigator.of(context).push(SettingsScreen.route()),
          ),
        ],
      ),
      body: _busy
          ? Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(l.analyzing, style: theme.textTheme.titleMedium),
              ]),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                SegmentedButton<String>(
                  segments: [
                    ButtonSegment(
                        value: 'explain',
                        icon: const Icon(Icons.lightbulb_outline),
                        label: Text(l.modeExplain)),
                    ButtonSegment(
                        value: 'check',
                        icon: const Icon(Icons.fact_check_outlined),
                        label: Text(l.modeCheck)),
                  ],
                  selected: {_mode},
                  onSelectionChanged: (s) => setState(() => _mode = s.first),
                ),
                const SizedBox(height: 8),
                Text(_mode == 'explain' ? l.modeExplainHint : l.modeCheckHint,
                    style: theme.textTheme.bodyMedium),
                const SizedBox(height: 16),
                Text(l.subjectLabel, style: theme.textTheme.titleSmall),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final s in subjects)
                      ChoiceChip(
                        label: Text(subjectLabel(l, s)),
                        selected: _subject == s,
                        onSelected: (_) => setState(() => _subject = s),
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: () => _pick(ImageSource.camera),
                  icon: const Icon(Icons.photo_camera),
                  label: Text(l.takePhoto),
                  style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(56)),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () => _pick(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library_outlined),
                  label: Text(l.fromGallery),
                  style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                ),
                const SizedBox(height: 12),
                _QuotaLine(state: state),
                const SizedBox(height: 24),
                Text(l.historyTitle, style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                if (state.history.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(l.historyEmpty, style: theme.textTheme.bodyMedium),
                  )
                else
                  for (final e in state.history)
                    Card(
                      child: ListTile(
                        leading: Icon(e.mode == 'check'
                            ? Icons.fact_check_outlined
                            : Icons.lightbulb_outline),
                        title: Text(
                          e.explanation.topic.isEmpty ? subjectLabel(l, e.subject) : e.explanation.topic,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text('${subjectLabel(l, e.subject)} · ${dateFormat.format(e.createdAt)}'),
                        onTap: () => Navigator.of(context).push(ResultScreen.route(e)),
                      ),
                    ),
              ],
            ),
    );
  }
}

class _QuotaLine extends StatelessWidget {
  const _QuotaLine({required this.state});
  final AppState state;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    if (state.premium) {
      return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.workspace_premium, size: 18, color: theme.colorScheme.primary),
        const SizedBox(width: 6),
        Text(l.premiumActive, style: TextStyle(color: theme.colorScheme.primary)),
      ]);
    }
    final remaining = state.remainingFree;
    if (remaining == null) return const SizedBox.shrink();
    return Column(children: [
      Text(l.freeLeft(remaining), textAlign: TextAlign.center),
      TextButton(
        onPressed: () => Navigator.of(context).push(PaywallScreen.route()),
        child: Text(l.upgrade),
      ),
    ]);
  }
}
