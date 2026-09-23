import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Pure, deterministic validation functions for all SMRITI cognitive games.
class GameValidator {
  const GameValidator._();

  /// Validates Memory Match: Both flipped cards must have the same value.
  static bool isCorrectMatch(String cardA, String cardB) {
    if (cardA.isEmpty || cardB.isEmpty) return false;
    return cardA == cardB;
  }

  /// Validates Remember the Objects:
  /// - All required target objects must be selected.
  /// - Zero distractors may be selected.
  /// - Selection must not be empty or incomplete.
  static bool isCorrectObjectsAnswer({
    required Set<String> selected,
    required List<String> targets,
    required List<String> distractors,
  }) {
    if (selected.isEmpty) return false;
    if (selected.length != targets.length) return false;

    // Reject if any distractor is chosen
    for (final d in distractors) {
      if (selected.contains(d)) return false;
    }

    // Require every target to be selected
    for (final t in targets) {
      if (!selected.contains(t)) return false;
    }

    return true;
  }

  /// Validates Remember the Sequence:
  /// - The selected sequence must match the target sequence item-for-item and in exact order.
  /// - The length must match exactly.
  static bool isCorrectSequenceAnswer({
    required List<String> selected,
    required List<String> target,
  }) {
    if (selected.length != target.length) return false;
    return listEquals(selected, target);
  }

  /// Validates Word Recall:
  /// - All required target words must be selected.
  /// - Zero distractors may be selected.
  /// - Selection must not be empty or incomplete.
  static bool isCorrectWordAnswer({
    required Set<String> selected,
    required List<String> targets,
    required List<String> distractors,
  }) {
    if (selected.isEmpty) return false;
    if (selected.length != targets.length) return false;

    // Reject if any distractor is chosen
    for (final d in distractors) {
      if (selected.contains(d)) return false;
    }

    // Require every target word to be selected
    for (final t in targets) {
      if (!selected.contains(t)) return false;
    }

    return true;
  }
}

/// Reusable elderly-friendly feedback and contextual hint component.
/// Displays positive validation when correct, and calm, encouraging guidance
/// with contextual hint and retry action when incorrect.
class GameFeedbackBanner extends StatelessWidget {
  const GameFeedbackBanner({
    super.key,
    required this.isCorrect,
    required this.message,
    this.hint,
    this.onRetry,
    this.retryLabel = 'Try again',
    this.hintLabel = 'Hint',
  });

  /// null = no feedback (idle), true = correct, false = wrong.
  final bool? isCorrect;
  final String message;
  final String? hint;
  final VoidCallback? onRetry;
  final String retryLabel;
  final String hintLabel;

  @override
  Widget build(BuildContext context) {
    if (isCorrect == null) {
      return const SizedBox.shrink();
    }

    if (isCorrect == true) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFE0F5ED),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF20775B).withOpacity(0.35), width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: const BoxDecoration(
                color: Color(0xFF20775B),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_rounded, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Color(0xFF104A36),
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Wrong answer feedback (supportive, gentle, not harsh)
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.danger.withOpacity(0.35), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.danger.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close_rounded, color: AppColors.danger, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Color(0xFF881337),
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
              if (onRetry != null)
                TextButton.icon(
                  onPressed: onRetry,
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.blue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.refresh_rounded, size: 16),
                  label: Text(retryLabel, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                ),
            ],
          ),
          if (hint != null && hint!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFF43F5E).withOpacity(0.2)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('💡', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          hintLabel.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.1,
                            color: Color(0xFF9F1239),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          hint!,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF4C0519),
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
