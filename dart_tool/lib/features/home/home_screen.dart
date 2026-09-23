import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../localization/app_localizations.dart';
import '../../models/connectivity_state.dart';
import '../../services/local_data_service.dart';
import '../../widgets/connectivity_banner.dart';
import '../../widgets/role_switcher.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.localizations,
    required this.connection,
    required this.onOpenActivities,
    this.onOpenMemories,
    this.onOpenVoice,
    this.onNavigateTab,
  });

  final AppLocalizations localizations;
  final SmritiConnectionState connection;
  final VoidCallback onOpenActivities;
  final VoidCallback? onOpenMemories;
  final VoidCallback? onOpenVoice;
  final ValueChanged<int>? onNavigateTab;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: LocalDataService.instance,
      builder: (context, _) {
        final data = LocalDataService.instance;
        final patientName = data.authFullName ?? 'Bhaben Borah';
        final reminders = data.reminders;
        final activities = data.activities;
        final completedActivities = activities.where((a) => a.done).length;
        final careCount = data.careCircle.length;

        // Current date formatting
        final now = DateTime.now();
        final weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
        final months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
        final dayName = weekdays[now.weekday - 1];
        final monthName = months[now.month - 1];
        final dateStr = '$dayName\n${now.day} $monthName';

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(36, 24, 36, 60),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1450),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Action & Patient ID row
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  runSpacing: 10,
                  spacing: 12,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.sky,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.line),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.badge_outlined, size: 16, color: AppColors.blue),
                          const SizedBox(width: 6),
                          Text(
                            'Patient ID: ${data.patientId}',
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: AppColors.ink),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (onOpenVoice != null) ...[
                          IconButton(
                            style: IconButton.styleFrom(
                              backgroundColor: AppColors.sky,
                              foregroundColor: AppColors.blue,
                              padding: const EdgeInsets.all(10),
                            ),
                            icon: const Icon(Icons.mic, size: 20),
                            onPressed: onOpenVoice,
                          ),
                          const SizedBox(width: 8),
                        ],
                        const RoleSwitcher(),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // 1. Dashboard Hero Banner
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    gradient: AppColors.dashboardGradient,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.blue.withValues(alpha: 0.25),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    children: [
                      // Watermark Sun glyph
                      Positioned(
                        right: -10,
                        top: -50,
                        child: IgnorePointer(
                          child: Text(
                            '☀',
                            style: TextStyle(
                              fontSize: 170,
                              color: Colors.white.withValues(alpha: 0.12),
                            ),
                          ),
                        ),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'YOUR DAY WITH SMRITI',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.85),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.4,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'A calm, connected day awaits, $patientName.',
                                  style: const TextStyle(
                                    fontFamily: AppFonts.heading,
                                    fontFamilyFallback: AppFonts.headingFallback,
                                    fontSize: 32,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                    height: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                const Text(
                                  'Small moments matter. Here is a gentle overview of today.',
                                  style: TextStyle(color: Color(0xFFDBE8FF), fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 20),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.23)),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Text(
                              dateStr,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                height: 1.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // 2. Dashboard Grid (1.25fr Left : 0.75fr Right)
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth.isFinite && constraints.maxWidth > 850;

                    final leftColumn = Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Today's Rhythm Card
                        Container(
                          padding: const EdgeInsets.all(22),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: AppColors.line),
                            boxShadow: AppColors.cardShadow,
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Today’s rhythm',
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.ink),
                                  ),
                                  TextButton(
                                    onPressed: () => onNavigateTab?.call(2), // go to Engage
                                    child: const Text('View all', style: TextStyle(color: AppColors.blue, fontWeight: FontWeight.w700)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              ...reminders.take(3).map((r) {
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF7FAFF),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      InkWell(
                                        onTap: () => data.toggleReminder(r.id),
                                        borderRadius: BorderRadius.circular(8),
                                        child: Container(
                                          width: 24,
                                          height: 24,
                                          decoration: BoxDecoration(
                                            color: r.completed ? AppColors.green : Colors.white,
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(color: r.completed ? AppColors.green : const Color(0xFFAEBFDA), width: 2),
                                          ),
                                          child: r.completed
                                              ? const Icon(Icons.check, color: Colors.white, size: 16)
                                              : null,
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                      SizedBox(
                                        width: 54,
                                        child: Text(
                                          r.timeStr,
                                          style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.blue, fontSize: 13),
                                        ),
                                      ),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              r.title,
                                              style: TextStyle(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 14,
                                                color: r.completed ? AppColors.muted : AppColors.ink,
                                                decoration: r.completed ? TextDecoration.lineThrough : null,
                                              ),
                                            ),
                                            Text(
                                              r.category,
                                              style: const TextStyle(fontSize: 12, color: AppColors.muted),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // 3 Metric Cards
                        LayoutBuilder(
                          builder: (context, mConstraints) {
                            final mIsWide = mConstraints.maxWidth.isFinite && mConstraints.maxWidth > 550;
                            final children = [
                              _buildMetricCard(
                                label: 'DAILY PROGRESS',
                                value: '$completedActivities/4',
                                progress: completedActivities / 4,
                              ),
                              _buildMetricCard(
                                label: 'WATER TODAY',
                                value: '${data.hydrationCount} glasses',
                                progress: data.hydrationCount / 8,
                              ),
                              _buildMetricCard(
                                label: 'MEMORY STREAK',
                                value: '${data.currentStreakDays} days',
                                subtitle: 'You are doing beautifully.',
                              ),
                            ];

                            if (mIsWide) {
                              return Row(
                                children: children.map((c) => Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 5), child: c))).toList(),
                              );
                            }
                            return Column(
                              children: children.map((c) => Padding(padding: const EdgeInsets.only(bottom: 12), child: c)).toList(),
                            );
                          },
                        ),
                        const SizedBox(height: 20),

                        // Regional Diet: Today's Meals & Next Meal
                        _buildMealsCard(context, data),
                        const SizedBox(height: 20),

                        // Today's Gentle Challenge Hero Card
                        Container(
                          padding: const EdgeInsets.all(26),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEAF2FF),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'TODAY’S GENTLE CHALLENGE',
                                      style: TextStyle(color: AppColors.blue, fontWeight: FontWeight.w700, fontSize: 11, letterSpacing: 1.2),
                                    ),
                                    SizedBox(height: 6),
                                    Text(
                                      'Share one fond memory',
                                      style: TextStyle(
                                        fontFamily: AppFonts.heading,
                                        fontFamilyFallback: AppFonts.headingFallback,
                                        fontSize: 24,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.ink,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'A small story is a gift for your family.',
                                      style: TextStyle(color: AppColors.muted, fontSize: 13),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              FilledButton(
                                style: FilledButton.styleFrom(
                                  backgroundColor: AppColors.blue,
                                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                onPressed: () {
                                  onNavigateTab?.call(1); // go to Remember
                                },
                                child: const Text('Tell a story', style: TextStyle(fontWeight: FontWeight.w700)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );

                    final rightColumn = Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildQuickCard(
                          icon: '◈',
                          title: 'Memory game',
                          subtitle: 'A 3-minute brain warm-up',
                          actionLabel: 'Choose a game',
                          onAction: () => onNavigateTab?.call(1),
                        ),
                        const SizedBox(height: 18),
                        _buildQuickCard(
                          icon: '◉',
                          title: 'Talk to SMRITI',
                          subtitle: 'Use your voice, in your own words',
                          actionLabel: 'Start talking',
                          onAction: () => onOpenVoice?.call(),
                        ),
                        const SizedBox(height: 18),
                        _buildQuickCard(
                          icon: '♡',
                          title: 'Care Circle',
                          subtitle: '$careCount loved ones connected',
                          actionLabel: 'See circle',
                          onAction: () => onNavigateTab?.call(3),
                        ),
                      ],
                    );

                    if (isWide) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 5, child: leftColumn),
                          const SizedBox(width: 20),
                          Expanded(flex: 3, child: rightColumn),
                        ],
                      );
                    } else {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          leftColumn,
                          const SizedBox(height: 20),
                          rightColumn,
                        ],
                      );
                    }
                  },
                ),
                const SizedBox(height: 32),

                // Connectivity Banner
                ConnectivityBanner(state: connection),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMetricCard({
    required String label,
    required String value,
    double? progress,
    String? subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F8FF),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.muted, letterSpacing: 0.8)),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.ink)),
          const SizedBox(height: 8),
          if (progress != null)
            Container(
              height: 8,
              decoration: BoxDecoration(color: const Color(0xFFE6EDF9), borderRadius: BorderRadius.circular(99)),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: progress.clamp(0.0, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFF1950C6), Color(0xFF5B95F8)]),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
            )
          else if (subtitle != null)
            Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.muted)),
        ],
      ),
    );
  }

  Widget _buildQuickCard({
    required String icon,
    required String title,
    required String subtitle,
    required String actionLabel,
    required VoidCallback onAction,
  }) {
    return Container(
      constraints: const BoxConstraints(minHeight: 140),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.line),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(icon, style: const TextStyle(fontSize: 26, color: AppColors.blue)),
          const SizedBox(height: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.ink)),
              const SizedBox(height: 2),
              Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.muted)),
            ],
          ),
          const SizedBox(height: 14),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              backgroundColor: const Color(0xFFEEF4FF),
              foregroundColor: AppColors.blue,
              side: BorderSide.none,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: onAction,
            child: Text(actionLabel, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Widget _buildMealsCard(BuildContext context, LocalDataService data) {
    final next = data.nextMeal;
    final meals = data.regionalMeals;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.line),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                localizations.todaysMeals.toUpperCase(),
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: AppColors.muted,
                  letterSpacing: 1.1,
                ),
              ),
              Text(
                data.regionLabel,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  color: AppColors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Next Meal Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFEDF4FF),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.blue.withOpacity(0.25)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.blue,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'NEXT MEAL',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '${next.title} (${next.time})',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: AppColors.ink,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Meals List
          ...meals.map((m) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: InkWell(
                onTap: () => data.completeMeal(m.id),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7FAFF),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: m.completed ? AppColors.green : Colors.white,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: m.completed ? AppColors.green : const Color(0xFFAEBFDA),
                            width: 1.5,
                          ),
                        ),
                        child: m.completed
                            ? const Icon(Icons.check, color: Colors.white, size: 14)
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              m.title,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                color: m.completed ? AppColors.muted : AppColors.ink,
                                decoration: m.completed ? TextDecoration.lineThrough : null,
                              ),
                            ),
                            Text(
                              '${m.mealType.name.toUpperCase()} • ${m.time}',
                              style: const TextStyle(fontSize: 11, color: AppColors.muted),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),

          const SizedBox(height: 8),
          const Text(
            'Culturally familiar regional food routine',
            style: TextStyle(fontSize: 12, color: AppColors.muted, fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }
}
