import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../services/local_data_service.dart';
import '../../widgets/voice_companion_modal.dart';

class ConnectScreen extends StatefulWidget {
  const ConnectScreen({super.key, this.onOpenVoice});
  final VoidCallback? onOpenVoice;

  @override
  State<ConnectScreen> createState() => _ConnectScreenState();
}

class _ConnectScreenState extends State<ConnectScreen> {
  void _openVoice() {
    if (widget.onOpenVoice != null) {
      widget.onOpenVoice!();
    } else {
      VoiceCompanionModal.show(context, onNavigateTab: (_) {});
    }
  }

  void _openCareModal() {
    final nameCtrl = TextEditingController();
    final contactCtrl = TextEditingController();
    String relation = 'Family member';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => _buildModalShell(
          title: 'Add to Care Circle',
          subtitle: 'You decide what information this person can see.',
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Name', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.ink)),
              const SizedBox(height: 6),
              TextField(controller: nameCtrl, decoration: _modalInputDecoration('e.g. Priya Das')),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Relationship', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.ink)),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          value: relation,
                          decoration: _modalInputDecoration(''),
                          items: ['Family member', 'Son / daughter', 'Spouse', 'Caregiver', 'Trusted person']
                              .map((r) => DropdownMenuItem(value: r, child: Text(r, style: const TextStyle(fontSize: 14))))
                              .toList(),
                          onChanged: (v) {
                            if (v != null) setModalState(() => relation = v);
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
                        const Text('Contact', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.ink)),
                        const SizedBox(height: 6),
                        TextField(controller: contactCtrl, decoration: _modalInputDecoration('Phone number')),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F5ED),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Text(
                  'They will be able to see today’s activity completion only.',
                  style: TextStyle(color: Color(0xFF126347), fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 22),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.blue,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  final name = nameCtrl.text.trim();
                  if (name.isEmpty) return;
                  LocalDataService.instance.addCareCircleMember(name, relation, contactCtrl.text.trim());
                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('$name is now in your Care Circle.'), duration: const Duration(seconds: 2)),
                  );
                },
                child: const Text('Add trusted person', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openReminderModal() {
    final titleCtrl = TextEditingController();
    final timeCtrl = TextEditingController(text: '14:00');
    String type = 'Medicine';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => _buildModalShell(
          title: 'New reminder',
          subtitle: 'A gentle cue, right when you need it.',
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('What should we remind you?', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.ink)),
              const SizedBox(height: 6),
              TextField(controller: titleCtrl, decoration: _modalInputDecoration('e.g. Take afternoon medicine')),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Time', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.ink)),
                        const SizedBox(height: 6),
                        TextField(controller: timeCtrl, decoration: _modalInputDecoration('14:00')),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Type', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.ink)),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          value: type,
                          decoration: _modalInputDecoration(''),
                          items: ['Medicine', 'Meals', 'Exercise', 'Water', 'Custom']
                              .map((t) => DropdownMenuItem(value: t, child: Text(t, style: const TextStyle(fontSize: 14))))
                              .toList(),
                          onChanged: (v) {
                            if (v != null) setModalState(() => type = v);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.blue,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  final title = titleCtrl.text.trim();
                  if (title.isEmpty) return;
                  LocalDataService.instance.addReminder(title: title, category: type, timeStr: timeCtrl.text.trim());
                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Reminder saved.'), duration: Duration(seconds: 2)),
                  );
                },
                child: const Text('Save reminder', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openAppointmentModal() {
    final titleCtrl = TextEditingController();
    final timeCtrl = TextEditingController(text: '24 September · 10:30 AM');
    final locCtrl = TextEditingController(text: 'City Clinic');

    showDialog(
      context: context,
      builder: (ctx) => _buildModalShell(
        title: 'Add appointment',
        subtitle: 'Medical visits and family gatherings.',
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Appointment title', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.ink)),
            const SizedBox(height: 6),
            TextField(controller: titleCtrl, decoration: _modalInputDecoration('e.g. Visit with Dr. Sharma')),
            const SizedBox(height: 16),
            const Text('Date and time', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.ink)),
            const SizedBox(height: 6),
            TextField(controller: timeCtrl, decoration: _modalInputDecoration('e.g. 24 September · 10:30 AM')),
            const SizedBox(height: 16),
            const Text('Clinic / Location', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.ink)),
            const SizedBox(height: 6),
            TextField(controller: locCtrl, decoration: _modalInputDecoration('e.g. City Clinic')),
            const SizedBox(height: 24),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.blue,
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                final title = titleCtrl.text.trim();
                if (title.isEmpty) return;
                LocalDataService.instance.addAppointment(title, timeCtrl.text.trim(), locCtrl.text.trim());
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Appointment added to your reminders.'), duration: Duration(seconds: 2)),
                );
              },
              child: const Text('Save appointment', style: TextStyle(fontWeight: FontWeight.w700)),
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
        constraints: const BoxConstraints(maxWidth: 520),
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
        final careCircle = data.careCircle;
        final reminders = data.reminders;
        final appointments = data.appointments;
        final primaryContact = careCircle.isNotEmpty ? careCircle.first.name : 'Ananya';

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(36, 28, 36, 60),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1450),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                const Text(
                  'Connect',
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
                  'The people, support and reminders that help you feel close.',
                  style: TextStyle(color: AppColors.muted, fontSize: 16),
                ),
                const SizedBox(height: 26),

                // 2-Column Grid
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth > 800;
                    final halfWidth = isWide ? (constraints.maxWidth - 18) / 2 : constraints.maxWidth;

                    return Wrap(
                      spacing: 18,
                      runSpacing: 18,
                      children: [
                        // 1. My Care Circle Card
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
                                    const Text('My Care Circle', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.ink)),
                                    TextButton(
                                      onPressed: _openCareModal,
                                      child: const Text('+ Add person', style: TextStyle(color: AppColors.blue, fontWeight: FontWeight.w700)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                const Text('You choose what each person can see.', style: TextStyle(fontSize: 13, color: AppColors.muted)),
                                const SizedBox(height: 16),
                                ...careCircle.map((p) {
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 10),
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF7FAFF),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 20,
                                          backgroundColor: const Color(0xFFD5E4FF),
                                          child: Text(
                                            p.name.isNotEmpty ? p.name[0] : 'C',
                                            style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.blue),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(p.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.ink)),
                                              const SizedBox(height: 2),
                                              Text('${p.relation} · ${p.contact}', style: const TextStyle(fontSize: 12, color: AppColors.muted)),
                                            ],
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text('Sharing settings opened for ${p.name}'), duration: const Duration(seconds: 2)),
                                            );
                                          },
                                          child: const Text('Manage', style: TextStyle(color: AppColors.blue, fontWeight: FontWeight.w700)),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                        ),

                        // 2. Voice Assistant Card
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
                                    const Text('Voice assistant', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.ink)),
                                    TextButton(
                                      onPressed: _openVoice,
                                      child: const Text('Open', style: TextStyle(color: AppColors.blue, fontWeight: FontWeight.w700)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(vertical: 26, horizontal: 16),
                                  decoration: BoxDecoration(
                                    gradient: const RadialGradient(
                                      center: Alignment.center,
                                      radius: 0.8,
                                      colors: [Color(0xFFD7E7FF), Color(0xFFF9FBFF)],
                                    ),
                                    borderRadius: BorderRadius.circular(21),
                                  ),
                                  child: Column(
                                    children: [
                                      InkWell(
                                        onTap: _openVoice,
                                        borderRadius: BorderRadius.circular(50),
                                        child: Container(
                                          width: 90,
                                          height: 90,
                                          decoration: BoxDecoration(
                                            color: AppColors.blue,
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(color: const Color(0xFFD7E6FF).withValues(alpha: 0.8), spreadRadius: 10),
                                              BoxShadow(color: const Color(0xFFEDF4FF).withValues(alpha: 0.8), spreadRadius: 20),
                                            ],
                                          ),
                                          child: const Center(
                                            child: Icon(Icons.mic, size: 36, color: Colors.white),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 24),
                                      const Text(
                                        'Ask SMRITI anything',
                                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: AppColors.ink),
                                      ),
                                      const SizedBox(height: 4),
                                      const Text(
                                        '“What do I have today?” · “Start a memory game.”',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(fontSize: 13, color: AppColors.muted),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // 3. Reminders Card
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
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Reminders', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.ink)),
                                    TextButton(
                                      onPressed: _openReminderModal,
                                      child: const Text('+ New', style: TextStyle(color: AppColors.blue, fontWeight: FontWeight.w700)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                ...reminders.map((r) {
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 10),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF8FAFF),
                                      borderRadius: BorderRadius.circular(13),
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
                                        const SizedBox(width: 12),
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
                                              const SizedBox(height: 2),
                                              Text(r.category, style: const TextStyle(fontSize: 12, color: AppColors.muted)),
                                            ],
                                          ),
                                        ),
                                        Text(
                                          r.timeStr,
                                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.blue),
                                        ),
                                        const SizedBox(width: 8),
                                        IconButton(
                                          icon: const Icon(Icons.close, size: 18, color: AppColors.muted),
                                          onPressed: () => data.deleteReminder(r.id),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                        ),

                        // 4. "I Need Help" Card
                        SizedBox(
                          width: halfWidth,
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              gradient: AppColors.emergencyGradient,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'I need help',
                                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Your trusted contacts are one tap away.',
                                  style: TextStyle(color: Color(0xFFFFE3E7), fontSize: 14),
                                ),
                                const SizedBox(height: 22),
                                Wrap(
                                  spacing: 12,
                                  runSpacing: 10,
                                  children: [
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        foregroundColor: const Color(0xFFA3253D),
                                        elevation: 0,
                                        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                                      ),
                                      onPressed: () {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('In a real app, this would call $primaryContact. No call was placed.'), duration: const Duration(seconds: 2)),
                                        );
                                      },
                                      child: Text('Call $primaryContact'),
                                    ),
                                    FilledButton(
                                      style: FilledButton.styleFrom(
                                        backgroundColor: const Color(0xFF7D1531),
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                                      ),
                                      onPressed: () {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Emergency support flow opened safely.'), duration: Duration(seconds: 2)),
                                        );
                                      },
                                      child: const Text('Emergency'),
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
                const SizedBox(height: 24),

                // Bottom: Upcoming Appointments Card
                Container(
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
                          const Text('Upcoming appointment', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.ink)),
                          TextButton(
                            onPressed: _openAppointmentModal,
                            child: const Text('+ Add appointment', style: TextStyle(color: AppColors.blue, fontWeight: FontWeight.w700)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...appointments.map((appt) {
                        return Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF7FAFF),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: AppColors.blue,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Center(
                                  child: Text('⌚', style: TextStyle(fontSize: 22, color: Colors.white)),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(appt.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.ink)),
                                    const SizedBox(height: 2),
                                    Text('${appt.dateTimeStr} · ${appt.location}', style: const TextStyle(fontSize: 13, color: AppColors.muted)),
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
              ],
            ),
          ),
        );
      },
    );
  }
}
