import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../services/local_data_service.dart';

class MemoriesScreen extends StatefulWidget {
  const MemoriesScreen({super.key});

  @override
  State<MemoriesScreen> createState() => _MemoriesScreenState();
}

class _MemoriesScreenState extends State<MemoriesScreen> {
  final Map<String, int?> _selectedOptions = {};
  final Map<String, bool> _showHints = {};

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: LocalDataService.instance,
      builder: (context, _) {
        final data = LocalDataService.instance;
        final l = data.localizations;
        final memories = data.memories;

        return Scaffold(
          backgroundColor: AppColors.ivory,
          appBar: AppBar(
            title: Text(l.memoryJournal, style: const TextStyle(fontWeight: FontWeight.w700)),
            centerTitle: false,
            backgroundColor: AppColors.ivory,
            elevation: 0,
          ),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 32),
              children: [
                Text(
                  l.memoryJournal,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 6),
                Text(
                  l.lookAtPhotos,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 24),
                ...memories.map((memory) => _buildMemoryCard(memory)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMemoryCard(MemoryItem memory) {
    final l = LocalDataService.instance.localizations;
    final selectedIdx = _selectedOptions[memory.id];
    final showHint = _showHints[memory.id] ?? false;
    final isAnswered = selectedIdx != null;
    final isCorrect = selectedIdx == memory.correctIndex;

    final localizedTitle = l.memoryTitle(memory.id, memory.title);
    final localizedDesc = l.memoryDesc(memory.id, memory.description);
    final localizedPrompt = l.memoryQuizPrompt(memory.id, memory.recallPrompt);

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.line),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Emoji Photo Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              color: AppColors.sage,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                memory.photoIcon,
                style: const TextStyle(fontSize: 44, letterSpacing: 6),
              ),
            ),
          ),
          const SizedBox(height: 18),

          // Date & Place tags
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.ivory,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.line),
                ),
                child: Text(
                  memory.date,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.muted),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Row(
                  children: [
                    const Icon(Icons.place_outlined, size: 15, color: AppColors.teal),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        memory.place,
                        style: const TextStyle(fontSize: 12, color: AppColors.tealDark, fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Title & Description
          Text(
            localizedTitle,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 22),
          ),
          const SizedBox(height: 10),
          Text(
            localizedDesc,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.55),
          ),
          const SizedBox(height: 20),
          const Divider(height: 1),
          const SizedBox(height: 18),

          // Recall Prompt Box
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FBFF),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.line),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.psychology_outlined, color: AppColors.teal, size: 22),
                    const SizedBox(width: 8),
                    Text(
                      l.recallPromptLabel.toUpperCase(),
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.tealDark, letterSpacing: 0.8),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  localizedPrompt,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 16),
                ),
                const SizedBox(height: 14),

                // Choice Options
                ...List.generate(memory.options.length, (optIdx) {
                  final optionText = memory.options[optIdx];
                  final isThisSelected = selectedIdx == optIdx;
                  final isThisCorrect = optIdx == memory.correctIndex;

                  Color optionBg = AppColors.surface;
                  Color optionBorder = AppColors.line;
                  Widget? iconTrailing;

                  if (isAnswered) {
                    if (isThisSelected) {
                      if (isThisCorrect) {
                        optionBg = const Color(0xFFF0FDF4);
                        optionBorder = const Color(0xFF86EFAC);
                        iconTrailing = const Icon(Icons.check_circle_rounded, color: Color(0xFF16A34A), size: 22);
                      } else {
                        optionBg = const Color(0xFFFEF2F2);
                        optionBorder = const Color(0xFFFCA5A5);
                        iconTrailing = const Icon(Icons.cancel_rounded, color: Color(0xFFDC2626), size: 22);
                      }
                    } else if (isThisCorrect) {
                      optionBg = const Color(0xFFF0FDF4);
                      optionBorder = const Color(0xFF86EFAC);
                      iconTrailing = const Icon(Icons.check_circle_outline, color: Color(0xFF16A34A), size: 22);
                    }
                  }

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: InkWell(
                      onTap: isAnswered
                          ? null
                          : () {
                              setState(() {
                                _selectedOptions[memory.id] = optIdx;
                              });

                              if (optIdx == memory.correctIndex) {
                                LocalDataService.instance.recordGameCompletion(
                                  title: localizedTitle,
                                  category: 'Memory Recall',
                                  score: 100,
                                  accuracy: 100,
                                  durationSeconds: 40,
                                  icon: Icons.photo_library_outlined,
                                );
                              }
                            },
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: optionBg,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: optionBorder, width: isThisSelected ? 2 : 1),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                optionText,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: isThisSelected
                                      ? (isThisCorrect ? const Color(0xFF15803D) : const Color(0xFF991B1B))
                                      : AppColors.charcoal,
                                ),
                              ),
                            ),
                            if (iconTrailing != null) iconTrailing,
                          ],
                        ),
                      ),
                    ),
                  );
                }),

                // Hint Toggle & Text
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _showHints[memory.id] = !showHint;
                        });
                      },
                      icon: const Icon(Icons.lightbulb_outline_rounded, size: 18, color: AppColors.teal),
                      label: Text(
                        showHint ? 'Hide hint' : l.hintLabel,
                        style: const TextStyle(fontSize: 13, color: AppColors.teal, fontWeight: FontWeight.w700),
                      ),
                    ),
                    if (isAnswered)
                      Text(
                        isCorrect ? 'Remembered nicely! ✓' : 'Good reflection!',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: isCorrect ? const Color(0xFF16A34A) : AppColors.muted,
                        ),
                      ),
                  ],
                ),
                if (showHint)
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFBEB),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFFDE68A)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('💡 ', style: TextStyle(fontSize: 16)),
                        Expanded(
                          child: Text(
                            memory.hint,
                            style: const TextStyle(fontSize: 13, color: Color(0xFF92400E)),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
