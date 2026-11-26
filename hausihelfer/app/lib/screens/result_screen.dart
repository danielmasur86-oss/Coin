import 'package:material_ui/material_ui.dart';

import '../app_state.dart';
import '../l10n/gen/app_localizations.dart';
import '../models/explanation.dart';
import '../services/api_client.dart';

/// Shows the explanation for the parent. Steps are revealed one at a time and the full
/// solution is hidden behind a button, so the parent guides the child instead of dictating.
class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key, required this.entry});
  final HistoryEntry entry;

  static Route<void> route(HistoryEntry entry) =>
      MaterialPageRoute(builder: (_) => ResultScreen(entry: entry));

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  int _visibleSteps = 1;
  bool _showSolution = false;

  Explanation get e => widget.entry.explanation;

  Future<void> _report() async {
    final state = AppScope.of(context);
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    // The dialog owns its text field, so nothing is disposed while it animates out.
    final comment = await showDialog<String>(context: context, builder: (_) => const _ReportDialog());
    if (comment == null) return;
    try {
      await state.api.feedback(
        language: state.profile?.language ?? 'de',
        subject: widget.entry.subject,
        topicDe: e.topicDe,
        taskDe: e.taskOriginalDe,
        comment: comment,
      );
      messenger.showSnackBar(SnackBar(content: Text(l.reportThanks)));
    } on ApiException {
      messenger.showSnackBar(SnackBar(content: Text(l.errorNetwork)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);

    if (!e.readable) {
      return Scaffold(
        appBar: AppBar(),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.image_not_supported_outlined, size: 56, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text(l.unreadableTitle, style: theme.textTheme.titleLarge, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(e.taskTranslation, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            FilledButton(onPressed: () => Navigator.of(context).pop(), child: Text(l.tryAgain)),
          ]),
        ),
      );
    }

    final isCheck = widget.entry.mode == 'check';

    return Scaffold(
      appBar: AppBar(title: Text(e.topic, maxLines: 1, overflow: TextOverflow.ellipsis)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (e.confidence == 'low')
            _Banner(icon: Icons.warning_amber_rounded, text: l.lowConfidence, color: theme.colorScheme.errorContainer),
          if (isCheck && e.isCorrect != null)
            _Banner(
              icon: e.isCorrect! ? Icons.check_circle_outline : Icons.error_outline,
              text: e.isCorrect! ? l.checkCorrect : l.checkWrong,
              color: e.isCorrect! ? theme.colorScheme.primaryContainer : theme.colorScheme.tertiaryContainer,
              body: e.checkFeedback,
            ),
          _Section(
            title: l.resultTaskTitle,
            children: [
              Text(e.taskTranslation, style: theme.textTheme.bodyLarge),
              if (e.taskOriginalDe.isNotEmpty)
                ExpansionTile(
                  tilePadding: EdgeInsets.zero,
                  title: Text(l.resultOriginal, style: theme.textTheme.labelLarge),
                  children: [
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: SelectableText(e.taskOriginalDe, textDirection: TextDirection.ltr),
                    ),
                  ],
                ),
            ],
          ),
          _Section(title: l.resultHowToExplain, children: [Text(e.howToExplain)]),
          if (e.steps.isNotEmpty)
            _Section(
              title: l.resultSteps,
              children: [
                for (var i = 0; i < _visibleSteps && i < e.steps.length; i++)
                  _StepCard(index: i + 1, step: e.steps[i]),
                if (_visibleSteps < e.steps.length)
                  OutlinedButton.icon(
                    onPressed: () => setState(() => _visibleSteps++),
                    icon: const Icon(Icons.arrow_downward),
                    label: Text(l.showNextStep),
                  ),
              ],
            ),
          if (e.vocabulary.isNotEmpty)
            _Section(
              title: l.vocabulary,
              children: [
                for (final v in e.vocabulary)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Expanded(
                        child: Text(v.de,
                            textDirection: TextDirection.ltr,
                            style: const TextStyle(fontWeight: FontWeight.w600)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Text(v.translation)),
                    ]),
                  ),
              ],
            ),
          if (e.solution.isNotEmpty)
            _Section(
              // While hidden, the button itself is the heading.
              title: _showSolution ? l.solutionTitle : null,
              children: [
                if (!_showSolution) ...[
                  Text(l.solutionWarning, style: theme.textTheme.bodySmall),
                  const SizedBox(height: 8),
                  FilledButton.tonal(
                    onPressed: () => setState(() => _showSolution = true),
                    child: Text(l.showSolution),
                  ),
                ] else ...[
                  SelectableText(e.solution),
                  TextButton(
                    onPressed: () => setState(() => _showSolution = false),
                    child: Text(l.hideSolution),
                  ),
                ],
              ],
            ),
          const SizedBox(height: 8),
          Text(l.aiDisclaimer, style: theme.textTheme.bodySmall, textAlign: TextAlign.center),
          TextButton.icon(
            onPressed: _report,
            icon: const Icon(Icons.flag_outlined),
            label: Text(l.reportProblem),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});
  final String? title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        if (title != null) ...[
          Text(title!, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
        ],
        ...children,
      ]),
    );
  }
}

class _StepCard extends StatelessWidget {
  const _StepCard({required this.index, required this.step});
  final int index;
  final TaskStep step;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(l.stepN(index), style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.primary)),
          const SizedBox(height: 4),
          Text(step.parentHint),
          if (step.askChildDe.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(l.askChild, style: theme.textTheme.labelMedium),
            const SizedBox(height: 2),
            Text('„${step.askChildDe}“',
                textDirection: TextDirection.ltr,
                style: theme.textTheme.bodyLarge?.copyWith(fontStyle: FontStyle.italic)),
            Text(step.askChildTranslation, style: theme.textTheme.bodySmall),
          ],
        ]),
      ),
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({required this.icon, required this.text, required this.color, this.body});
  final IconData icon;
  final String text;
  final Color color;
  final String? body;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon),
        const SizedBox(width: 10),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
            if (body != null && body!.isNotEmpty) ...[const SizedBox(height: 4), Text(body!)],
          ]),
        ),
      ]),
    );
  }
}

/// Asks for an optional comment. Returns the text on "Send", null on "Cancel".
class _ReportDialog extends StatefulWidget {
  const _ReportDialog();

  @override
  State<_ReportDialog> createState() => _ReportDialogState();
}

class _ReportDialogState extends State<_ReportDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l.reportProblem),
      content: TextField(
        controller: _controller,
        maxLines: 4,
        maxLength: 2000,
        decoration: InputDecoration(hintText: l.reportHint, border: const OutlineInputBorder()),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(l.cancel)),
        FilledButton(onPressed: () => Navigator.pop(context, _controller.text), child: Text(l.send)),
      ],
    );
  }
}
