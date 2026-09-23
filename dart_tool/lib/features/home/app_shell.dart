import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../localization/app_language.dart';
import '../../localization/app_localizations.dart';
import '../../models/connectivity_state.dart';
import '../../services/connectivity_service.dart';
import '../../services/local_data_service.dart';
import '../../widgets/voice_companion_modal.dart';
import '../connect/connect_screen.dart';
import '../engage/engage_screen.dart';
import '../memories/remember_screen.dart';
import '../profile/profile_screen.dart';
import 'home_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key, required this.language});
  final AppLanguage language;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  late AppLanguage _language;
  int _index = 0;
  final _connectivity = ConnectivityService();
  StreamSubscription<SmritiConnectionState>? _subscription;
  SmritiConnectionState _state = SmritiConnectionState.connected;

  @override
  void initState() {
    super.initState();
    _language = widget.language;
    _subscription = _connectivity.watch().listen((event) {
      if (mounted) setState(() => _state = event);
    });
  }

  @override
  void didUpdateWidget(covariant AppShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.language != widget.language) {
      setState(() => _language = widget.language);
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void _openVoiceCompanion() {
    VoiceCompanionModal.show(
      context,
      onNavigateTab: (targetIndex) {
        if (targetIndex >= 0 && targetIndex < 5) {
          setState(() => _index = targetIndex);
        }
      },
    );
  }

  void _navigateTo(int index) {
    setState(() => _index = index);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations(_language);

    final pages = <Widget>[
      HomeScreen(
        localizations: l,
        connection: _state,
        onOpenActivities: () => _navigateTo(2), // Engage hub
        onOpenMemories: () => _navigateTo(1), // Remember hub
        onOpenVoice: _openVoiceCompanion,
      ),
      const RememberScreen(),
      const EngageScreen(),
      const ConnectScreen(),
      ProfileScreen(
        language: _language,
        onLanguageChanged: (value) => setState(() => _language = value),
      ),
    ];

    return ListenableBuilder(
      listenable: LocalDataService.instance,
      builder: (context, _) {
        final data = LocalDataService.instance;
        final patientName = data.authFullName ?? 'Bhaben Borah';
        final userLocation = data.userHometown;

        return LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth > 850;

            if (isDesktop) {
              return Scaffold(
                body: Row(
                  children: [
                    // Desktop Blue Sidebar
                    _DesktopSidebar(
                      selectedIndex: _index,
                      onSelect: _navigateTo,
                    ),

                    // Main Content Area with Topbar
                    Expanded(
                      child: Column(
                        children: [
                          _AppTopbar(
                            name: patientName,
                            subtitle: '${data.currentLanguage.label} · $userLocation',
                            onOpenVoice: _openVoiceCompanion,
                            isDesktop: true,
                          ),
                          Expanded(
                            child: ColoredBox(
                              color: AppColors.background,
                              child: pages[_index],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }

            // Mobile Layout: Topbar + Page + Bottom Nav
            return Scaffold(
              body: SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    _AppTopbar(
                      name: patientName,
                      subtitle: '${data.currentLanguage.label} · $userLocation',
                      onOpenVoice: _openVoiceCompanion,
                      isDesktop: false,
                    ),
                    Expanded(
                      child: ColoredBox(
                        color: AppColors.background,
                        child: pages[_index],
                      ),
                    ),
                  ],
                ),
              ),
              bottomNavigationBar: _MobileBottomNav(
                selectedIndex: _index,
                onSelect: _navigateTo,
              ),
              floatingActionButton: FloatingActionButton(
                onPressed: _openVoiceCompanion,
                backgroundColor: AppColors.blue,
                foregroundColor: Colors.white,
                elevation: 4,
                tooltip: 'Voice Companion',
                child: const Icon(Icons.mic_rounded, size: 28),
              ),
            );
          },
        );
      },
    );
  }
}

class _NavEntry {
  const _NavEntry(this.id, this.symbol, this.label, this.icon);
  final String id;
  final String symbol;
  final String label;
  final IconData icon;
}

const _navItems = <_NavEntry>[
  _NavEntry('home', '⌂', 'Home', Icons.home_rounded),
  _NavEntry('remember', '◈', 'Remember', Icons.psychology_rounded),
  _NavEntry('engage', '◎', 'Engage', Icons.auto_awesome_rounded),
  _NavEntry('connect', '◌', 'Connect', Icons.favorite_border_rounded),
  _NavEntry('settings', '⚙', 'Settings', Icons.settings_rounded),
];

class _DesktopSidebar extends StatelessWidget {
  const _DesktopSidebar({
    required this.selectedIndex,
    required this.onSelect,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      color: AppColors.blue,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Brand
          Padding(
            padding: const EdgeInsets.only(left: 12, right: 12, bottom: 40),
            child: Text(
              'SMRITI',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2.8,
                    fontSize: 20,
                  ),
            ),
          ),

          // Nav Items
          ...List.generate(_navItems.length, (idx) {
            final item = _navItems[idx];
            final isActive = selectedIndex == idx;

            return Padding(
              padding: const EdgeInsets.only(bottom: 7),
              child: InkWell(
                onTap: () => onSelect(idx),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                  decoration: BoxDecoration(
                    color: isActive ? const Color(0xFF3973DD) : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Text(
                        item.symbol,
                        style: TextStyle(
                          fontSize: 18,
                          color: isActive ? Colors.white : const Color(0xFFDCE8FF),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Text(
                        item.label,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
                          color: isActive ? Colors.white : const Color(0xFFDCE8FF),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),

          const Spacer(),

          // Sidebar Bottom
          Container(
            padding: const EdgeInsets.all(13),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Remember. Engage. Connect.',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Your personal companion',
                  style: TextStyle(
                    color: const Color(0xFFDCE8FF).withOpacity(0.85),
                    fontSize: 12,
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

class _AppTopbar extends StatelessWidget {
  const _AppTopbar({
    required this.name,
    required this.subtitle,
    required this.onOpenVoice,
    required this.isDesktop,
  });

  final String name;
  final String subtitle;
  final VoidCallback onOpenVoice;
  final bool isDesktop;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: isDesktop ? 78 : 70,
      padding: EdgeInsets.symmetric(horizontal: isDesktop ? 42 : 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.line, width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Greeting
          Expanded(
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    'Good morning, $name',
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                const Text('☀', style: TextStyle(fontSize: 16, color: Color(0xFFE5A11A))),
              ],
            ),
          ),

          // Top Actions
          Row(
            children: [
              if (isDesktop) ...[
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.muted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 14),
              ],
              InkWell(
                onTap: onOpenVoice,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 43,
                  height: 43,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEDF4FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Icon(Icons.mic_rounded, color: AppColors.blue, size: 22),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MobileBottomNav extends StatelessWidget {
  const _MobileBottomNav({
    required this.selectedIndex,
    required this.onSelect,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.line, width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(_navItems.length, (idx) {
          final item = _navItems[idx];
          final isActive = selectedIndex == idx;

          return Expanded(
            child: InkWell(
              onTap: () => onSelect(idx),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    item.symbol,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: isActive ? AppColors.blue : AppColors.muted,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    item.label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: isActive ? AppColors.blue : AppColors.muted,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

