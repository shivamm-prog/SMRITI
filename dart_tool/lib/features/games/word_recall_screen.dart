import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../services/local_data_service.dart';
import 'game_feedback.dart';

class WordRecallGameScreen extends StatefulWidget {
  const WordRecallGameScreen({super.key});

  @override
  State<WordRecallGameScreen> createState() => _WordRecallGameScreenState();
}

class _WordRecallGameScreenState extends State<WordRecallGameScreen> {
  final List<String> _items = ['river', 'tea', 'bamboo', 'song'];
  final List<String> _options = ['river', 'tea', 'bamboo', 'song', 'cloud', 'market'];
  final Set<String> _chosen = {};

  bool _isShowingPhase = true;
  Timer? _timer;
  bool? _isCorrect;
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    _startRound();
  }

  void _startRound() {
    _isShowingPhase = true;
    _chosen.clear();
    _isCorrect = null;
    _submitted = false;
    _timer?.cancel();
    _timer = Timer(const Duration(milliseconds: 2800), () {
      if (mounted) {
        setState(() {
          _isShowingPhase = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _toggleWord(String word) {
    setState(() {
      if (_submitted && _isCorrect == false) {
        _isCorrect = null;
        _submitted = false;
      }
      if (_chosen.contains(word)) {
        _chosen.remove(word);
      } else {
        _chosen.add(word);
      }
    });
  }

  void _checkAnswer() {
    final distractors = _options.where((x) => !_items.contains(x)).toList();
    final isCorrect = GameValidator.isCorrectWordAnswer(
      selected: _chosen,
      targets: _items,
      distractors: distractors,
    );

    setState(() {
      _submitted = true;
      _isCorrect = isCorrect;
    });

    if (isCorrect) {
      LocalDataService.instance.recordGameScore('words');

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(21)),
          title: Text(
            LocalDataService.instance.localizations.wonderfulRecall,
            style: const TextStyle(
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
                  'You recalled all target words! Today’s game progress has been updated.',
                  style: TextStyle(color: Color(0xFF126347), fontWeight: FontWeight.w600, fontSize: 13),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Score: ${_items.length} of ${_items.length} · Session saved in your Memory Progress.',
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
                setState(() {
                  _startRound();
                });
              },
              child: Text(LocalDataService.instance.localizations.playAgain),
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ivory,
      appBar: AppBar(
        title: const Text(
          'Word Recall',
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
                      'Word Recall',
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
                      _isShowingPhase
                          ? 'Take a quiet moment to remember these words.'
                          : 'Select the words you remember seeing.',
                      style: const TextStyle(color: AppColors.muted, fontSize: 15),
                    ),
                    const SizedBox(height: 24),

                    if (_isShowingPhase) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7FAFF),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 12,
                          runSpacing: 12,
                          children: _items.map((word) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEAF2FF),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                word,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.blue,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'They will hide in a moment…',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.muted, fontSize: 13),
                      ),
                    ] else ...[
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: _options.map((opt) {
                          final isSelected = _chosen.contains(opt);
                          return InkWell(
                            onTap: () => _toggleWord(opt),
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.blue : const Color(0xFFEDF4FF),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                opt,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: isSelected ? Colors.white : AppColors.blue,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      if (_submitted && _isCorrect != null)
                        GameFeedbackBanner(
                          isCorrect: _isCorrect,
                          message: _isCorrect == true
                              ? LocalDataService.instance.localizations.wonderfulRecall
                              : LocalDataService.instance.localizations.notQuiteShort,
                          hint: _isCorrect == false
                              ? LocalDataService.instance.localizations.wordRecallHint
                              : null,
                          hintLabel: LocalDataService.instance.localizations.hint,
                          retryLabel: LocalDataService.instance.localizations.tryAgain,
                          onRetry: () {
                            setState(() {
                              _chosen.clear();
                              _submitted = false;
                              _isCorrect = null;
                            });
                          },
                        ),
                      const SizedBox(height: 24),
                      FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.blue,
                          minimumSize: const Size.fromHeight(50),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: _chosen.isNotEmpty ? _checkAnswer : null,
                        child: const Text('Check my answer', style: TextStyle(fontWeight: FontWeight.w700)),
                      ),
                    ],

                    const SizedBox(height: 16),
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
