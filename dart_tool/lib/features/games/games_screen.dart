import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../services/local_data_service.dart';
import 'matching_game_screen.dart';
import 'sequence_game_screen.dart';

class GamesScreen extends StatelessWidget {
  const GamesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: LocalDataService.instance,
      builder: (context, _) {
        final l = LocalDataService.instance.localizations;

        return Scaffold(
          backgroundColor: AppColors.ivory,
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text(l.activitiesListTitle, style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 8),
                Text(
                  l.activitiesListSubtitle,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 28),

                // 1. Tea Sequence Game (Playable)
                _ActivityRow(
                  icon: Icons.coffee_rounded,
                  title: l.teaRoutineTitle,
                  detail: l.teaRoutineDetail,
                  difficulty: '${l.teaRoutineSubtitle.split('·').first.trim()} · 3 ${l.minutesUnit}',
                  startLabel: l.startButtonLabel,
                  featured: true,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const DailySequenceGameScreen()),
                    );
                  },
                ),
                const Divider(height: 1),

                // 2. Cultural Card Match (Playable)
                _ActivityRow(
                  icon: Icons.grid_view_rounded,
                  title: l.cardMatchTitle,
                  detail: l.cardMatchDetail,
                  difficulty: '${l.cardMatchSubtitle.split('·').first.trim()} · 4 ${l.minutesUnit}',
                  startLabel: l.startButtonLabel,
                  featured: true,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const MatchingGameScreen()),
                    );
                  },
                ),
                const Divider(height: 1),

                // 3. Picture Recall
                _ActivityRow(
                  icon: Icons.lightbulb_outline,
                  title: l.pictureRecallTitle,
                  detail: l.pictureRecallDetail,
                  difficulty: '${l.memoriesSubtitle.split('·').first.trim()} · 4 ${l.minutesUnit}',
                  startLabel: l.startButtonLabel,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const MatchingGameScreen()),
                    );
                  },
                ),
                const Divider(height: 1),

                // 4. Daily Sequence
                _ActivityRow(
                  icon: Icons.timeline_rounded,
                  title: l.householdRoutineTitle,
                  detail: l.householdRoutineDetail,
                  difficulty: '${l.teaRoutineSubtitle.split('·').first.trim()} · 3 ${l.minutesUnit}',
                  startLabel: l.startButtonLabel,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const DailySequenceGameScreen()),
                    );
                  },
                ),

                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.sage.withValues(alpha: 0.65),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.line),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.offline_pin_outlined, color: AppColors.tealDark),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          l.offlineActivitiesBanner,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.tealDark),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ActivityRow extends StatelessWidget {
  const _ActivityRow({
    required this.icon,
    required this.title,
    required this.detail,
    required this.difficulty,
    required this.startLabel,
    required this.onTap,
    this.featured = false,
  });

  final IconData icon;
  final String title, detail, difficulty, startLabel;
  final VoidCallback onTap;
  final bool featured;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '$title. $detail. $difficulty',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: featured ? AppColors.sage : AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: featured ? AppColors.teal : AppColors.line),
                ),
                child: Icon(icon, color: AppColors.tealDark, size: 28),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(detail, style: Theme.of(context).textTheme.bodyMedium),
                    const SizedBox(height: 6),
                    Text(
                      difficulty,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.tealDark,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: onTap,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.teal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  minimumSize: const Size(64, 42),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text(startLabel, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
