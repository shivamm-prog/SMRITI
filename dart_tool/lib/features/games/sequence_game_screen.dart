import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../services/local_data_service.dart';

class _TeaStep {
  const _TeaStep({
    required this.orderIndex,
    required this.emoji,
    required this.icon,
  });

  final int orderIndex; // 0, 1, 2, 3
  final String emoji;
  final IconData icon;
}

class DailySequenceGameScreen extends StatefulWidget {
  const DailySequenceGameScreen({super.key});

  @override
  State<DailySequenceGameScreen> createState() => _DailySequenceGameScreenState();
}

class _DailySequenceGameScreenState extends State<DailySequenceGameScreen> {
  static const List<_TeaStep> _canonicalSteps = [
    _TeaStep(orderIndex: 0, emoji: '🫖', icon: Icons.water_drop_outlined),
    _TeaStep(orderIndex: 1, emoji: '🍃', icon: Icons.eco_outlined),
    _TeaStep(orderIndex: 2, emoji: '🥛', icon: Icons.local_cafe_outlined),
    _TeaStep(orderIndex: 3, emoji: '☕', icon: Icons.coffee_rounded),
  ];

  late List<_TeaStep> _shuffledSteps;
  final List<int> _completedStepIndices = [];
  int _currentExpectedStep = 0;
  String? _feedbackMessage;
  bool _isSuccessFeedback = true;
  bool _gameCompleted = false;
  int _mistakeCount = 0;
  final DateTime _startTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    _startNewGame();
  }

  void _startNewGame() {
    setState(() {
      _shuffledSteps = List<_TeaStep>.from(_canonicalSteps)..shuffle();
      _completedStepIndices.clear();
      _currentExpectedStep = 0;
      _feedbackMessage = null;
      _isSuccessFeedback = true;
      _gameCompleted = false;
      _mistakeCount = 0;
    });
  }

  void _onStepTapped(_TeaStep step) {
    if (_gameCompleted) return;
    if (_completedStepIndices.contains(step.orderIndex)) return;

    final l = LocalDataService.instance.localizations;

    if (step.orderIndex == _currentExpectedStep) {
      setState(() {
        _completedStepIndices.add(step.orderIndex);
        _currentExpectedStep++;
        _isSuccessFeedback = true;

        if (_currentExpectedStep == 4) {
          _gameCompleted = true;
          _feedbackMessage = l.congratulations;
          _recordResult();
        } else {
          _feedbackMessage = l.feedbackCorrectStep;
        }
      });
    } else {
      setState(() {
        _mistakeCount++;
        _isSuccessFeedback = false;
        _feedbackMessage = switch (_currentExpectedStep) {
          0 => l.feedbackBoilFirst,
          1 => l.feedbackLeavesSecond,
          2 => l.feedbackMilkThird,
          _ => l.feedbackStrainLast,
        };
      });
    }
  }

  void _recordResult() {
    final durationSeconds = DateTime.now().difference(_startTime).inSeconds;
    final score = (_mistakeCount == 0) ? 100 : (_mistakeCount == 1 ? 95 : 90);
    final l = LocalDataService.instance.localizations;

    LocalDataService.instance.recordGameCompletion(
      title: l.sequenceGameTitle,
      category: 'Sequence',
      score: score,
      accuracy: score,
      durationSeconds: durationSeconds > 0 ? durationSeconds : 65,
      icon: Icons.coffee_rounded,
    );
  }

  String _getStepTitle(int orderIndex) {
    final l = LocalDataService.instance.localizations;
    return switch (orderIndex) {
      0 => l.stepBoilWater,
      1 => l.stepTeaLeaves,
      2 => l.stepGingerMilk,
      _ => l.stepStrainCup,
    };
  }

  String _getStepSubtitle(int orderIndex) {
    final l = LocalDataService.instance.localizations;
    return switch (orderIndex) {
      0 => l.stepBoilWaterDesc,
      1 => l.stepTeaLeavesDesc,
      2 => l.stepGingerMilkDesc,
      _ => l.stepStrainCupDesc,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l = LocalDataService.instance.localizations;

    return Scaffold(
      backgroundColor: AppColors.ivory,
      appBar: AppBar(
        backgroundColor: AppColors.ivory,
        elevation: 0,
        title: Text(
          l.sequenceGameTitle,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: l.playAgain,
            onPressed: _startNewGame,
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 32),
          children: [
            // Instructions Banner
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.line),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, color: AppColors.teal, size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      l.teaSequenceInstructions,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.charcoal,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Sequence Step Cards
            ..._shuffledSteps.map((step) {
              final isCompleted = _completedStepIndices.contains(step.orderIndex);
              final title = _getStepTitle(step.orderIndex);
              final subtitle = _getStepSubtitle(step.orderIndex);

              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: InkWell(
                  onTap: () => _onStepTapped(step),
                  borderRadius: BorderRadius.circular(20),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: isCompleted ? const Color(0xFFF0FDF4) : AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isCompleted ? const Color(0xFF86EFAC) : AppColors.line,
                        width: isCompleted ? 2 : 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: isCompleted ? const Color(0xFFDCFCE7) : AppColors.sage,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Center(
                            child: isCompleted
                                ? const Icon(Icons.check_circle_rounded, color: Color(0xFF16A34A), size: 30)
                                : Text(step.emoji, style: const TextStyle(fontSize: 26)),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: isCompleted ? const Color(0xFF15803D) : AppColors.charcoal,
                                    ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                subtitle,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      fontSize: 13,
                                      color: isCompleted ? const Color(0xFF166534) : AppColors.muted,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        if (isCompleted)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDCFCE7),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              'Step ${_completedStepIndices.indexOf(step.orderIndex) + 1}',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF16A34A),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(height: 10),

            // Live Feedback Banner
            if (_feedbackMessage != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                decoration: BoxDecoration(
                  color: _isSuccessFeedback ? const Color(0xFFEFF6FF) : const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _isSuccessFeedback ? const Color(0xFF93C5FD) : const Color(0xFFFCD34D),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _isSuccessFeedback ? Icons.check_circle_outline_rounded : Icons.lightbulb_outline_rounded,
                      color: _isSuccessFeedback ? AppColors.tealDark : const Color(0xFFB45309),
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _feedbackMessage!,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: _isSuccessFeedback ? AppColors.tealDark : const Color(0xFF92400E),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Completion Celebration Card
            if (_gameCompleted) ...[
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: AppColors.teal,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.teal.withOpacity(0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text('☕ ✨', style: TextStyle(fontSize: 40)),
                    const SizedBox(height: 10),
                    Text(
                      l.congratulations,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l.congratulationsDesc,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withOpacity(0.92),
                            fontSize: 14,
                          ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: Colors.white, width: 1.5),
                              minimumSize: const Size.fromHeight(50),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: _startNewGame,
                            child: Text(
                              l.playAgain,
                              style: const TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton(
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: AppColors.tealDark,
                              minimumSize: const Size.fromHeight(50),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text(
                              l.finishActivity,
                              style: const TextStyle(fontWeight: FontWeight.w800),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
