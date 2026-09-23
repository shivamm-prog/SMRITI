import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../models/diet_item.dart';
import '../../services/local_data_service.dart';

class EngageScreen extends StatefulWidget {
  const EngageScreen({super.key});

  @override
  State<EngageScreen> createState() => _EngageScreenState();
}

class _EngageScreenState extends State<EngageScreen> {
  void _openAddActivityModal() {
    final nameCtrl = TextEditingController();
    final detailCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(21)),
        backgroundColor: Colors.white,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Add an activity',
                      style: TextStyle(
                        fontFamily: AppFonts.heading,
                        fontFamilyFallback: AppFonts.headingFallback,
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: AppColors.ink,
                      ),
                    ),
                    IconButton(
                      style: IconButton.styleFrom(backgroundColor: const Color(0xFFEDF4FF), foregroundColor: AppColors.blue),
                      onPressed: () => Navigator.of(ctx).pop(),
                      icon: const Icon(Icons.close, size: 20),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                const Text('Activity', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.ink)),
                const SizedBox(height: 6),
                TextField(
                  controller: nameCtrl,
                  decoration: _modalInputDecoration('e.g. Water the balcony plants'),
                ),
                const SizedBox(height: 16),
                const Text('Helpful detail', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.ink)),
                const SizedBox(height: 6),
                TextField(
                  controller: detailCtrl,
                  decoration: _modalInputDecoration('e.g. 15 minutes'),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.blue,
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    final name = nameCtrl.text.trim();
                    if (name.isEmpty) return;
                    LocalDataService.instance.addCustomActivity(name, detailCtrl.text.trim());
                    Navigator.of(ctx).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Activity added to your day.'), duration: Duration(seconds: 2)),
                    );
                  },
                  child: const Text('Add to today', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _modalInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(11), borderSide: const BorderSide(color: Color(0xFFCBD9EF), width: 1.5)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(11), borderSide: const BorderSide(color: Color(0xFFCBD9EF), width: 1.5)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(11), borderSide: const BorderSide(color: AppColors.blue, width: 2)),
      filled: true,
      fillColor: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: LocalDataService.instance,
      builder: (context, _) {
        final data = LocalDataService.instance;
        final activities = data.activities;
        final completedCount = activities.where((a) => a.done).length;
        final hydration = data.hydrationCount;
        final regionalMeals = data.regionalMeals;

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(36, 28, 36, 60),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1450),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                const Text(
                  'Engage',
                  style: TextStyle(
                    fontFamily: AppFonts.heading,
                    fontFamilyFallback: AppFonts.headingFallback,
                    fontSize: 37,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.8,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 7),
                const Text(
                  'Gentle activities that make every day feel more yours.',
                  style: TextStyle(color: AppColors.muted, fontSize: 16),
                ),
                const SizedBox(height: 26),

                // Top 3-Column Grid: Activities, Hydration, Music
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth > 950;
                    final colWidth = isWide ? (constraints.maxWidth - 36) / 3 : constraints.maxWidth;

                    return Wrap(
                      spacing: 18,
                      runSpacing: 18,
                      children: [
                        // 1. Today's Activities Card
                        SizedBox(
                          width: colWidth,
                          child: Container(
                            padding: const EdgeInsets.all(22),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: AppColors.line),
                              boxShadow: AppColors.cardShadow,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Today’s activities', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.ink)),
                                    TextButton(
                                      onPressed: _openAddActivityModal,
                                      child: const Text('+ Add', style: TextStyle(color: AppColors.blue, fontWeight: FontWeight.w700)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                ...activities.asMap().entries.map((entry) {
                                  final idx = entry.key;
                                  final act = entry.value;
                                  return Container(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    decoration: const BoxDecoration(
                                      border: Border(bottom: BorderSide(color: Color(0xFFEDF1F8))),
                                    ),
                                    child: Row(
                                      children: [
                                        InkWell(
                                          onTap: () {
                                            data.toggleActivity(idx);
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text(act.done ? 'Activity completed — wonderful!' : 'Activity marked for later.'),
                                                duration: const Duration(seconds: 2),
                                              ),
                                            );
                                          },
                                          borderRadius: BorderRadius.circular(8),
                                          child: Container(
                                            width: 24,
                                            height: 24,
                                            decoration: BoxDecoration(
                                              color: act.done ? AppColors.green : Colors.white,
                                              borderRadius: BorderRadius.circular(8),
                                              border: Border.all(color: act.done ? AppColors.green : const Color(0xFFAEBFDA), width: 2),
                                            ),
                                            child: act.done
                                                ? const Icon(Icons.check, color: Colors.white, size: 16)
                                                : null,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                act.title,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 14,
                                                  color: act.done ? AppColors.muted : AppColors.ink,
                                                  decoration: act.done ? TextDecoration.lineThrough : null,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(act.detail, style: const TextStyle(fontSize: 12, color: AppColors.muted)),
                                            ],
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.muted),
                                          onPressed: () => data.removeActivity(idx),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                                const SizedBox(height: 16),
                                Container(
                                  height: 9,
                                  decoration: BoxDecoration(color: const Color(0xFFE6EDF9), borderRadius: BorderRadius.circular(99)),
                                  child: FractionallySizedBox(
                                    alignment: Alignment.centerLeft,
                                    widthFactor: activities.isEmpty ? 0 : (completedCount / activities.length).clamp(0.0, 1.0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(colors: [Color(0xFF1950C6), Color(0xFF5B95F8)]),
                                        borderRadius: BorderRadius.circular(99),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text('$completedCount of ${activities.length} complete today', style: const TextStyle(fontSize: 12, color: AppColors.muted)),
                              ],
                            ),
                          ),
                        ),

                        // 2. Hydration Card with Visual Water Vessel
                        SizedBox(
                          width: colWidth,
                          child: Container(
                            padding: const EdgeInsets.all(22),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: AppColors.line),
                              boxShadow: AppColors.cardShadow,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Hydration', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.ink)),
                                    Text('$hydration/8', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.blue)),
                                  ],
                                ),
                                const SizedBox(height: 14),

                                // Water Cup graphic
                                Center(
                                  child: Container(
                                    height: 140,
                                    width: 110,
                                    decoration: BoxDecoration(
                                      border: Border.all(color: const Color(0xFFA8C6FA), width: 3),
                                      borderRadius: const BorderRadius.only(
                                        bottomLeft: Radius.circular(28),
                                        bottomRight: Radius.circular(28),
                                      ),
                                    ),
                                    clipBehavior: Clip.antiAlias,
                                    child: Align(
                                      alignment: Alignment.bottomCenter,
                                      child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 350),
                                        height: 140 * (hydration / 8).clamp(0.0, 1.0),
                                        width: double.infinity,
                                        decoration: const BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [Color(0xFF70AFFF), Color(0xFF2164D1)],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                FilledButton(
                                  style: FilledButton.styleFrom(
                                    backgroundColor: AppColors.blue,
                                    minimumSize: const Size.fromHeight(48),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  onPressed: () {
                                    if (hydration < 8) {
                                      data.addWaterGlass();
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('One glass added. Lovely!'), duration: Duration(seconds: 2)),
                                      );
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('You have reached today’s water goal.'), duration: Duration(seconds: 2)),
                                      );
                                    }
                                  },
                                  child: const Text('+ Add a glass', style: TextStyle(fontWeight: FontWeight.w700)),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // 3. Listen & Remember Card
                        SizedBox(
                          width: colWidth,
                          child: Container(
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
                                const Text('Listen & remember', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.ink)),
                                const SizedBox(height: 4),
                                const Text('Music that feels like home.', style: TextStyle(color: AppColors.muted, fontSize: 13)),
                                const SizedBox(height: 16),
                                ...['O mor aponar desh', 'Bihu rhythm — instrumental', 'Evening by the Brahmaputra'].map((song) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                    decoration: const BoxDecoration(
                                      border: Border(bottom: BorderSide(color: Color(0xFFEDF1F8))),
                                    ),
                                    child: Row(
                                      children: [
                                        IconButton(
                                          style: IconButton.styleFrom(
                                            backgroundColor: const Color(0xFFE8F1FF),
                                            foregroundColor: AppColors.blue,
                                            iconSize: 18,
                                          ),
                                          onPressed: () {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text('Now playing: $song'), duration: const Duration(seconds: 2)),
                                            );
                                          },
                                          icon: const Icon(Icons.play_arrow_rounded),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(song, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.ink)),
                                              const SizedBox(height: 2),
                                              const Text('Familiar favourites', style: TextStyle(fontSize: 11, color: AppColors.muted)),
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
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 28),

                // Bottom 2-Column Grid: Meals Today & Move Gently
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth > 800;
                    final halfWidth = isWide ? (constraints.maxWidth - 18) / 2 : constraints.maxWidth;

                    return Wrap(
                      spacing: 18,
                      runSpacing: 18,
                      children: [
                        // Meals Today Card
                        SizedBox(
                          width: halfWidth,
                          child: Container(
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
                                    const Text('Meals today', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.ink)),
                                    Text(data.regionLabel, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.blue)),
                                  ],
                                ),
                                const SizedBox(height: 14),
                                ...regionalMeals.take(3).map((meal) {
                                  final icon = switch (meal.mealType) {
                                    MealType.breakfast => '☀',
                                    MealType.lunch => '◐',
                                    MealType.dinner => '☾',
                                    MealType.snack => '☕',
                                  };
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 10),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF7FAFF),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      children: [
                                        Text(icon, style: const TextStyle(fontSize: 20)),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(meal.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.ink)),
                                              const SizedBox(height: 2),
                                              Text(meal.description, style: const TextStyle(fontSize: 12, color: AppColors.muted), maxLines: 1, overflow: TextOverflow.ellipsis),
                                            ],
                                          ),
                                        ),
                                        if (meal.completed)
                                          const Icon(Icons.check_circle, color: AppColors.green, size: 20),
                                      ],
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                        ),

                        // Move Gently Card
                        SizedBox(
                          width: halfWidth,
                          child: Container(
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
                                const Text('Move gently', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.ink)),
                                const SizedBox(height: 4),
                                const Text('A short walk or stretch is a lovely way to reset.', style: TextStyle(color: AppColors.muted, fontSize: 14)),
                                const SizedBox(height: 18),
                                Row(
                                  children: [
                                    Expanded(
                                      child: InkWell(
                                        onTap: () {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Walk recorded for today. Well done!'), duration: Duration(seconds: 2)),
                                          );
                                        },
                                        borderRadius: BorderRadius.circular(14),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(vertical: 20),
                                          decoration: BoxDecoration(
                                            border: Border.all(color: AppColors.line, width: 1.5),
                                            borderRadius: BorderRadius.circular(14),
                                            color: Colors.white,
                                          ),
                                          child: const Column(
                                            children: [
                                              Text('🚶', style: TextStyle(fontSize: 30)),
                                              SizedBox(height: 8),
                                              Text('20-minute walk', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.ink)),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: InkWell(
                                        onTap: () {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Stretching recorded for today. Well done!'), duration: Duration(seconds: 2)),
                                          );
                                        },
                                        borderRadius: BorderRadius.circular(14),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(vertical: 20),
                                          decoration: BoxDecoration(
                                            border: Border.all(color: AppColors.line, width: 1.5),
                                            borderRadius: BorderRadius.circular(14),
                                            color: Colors.white,
                                          ),
                                          child: const Column(
                                            children: [
                                              Text('🤸', style: TextStyle(fontSize: 30)),
                                              SizedBox(height: 8),
                                              Text('10-minute stretch', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.ink)),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
