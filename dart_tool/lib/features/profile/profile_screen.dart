import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../localization/app_language.dart';
import '../../localization/app_region.dart';
import '../../services/local_data_service.dart';
import '../../widgets/role_switcher.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({
    super.key,
    required this.language,
    required this.onLanguageChanged,
  });

  final AppLanguage language;
  final ValueChanged<AppLanguage> onLanguageChanged;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: LocalDataService.instance,
      builder: (context, _) {
        final data = LocalDataService.instance;
        final patientName = data.authFullName ?? 'Bhaben Borah';
        final age = data.authAge;
        final hometown = data.userHometown;
        final currentRegion = data.currentRegion;
        final currentLanguage = data.currentLanguage;

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title & Subtitle
                Text(
                  'Profile & settings',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontFamily: 'Fraunces',
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.8,
                      ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Make SMRITI feel just right for you.',
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors.muted,
                  ),
                ),
                const SizedBox(height: 24),

                // 2-Column Responsive Grid of 4 Cards
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth > 700;

                    final card1 = _buildProfileCard(context, data, patientName, age, hometown, currentRegion, currentLanguage);
                    final card2 = _buildAccessibilityCard(context, data);
                    final card3 = _buildPrivacyCard(context);
                    final card4 = _buildAccountCard(context, data);

                    if (isWide) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                card1,
                                const SizedBox(height: 18),
                                card3,
                              ],
                            ),
                          ),
                          const SizedBox(width: 18),
                          Expanded(
                            child: Column(
                              children: [
                                card2,
                                const SizedBox(height: 18),
                                card4,
                              ],
                            ),
                          ),
                        ],
                      );
                    }

                    return Column(
                      children: [
                        card1,
                        const SizedBox(height: 18),
                        card2,
                        const SizedBox(height: 18),
                        card3,
                        const SizedBox(height: 18),
                        card4,
                      ],
                    );
                  },
                ),

                const SizedBox(height: 28),

                // Role Switcher Card (Preserved for demonstration & clinician testing)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.line),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Role Switcher (Demonstration)',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.muted,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Switch perspective between Patient, Family Caregiver, and Clinician.',
                        style: TextStyle(fontSize: 13, color: AppColors.muted),
                      ),
                      SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: RoleSwitcher(),
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

  // Card 1: Your Profile
  Widget _buildProfileCard(
    BuildContext context,
    LocalDataService data,
    String patientName,
    int age,
    String hometown,
    AppRegion currentRegion,
    AppLanguage currentLanguage,
  ) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.line),
          boxShadow: const [
            BoxShadow(color: Color.fromRGBO(26, 68, 141, 0.04), blurRadius: 14, offset: Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your profile',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.ink),
          ),
          const SizedBox(height: 14),

          // Avatar Row
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: const Color(0xFFD5E4FF),
                child: Text(
                  patientName.isNotEmpty ? patientName[0] : 'S',
                  style: const TextStyle(
                    color: AppColors.blue,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      patientName,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.ink),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$age years · $hometown',
                      style: const TextStyle(fontSize: 13, color: AppColors.muted),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _openEditProfileDialog(context, data),
                icon: const Icon(Icons.edit_outlined, size: 20, color: AppColors.blue),
                tooltip: 'Edit Profile',
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFFEDF4FF),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),

          const Divider(height: 28, color: Color(0xFFEDF1F8)),

          // Region ListTile (Compatible with region_multilingual_test.dart)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.location_on_outlined, color: AppColors.blue),
            title: Text(currentRegion.name, style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.ink)),
            subtitle: Text('My North-East · ${data.userDistrict}, ${data.userState}', style: const TextStyle(fontSize: 12, color: AppColors.muted)),
            trailing: TextButton(
              onPressed: () => _regionSheet(context),
              child: const Text('Change', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.blue)),
            ),
            onTap: () => _regionSheet(context),
          ),

          const Divider(height: 14, color: Color(0xFFEDF1F8)),

          // Language Row
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.language_rounded, color: AppColors.blue),
            title: const Text('Language', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.ink)),
            subtitle: Text(currentLanguage.label, style: const TextStyle(fontSize: 12, color: AppColors.muted)),
            trailing: TextButton(
              onPressed: () => _languageSheet(context),
              child: const Text('Change', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.blue)),
            ),
            onTap: () => _languageSheet(context),
          ),
        ],
      ),
    ),
  );
}

  // Card 2: Accessibility
  Widget _buildAccessibilityCard(BuildContext context, LocalDataService data) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.line),
        boxShadow: const [
          BoxShadow(color: Color.fromRGBO(26, 68, 141, 0.04), blurRadius: 14, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Accessibility',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.ink),
          ),
          const SizedBox(height: 14),

          // Large Text
          _settingsRow(
            title: 'Large text',
            subtitle: data.textSizeLabel,
            action: TextButton(
              onPressed: () {
                data.toggleLargeText();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Text size set to ${data.textSizeLabel}.')),
                );
              },
              child: const Text('Adjust', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.blue)),
            ),
          ),
          const Divider(height: 14, color: Color(0xFFEDF1F8)),

          // Voice Assistance
          _settingsRow(
            title: 'Voice assistance',
            subtitle: data.voiceAssistanceEnabled ? 'Voice prompts are enabled' : 'Voice prompts disabled',
            action: Switch.adaptive(
              value: data.voiceAssistanceEnabled,
              activeColor: AppColors.blue,
              onChanged: (_) => data.toggleVoiceAssistance(),
            ),
          ),
          const Divider(height: 14, color: Color(0xFFEDF1F8)),

          // Reminder Notifications
          _settingsRow(
            title: 'Reminder notifications',
            subtitle: data.reminderNotificationsEnabled ? 'Gentle on-screen alerts' : 'Alerts paused',
            action: Switch.adaptive(
              value: data.reminderNotificationsEnabled,
              activeColor: AppColors.blue,
              onChanged: (_) => data.toggleReminderNotifications(),
            ),
          ),
        ],
      ),
    );
  }

  // Card 3: Privacy & memories
  Widget _buildPrivacyCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.line),
        boxShadow: const [
          BoxShadow(color: Color.fromRGBO(26, 68, 141, 0.04), blurRadius: 14, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Privacy & memories',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.ink),
          ),
          const SizedBox(height: 14),

          _settingsRow(
            title: 'Memory sharing',
            subtitle: 'You control every share',
            action: TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Your memories stay private until you choose to share them.')),
                );
              },
              child: const Text('Review', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.blue)),
            ),
          ),
          const Divider(height: 14, color: Color(0xFFEDF1F8)),

          _settingsRow(
            title: 'Emergency contacts',
            subtitle: 'Encrypted locally & synced',
            action: TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Manage your Care Circle from the Connect tab.')),
                );
              },
              child: const Text('Manage', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.blue)),
            ),
          ),
        ],
      ),
    );
  }

  // Card 4: Account
  Widget _buildAccountCard(BuildContext context, LocalDataService data) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.line),
        boxShadow: const [
          BoxShadow(color: Color.fromRGBO(26, 68, 141, 0.04), blurRadius: 14, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Account',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.ink),
          ),
          const SizedBox(height: 6),
          const Text(
            'Your changes are saved on this device.',
            style: TextStyle(fontSize: 14, color: AppColors.muted),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
              minimumSize: const Size(130, 48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            onPressed: () {
              data.logout();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('You have been logged out safely.')),
              );
            },
            child: const Text(
              'Log out',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }

  Widget _settingsRow({required String title, required String subtitle, required Widget action}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: AppColors.ink)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(fontSize: 13, color: AppColors.muted)),
              ],
            ),
          ),
          action,
        ],
      ),
    );
  }

  void _openEditProfileDialog(BuildContext context, LocalDataService data) {
    final nameCtrl = TextEditingController(text: data.authFullName);
    final ageCtrl = TextEditingController(text: '${data.authAge}');
    final districtCtrl = TextEditingController(text: data.userDistrict);
    final hometownCtrl = TextEditingController(text: data.userHometown);

    showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Edit profile', style: TextStyle(fontFamily: 'Fraunces', fontWeight: FontWeight.w700)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Name', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: ageCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Age', border: OutlineInputBorder()),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: districtCtrl,
                      decoration: const InputDecoration(labelText: 'District', border: OutlineInputBorder()),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              TextField(
                controller: hometownCtrl,
                decoration: const InputDecoration(labelText: 'Hometown', border: OutlineInputBorder()),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.blue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              final parsedAge = int.tryParse(ageCtrl.text) ?? data.authAge;
              data.updateProfile(
                name: nameCtrl.text,
                age: parsedAge,
                district: districtCtrl.text,
                hometown: hometownCtrl.text,
              );
              Navigator.pop(dialogCtx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Your profile has been updated.')),
              );
            },
            child: const Text('Save changes'),
          ),
        ],
      ),
    );
  }

  void _regionSheet(BuildContext context) => showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        isScrollControlled: true,
        builder: (context) => SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.75,
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Choose your region', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 6),
                  const Text(
                    'Selecting a region automatically updates the application language.',
                    style: TextStyle(fontSize: 13, color: AppColors.muted),
                  ),
                  const SizedBox(height: 14),
                  Expanded(
                    child: ListView(
                      children: AppRegion.values.map((region) {
                        return RadioListTile<AppRegion>(
                          contentPadding: EdgeInsets.zero,
                          value: region,
                          groupValue: LocalDataService.instance.currentRegion,
                          title: Text(region.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                          subtitle: Text('${region.detail} • Language: ${region.defaultLanguage.label}'),
                          onChanged: (value) {
                            if (value != null) {
                              LocalDataService.instance.setRegion(value);
                              onLanguageChanged(value.defaultLanguage);
                              Navigator.pop(context);
                            }
                          },
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

  void _languageSheet(BuildContext context) => showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        builder: (context) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Choose your preferred language', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                ...AppLanguage.values.map(
                  (item) => RadioListTile<AppLanguage>(
                    contentPadding: EdgeInsets.zero,
                    value: item,
                    groupValue: LocalDataService.instance.currentLanguage,
                    title: Text(item.label, style: const TextStyle(fontWeight: FontWeight.w700)),
                    onChanged: (value) {
                      if (value != null) {
                        LocalDataService.instance.setLanguage(value);
                        onLanguageChanged(value);
                        Navigator.pop(context);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}

