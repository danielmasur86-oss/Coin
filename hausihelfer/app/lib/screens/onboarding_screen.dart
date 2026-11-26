import 'package:material_ui/material_ui.dart';

import '../app_state.dart';
import '../l10n/gen/app_localizations.dart';
import '../models/profile.dart';
import '../widgets/labels.dart';

/// First launch (and "edit profile" from settings): language, Bundesland, school, grade.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, this.editing = false});
  final bool editing;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late Profile _draft;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    final state = AppScope.of(context);
    final deviceLang = Localizations.localeOf(context).languageCode;
    _draft = state.profile ??
        Profile(
          language: supportedLanguages.containsKey(deviceLang) ? deviceLang : 'de',
          bundesland: 'NW',
          schoolType: 'grundschule',
          grade: 3,
        );
  }

  Future<void> _save() async {
    final state = AppScope.of(context);
    await state.saveProfile(_draft);
    if (widget.editing && mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    // Show the screen in the language being picked, so the parent sees the effect at once.
    return Localizations.override(
      context: context,
      locale: Locale(_draft.language),
      child: Builder(builder: (context) {
        final l = AppLocalizations.of(context);
        final theme = Theme.of(context);
        return Scaffold(
          appBar: widget.editing ? AppBar(title: Text(l.profileSection)) : null,
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                if (!widget.editing) ...[
                  const SizedBox(height: 12),
                  Icon(Icons.menu_book_rounded, size: 56, color: theme.colorScheme.primary),
                  const SizedBox(height: 12),
                  Text(l.onboardingTitle,
                      style: theme.textTheme.headlineSmall, textAlign: TextAlign.center),
                  const SizedBox(height: 8),
                  Text(l.onboardingSubtitle,
                      style: theme.textTheme.bodyLarge, textAlign: TextAlign.center),
                  const SizedBox(height: 24),
                ],
                _Dropdown<String>(
                  label: l.chooseLanguage,
                  value: _draft.language,
                  items: {for (final e in supportedLanguages.entries) e.key: e.value},
                  onChanged: (v) => setState(() => _draft = _draft.copyWith(language: v)),
                ),
                _Dropdown<String>(
                  label: l.chooseState,
                  value: _draft.bundesland,
                  items: bundeslaender,
                  onChanged: (v) => setState(() => _draft = _draft.copyWith(bundesland: v)),
                ),
                _Dropdown<String>(
                  label: l.chooseSchoolType,
                  value: _draft.schoolType,
                  items: {for (final t in schoolTypes) t: schoolTypeLabel(l, t)},
                  onChanged: (v) => setState(() => _draft = _draft.copyWith(schoolType: v)),
                ),
                _Dropdown<int>(
                  label: l.chooseGrade,
                  value: _draft.grade,
                  items: {for (var g = 1; g <= 13; g++) g: l.gradeLabel(g)},
                  onChanged: (v) => setState(() => _draft = _draft.copyWith(grade: v)),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _save,
                  style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
                  child: Text(widget.editing ? l.save : l.continueButton),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class _Dropdown<T> extends StatelessWidget {
  const _Dropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final T value;
  final Map<T, String> items;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<T>(
        initialValue: value,
        isExpanded: true,
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
        items: [
          for (final e in items.entries) DropdownMenuItem(value: e.key, child: Text(e.value)),
        ],
        onChanged: (v) {
          if (v != null) onChanged(v);
        },
      ),
    );
  }
}
