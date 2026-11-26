/// Mirrors the `Explanation` schema in backend/src/schema.ts.
class Explanation {
  Explanation({
    required this.readable,
    required this.taskOriginalDe,
    required this.taskTranslation,
    required this.topic,
    required this.topicDe,
    required this.howToExplain,
    required this.steps,
    required this.vocabulary,
    required this.solution,
    required this.isCorrect,
    required this.checkFeedback,
    required this.confidence,
  });

  final bool readable;
  final String taskOriginalDe;
  final String taskTranslation;
  final String topic;
  final String topicDe;
  final String howToExplain;
  final List<TaskStep> steps;
  final List<Vocab> vocabulary;
  final String solution;
  final bool? isCorrect;
  final String checkFeedback;
  final String confidence; // high | medium | low

  factory Explanation.fromJson(Map<String, dynamic> j) {
    final check = (j['check'] as Map?)?.cast<String, dynamic>() ?? const {};
    return Explanation(
      readable: j['readable'] as bool? ?? false,
      taskOriginalDe: j['task_original_de'] as String? ?? '',
      taskTranslation: j['task_translation'] as String? ?? '',
      topic: j['topic'] as String? ?? '',
      topicDe: j['topic_de'] as String? ?? '',
      howToExplain: j['how_to_explain'] as String? ?? '',
      steps: [
        for (final s in (j['steps'] as List? ?? const []))
          TaskStep.fromJson((s as Map).cast<String, dynamic>()),
      ],
      vocabulary: [
        for (final v in (j['german_vocabulary'] as List? ?? const []))
          Vocab.fromJson((v as Map).cast<String, dynamic>()),
      ],
      solution: j['solution'] as String? ?? '',
      isCorrect: check['is_correct'] as bool?,
      checkFeedback: check['feedback'] as String? ?? '',
      confidence: j['confidence'] as String? ?? 'medium',
    );
  }

  Map<String, dynamic> toJson() => {
        'readable': readable,
        'task_original_de': taskOriginalDe,
        'task_translation': taskTranslation,
        'topic': topic,
        'topic_de': topicDe,
        'how_to_explain': howToExplain,
        'steps': [for (final s in steps) s.toJson()],
        'german_vocabulary': [for (final v in vocabulary) v.toJson()],
        'solution': solution,
        'check': {'is_correct': isCorrect, 'feedback': checkFeedback},
        'confidence': confidence,
      };
}

class TaskStep {
  TaskStep({required this.parentHint, required this.askChildDe, required this.askChildTranslation});
  final String parentHint;
  final String askChildDe;
  final String askChildTranslation;

  factory TaskStep.fromJson(Map<String, dynamic> j) => TaskStep(
        parentHint: j['parent_hint'] as String? ?? '',
        askChildDe: j['ask_child_de'] as String? ?? '',
        askChildTranslation: j['ask_child_translation'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'parent_hint': parentHint,
        'ask_child_de': askChildDe,
        'ask_child_translation': askChildTranslation,
      };
}

class Vocab {
  Vocab({required this.de, required this.translation});
  final String de;
  final String translation;

  factory Vocab.fromJson(Map<String, dynamic> j) =>
      Vocab(de: j['de'] as String? ?? '', translation: j['translation'] as String? ?? '');

  Map<String, dynamic> toJson() => {'de': de, 'translation': translation};
}

/// A saved task in the local history (no photo is stored).
class HistoryEntry {
  HistoryEntry({
    required this.createdAt,
    required this.subject,
    required this.mode,
    required this.explanation,
  });

  final DateTime createdAt;
  final String subject;
  final String mode;
  final Explanation explanation;

  Map<String, dynamic> toJson() => {
        'createdAt': createdAt.toIso8601String(),
        'subject': subject,
        'mode': mode,
        'explanation': explanation.toJson(),
      };

  factory HistoryEntry.fromJson(Map<String, dynamic> j) => HistoryEntry(
        createdAt: DateTime.parse(j['createdAt'] as String),
        subject: j['subject'] as String,
        mode: j['mode'] as String,
        explanation: Explanation.fromJson((j['explanation'] as Map).cast<String, dynamic>()),
      );
}
