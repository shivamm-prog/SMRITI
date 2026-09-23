import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../services/local_data_service.dart';
import '../games/digit_sequence_game_screen.dart';
import '../games/matching_game_screen.dart';
import '../games/objects_game_screen.dart';
import '../games/word_recall_screen.dart';

class RememberScreen extends StatefulWidget {
  const RememberScreen({super.key, this.initialTab = 'games', this.autoOpenModal});
  final String initialTab;
  final String? autoOpenModal;

  @override
  State<RememberScreen> createState() => _RememberScreenState();
}

class _RememberScreenState extends State<RememberScreen> {
  String _activeTab = 'games';

  @override
  void initState() {
    super.initState();
    _activeTab = widget.initialTab;
    if (widget.autoOpenModal == 'memory') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _openSaveMemoryModal();
      });
    }
  }

  void _onTabSelected(String tab) {
    if (tab == 'games') {
      setState(() => _activeTab = 'games');
    } else if (tab == 'roots') {
      _openRootsModal();
    } else if (tab == 'journey') {
      _openJourneyModal();
    } else if (tab == 'teach') {
      _openTeachModal();
    } else if (tab == 'nostalgia') {
      _openNostalgiaModal();
    }
  }

  void _openRootsModal() {
    showDialog(
      context: context,
      builder: (ctx) => _buildModalShell(
        title: 'My Roots',
        subtitle: '${LocalDataService.instance.userDistrict}, ${LocalDataService.instance.userState} · ${LocalDataService.instance.userHometown}',
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
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
                          'A PLACE TO KEEP CLOSE',
                          style: TextStyle(color: AppColors.blue, fontWeight: FontWeight.w700, fontSize: 11, letterSpacing: 1.2),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Stories of food, family and home.',
                          style: TextStyle(fontFamily: AppFonts.heading, fontFamilyFallback: AppFonts.headingFallback, fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.ink),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  FilledButton(
                    style: FilledButton.styleFrom(backgroundColor: AppColors.blue, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      _openSaveMemoryModal();
                    },
                    child: const Text('+ Add memory', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ...LocalDataService.instance.memories.map((m) => _buildMemoryRow(m)),
          ],
        ),
      ),
    );
  }

  void _openSaveMemoryModal() {
    final titleCtrl = TextEditingController();
    final dateCtrl = TextEditingController(text: '1975');
    final textCtrl = TextEditingController();
    String selectedCat = 'Childhood';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => _buildModalShell(
          title: 'Save a memory',
          subtitle: 'A story, a recipe, a person or a place — it all belongs here.',
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Give this memory a title', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.ink)),
              const SizedBox(height: 6),
              TextField(controller: titleCtrl, decoration: _modalInputDecoration('e.g. Sunday lunch with my father')),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Category', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.ink)),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          value: selectedCat,
                          decoration: _modalInputDecoration(''),
                          items: ['Childhood', 'Family', 'Food', 'Festivals', 'Hometown', 'Special moments']
                              .map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 14))))
                              .toList(),
                          onChanged: (v) {
                            if (v != null) setModalState(() => selectedCat = v);
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('When was this?', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.ink)),
                        const SizedBox(height: 6),
                        TextField(controller: dateCtrl, decoration: _modalInputDecoration('e.g. 1975')),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text('Tell the story', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.ink)),
              const SizedBox(height: 6),
              TextField(
                controller: textCtrl,
                maxLines: 4,
                decoration: _modalInputDecoration('Write it here, as you remember it…'),
              ),
              const SizedBox(height: 24),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.blue,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  if (titleCtrl.text.trim().isEmpty || textCtrl.text.trim().isEmpty) return;
                  LocalDataService.instance.addMemory(
                    title: titleCtrl.text.trim(),
                    category: selectedCat,
                    date: dateCtrl.text.trim(),
                    text: textCtrl.text.trim(),
                  );
                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Your memory has been saved.'), duration: Duration(seconds: 2)),
                  );
                },
                child: const Text('Save this memory', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openJourneyModal() {
    showDialog(
      context: context,
      builder: (ctx) => _buildModalShell(
        title: 'Memory Journey',
        subtitle: 'A personal timeline, made from the things you choose to keep.',
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ...LocalDataService.instance.memories.map((m) => _buildMemoryRow(m)),
            const SizedBox(height: 18),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.blue,
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                Navigator.of(ctx).pop();
                _openSaveMemoryModal();
              },
              child: const Text('Add to your journey', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }

  void _openTeachModal() {
    final teachCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => _buildModalShell(
        title: 'Teach SMRITI',
        subtitle: 'Your knowledge can become a gift for future generations.',
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF4F8FF),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.line),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Try a prompt', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.ink)),
                  SizedBox(height: 4),
                  Text('“Tell SMRITI something you remember from your childhood.”', style: TextStyle(color: AppColors.muted, fontSize: 13)),
                ],
              ),
            ),
            const SizedBox(height: 18),
            const Text('What would you like to share?', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.ink)),
            const SizedBox(height: 6),
            TextField(
              controller: teachCtrl,
              maxLines: 4,
              decoration: _modalInputDecoration('Tell a story, share a recipe, or describe a tradition from home…'),
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: const Color(0xFFEEF4FF),
                      foregroundColor: AppColors.blue,
                      side: BorderSide.none,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Recording started — speak when you feel ready.'), duration: Duration(seconds: 2)),
                      );
                    },
                    icon: const Icon(Icons.mic, size: 18),
                    label: const Text('Record voice', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      if (teachCtrl.text.trim().isEmpty) return;
                      LocalDataService.instance.addMemory(
                        title: 'A story I taught SMRITI',
                        category: 'Family',
                        date: 'Today',
                        text: teachCtrl.text.trim(),
                        icon: '✦',
                      );
                      Navigator.of(ctx).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Thank you. Your story is safely saved.'), duration: Duration(seconds: 2)),
                      );
                    },
                    child: const Text('Save my story', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _openNostalgiaModal() {
    final prompts = [
      ('🍲', 'What food reminds you of someone you love?'),
      ('🎶', 'What song instantly takes you back?'),
      ('🌧', 'What did a rainy day in your hometown feel like?'),
      ('🏡', 'Who would you find at home after school?'),
    ];

    showDialog(
      context: context,
      builder: (ctx) => _buildModalShell(
        title: 'Nostalgia mode',
        subtitle: 'A gentle space for familiar prompts — no rush, no right answers.',
        content: Column(
          children: prompts.map((p) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.line),
              ),
              child: Row(
                children: [
                  Text(p.$1, style: const TextStyle(fontSize: 24)),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      p.$2,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.ink),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      _openTeachModal();
                    },
                    child: const Text('Reflect', style: TextStyle(color: AppColors.blue, fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  void _openProgressModal() {
    final scores = LocalDataService.instance.gameScores;
    final totalGames = scores.values.fold(0, (a, b) => a + b);

    showDialog(
      context: context,
      builder: (ctx) => _buildModalShell(
        title: 'Your memory rhythm',
        subtitle: 'Progress is about showing up for yourself, never about a score.',
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(color: const Color(0xFFF4F8FF), borderRadius: BorderRadius.circular(14)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('THIS WEEK', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.muted, letterSpacing: 0.8)),
                        const SizedBox(height: 6),
                        Text('$totalGames games', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.ink)),
                        const SizedBox(height: 4),
                        const Text('A steady, thoughtful habit.', style: TextStyle(fontSize: 12, color: AppColors.muted)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(color: const Color(0xFFF4F8FF), borderRadius: BorderRadius.circular(14)),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('CURRENT STREAK', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.muted, letterSpacing: 0.8)),
                        SizedBox(height: 6),
                        Text('3 days', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.ink)),
                        SizedBox(height: 4),
                        Text('Great job!', style: TextStyle(fontSize: 12, color: AppColors.muted)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.line)),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Recent activity', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.ink)),
                  SizedBox(height: 8),
                  Text('Today — Memory Match completed', style: TextStyle(fontSize: 13, color: AppColors.muted)),
                  SizedBox(height: 4),
                  Text('Yesterday — Remember the Sequence played', style: TextStyle(fontSize: 13, color: AppColors.muted)),
                  SizedBox(height: 4),
                  Text('Thursday — A family memory saved', style: TextStyle(fontSize: 13, color: AppColors.muted)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModalShell({required String title, required String subtitle, required Widget content}) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(21)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 540, maxHeight: 750),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(fontFamily: AppFonts.heading, fontFamilyFallback: AppFonts.headingFallback, fontSize: 26, fontWeight: FontWeight.w600, color: AppColors.ink),
                    ),
                  ),
                  IconButton(
                    style: IconButton.styleFrom(backgroundColor: const Color(0xFFEDF4FF), foregroundColor: AppColors.blue),
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, size: 20),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(subtitle, style: const TextStyle(color: AppColors.muted, fontSize: 14)),
              const SizedBox(height: 20),
              Flexible(child: SingleChildScrollView(child: content)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMemoryRow(MemoryItem m) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEDF1F8)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFA8C7FF), Color(0xFFE1EEFF)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(m.photoIcon.isNotEmpty ? m.photoIcon : '✦', style: const TextStyle(fontSize: 24)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(m.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.ink)),
                const SizedBox(height: 3),
                Text(m.description, style: const TextStyle(fontSize: 13, color: AppColors.ink, height: 1.35), maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text('${m.place} · ${m.date}', style: const TextStyle(fontSize: 12, color: AppColors.muted)),
              ],
            ),
          ),
        ],
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
        final scores = data.gameScores;

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(36, 28, 36, 60),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1450),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Page Title
                const Text(
                  'Remember',
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
                  'Your stories, familiar moments, and little challenges — all in one place.',
                  style: TextStyle(color: AppColors.muted, fontSize: 16),
                ),
                const SizedBox(height: 22),

                // Horizontal Section Tabs
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildTabButton('games', 'Memory games'),
                      const SizedBox(width: 8),
                      _buildTabButton('roots', 'My Roots'),
                      const SizedBox(width: 8),
                      _buildTabButton('journey', 'Memory Journey'),
                      const SizedBox(width: 8),
                      _buildTabButton('teach', 'Teach SMRITI'),
                      const SizedBox(width: 8),
                      _buildTabButton('nostalgia', 'Nostalgia'),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // 2-Column Game Cards Grid
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth > 700;
                    return Wrap(
                      spacing: 18,
                      runSpacing: 18,
                      children: [
                        SizedBox(
                          width: isWide ? (constraints.maxWidth - 18) / 2 : constraints.maxWidth,
                          child: _buildGameCard(
                            symbol: '▦',
                            title: 'Memory Match',
                            description: 'Find the familiar pairs.',
                            playCount: scores['match'] ?? 2,
                            onPlay: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const MatchingGameScreen())),
                          ),
                        ),
                        SizedBox(
                          width: isWide ? (constraints.maxWidth - 18) / 2 : constraints.maxWidth,
                          child: _buildGameCard(
                            symbol: '◉',
                            title: 'Remember the Objects',
                            description: 'Notice what you see.',
                            playCount: scores['objects'] ?? 1,
                            onPlay: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ObjectsGameScreen())),
                          ),
                        ),
                        SizedBox(
                          width: isWide ? (constraints.maxWidth - 18) / 2 : constraints.maxWidth,
                          child: _buildGameCard(
                            symbol: '↗',
                            title: 'Remember the Sequence',
                            description: 'Follow the gentle pattern.',
                            playCount: scores['sequence'] ?? 3,
                            onPlay: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const DigitSequenceGameScreen())),
                          ),
                        ),
                        SizedBox(
                          width: isWide ? (constraints.maxWidth - 18) / 2 : constraints.maxWidth,
                          child: _buildGameCard(
                            symbol: 'Aa',
                            title: 'Word Recall',
                            description: 'Bring meaningful words to mind.',
                            playCount: scores['words'] ?? 1,
                            onPlay: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const WordRecallGameScreen())),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 28),

                // Bottom Dashboard Grid: My Roots & Memory Progress
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth > 850;
                    final leftWidth = isWide ? constraints.maxWidth * 0.62 - 9 : constraints.maxWidth;
                    final rightWidth = isWide ? constraints.maxWidth * 0.38 - 9 : constraints.maxWidth;

                    return Wrap(
                      spacing: 18,
                      runSpacing: 18,
                      children: [
                        // Left: My Roots preview card
                        SizedBox(
                          width: leftWidth,
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
                                    const Text('My Roots', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.ink)),
                                    TextButton(
                                      onPressed: _openRootsModal,
                                      child: const Text('View all', style: TextStyle(color: AppColors.blue, fontWeight: FontWeight.w700)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 14),
                                ...data.memories.take(3).map((m) => _buildMemoryRow(m)),
                              ],
                            ),
                          ),
                        ),

                        // Right: Memory Progress card
                        SizedBox(
                          width: rightWidth,
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
                                const Text('Memory progress', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.ink)),
                                const SizedBox(height: 6),
                                const Text('Four sessions this week — a lovely rhythm.', style: TextStyle(color: AppColors.muted, fontSize: 14)),
                                const SizedBox(height: 18),
                                Container(
                                  height: 9,
                                  decoration: BoxDecoration(color: const Color(0xFFE6EDF9), borderRadius: BorderRadius.circular(99)),
                                  child: FractionallySizedBox(
                                    alignment: Alignment.centerLeft,
                                    widthFactor: 0.68,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(colors: [Color(0xFF1950C6), Color(0xFF5B95F8)]),
                                        borderRadius: BorderRadius.circular(99),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 14),
                                const Text('You completed today’s first game challenge.', style: TextStyle(fontSize: 13, color: AppColors.muted)),
                                const SizedBox(height: 20),
                                OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    backgroundColor: const Color(0xFFEEF4FF),
                                    foregroundColor: AppColors.blue,
                                    side: BorderSide.none,
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                  onPressed: _openProgressModal,
                                  child: const Text('See progress', style: TextStyle(fontWeight: FontWeight.w700)),
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

  Widget _buildTabButton(String tabKey, String label) {
    final isActive = _activeTab == tabKey;
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isActive ? AppColors.blue : Colors.white,
        foregroundColor: isActive ? Colors.white : AppColors.muted,
        elevation: 0,
        side: BorderSide(color: isActive ? AppColors.blue : AppColors.line),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      onPressed: () => _onTabSelected(tabKey),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
    );
  }

  Widget _buildGameCard({
    required String symbol,
    required String title,
    required String description,
    required int playCount,
    required VoidCallback onPlay,
  }) {
    return Container(
      constraints: const BoxConstraints(minHeight: 190),
      padding: const EdgeInsets.all(22),
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
          Text(symbol, style: const TextStyle(fontSize: 34, color: AppColors.blue)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: AppColors.ink)),
              const SizedBox(height: 6),
              Text(description, style: const TextStyle(color: AppColors.muted, fontSize: 14, height: 1.4)),
              const SizedBox(height: 8),
              Text('Played $playCount times this week', style: const TextStyle(fontSize: 13, color: AppColors.muted)),
            ],
          ),
          const SizedBox(height: 16),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.blue,
              minimumSize: const Size.fromHeight(46),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: onPlay,
            child: const Text('Play now', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}
