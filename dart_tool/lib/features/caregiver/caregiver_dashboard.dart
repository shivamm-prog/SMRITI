import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../models/diet_item.dart';
import '../../services/api_service.dart';
import '../../services/local_data_service.dart';
import '../../widgets/role_switcher.dart';
import '../../widgets/section_heading.dart';

class CaregiverDashboard extends StatefulWidget {
  const CaregiverDashboard({super.key});

  @override
  State<CaregiverDashboard> createState() => _CaregiverDashboardState();
}

class _CaregiverDashboardState extends State<CaregiverDashboard> {
  String _selectedMood = 'Calm';
  double _sleepHours = 7.5;
  String _selectedAppetite = 'Good';
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _patientIdController = TextEditingController(text: 'MS-ASSAM-001');
  bool _isConnecting = false;
  String? _connectError;

  final List<Map<String, dynamic>> _moods = [
    {'label': 'Happy', 'emoji': '😊'},
    {'label': 'Calm', 'emoji': '😌'},
    {'label': 'Low', 'emoji': '😔'},
    {'label': 'Concerned', 'emoji': '😟'},
  ];

  final List<String> _appetiteLevels = ['Good', 'Average', 'Poor'];

  @override
  void dispose() {
    _notesController.dispose();
    _patientIdController.dispose();
    super.dispose();
  }

  Future<void> _connectPatient() async {
    final pid = _patientIdController.text.trim();
    if (pid.isEmpty) return;

    setState(() {
      _isConnecting = true;
      _connectError = null;
    });

    try {
      final res = await ApiService.instance.connectCaregiverPatient(pid);
      if (res.isSuccess && res.data != null) {
        final d = res.data!;
        final pData = d['patient'] as Map<String, dynamic>?;
        final pName = (pData != null ? pData['name'] as String? : null) ?? d['patient_name']?.toString() ?? 'Bhaben Borah';
        final pId = d['patient_id']?.toString() ?? pid;
        final pAge = pData != null ? pData['age'] as int? : 72;
        final pReg = pData != null ? pData['region'] as String? : 'Tezpur, Assam';

        LocalDataService.instance.setConnectedPatient(
          patientId: pId,
          patientName: pName,
          age: pAge,
          region: pReg,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Connected to patient $pName ($pId)'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } else {
        setState(() {
          _connectError = res.message ?? "Patient ID '$pid' not found. Please verify.";
        });
      }
    } catch (e) {
      setState(() {
        _connectError = 'Connection error: $e';
      });
    } finally {
      if (mounted) setState(() => _isConnecting = false);
    }
  }

  void _submitObservation() {
    LocalDataService.instance.saveObservation(
      mood: _selectedMood,
      sleepHours: _sleepHours,
      appetite: _selectedAppetite,
      notes: _notesController.text,
    );

    _notesController.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Daily observation saved locally and queued for sync.'),
        backgroundColor: AppColors.tealDark,
      ),
    );
  }

  void _showEmergencyDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 28),
            SizedBox(width: 10),
            Text('Emergency / SOS', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Immediate contacts for Bhaben Borah:',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),
            const SizedBox(height: 14),
            _contactRow('Primary Caregiver', 'Anamika Borah (Daughter)', '+91 94350 12345'),
            const Divider(height: 18),
            _contactRow('Doctor on Call', 'Dr. Debabrata Sarma', '+91 98640 11223'),
            const Divider(height: 18),
            _contactRow('Assam Health Emergency', 'Ambulance Helpline', '108 / 112'),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'Guidance: Keep the patient in a calm, familiar room with soft lighting and familiar family objects.',
                style: TextStyle(fontSize: 12, color: AppColors.error),
              ),
            ),
          ],
        ),
        actions: [
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.tealDark),
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _contactRow(String label, String name, String phone) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.muted)),
        const SizedBox(height: 2),
        Text(name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.charcoal)),
        const SizedBox(height: 1),
        Text(phone, style: const TextStyle(fontSize: 14, color: AppColors.teal, fontWeight: FontWeight.w600)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: LocalDataService.instance,
      builder: (context, _) {
        final data = LocalDataService.instance;
        final reminders = data.reminders;
        final completedReminders = reminders.where((r) => r.completed).length;
        final latestObs = data.latestObservation;

        return Scaffold(
          backgroundColor: AppColors.ivory,
          appBar: AppBar(
            backgroundColor: AppColors.ivory,
            elevation: 0,
            title: const Text('Caregiver Portal', style: TextStyle(fontWeight: FontWeight.w700)),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout_rounded, color: AppColors.muted),
                tooltip: 'Log Out',
                onPressed: () => LocalDataService.instance.logout(),
              ),
              const Padding(
                padding: EdgeInsets.only(right: 16),
                child: Center(child: RoleSwitcher()),
              ),
            ],
          ),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 32),
              children: [
                // Caregiver Header Badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Welcome, Anamika', style: Theme.of(context).textTheme.headlineMedium),
                        const SizedBox(height: 4),
                        Text(
                          'Caring for ${data.connectedPatientName} (${data.connectedPatientId})',
                          style: const TextStyle(fontSize: 15, color: AppColors.muted, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    IconButton.filled(
                      style: IconButton.styleFrom(
                        backgroundColor: const Color(0xFFFEE2E2),
                        foregroundColor: AppColors.error,
                      ),
                      onPressed: _showEmergencyDialog,
                      icon: const Icon(Icons.sos_rounded, size: 28),
                      tooltip: 'Emergency SOS',
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // 1. CONNECT TO PATIENT CARD
                _buildConnectPatientCard(data),
                const SizedBox(height: 22),

                // 2. SYNC & 2-DAY ALERT CARD
                _buildSyncCard(data),
                const SizedBox(height: 24),

                // 3. PATIENT PROFILE CARD
                const SectionHeading(title: 'Connected patient profile'),
                const SizedBox(height: 12),
                _buildPatientProfileCard(data),
                const SizedBox(height: 24),

                // 3. TODAY'S PATIENT STATUS METRICS
                const SectionHeading(title: "Today's activity status"),
                const SizedBox(height: 12),
                _buildStatusMetrics(data, completedReminders, reminders.length),
                const SizedBox(height: 28),

                // 4. REMINDER MANAGEMENT & MEAL STATUS
                SectionHeading(
                  title: 'Daily reminder management',
                  action: '$completedReminders of ${reminders.length} verified',
                ),
                const SizedBox(height: 12),
                _buildCaregiverMealStatusCard(data),
                const SizedBox(height: 14),
                ...reminders.map((reminder) => _buildCaregiverReminderRow(reminder, data)),
                const SizedBox(height: 28),

                // 5. DAILY OBSERVATION FORM
                const SectionHeading(title: 'Log daily observation'),
                const SizedBox(height: 12),
                _buildObservationForm(data),
                const SizedBox(height: 28),

                // 6. LATEST SAVED OBSERVATION CARD
                if (latestObs != null) ...[
                  const SectionHeading(title: 'Latest logged observation'),
                  const SizedBox(height: 12),
                  _buildLatestObservationCard(latestObs),
                  const SizedBox(height: 20),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSyncCard(LocalDataService data) {
    final isOverdue = data.isSyncOverdue;
    final hours = data.hoursSinceLastSync;

    if (isOverdue) {
      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFFFEF3C7),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFF59E0B), width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.warning_amber_rounded, color: Color(0xFFB45309), size: 24),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Sync Attention Required (>48 Hours)',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF92400E)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Patient tablet has not synced with the cloud for $hours hours (over 2 days). Please connect the patient tablet to Wi-Fi so the doctor receives the latest observations.',
              style: const TextStyle(fontSize: 13, color: Color(0xFF78350F), height: 1.45),
            ),
            const SizedBox(height: 14),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFB45309),
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(44),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () => data.simulateSyncNow(),
              icon: const Icon(Icons.sync_rounded, size: 20),
              label: const Text('Simulate Manual Sync Now'),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFECFDF5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.cloud_done_rounded, color: AppColors.success, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'All Data Synced',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.charcoal),
                ),
                SizedBox(height: 2),
                Text(
                  'Patient records are up to date with Dr. Sarma',
                  style: TextStyle(fontSize: 13, color: AppColors.muted),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => data.simulateSyncNow(),
            child: const Text('Sync', style: TextStyle(color: AppColors.teal, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectPatientCard(LocalDataService data) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.teal.withOpacity(0.35)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.sage,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.link_rounded, color: AppColors.tealDark, size: 22),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Connect to Patient',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.charcoal),
                    ),
                    Text(
                      'Enter patient ID to link caregiving records',
                      style: TextStyle(fontSize: 12, color: AppColors.muted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _patientIdController,
                  decoration: InputDecoration(
                    labelText: 'Patient ID',
                    hintText: 'e.g. MS-ASSAM-001',
                    prefixIcon: const Icon(Icons.badge_outlined, size: 20),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.tealDark,
                  minimumSize: const Size(140, 48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _isConnecting ? null : _connectPatient,
                child: _isConnecting
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Connect Patient', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
              ),
            ],
          ),
          if (_connectError != null) ...[
            const SizedBox(height: 8),
            Text(_connectError!, style: const TextStyle(color: AppColors.error, fontSize: 12, fontWeight: FontWeight.w600)),
          ],
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const Text('Quick Demo:', style: TextStyle(fontSize: 11, color: AppColors.muted)),
              ActionChip(
                label: const Text('MS-ASSAM-001 (Bhaben Borah)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                avatar: const Icon(Icons.person_pin_circle_outlined, size: 14, color: AppColors.tealDark),
                backgroundColor: AppColors.sage,
                onPressed: () {
                  _patientIdController.text = 'MS-ASSAM-001';
                  _connectPatient();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPatientProfileCard(LocalDataService data) {
    final patientName = data.connectedPatientName;
    final patientId = data.connectedPatientId;
    final age = data.connectedPatientAge;
    final region = data.connectedPatientRegion;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.line),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: AppColors.sage,
                child: Text(
                  patientName.isNotEmpty ? patientName[0] : 'P',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppColors.tealDark),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(patientName, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 20)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text('Age: $age · Male  ', style: const TextStyle(fontSize: 13, color: AppColors.muted, fontWeight: FontWeight.w600)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.sage,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'ID: $patientId',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.tealDark),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.sage,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Active Patient',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.tealDark),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _InfoTag(label: 'Region', value: region),
              const _InfoTag(label: 'Language', value: 'Assamese / English'),
              const _InfoTag(label: 'Doctor', value: 'Dr. D. Sarma'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusMetrics(LocalDataService data, int completedReminders, int totalReminders) {
    return Row(
      children: [
        Expanded(
          child: _StatusBox(
            value: '${data.completedActivitiesCount}',
            label: 'activities done',
            color: AppColors.tealDark,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatusBox(
            value: '${data.currentStreakDays} days',
            label: 'activity streak',
            color: AppColors.teal,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatusBox(
            value: '${data.averageAccuracy}%',
            label: 'avg accuracy',
            color: AppColors.success,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatusBox(
            value: '$completedReminders/$totalReminders',
            label: 'reminders done',
            color: AppColors.charcoal,
          ),
        ),
      ],
    );
  }

  Widget _buildCaregiverReminderRow(DailyReminder reminder, LocalDataService data) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: reminder.completed ? const Color(0xFFF0FDF4) : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: reminder.completed ? const Color(0xFF86EFAC) : AppColors.line,
        ),
      ),
      child: Row(
        children: [
          Icon(
            reminder.completed ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
            color: reminder.completed ? AppColors.success : AppColors.muted,
            size: 24,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      reminder.timeStr,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: reminder.completed ? AppColors.muted : AppColors.tealDark,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      reminder.title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: reminder.completed ? AppColors.muted : AppColors.charcoal,
                        decoration: reminder.completed ? TextDecoration.lineThrough : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  reminder.instructions,
                  style: const TextStyle(fontSize: 12, color: AppColors.muted),
                ),
                if (reminder.verifiedByCaregiver)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      children: const [
                        Icon(Icons.verified, size: 13, color: AppColors.success),
                        SizedBox(width: 4),
                        Text(
                          'Verified by Caregiver',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.success),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          if (!reminder.verifiedByCaregiver)
            TextButton(
              onPressed: () => data.verifyReminder(reminder.id),
              child: const Text('Verify', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.teal)),
            ),
        ],
      ),
    );
  }

  Widget _buildCaregiverMealStatusCard(LocalDataService data) {
    final meals = data.regionalMeals;
    final completedCount = meals.where((m) => m.completed).length;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.teal.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.teal.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.sage,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.restaurant_rounded, size: 18, color: AppColors.tealDark),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    "Today's Meal Status",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.charcoal),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: completedCount == meals.length ? const Color(0xFFDCFCE7) : AppColors.sage,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$completedCount of ${meals.length} completed',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: completedCount == meals.length ? const Color(0xFF166534) : AppColors.tealDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...meals.map((meal) {
            final mealTypeLabel = switch (meal.mealType) {
              MealType.breakfast => 'Breakfast',
              MealType.lunch => 'Lunch',
              MealType.snack => 'Evening Snack',
              MealType.dinner => 'Dinner',
            };
            final rem = data.reminders.where((r) => r.id == meal.reminderId).firstOrNull;
            final isVerified = rem?.verifiedByCaregiver ?? false;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Text(
                    meal.completed ? '✓' : '○',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: meal.completed ? AppColors.success : AppColors.muted,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(meal.icon, style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              mealTypeLabel,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: meal.completed ? AppColors.charcoal : AppColors.muted,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '(${meal.time})',
                              style: const TextStyle(fontSize: 11, color: AppColors.muted),
                            ),
                          ],
                        ),
                        Text(
                          meal.title,
                          style: TextStyle(
                            fontSize: 12,
                            color: meal.completed ? AppColors.tealDark : AppColors.muted,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (meal.completed) ...[
                    if (isVerified)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.success.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Verified',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.success),
                        ),
                      )
                    else if (meal.reminderId != null)
                      TextButton(
                        style: TextButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        ),
                        onPressed: () => data.verifyReminder(meal.reminderId!),
                        child: const Text('Verify', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.teal)),
                      ),
                  ] else
                    const Text(
                      'Pending',
                      style: TextStyle(fontSize: 11, color: AppColors.muted, fontStyle: FontStyle.italic),
                    ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildObservationForm(LocalDataService data) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.line),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Mood
          const Text('PATIENT MOOD TODAY', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.muted, letterSpacing: 0.8)),
          const SizedBox(height: 10),
          Row(
            children: _moods.map((m) {
              final isSelected = _selectedMood == m['label'];
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: InkWell(
                    onTap: () => setState(() => _selectedMood = m['label'] as String),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.sage : AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? AppColors.teal : AppColors.line,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(m['emoji'] as String, style: const TextStyle(fontSize: 24)),
                          const SizedBox(height: 4),
                          Text(
                            m['label'] as String,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              color: isSelected ? AppColors.tealDark : AppColors.charcoal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // 2. Sleep Hours
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('SLEEP DURATION', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.muted, letterSpacing: 0.8)),
              Text(
                '${_sleepHours.toStringAsFixed(1)} hours',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.tealDark),
              ),
            ],
          ),
          Slider(
            value: _sleepHours,
            min: 4.0,
            max: 12.0,
            divisions: 16,
            activeColor: AppColors.teal,
            inactiveColor: AppColors.sage,
            onChanged: (val) => setState(() => _sleepHours = val),
          ),
          const SizedBox(height: 12),

          // 3. Appetite
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('APPETITE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.muted, letterSpacing: 0.8)),
              Text(
                '${data.regionalMeals.where((m) => m.completed).length}/${data.regionalMeals.length} meals completed today',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.tealDark),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: _appetiteLevels.map((lvl) {
              final isSelected = _selectedAppetite == lvl;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Center(child: Text(lvl)),
                    selected: isSelected,
                    selectedColor: AppColors.sage,
                    labelStyle: TextStyle(
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? AppColors.tealDark : AppColors.charcoal,
                    ),
                    onSelected: (_) => setState(() => _selectedAppetite = lvl),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // 4. Notes Text Field
          const Text('OBSERVATIONS & BEHAVIOR NOTES', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.muted, letterSpacing: 0.8)),
          const SizedBox(height: 8),
          TextField(
            controller: _notesController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'e.g. Father drank morning tea with joy, smiled at family album...',
              hintStyle: const TextStyle(fontSize: 14, color: AppColors.muted),
              filled: true,
              fillColor: AppColors.ivory,
              contentPadding: const EdgeInsets.all(14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.line),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.line),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.teal),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Save Button
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.teal,
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: _submitObservation,
            icon: const Icon(Icons.check_circle_outline),
            label: const Text('Save Daily Observation', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Widget _buildLatestObservationCard(CaregiverObservation obs) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                obs.timestampStr,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.muted),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.sage,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Mood: ${obs.mood}',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.tealDark),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text('Sleep: ${obs.sleepHours} hrs', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.charcoal)),
              const SizedBox(width: 16),
              Text('Appetite: ${obs.appetite}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.charcoal)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            obs.notes,
            style: const TextStyle(fontSize: 14, color: AppColors.charcoal, height: 1.45),
          ),
        ],
      ),
    );
  }
}

class _InfoTag extends StatelessWidget {
  const _InfoTag({required this.label, required this.value});
  final String label, value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.muted)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.charcoal)),
      ],
    );
  }
}

class _StatusBox extends StatelessWidget {
  const _StatusBox({required this.value, required this.label, required this.color});
  final String value, label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        children: [
          Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: color)),
          const SizedBox(height: 2),
          Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 10, color: AppColors.muted, height: 1.2)),
        ],
      ),
    );
  }
}
