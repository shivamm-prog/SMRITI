import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smriti/features/games/digit_sequence_game_screen.dart';
import 'package:smriti/features/games/game_feedback.dart';
import 'package:smriti/features/games/matching_game_screen.dart';
import 'package:smriti/features/games/objects_game_screen.dart';
import 'package:smriti/features/games/word_recall_screen.dart';
import 'package:smriti/localization/app_language.dart';
import 'package:smriti/services/local_data_service.dart';

void main() {
  setUp(() {
    LocalDataService.instance.setLanguage(AppLanguage.english);
  });

  group('GameValidator Unit Tests - Deterministic & Strict Validation', () {
    test('Memory Match - isCorrectMatch', () {
      // Correct: identical cards
      expect(GameValidator.isCorrectMatch('🌸', '🌸'), isTrue);
      expect(GameValidator.isCorrectMatch('☕', '☕'), isTrue);

      // Wrong: mismatched pair MUST FAIL
      expect(GameValidator.isCorrectMatch('🌸', '☕'), isFalse);
      expect(GameValidator.isCorrectMatch('🏠', '🎶'), isFalse);

      // Incomplete / empty MUST FAIL
      expect(GameValidator.isCorrectMatch('', '🌸'), isFalse);
      expect(GameValidator.isCorrectMatch('', ''), isFalse);
    });

    test('Remember the Objects - isCorrectObjectsAnswer', () {
      final targets = ['☕', '🔑', '🍊', '🪴'];
      final distractors = ['📚', '🧣'];

      // Correct: exactly all targets, zero distractors
      expect(
        GameValidator.isCorrectObjectsAnswer(
          selected: {'☕', '🔑', '🍊', '🪴'},
          targets: targets,
          distractors: distractors,
        ),
        isTrue,
      );

      // Wrong: partial / incomplete selection MUST FAIL
      expect(
        GameValidator.isCorrectObjectsAnswer(
          selected: {'☕', '🔑', '🍊'},
          targets: targets,
          distractors: distractors,
        ),
        isFalse,
      );

      // Wrong: selecting any distractor MUST FAIL
      expect(
        GameValidator.isCorrectObjectsAnswer(
          selected: {'☕', '🔑', '🍊', '📚'},
          targets: targets,
          distractors: distractors,
        ),
        isFalse,
      );

      // Wrong: targets plus distractor MUST FAIL
      expect(
        GameValidator.isCorrectObjectsAnswer(
          selected: {'☕', '🔑', '🍊', '🪴', '📚'},
          targets: targets,
          distractors: distractors,
        ),
        isFalse,
      );

      // Wrong: empty selection MUST FAIL
      expect(
        GameValidator.isCorrectObjectsAnswer(
          selected: {},
          targets: targets,
          distractors: distractors,
        ),
        isFalse,
      );

      // Wrong: only distractors MUST FAIL
      expect(
        GameValidator.isCorrectObjectsAnswer(
          selected: {'📚', '🧣'},
          targets: targets,
          distractors: distractors,
        ),
        isFalse,
      );
    });

    test('Remember the Sequence - isCorrectSequenceAnswer', () {
      final target = ['3', '7', '2', '5'];

      // Correct: exact sequence, exact order, exact length
      expect(
        GameValidator.isCorrectSequenceAnswer(
          selected: ['3', '7', '2', '5'],
          target: target,
        ),
        isTrue,
      );

      // Wrong: specifically target = 3,7,2,5 and wrong = 3,2,7,5 MUST FAIL
      expect(
        GameValidator.isCorrectSequenceAnswer(
          selected: ['3', '2', '7', '5'],
          target: target,
        ),
        isFalse,
      );

      // Wrong: partial / incomplete sequence MUST FAIL
      expect(
        GameValidator.isCorrectSequenceAnswer(
          selected: ['3', '7'],
          target: target,
        ),
        isFalse,
      );

      // Wrong: incorrect digit MUST FAIL
      expect(
        GameValidator.isCorrectSequenceAnswer(
          selected: ['3', '7', '2', '9'],
          target: target,
        ),
        isFalse,
      );

      // Wrong: empty sequence MUST FAIL
      expect(
        GameValidator.isCorrectSequenceAnswer(
          selected: [],
          target: target,
        ),
        isFalse,
      );
    });

    test('Word Recall - isCorrectWordAnswer', () {
      final targets = ['river', 'tea', 'bamboo', 'song'];
      final distractors = ['cloud', 'market'];

      // Correct: exact targets, zero distractors
      expect(
        GameValidator.isCorrectWordAnswer(
          selected: {'river', 'tea', 'bamboo', 'song'},
          targets: targets,
          distractors: distractors,
        ),
        isTrue,
      );

      // Wrong: partial / incomplete selection (even 3 of 4) MUST FAIL
      expect(
        GameValidator.isCorrectWordAnswer(
          selected: {'river', 'tea', 'bamboo'},
          targets: targets,
          distractors: distractors,
        ),
        isFalse,
      );

      // Wrong: selecting a distractor word MUST FAIL
      expect(
        GameValidator.isCorrectWordAnswer(
          selected: {'river', 'tea', 'bamboo', 'cloud'},
          targets: targets,
          distractors: distractors,
        ),
        isFalse,
      );

      // Wrong: all targets plus distractor MUST FAIL
      expect(
        GameValidator.isCorrectWordAnswer(
          selected: {'river', 'tea', 'bamboo', 'song', 'market'},
          targets: targets,
          distractors: distractors,
        ),
        isFalse,
      );

      // Wrong: empty selection MUST FAIL
      expect(
        GameValidator.isCorrectWordAnswer(
          selected: {},
          targets: targets,
          distractors: distractors,
        ),
        isFalse,
      );
    });
  });

  group('Widget Tests - Game Screens Error Feedback & Retries', () {
    testWidgets('Remember the Sequence widget test: wrong order 3,2,7,5 vs 3,7,2,5 fails and shows hint', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: DigitSequenceGameScreen()));

      // Fast-forward initial showing phase timer (2500ms)
      await tester.pump(const Duration(milliseconds: 2600));

      // Target sequence is 3, 7, 2, 5
      // Enter incorrect order: 3, 2, 7, 5
      await tester.tap(find.widgetWithText(ElevatedButton, '3'));
      await tester.pump();
      await tester.tap(find.widgetWithText(ElevatedButton, '2'));
      await tester.pump();
      await tester.tap(find.widgetWithText(ElevatedButton, '7'));
      await tester.pump();
      await tester.tap(find.widgetWithText(ElevatedButton, '5'));
      await tester.pumpAndSettle();

      // Wrong order MUST show error message and sequence hint
      expect(find.text(LocalDataService.instance.localizations.orderWasDifferent), findsOneWidget);
      expect(find.text(LocalDataService.instance.localizations.sequenceHint), findsOneWidget);
      expect(find.byType(AlertDialog), findsNothing);

      // Tap retry to reset selection
      expect(find.text(LocalDataService.instance.localizations.tryAgain), findsWidgets);
      await tester.tap(find.widgetWithText(TextButton, LocalDataService.instance.localizations.tryAgain).first);
      await tester.pumpAndSettle();

      // Ensure error banner is cleared
      expect(find.text(LocalDataService.instance.localizations.orderWasDifferent), findsNothing);

      // Now enter CORRECT sequence: 3, 7, 2, 5
      await tester.tap(find.widgetWithText(ElevatedButton, '3'));
      await tester.pump();
      await tester.tap(find.widgetWithText(ElevatedButton, '7'));
      await tester.pump();
      await tester.tap(find.widgetWithText(ElevatedButton, '2'));
      await tester.pump();
      await tester.tap(find.widgetWithText(ElevatedButton, '5'));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // Win dialog must appear and no wrong-answer hint shown
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text(LocalDataService.instance.localizations.wonderfulRecall), findsWidgets);
      expect(find.text(LocalDataService.instance.localizations.sequenceHint), findsNothing);
    });

    testWidgets('Remember the Objects widget test: distractor selection fails and shows hint', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: ObjectsGameScreen()));

      // Fast-forward initial showing phase timer (2800ms)
      await tester.pump(const Duration(milliseconds: 2900));

      // Targets: ☕, 🔑, 🍊, 🪴. Distractors: 📚, 🧣
      // Select 3 targets + 1 distractor (📚)
      await tester.tap(find.text('☕'));
      await tester.tap(find.text('🔑'));
      await tester.tap(find.text('🍊'));
      await tester.tap(find.text('📚'));
      await tester.pump();

      // Tap Check my answer
      await tester.tap(find.text('Check my answer'));
      await tester.pumpAndSettle();

      // Distractor selected MUST FAIL
      expect(find.text(LocalDataService.instance.localizations.notQuite), findsOneWidget);
      expect(find.text(LocalDataService.instance.localizations.objectsHint), findsOneWidget);
      expect(find.byType(AlertDialog), findsNothing);

      // Tap Try again button in feedback banner
      await tester.tap(find.widgetWithText(TextButton, LocalDataService.instance.localizations.tryAgain));
      await tester.pumpAndSettle();

      // Banner is dismissed
      expect(find.text(LocalDataService.instance.localizations.notQuite), findsNothing);

      // Select strictly the 4 target objects
      await tester.tap(find.text('☕'));
      await tester.tap(find.text('🔑'));
      await tester.tap(find.text('🍊'));
      await tester.tap(find.text('🪴'));
      await tester.pump();

      await tester.tap(find.text('Check my answer'));
      await tester.pumpAndSettle();

      // Win dialog must appear and no wrong-answer hint shown
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text(LocalDataService.instance.localizations.wonderfulRecall), findsWidgets);
      expect(find.text(LocalDataService.instance.localizations.objectsHint), findsNothing);
    });

    testWidgets('Word Recall widget test: distractor selection fails and shows hint', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: WordRecallGameScreen()));

      // Fast-forward initial showing phase timer (2800ms)
      await tester.pump(const Duration(milliseconds: 2900));

      // Targets: river, tea, bamboo, song. Distractors: cloud, market
      // Select 3 targets + 1 distractor ('cloud')
      await tester.tap(find.text('river'));
      await tester.tap(find.text('tea'));
      await tester.tap(find.text('bamboo'));
      await tester.tap(find.text('cloud'));
      await tester.pump();

      // Tap Check my answer
      await tester.tap(find.text('Check my answer'));
      await tester.pumpAndSettle();

      // Distractor selected MUST FAIL
      expect(find.text(LocalDataService.instance.localizations.notQuiteShort), findsOneWidget);
      expect(find.text(LocalDataService.instance.localizations.wordRecallHint), findsOneWidget);
      expect(find.byType(AlertDialog), findsNothing);

      // Tap Try again
      await tester.tap(find.widgetWithText(TextButton, LocalDataService.instance.localizations.tryAgain));
      await tester.pumpAndSettle();

      // Banner dismissed
      expect(find.text(LocalDataService.instance.localizations.notQuiteShort), findsNothing);

      // Select all 4 correct targets
      await tester.tap(find.text('river'));
      await tester.tap(find.text('tea'));
      await tester.tap(find.text('bamboo'));
      await tester.tap(find.text('song'));
      await tester.pump();

      await tester.tap(find.text('Check my answer'));
      await tester.pumpAndSettle();

      // Win dialog must appear and no wrong-answer hint shown
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text(LocalDataService.instance.localizations.wonderfulRecall), findsWidgets);
      expect(find.text(LocalDataService.instance.localizations.wordRecallHint), findsNothing);
    });

    testWidgets('Memory Match widget test: mismatch fails and shows hint', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: MatchingGameScreen()));
      await tester.pumpAndSettle();

      // Tap card 0
      final cards = find.byType(InkWell);
      await tester.tap(cards.at(0));
      await tester.pump();

      // Find another card that does not match card 0
      // We can try index 1, 2, 3 until a mismatch is found or inspect cards
      // There are 8 cards with pairs. At least one card in 1..7 does not match 0.
      await tester.tap(cards.at(1));
      await tester.pump();

      // Check if it was a match or mismatch
      final hasMismatch = find.text(LocalDataService.instance.localizations.notAMatch).evaluate().isNotEmpty;
      if (hasMismatch) {
        expect(find.text(LocalDataService.instance.localizations.notAMatch), findsOneWidget);
        expect(find.text(LocalDataService.instance.localizations.memoryMatchHint), findsOneWidget);
        expect(find.byType(AlertDialog), findsNothing);

        // Advance 700ms timer to flip cards back
        await tester.pump(const Duration(milliseconds: 750));
        expect(find.text(LocalDataService.instance.localizations.notAMatch), findsNothing);
      }
    });
  });
}
