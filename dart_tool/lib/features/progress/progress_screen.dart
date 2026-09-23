import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../services/local_data_service.dart';
import '../../widgets/section_heading.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: LocalDataService.instance,
      builder: (context, _) {
        final data = LocalDataService.instance;
        final l = data.localizations;
        final history = data.history;

        return Scaffold(
          backgroundColor: AppColors.ivory,
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              children: [
                Text(l.yourProgressTitle, style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 8),
                Text(
                  l.progressSubtitle,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 28),

                // Weekly Engagement Bar Chart
                SectionHeading(title: l.weeklyEngagementTitle),
                const SizedBox(height: 16),
                _WeekBars(activitiesCount: data.completedActivitiesCount),
                const SizedBox(height: 28),

                // Dynamic Stat Cards
                Row(
                  children: [
                    Expanded(
                      child: _Stat('${data.completedActivitiesCount}', l.activitiesCompletedStat),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _Stat('${data.currentStreakDays} ${l.daysUnit}', l.currentStreakStat),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _Stat('${data.averageAccuracy}%', l.averageAccuracyStat),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _Stat('${data.practiceMinutes} ${l.minutesUnit}', l.practiceTimeStat),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Dynamic Activity History List
                SectionHeading(title: l.recentActivityHistoryTitle),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.line),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: history.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(24),
                          child: Center(
                            child: Text(
                              l.noActivitiesYetDesc,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: AppColors.muted),
                            ),
                          ),
                        )
                      : Column(
                          children: List.generate(history.length, (index) {
                            final item = history[index];
                            final isLast = index == history.length - 1;

                            return Column(
                              children: [
                                ListTile(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                                  leading: Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: AppColors.sage,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(item.icon, color: AppColors.tealDark, size: 24),
                                  ),
                                  title: Text(
                                    item.title,
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 16),
                                  ),
                                  subtitle: Text(
                                    '${item.timeAgo} · ${item.category}',
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 13),
                                  ),
                                  trailing: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF0FDF4),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: const Color(0xFF86EFAC)),
                                    ),
                                    child: Text(
                                      '${item.accuracy}%',
                                      style: const TextStyle(
                                        color: AppColors.success,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ),
                                if (!isLast) const Divider(height: 1, indent: 18, endIndent: 18),
                              ],
                            );
                          }),
                        ),
                ),
                const SizedBox(height: 24),

                // Supportive Note
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.sage.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.shield_outlined, color: AppColors.teal, size: 20),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'These gentle insights show your everyday practice routines. Final clinical insights remain with your doctor.',
                          style: TextStyle(fontSize: 12, color: AppColors.tealDark, height: 1.4),
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

class _Stat extends StatelessWidget {
  const _Stat(this.value, this.label);
  final String value, label;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.line),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.tealDark,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 4),
            Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      );
}

class _WeekBars extends StatelessWidget {
  const _WeekBars({required this.activitiesCount});
  final int activitiesCount;

  @override
  Widget build(BuildContext context) {
    // Dynamic height for today based on activitiesCount
    final todayHeight = (activitiesCount * 22.0).clamp(24.0, 78.0);
    final heights = [28.0, 46.0, 36.0, todayHeight, 42.0, 20.0, 0.0];
    const labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return Container(
      height: 146,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.line),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(
          7,
          (i) => Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  height: heights[i],
                  width: 20,
                  decoration: BoxDecoration(
                    color: i == 3 ? AppColors.teal : AppColors.sage,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  labels[i],
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 12,
                        fontWeight: i == 3 ? FontWeight.w700 : FontWeight.w500,
                        color: i == 3 ? AppColors.tealDark : AppColors.muted,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
