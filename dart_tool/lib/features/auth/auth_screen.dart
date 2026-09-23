import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../localization/app_language.dart';
import '../../services/api_service.dart';
import '../../services/local_data_service.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key, this.initialIsSignUp = false});
  final bool initialIsSignUp;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  late bool _isSignUp;
  UserRole _selectedRole = UserRole.patient;

  @override
  void initState() {
    super.initState();
    _isSignUp = widget.initialIsSignUp;
  }

  final _emailController = TextEditingController(text: 'patient@mindsetu.in');
  final _passwordController = TextEditingController(text: 'MindSetu@2026');
  final _nameController = TextEditingController(text: 'Bhaben Borah');

  bool _isLoading = false;
  String? _errorMessage;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _onRoleChanged(UserRole role) {
    setState(() {
      _selectedRole = role;
      switch (role) {
        case UserRole.patient:
          _emailController.text = 'patient@mindsetu.in';
          _nameController.text = 'Bhaben Borah';
          break;
        case UserRole.caregiver:
          _emailController.text = 'caregiver@mindsetu.in';
          _nameController.text = 'Anamika Borah';
          break;
        case UserRole.doctor:
          _emailController.text = 'doctor@mindsetu.in';
          _nameController.text = 'Dr. Debabrata Sarma';
          break;
      }
    });
  }

  Future<void> _submitAuth() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final fullName = _nameController.text.trim();

    if (email.isEmpty || password.isEmpty || (_isSignUp && fullName.isEmpty)) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Please complete all required fields.';
      });
      return;
    }

    try {
      String? returnedPatientId;

      if (_isSignUp) {
        final roleStr = switch (_selectedRole) {
          UserRole.patient => 'PATIENT',
          UserRole.caregiver => 'CAREGIVER',
          UserRole.doctor => 'DOCTOR',
        };

        final regRes = await ApiService.instance.register(
          email: email,
          password: password,
          fullName: fullName,
          role: roleStr,
        );

        if (!regRes.isSuccess && !regRes.isOffline) {
          setState(() {
            _isLoading = false;
            _errorMessage = regRes.message ?? 'Registration failed. Try signing in.';
          });
          return;
        }

        if (regRes.data != null) {
          returnedPatientId = regRes.data!['patient_id'] as String? ?? regRes.data!['patient_code'] as String?;
        }
      }

      // Login
      final loginRes = await ApiService.instance.login(email: email, password: password);

      if (loginRes.isSuccess && loginRes.data != null) {
        final data = loginRes.data!;
        final token = data['access_token'] as String?;
        final userName = (data['full_name'] as String?) ?? fullName;
        final roleStr = (data['role'] as String?)?.toLowerCase();
        final patientId = (data['patient_id'] as String?) ?? (data['patient_code'] as String?) ?? returnedPatientId ?? (_selectedRole == UserRole.patient ? 'MS-ASSAM-001' : null);

        UserRole actualRole = _selectedRole;
        if (roleStr == 'caregiver') actualRole = UserRole.caregiver;
        if (roleStr == 'doctor') actualRole = UserRole.doctor;
        if (roleStr == 'patient') actualRole = UserRole.patient;

        if (_isSignUp && actualRole == UserRole.patient && patientId != null) {
          setState(() => _isLoading = false);
          if (mounted) {
            await showDialog<void>(
              context: context,
              barrierDismissible: false,
              builder: (ctx) => AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                title: Row(
                  children: const [
                    Icon(Icons.celebration_rounded, color: AppColors.teal, size: 28),
                    SizedBox(width: 10),
                    Text('Welcome to MindSetu!', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20)),
                  ],
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Your account has been created successfully.',
                      style: TextStyle(fontSize: 14, color: AppColors.muted),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.sage,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.teal.withOpacity(0.4)),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'Your MindSetu Patient ID',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.charcoal),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            patientId,
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.tealDark, letterSpacing: 1),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Share this ID with your caregiver and doctor to connect them to your account.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: AppColors.charcoal, height: 1.4),
                    ),
                  ],
                ),
                actions: [
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.tealDark,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text('Enter MindSetu Home', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            );
          }
        }

        LocalDataService.instance.setAuthenticatedUser(
          role: actualRole,
          fullName: userName,
          email: email,
          token: token,
          patientId: patientId,
        );

        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).popUntil((route) => route.isFirst);
          }
        }
      } else if (loginRes.isOffline) {
        // Offline resilient demonstration mode
        LocalDataService.instance.setAuthenticatedUser(
          role: _selectedRole,
          fullName: fullName.isNotEmpty ? fullName : (_selectedRole == UserRole.patient ? 'Bhaben Borah' : 'Caregiver'),
          email: email,
          patientId: _selectedRole == UserRole.patient ? 'MS-ASSAM-001' : null,
        );

        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).popUntil((route) => route.isFirst);
          }
        }
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = loginRes.message ?? 'Invalid email or password. Please try again.';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Authentication error: $e';
      });
    }
  }

  void _quickDemoLogin(UserRole role) {
    _onRoleChanged(role);
    _passwordController.text = 'MindSetu@2026';
    _submitAuth();
  }

  @override
  Widget build(BuildContext context) {
    final l = LocalDataService.instance.localizations;
    final currentLang = LocalDataService.instance.currentLanguage;

    return Scaffold(
      backgroundColor: AppColors.ivory,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Language Selector Bar at the very top
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.line),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.language, size: 16, color: AppColors.teal),
                            const SizedBox(width: 6),
                            DropdownButton<AppLanguage>(
                              value: currentLang,
                              underline: const SizedBox(),
                              isDense: true,
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.charcoal),
                              items: AppLanguage.values.map((lang) {
                                return DropdownMenuItem(
                                  value: lang,
                                  child: Text(lang.label),
                                );
                              }).toList(),
                              onChanged: (newLang) {
                                if (newLang != null) {
                                  LocalDataService.instance.setLanguage(newLang);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Brand Icon & Title
                  Center(
                    child: Container(
                      width: 68,
                      height: 68,
                      decoration: BoxDecoration(
                        color: AppColors.sage,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: AppColors.teal.withOpacity(0.25), width: 1.5),
                      ),
                      child: const Center(
                        child: Text('🧠', style: TextStyle(fontSize: 34)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Center(
                    child: Text(
                      'MindSetu · Smriti',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.tealDark,
                          ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Center(
                    child: Text(
                      'AI Cognitive & Memory Companion for North-East Elders',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.muted,
                            fontSize: 13,
                          ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 1-Tap Demo Shortcuts Panel
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.teal.withOpacity(0.2)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.bolt_rounded, color: AppColors.teal, size: 20),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                l.demoAccountsHeader,
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.tealDark),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: _DemoButton(
                                icon: '👤',
                                title: 'Patient',
                                subtitle: 'Bhaben',
                                isSelected: _selectedRole == UserRole.patient,
                                onTap: () => _quickDemoLogin(UserRole.patient),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _DemoButton(
                                icon: '🤝',
                                title: 'Caregiver',
                                subtitle: 'Anamika',
                                isSelected: _selectedRole == UserRole.caregiver,
                                onTap: () => _quickDemoLogin(UserRole.caregiver),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _DemoButton(
                                icon: '🩺',
                                title: 'Doctor',
                                subtitle: 'Dr. Sarma',
                                isSelected: _selectedRole == UserRole.doctor,
                                onTap: () => _quickDemoLogin(UserRole.doctor),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Auth Card (Form)
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.line),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Tab Selector: Sign In / Create Account
                        Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () => setState(() {
                                  _isSignUp = false;
                                  _errorMessage = null;
                                }),
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: !_isSignUp ? AppColors.teal : Colors.transparent,
                                        width: 2.5,
                                      ),
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      l.signInButton,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: !_isSignUp ? FontWeight.w800 : FontWeight.w600,
                                        color: !_isSignUp ? AppColors.tealDark : AppColors.muted,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: InkWell(
                                onTap: () => setState(() {
                                  _isSignUp = true;
                                  _errorMessage = null;
                                }),
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: _isSignUp ? AppColors.teal : Colors.transparent,
                                        width: 2.5,
                                      ),
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      l.signUpButton,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: _isSignUp ? FontWeight.w800 : FontWeight.w600,
                                        color: _isSignUp ? AppColors.tealDark : AppColors.muted,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Error Banner if present
                        if (_errorMessage != null) ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.error.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.error.withOpacity(0.3)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _errorMessage!,
                                    style: const TextStyle(color: AppColors.error, fontSize: 13, fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Role Selector Pills
                        Text(l.selectRole, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.muted)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _RoleChip(
                              label: l.patientRoleLabel,
                              isSelected: _selectedRole == UserRole.patient,
                              onTap: () => _onRoleChanged(UserRole.patient),
                            ),
                            const SizedBox(width: 8),
                            _RoleChip(
                              label: l.caregiverRoleLabel,
                              isSelected: _selectedRole == UserRole.caregiver,
                              onTap: () => _onRoleChanged(UserRole.caregiver),
                            ),
                            const SizedBox(width: 8),
                            _RoleChip(
                              label: l.doctorRoleLabel,
                              isSelected: _selectedRole == UserRole.doctor,
                              onTap: () => _onRoleChanged(UserRole.doctor),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Full Name (if signup)
                        if (_isSignUp) ...[
                          Text(l.fullNameLabel, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.muted)),
                          const SizedBox(height: 6),
                          TextField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.person_outline, color: AppColors.teal),
                              hintText: 'e.g. Bhaben Borah',
                              filled: true,
                              fillColor: AppColors.ivory,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.line)),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.line)),
                            ),
                          ),
                          const SizedBox(height: 14),
                        ],

                        // Email
                        Text(l.emailLabel, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.muted)),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.email_outlined, color: AppColors.teal),
                            hintText: 'name@mindsetu.in',
                            filled: true,
                            fillColor: AppColors.ivory,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.line)),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.line)),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Password
                        Text(l.passwordLabel, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.muted)),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.lock_outline, color: AppColors.teal),
                            suffixIcon: IconButton(
                              icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                            ),
                            hintText: '••••••••',
                            filled: true,
                            fillColor: AppColors.ivory,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.line)),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.line)),
                          ),
                        ),
                        const SizedBox(height: 22),

                        // Submit Button
                        FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.teal,
                            minimumSize: const Size.fromHeight(52),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          onPressed: _isLoading ? null : _submitAuth,
                          child: _isLoading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(strokeWidth: 2.2, color: Colors.white),
                                )
                              : Text(
                                  _isSignUp ? l.signUpButton : l.signInButton,
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                                ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleChip extends StatelessWidget {
  const _RoleChip({required this.label, required this.isSelected, required this.onTap});
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.tealDark : AppColors.ivory,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isSelected ? AppColors.tealDark : AppColors.line),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isSelected ? Colors.white : AppColors.charcoal,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DemoButton extends StatelessWidget {
  const _DemoButton({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  final String icon;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.sage : AppColors.ivory,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? AppColors.teal : AppColors.line, width: isSelected ? 1.5 : 1),
        ),
        child: Column(
          children: [
            Text(icon, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 3),
            Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.tealDark)),
            Text(subtitle, style: const TextStyle(fontSize: 10, color: AppColors.muted)),
          ],
        ),
      ),
    );
  }
}
