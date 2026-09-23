import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../services/api_service.dart';
import '../../services/local_data_service.dart';
import '../../services/pdf_report_service.dart';
import '../../widgets/role_switcher.dart';
import '../../widgets/section_heading.dart';
import 'clinical_report_screen.dart';

class DoctorDashboard extends StatefulWidget {
  const DoctorDashboard({super.key});

  @override
  State<DoctorDashboard> createState() => _DoctorDashboardState();
}

class _DoctorDashboardState extends State<DoctorDashboard> {
  int _selectedPatientIndex = 0;
  final TextEditingController _patientIdController = TextEditingController(text: 'MS-ASSAM-001');
  bool _isOpening = false;
  String? _openError;

  @override
  void dispose() {
    _patientIdController.dispose();
    super.dispose();
  }

  Future<void> _openPatientById() async {
    final pid = _patientIdController.text.trim();
    if (pid.isEmpty) return;

    setState(() {
      _isOpening = true;
      _openError = null;
    });

    try {
      final res = await ApiService.instance.openDoctorPatient(pid);
      if (res.isSuccess && res.data != null) {
        final d = res.data!;
        final pData = d['patient'] as Map<String, dynamic>?;
        final pName = (pData != null ? pData['name'] as String? : null) ?? 'Bhaben Borah';
        final pId = d['patient_id']?.toString() ?? pid;
        final pAge = pData != null ? pData['age'] as int? : 72;
        final pReg = pData != null ? pData['region'] as String? : 'Tezpur, Assam';

        final profile = DoctorPatientProfile(
          id: pId,
          patientCode: pId,
          name: pName,
          age: pAge ?? 72,
          region: pReg ?? 'Tezpur, Assam',
          language: 'Assamese (অসমীয়া)',
          caregiverName: 'Anamika Borah (Daughter)',
          caregiverPhone: '+91 94350 12345',
          adherenceRate: 85,
          avgAccuracy: 92,
          activeStreak: 3,
          statusSummary: 'Record opened via Patient ID $pId.',
        );

        if (mounted) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ClinicalReportScreen(patient: profile),
            ),
          );
        }
      } else {
        setState(() {
          _openError = res.message ?? "Patient with ID '$pid' not found.";
        });
      }
    } catch (e) {
      setState(() {
        _openError = 'Error opening patient: $e';
      });
    } finally {
      if (mounted) setState(() => _isOpening = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: LocalDataService.instance,
      builder: (context, _) {
        final data = LocalDataService.instance;
        final patients = data.patients;
        final selectedPatient = patients[_selectedPatientIndex];
        final observations = data.observations;

        return Scaffold(
          backgroundColor: AppColors.ivory,
          appBar: AppBar(
            backgroundColor: AppColors.ivory,
            elevation: 0,
            title: const Text('Doctor Portal', style: TextStyle(fontWeight: FontWeight.w700)),
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
                // Doctor Header Subtitle
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.sage,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.medical_information_outlined, color: AppColors.tealDark, size: 26),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('Dr. Debabrata Sarma', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.charcoal)),
                          SizedBox(height: 2),
                          Text('MD, Geriatric Medicine · Guwahati Institute', style: TextStyle(fontSize: 13, color: AppColors.muted)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // 1. OPEN PATIENT BY ID CARD
                _buildOpenPatientCard(),
                const SizedBox(height: 24),

                // 2. PATIENT REGISTRY SELECTOR
                const SectionHeading(title: 'Active dementia / MCI patient registry'),
                const SizedBox(height: 12),
                SizedBox(
                  height: 68,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: patients.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (context, index) {
                      final p = patients[index];
                      final isSelected = _selectedPatientIndex == index;

                      return InkWell(
                        onTap: () => setState(() => _selectedPatientIndex = index),
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.tealDark : AppColors.surface,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: isSelected ? AppColors.tealDark : AppColors.line),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    p.name,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: isSelected ? Colors.white : AppColors.charcoal,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: isSelected ? Colors.white24 : AppColors.sage,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      p.patientCode,
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                        color: isSelected ? Colors.white : AppColors.tealDark,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${p.age}y · ${p.region}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isSelected ? Colors.white70 : AppColors.muted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),

                // 3. PATIENT SUMMARY CARD
                const SectionHeading(title: 'Patient summary & profile'),
                const SizedBox(height: 12),
                _buildPatientSummaryCard(selectedPatient),
                const SizedBox(height: 24),

                // 3. CORE CLINICAL INDICATORS
                const SectionHeading(title: 'Longitudinal clinical indicators'),
                const SizedBox(height: 12),
                _buildIndicatorsGrid(selectedPatient, data),
                const SizedBox(height: 24),

                // 4. TREND VISUALIZATION
                const SectionHeading(title: '7-Day activity & consistency trend'),
                const SizedBox(height: 12),
                _buildTrendChart(data),
                const SizedBox(height: 24),

                // 5. CAREGIVER OBSERVATIONS LOG
                SectionHeading(
                  title: 'Caregiver observations',
                  action: 'By ${selectedPatient.caregiverName}',
                ),
                const SizedBox(height: 12),
                _buildCaregiverObservations(observations),
                const SizedBox(height: 24),

                // 6. CLINICAL INSIGHTS SECTION (PRELIMINARY / DEMO)
                _buildClinicalInsightsSection(data),
                const SizedBox(height: 24),

                // 7. REPORT ACTIONS
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.teal,
                    minimumSize: const Size.fromHeight(54),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ClinicalReportScreen(patient: selectedPatient),
                      ),
                    );
                  },
                  icon: const Icon(Icons.description_outlined),
                  label: const Text('View Full Clinical Report', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    foregroundColor: AppColors.tealDark,
                    side: const BorderSide(color: AppColors.teal),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () async {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Generating and downloading Patient Report (PDF)...'),
                        backgroundColor: AppColors.tealDark,
                        duration: Duration(seconds: 2),
                      ),
                    );
                    try {
                      final pdfBytes = PdfReportService.instance.generateReport(
                        patient: {
                          'id': selectedPatient.id,
                          'name': selectedPatient.name,
                          'age': selectedPatient.age,
                          'region': selectedPatient.region,
                          'preferred_language': selectedPatient.language,
                          'emergency_contact': {
                            'name': selectedPatient.caregiverName,
                            'phone': selectedPatient.caregiverPhone,
                          },
                        },
                        activityHistory: [],
                        caregiverObservations: [],
                        domainTrends: {
                          'Routine Sequencing': '100%',
                          'Memory Recall': '96%',
                          'Matching': '${selectedPatient.avgAccuracy}%',
                          'Visual Attention': '92%',
                        },
                        adherenceData: {
                          'adherence_percentage': '${selectedPatient.adherenceRate}%',
                          'caregiver_verified_rate': '94%',
                        },
                        preliminaryInsights: [],
                        doctorName: 'Dr. Debabrata Sarma, MD (Geriatric Medicine)',
                      );
                      final savedPath = await PdfReportService.instance.savePdfFile(
                        bytes: pdfBytes,
                        patientName: selectedPatient.name,
                      );
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: AppColors.tealDark,
                            duration: const Duration(seconds: 7),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Report Downloaded Successfully!', style: TextStyle(fontWeight: FontWeight.w700)),
                                const SizedBox(height: 2),
                                Text(savedPath, style: const TextStyle(fontSize: 11, color: AppColors.sage)),
                              ],
                            ),
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Download failed: $e'), backgroundColor: AppColors.error),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.download_rounded),
                  label: const Text('Download Patient Report (PDF)', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    foregroundColor: AppColors.tealDark,
                    side: const BorderSide(color: AppColors.line),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () {
                    data.syncWithBackend();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Connecting to FastAPI backend & refreshing patient insights...'),
                        backgroundColor: AppColors.tealDark,
                      ),
                    );
                  },
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Refresh Insights from Backend', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOpenPatientCard() {
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
                child: const Icon(Icons.person_search_rounded, color: AppColors.tealDark, size: 22),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Open Patient Record',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.charcoal),
                    ),
                    Text(
                      'Enter Patient ID to open patient clinical details and reports',
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
                  minimumSize: const Size(130, 48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _isOpening ? null : _openPatientById,
                child: _isOpening
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Open Patient', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
              ),
            ],
          ),
          if (_openError != null) ...[
            const SizedBox(height: 8),
            Text(_openError!, style: const TextStyle(color: AppColors.error, fontSize: 12, fontWeight: FontWeight.w600)),
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
                  _openPatientById();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPatientSummaryCard(DoctorPatientProfile p) {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.sage,
                child: Text(
                  p.name[0],
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.tealDark),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p.name, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: AppColors.charcoal)),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text('${p.age} years · ${p.region}  ', style: const TextStyle(fontSize: 13, color: AppColors.muted, fontWeight: FontWeight.w600)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.sage,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'ID: ${p.patientCode}',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.tealDark),
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
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF86EFAC)),
                ),
                child: const Text('Routine Active', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.success)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 12),
          Text(p.statusSummary, style: const TextStyle(fontSize: 13, color: AppColors.charcoal, height: 1.4)),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.person_outline, size: 15, color: AppColors.teal),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Caregiver: ${p.caregiverName} (${p.caregiverPhone})',
                  style: const TextStyle(fontSize: 12, color: AppColors.muted, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIndicatorsGrid(DoctorPatientProfile p, LocalDataService data) {
    return Row(
      children: [
        Expanded(
          child: _IndicatorCard(
            title: 'Consistency',
            value: '${p.adherenceRate}%',
            subtitle: '6 of 7 days active',
            color: AppColors.tealDark,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _IndicatorCard(
            title: 'Accuracy Trend',
            value: '${data.averageAccuracy}%',
            subtitle: 'Steady performance',
            color: AppColors.teal,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _IndicatorCard(
            title: 'Adherence',
            value: '85%',
            subtitle: 'Reminders checked',
            color: AppColors.success,
          ),
        ),
      ],
    );
  }

  Widget _buildTrendChart(LocalDataService data) {
    final heights = [32.0, 48.0, 40.0, 64.0, 52.0, 24.0, 18.0];
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

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
            children: const [
              Text('Cognitive Engagement (Mins/Day)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.charcoal)),
              Text('Target: 15m/day', style: TextStyle(fontSize: 11, color: AppColors.muted, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 100,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (i) {
                final isPeak = i == 3;
                return Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        height: heights[i],
                        width: 22,
                        decoration: BoxDecoration(
                          color: isPeak ? AppColors.teal : AppColors.sage,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(days[i], style: const TextStyle(fontSize: 11, color: AppColors.muted, fontWeight: FontWeight.w600)),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCaregiverObservations(List<CaregiverObservation> obs) {
    if (obs.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.line),
        ),
        child: const Center(child: Text('No observations logged yet.', style: TextStyle(color: AppColors.muted))),
      );
    }

    return Column(
      children: obs.take(2).map((item) {
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.line),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(item.timestampStr, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.teal)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.sage,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text('Mood: ${item.mood}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.tealDark)),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Sleep: ${item.sleepHours}h · Appetite: ${item.appetite}',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.muted),
              ),
              const SizedBox(height: 6),
              Text(item.notes, style: const TextStyle(fontSize: 13, color: AppColors.charcoal, height: 1.4)),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildClinicalInsightsSection(LocalDataService data) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FBFF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.teal.withOpacity(0.35), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.tealDark,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'PRELIMINARY DEMO INSIGHTS',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 0.6),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Non-diagnostic',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.muted),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _bulletPoint('Memory activity accuracy remains high (95%) when anchored to culturally familiar North-East symbols (Pepa, Rhino, Tea).'),
          _bulletPoint('Tea brewing sequence routine completed in ~3.2 minutes, indicating preserved procedural memory for household routines.'),
          _bulletPoint('Reminder adherence has been consistent (>80% over 14 days), supported by daughter Anamika’s daily verifications.'),
          _bulletPoint('Sleep duration reported at 7.5–8.0 hours with steady morning appetite.'),
          const SizedBox(height: 10),
          const Divider(height: 1),
          const SizedBox(height: 10),
          const Text(
            'Notice: Preliminary AI-assisted longitudinal activity summary. Final medical diagnosis and treatment plans remain the responsibility of the attending physician.',
            style: TextStyle(fontSize: 11, color: AppColors.muted, fontStyle: FontStyle.italic, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _bulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 16, color: AppColors.teal, fontWeight: FontWeight.w800)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13, color: AppColors.charcoal, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

class _IndicatorCard extends StatelessWidget {
  const _IndicatorCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.color,
  });

  final String title, value, subtitle;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.muted, letterSpacing: 0.5)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: color)),
          const SizedBox(height: 2),
          Text(subtitle, style: const TextStyle(fontSize: 10, color: AppColors.muted)),
        ],
      ),
    );
  }
}
