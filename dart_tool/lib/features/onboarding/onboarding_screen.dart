import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../localization/app_language.dart';
import '../../localization/app_region.dart';
import '../../services/local_data_service.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, required this.onComplete});
  final ValueChanged<AppRegion> onComplete;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _step = 1;

  final _nameController = TextEditingController(text: 'Mitali');
  final _ageController = TextEditingController(text: '67');
  final _hometownController = TextEditingController(text: 'Guwahati');

  String _selectedState = 'Assam';
  AppRegion _selectedRegion = AppRegion.assam;
  String _selectedLanguage = 'English';
  String _selectedInterest = 'All of these';

  final List<String> _states = [
    'Assam',
    'Meghalaya',
    'Manipur',
    'Mizoram',
    'Tripura',
    'Nagaland',
    'Arunachal Pradesh',
    'Sikkim',
  ];

  final List<String> _languages = [
    'English',
    'Hindi',
    'Assamese',
    'Bengali',
    'Bodo',
    'Khasi',
    'Manipuri / Meitei',
    'Mizo',
  ];

  final List<String> _interests = [
    'Memory',
    'Daily routine',
    'Health & wellness',
    'Staying connected',
    'All of these',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _hometownController.dispose();
    super.dispose();
  }

  void _next() {
    if (_step < 4) {
      setState(() => _step++);
    } else {
      _finish();
    }
  }

  void _back() {
    if (_step > 1) {
      setState(() => _step--);
    }
  }

  void _finish() {
    final data = LocalDataService.instance;
    final age = int.tryParse(_ageController.text.trim()) ?? 67;
    data.updateProfile(
      name: _nameController.text.trim().isEmpty ? 'Mitali' : _nameController.text.trim(),
      district: 'Kamrup Metropolitan',
      hometown: _hometownController.text.trim().isEmpty ? 'Guwahati' : _hometownController.text.trim(),
      state: _selectedRegion.name,
      age: age,
    );

    data.completeOnboarding(region: _selectedRegion);
    widget.onComplete(_selectedRegion);

    if (mounted && Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FF),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.line),
                boxShadow: AppColors.shadowElevation,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Brand
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'SMRITI',
                        style: TextStyle(
                          color: AppColors.blue,
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                          letterSpacing: 2.5,
                        ),
                      ),
                      Text(
                        'Smriti Cognitive Care',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.muted.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // Stepper (4 bars)
                  Row(
                    children: List.generate(4, (idx) {
                      final isActive = idx + 1 <= _step;
                      return Expanded(
                        child: Container(
                          margin: EdgeInsets.only(right: idx < 3 ? 6 : 0),
                          height: 5,
                          decoration: BoxDecoration(
                            color: isActive ? AppColors.blue : const Color(0xFFD5E2F8),
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 26),

                  // Step Content
                  if (_step == 1) _buildStep1(),
                  if (_step == 2) _buildStep2(),
                  if (_step == 3) _buildStep3(),
                  if (_step == 4) _buildStep4(),

                  const SizedBox(height: 28),

                  // Actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          backgroundColor: _step > 1 ? const Color(0xFFEEF4FF) : Colors.transparent,
                          foregroundColor: AppColors.blue,
                          side: BorderSide.none,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: _step > 1 ? _back : null,
                        child: const Text('Back', style: TextStyle(fontWeight: FontWeight.w700)),
                      ),
                      FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: _next,
                        child: Text(
                          _step == 4 ? "Let's get started" : 'Continue',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Let’s get to know you',
          style: TextStyle(
            fontFamily: AppFonts.heading,
            fontFamilyFallback: AppFonts.headingFallback,
            fontSize: 28,
            fontWeight: FontWeight.w600,
            color: AppColors.ink,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'These details help make SMRITI personal and familiar.',
          style: TextStyle(color: AppColors.muted, fontSize: 14, height: 1.4),
        ),
        const SizedBox(height: 20),

        // Your name
        const Text('Your name', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.ink)),
        const SizedBox(height: 6),
        TextField(
          controller: _nameController,
          decoration: _inputDecoration('e.g. Mitali'),
        ),
        const SizedBox(height: 16),

        // Age & State Row
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Age', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.ink)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _ageController,
                    keyboardType: TextInputType.number,
                    decoration: _inputDecoration('e.g. 67'),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('State', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.ink)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: _selectedState,
                    isExpanded: true,
                    decoration: _inputDecoration(''),
                    items: _states.map((s) => DropdownMenuItem(value: s, child: Text(s, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14)))).toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => _selectedState = v);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Hometown
        const Text('Hometown', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.ink)),
        const SizedBox(height: 6),
        TextField(
          controller: _hometownController,
          decoration: _inputDecoration('e.g. Guwahati'),
        ),
      ],
    );
  }

  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Choose your language',
          style: TextStyle(
            fontFamily: AppFonts.heading,
            fontFamilyFallback: AppFonts.headingFallback,
            fontSize: 28,
            fontWeight: FontWeight.w600,
            color: AppColors.ink,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'You can change this at any time in settings.',
          style: TextStyle(color: AppColors.muted, fontSize: 14, height: 1.4),
        ),
        const SizedBox(height: 20),

        // Choice Grid
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _languages.map((lang) {
            final isSelected = _selectedLanguage == lang;
            return SizedBox(
              width: 200,
              child: InkWell(
                onTap: () => setState(() => _selectedLanguage = lang),
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFEDF4FF) : Colors.white,
                    border: Border.all(
                      color: isSelected ? AppColors.blue : AppColors.line,
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    lang,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: isSelected ? AppColors.blue : AppColors.ink,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildStep3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'What matters most to you?',
          style: TextStyle(
            fontFamily: AppFonts.heading,
            fontFamilyFallback: AppFonts.headingFallback,
            fontSize: 28,
            fontWeight: FontWeight.w600,
            color: AppColors.ink,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'We’ll put the things you care about first.',
          style: TextStyle(color: AppColors.muted, fontSize: 14, height: 1.4),
        ),
        const SizedBox(height: 20),

        // Choice Grid
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _interests.map((item) {
            final isSelected = _selectedInterest == item;
            return SizedBox(
              width: 200,
              child: InkWell(
                onTap: () => setState(() => _selectedInterest = item),
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFEDF4FF) : Colors.white,
                    border: Border.all(
                      color: isSelected ? AppColors.blue : AppColors.line,
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    item,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: isSelected ? AppColors.blue : AppColors.ink,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),

        // Care Circle reassurance card
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
              Text(
                'Care Circle is always optional.',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.ink),
              ),
              SizedBox(height: 4),
              Text(
                'You can invite a family member later, once you’re settled in.',
                style: TextStyle(fontSize: 12, color: AppColors.muted),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStep4() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Choose your region',
          style: TextStyle(
            fontFamily: AppFonts.heading,
            fontFamilyFallback: AppFonts.headingFallback,
            fontSize: 28,
            fontWeight: FontWeight.w600,
            color: AppColors.ink,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Connect with culturally familiar memories, folk music, and regional dietary routines across the 8 North-Eastern states.',
          style: TextStyle(color: AppColors.muted, fontSize: 14, height: 1.4),
        ),
        const SizedBox(height: 18),

        // Confirmation banner for selected region
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFEDF4FF),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.blue.withOpacity(0.35)),
          ),
          child: Row(
            children: [
              const Icon(Icons.location_on_rounded, color: AppColors.blue, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Selected: ${_selectedRegion.name}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Default language: ${_selectedRegion.defaultLanguage.englishLabel} (${_selectedRegion.defaultLanguage.label})',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.blue,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 8 NER States Cards
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: AppRegion.values.map((region) {
            final isSelected = _selectedRegion == region;
            return SizedBox(
              width: 210,
              child: InkWell(
                onTap: () => setState(() => _selectedRegion = region),
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFEDF4FF) : Colors.white,
                    border: Border.all(
                      color: isSelected ? AppColors.blue : AppColors.line,
                      width: isSelected ? 2 : 1.5,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        region.name,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: isSelected ? AppColors.blue : AppColors.ink,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        region.defaultLanguage.label,
                        style: const TextStyle(fontSize: 12, color: AppColors.muted),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(11),
        borderSide: const BorderSide(color: Color(0xFFCBD9EF), width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(11),
        borderSide: const BorderSide(color: Color(0xFFCBD9EF), width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(11),
        borderSide: const BorderSide(color: AppColors.blue, width: 2),
      ),
      filled: true,
      fillColor: Colors.white,
    );
  }
}

