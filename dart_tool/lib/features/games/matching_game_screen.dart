import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../services/local_data_service.dart';
import 'game_feedback.dart';

class MatchingGameScreen extends StatefulWidget {
  const MatchingGameScreen({super.key});

  @override
  State<MatchingGameScreen> createState() => _MatchingGameScreenState();
}

class _MatchingGameScreenState extends State<MatchingGameScreen> {
  final List<String> _initialIcons = ['🌸', '🌸', '☕', '☕', '🏠', '🏠', '🎶', '🎶'];
  late List<String> _cards;
  final List<int> _flipped = [];
  final List<int> _matched = [];
  int _moves = 0;
  int _mismatches = 0;
  bool? _lastMatchCorrect;

  @override
  void initState() {
    super.initState();
    _startNewGame();
  }

  void _startNewGame() {
    setState(() {
      _cards = List.from(_initialIcons)..shuffle();
      _flipped.clear();
      _matched.clear();
      _moves = 0;
      _mismatches = 0;
      _lastMatchCorrect = null;
    });
  }

  void _flipCard(int index) {
    if (_flipped.length == 2 || _flipped.contains(index) || _matched.contains(index)) {
      return;
    }

    setState(() {
      _flipped.add(index);
    });

    if (_flipped.length == 2) {
      _moves++;
      final a = _flipped[0];
      final b = _flipped[1];

      final isMatch = GameValidator.isCorrectMatch(_cards[a], _cards[b]);

      if (isMatch) {
        setState(() {
          _lastMatchCorrect = true;
        });
        Timer(const Duration(milliseconds: 450), () {
          if (mounted) {
            setState(() {
              _matched.addAll([a, b]);
              _flipped.clear();
              _lastMatchCorrect = null;
            });

            if (_matched.length == _cards.length) {
              _showWinDialog();
            }
          }
        });
      } else {
        setState(() {
          _mismatches++;
          _lastMatchCorrect = false;
        });
        Timer(const Duration(milliseconds: 700), () {
          if (mounted) {
            setState(() {
              _flipped.clear();
              _lastMatchCorrect = null;
            });
          }
        });
      }
    }
  }

  void _showWinDialog() {
    LocalDataService.instance.recordGameScore('match');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(21)),
        title: const Text(
          'You found every pair!',
          style: TextStyle(
            fontFamily: AppFonts.heading,
            fontFamilyFallback: AppFonts.headingFallback,
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: AppColors.ink,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFE0F5ED),
                borderRadius: BorderRadius.circular(11),
              ),
              child: const Text(
                'You played with care. Today’s game progress has been updated.',
                style: TextStyle(color: Color(0xFF126347), fontWeight: FontWeight.w600, fontSize: 13),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Moves: $_moves · Mismatches: $_mismatches · Session saved in your Memory Progress.',
              style: const TextStyle(color: AppColors.muted, fontSize: 13),
            ),
          ],
        ),
        actions: [
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.blue,
              side: const BorderSide(color: AppColors.line),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              _startNewGame();
            },
            child: const Text('Play again'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.blue,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ivory,
      appBar: AppBar(
        title: const Text(
          'Memory Match',
          style: TextStyle(
            fontFamily: AppFonts.heading,
            fontFamilyFallback: AppFonts.headingFallback,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(21),
                  border: Border.all(color: AppColors.line),
                  boxShadow: AppColors.shadowElevation,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Memory Match',
                      style: TextStyle(
                        fontFamily: AppFonts.heading,
                        fontFamilyFallback: AppFonts.headingFallback,
                        fontSize: 26,
                        fontWeight: FontWeight.w600,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Find all four pairs. Moves: $_moves',
                      style: const TextStyle(color: AppColors.muted, fontSize: 15),
                    ),
                    if (_lastMatchCorrect != null)
                      GameFeedbackBanner(
                        isCorrect: _lastMatchCorrect,
                        message: _lastMatchCorrect == true
                            ? LocalDataService.instance.localizations.wonderfulRecall
                            : LocalDataService.instance.localizations.notAMatch,
                        hint: _lastMatchCorrect == false
                            ? LocalDataService.instance.localizations.memoryMatchHint
                            : null,
                        hintLabel: LocalDataService.instance.localizations.hint,
                        retryLabel: LocalDataService.instance.localizations.tryAgain,
                      ),
                    const SizedBox(height: 24),

                    // 4x2 Grid of cards
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 1.0,
                      ),
                      itemCount: _cards.length,
                      itemBuilder: (context, index) {
                        final isRevealed = _flipped.contains(index) || _matched.contains(index);
                        return InkWell(
                          onTap: () => _flipCard(index),
                          borderRadius: BorderRadius.circular(12),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              color: isRevealed ? const Color(0xFFEEF4FF) : AppColors.blue,
                              borderRadius: BorderRadius.circular(12),
                              border: isRevealed ? Border.all(color: const Color(0xFFC6D9FA), width: 1.5) : null,
                            ),
                            child: Center(
                              child: Text(
                                isRevealed ? _cards[index] : '?',
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w700,
                                  color: isRevealed ? AppColors.ink : Colors.white,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 24),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Exit game', style: TextStyle(color: AppColors.blue, fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
