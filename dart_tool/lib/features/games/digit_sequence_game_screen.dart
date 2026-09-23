import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../services/local_data_service.dart';
import 'game_feedback.dart';

class DigitSequenceGameScreen extends StatefulWidget {
  const DigitSequenceGameScreen({super.key});

  @override
  State<DigitSequenceGameScreen> createState() => _DigitSequenceGameScreenState();
}

class _DigitSequenceGameScreenState extends State<DigitSequenceGameScreen> {
  final List<String> _items = ['3', '7', '2', '5'];
  late List<String> _options;
  final List<String> _chosen = [];

  bool _isShowingPhase = true;
  Timer? _timer;
  bool? _isCorrect;

  @override
  void initState() {
    super.initState();
    _startRound();
  }

  void _startRound() {
    _isShowingPhase = true;
    _chosen.clear();
    _isCorrect = null;
    _options = List.from(_items)..shuffle();
    _timer?.cancel();
    _timer = Timer(const Duration(milliseconds: 2500), () {
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

  void _chooseDigit(String digit) {
    if (_chosen.length >= _items.length) return;
    setState(() {
      _chosen.add(digit);
      _isCorrect = null;
    });

    if (_chosen.length == _items.length) {
      final isCorrect = GameValidator.isCorrectSequenceAnswer(
        selected: _chosen,
        target: _items,
      );
      setState(() {
        _isCorrect = isCorrect;
      });

      if (isCorrect) {
        Timer(const Duration(milliseconds: 400), () {
          if (mounted) {
            _showWinDialog();
          }
        });
      }
    }
  }

  void _showWinDialog() {
    LocalDataService.instance.recordGameScore('sequence');

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
                'You recalled the sequence perfectly! Today’s game progress has been updated.',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ivory,
      appBar: AppBar(
        title: const Text(
          'Remember the Sequence',
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
                      'Remember the Sequence',
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
                          ? 'Take a quiet moment to remember these numbers.'
                          : 'Tap the numbers in the order you saw them.',
                      style: const TextStyle(color: AppColors.muted, fontSize: 15),
                    ),
                    const SizedBox(height: 24),

                    if (_isShowingPhase) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 28),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7FAFF),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: _items.map((item) {
                            return Container(
                              width: 54,
                              height: 54,
                              decoration: BoxDecoration(
                                color: const Color(0xFFEAF2FF),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(
                                  item,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.blue,
                                  ),
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
                      // Shuffled digit buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: _options.map((digit) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFEDF4FF),
                                foregroundColor: AppColors.blue,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              ),
                              onPressed: _chosen.length < _items.length ? () => _chooseDigit(digit) : null,
                              child: Text(
                                digit,
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),

                      // Sequence chosen items
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(_items.length, (idx) {
                            final hasItem = idx < _chosen.length;
                            return Container(
                              margin: const EdgeInsets.symmetric(horizontal: 6),
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: hasItem ? AppColors.blue : const Color(0xFFEAF2FF),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(
                                  hasItem ? _chosen[idx] : '?',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                    color: hasItem ? Colors.white : AppColors.muted,
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                      if (_isCorrect != null)
                        GameFeedbackBanner(
                          isCorrect: _isCorrect,
                          message: _isCorrect == true
                              ? LocalDataService.instance.localizations.wonderfulRecall
                              : LocalDataService.instance.localizations.orderWasDifferent,
                          hint: _isCorrect == false
                              ? LocalDataService.instance.localizations.sequenceHint
                              : null,
                          hintLabel: LocalDataService.instance.localizations.hint,
                          retryLabel: LocalDataService.instance.localizations.tryAgain,
                          onRetry: () {
                            setState(() {
                              _chosen.clear();
                              _isCorrect = null;
                            });
                          },
                        ),
                      if (_chosen.isNotEmpty && _isCorrect == null)
                        Center(
                          child: TextButton.icon(
                            onPressed: () {
                              setState(() {
                                _chosen.clear();
                              });
                            },
                            icon: const Icon(Icons.backspace_outlined, size: 16),
                            label: Text(LocalDataService.instance.localizations.tryAgain),
                            style: TextButton.styleFrom(foregroundColor: AppColors.muted),
                          ),
                        ),
                    ],

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
