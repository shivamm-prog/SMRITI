import 'dart:async';
import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../localization/app_language.dart';
import '../services/local_data_service.dart';
import '../services/voice_service.dart';

enum VoiceModalState { listening, processing, response, error }

class VoiceCompanionModal extends StatefulWidget {
  const VoiceCompanionModal({
    super.key,
    required this.onNavigateTab,
    this.voiceService,
  });

  final void Function(int tabIndex) onNavigateTab;
  final VoiceService? voiceService;

  static Future<void> show(
    BuildContext context, {
    required void Function(int tabIndex) onNavigateTab,
    VoiceService? voiceService,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => VoiceCompanionModal(
        onNavigateTab: onNavigateTab,
        voiceService: voiceService,
      ),
    );
  }

  @override
  State<VoiceCompanionModal> createState() => _VoiceCompanionModalState();
}

class _VoiceCompanionModalState extends State<VoiceCompanionModal>
    with SingleTickerProviderStateMixin {
  late final VoiceService _voiceService;
  VoiceModalState _state = VoiceModalState.listening;
  String _recognizedText = '';
  String _errorMessage = '';
  VoiceResponse? _voiceResponse;
  bool _isSpeaking = false;
  late final AnimationController _pulseController;
  final TextEditingController _textInputController = TextEditingController();

  final List<String> _samplePrompts = [
    "Show my progress",
    "Start today's activity",
    "Change language to Hindi",
    "Change language to Assamese",
    "Show my reminders",
    "What do I have today?",
  ];

  @override
  void initState() {
    super.initState();
    _voiceService = widget.voiceService ?? MindSetuVoiceService.instance;
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _startListeningFlow();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _textInputController.dispose();
    _voiceService.stopSpeaking();
    super.dispose();
  }

  Future<void> _startListeningFlow() async {
    if (!mounted) return;
    setState(() {
      _state = VoiceModalState.listening;
      _recognizedText = '';
      _errorMessage = '';
      _voiceResponse = null;
      _isSpeaking = false;
    });

    final currentLang = LocalDataService.instance.currentLanguage;
    final available = await _voiceService.isAvailable();

    if (!available) {
      if (mounted) {
        setState(() {
          _state = VoiceModalState.error;
          _errorMessage = 'Microphone access is unavailable. You can type your request instead.';
        });
      }
      return;
    }

    final res = await _voiceService.listen(
      timeout: const Duration(seconds: 7),
      language: currentLang,
    );

    if (!mounted) return;

    if (res.isAvailable && res.text != null && res.text!.trim().isNotEmpty) {
      _handleCommand(res.text!.trim());
    } else {
      setState(() {
        _state = VoiceModalState.error;
        _errorMessage = res.errorMessage ?? 'Microphone access is unavailable. You can type your request instead.';
      });
    }
  }

  Future<void> _handleCommand(String text) async {
    if (text.trim().isEmpty) return;
    if (!mounted) return;

    setState(() {
      _recognizedText = text.trim();
      _state = VoiceModalState.processing;
    });

    // Gentle realistic delay so patient feels acknowledged
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;

    final data = LocalDataService.instance;
    final response = await _voiceService.processCommand(
      text,
      data: data,
      language: data.currentLanguage,
    );

    if (!mounted) return;
    setState(() {
      _voiceResponse = response;
      _state = VoiceModalState.response;
      _isSpeaking = true;
    });

    await _voiceService.speak(response.responseText, language: data.currentLanguage);
    if (mounted) {
      setState(() => _isSpeaking = false);
    }
  }

  void _onActionClick() {
    final target = _voiceResponse?.targetTabIndex;
    if (target != null) {
      widget.onNavigateTab(target);
      Navigator.of(context).pop();
    }
  }

  void _onSubmitTypedText() {
    final text = _textInputController.text.trim();
    if (text.isNotEmpty) {
      _textInputController.clear();
      FocusScope.of(context).unfocus();
      _handleCommand(text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: LocalDataService.instance,
      builder: (context, _) {
        final data = LocalDataService.instance;
        final currentLang = data.currentLanguage;
        final l = data.localizations;

        final subHeaderLang = switch (currentLang) {
          AppLanguage.assamese => 'অসমীয়া, হিন্দী বা ইংৰাজীত কওক। আপোনাৰ সময় লওক।',
          AppLanguage.hindi => 'हिंदी, असमिया या अंग्रेजी में बोलें। आराम से अपनी बात कहें।',
          AppLanguage.nepali => 'नेपाली, हिन्दी वा अंग्रेजीमा बोल्नुहोस्। आरामसँग भन्नुहोस्।',
          _ => 'Speak in your regional language, Hindi, or English. Take your time.',
        };

        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.88,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Top drag indicator
                    Center(
                      child: Container(
                        width: 48,
                        height: 5,
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: AppColors.line,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),

                    // Header row with active language indicator
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Text('🎙️', style: TextStyle(fontSize: 24)),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'MindSetu Voice Companion',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.ink,
                                  ),
                                ),
                                Text(
                                  'Active Language: ${currentLang.label}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.blue,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded, color: AppColors.muted, size: 24),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Language Support Notice Banner
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.sky,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.line),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.verified_outlined, color: AppColors.blue, size: 16),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Hindi & English STT fully supported · Assamese speech recognition is browser-dependent',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.blue,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Main visual state area
                    Flexible(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            // 1. LISTENING STATE (Teammate Radial Mic Area)
                            if (_state == VoiceModalState.listening) ...[
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 16),
                                decoration: BoxDecoration(
                                  gradient: const RadialGradient(
                                    radius: 0.7,
                                    colors: [Color(0xFFD7E7FF), Color(0xFFF9FBFF)],
                                  ),
                                  borderRadius: BorderRadius.circular(21),
                                ),
                                child: Column(
                                  children: [
                                    ScaleTransition(
                                      scale: Tween(begin: 0.95, end: 1.05).animate(_pulseController),
                                      child: InkWell(
                                        onTap: _startListeningFlow,
                                        borderRadius: BorderRadius.circular(50),
                                        child: AnimatedContainer(
                                          duration: const Duration(milliseconds: 300),
                                          width: 100,
                                          height: 100,
                                          decoration: BoxDecoration(
                                            color: AppColors.danger,
                                            shape: BoxShape.circle,
                                            boxShadow: const [
                                              BoxShadow(
                                                color: Color(0xFFFFDCE0),
                                                spreadRadius: 14,
                                              ),
                                              BoxShadow(
                                                color: Color(0xFFFFF0F2),
                                                spreadRadius: 26,
                                              ),
                                            ],
                                          ),
                                          child: const Center(
                                            child: Icon(
                                              Icons.mic_rounded,
                                              size: 44,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 28),

                                    // Animated wave bars
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: List.generate(5, (i) {
                                        final heights = [16.0, 28.0, 42.0, 24.0, 14.0];
                                        return AnimatedContainer(
                                          duration: const Duration(milliseconds: 300),
                                          margin: const EdgeInsets.symmetric(horizontal: 3),
                                          width: 5,
                                          height: heights[i],
                                          decoration: BoxDecoration(
                                            color: AppColors.blue,
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                        );
                                      }),
                                    ),
                                    const SizedBox(height: 14),

                                    Text(
                                      l.voiceListeningGently,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontFamily: 'Fraunces',
                                        fontSize: 22,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.ink,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      subHeaderLang,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(fontSize: 14, color: AppColors.muted),
                                    ),
                                  ],
                                ),
                              ),
                            ]
                            // 2. PROCESSING STATE
                            else if (_state == VoiceModalState.processing) ...[
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF7FAFF),
                                  borderRadius: BorderRadius.circular(21),
                                ),
                                child: Column(
                                  children: [
                                    Container(
                                      width: 78,
                                      height: 78,
                                      decoration: BoxDecoration(
                                        color: AppColors.sky,
                                        shape: BoxShape.circle,
                                        border: Border.all(color: AppColors.blue, width: 2),
                                      ),
                                      child: const Center(
                                        child: CircularProgressIndicator(
                                          color: AppColors.blue,
                                          strokeWidth: 3,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    Text(
                                      'Understanding: "$_recognizedText"',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.blue,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      l.voiceProcessingCare,
                                      style: const TextStyle(fontSize: 13, color: AppColors.muted),
                                    ),
                                  ],
                                ),
                              ),
                            ]
                            // 3. RESPONSE STATE
                            else if (_state == VoiceModalState.response && _voiceResponse != null) ...[
                              const SizedBox(height: 12),
                              Container(
                                width: 68,
                                height: 68,
                                decoration: BoxDecoration(
                                  color: _isSpeaking ? const Color(0xFFDCFCE7) : AppColors.sky,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  _isSpeaking ? Icons.volume_up_rounded : Icons.record_voice_over_rounded,
                                  size: 36,
                                  color: _isSpeaking ? const Color(0xFF15803D) : AppColors.blue,
                                ),
                              ),
                              if (_isSpeaking) ...[
                                const SizedBox(height: 6),
                                Text(
                                  l.voiceSpeakingGently,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF15803D),
                                  ),
                                ),
                              ],
                              const SizedBox(height: 12),

                              // Visible Patient Transcript Card
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: AppColors.line),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'You said:',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.muted,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '"${_voiceResponse!.query}"',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.ink,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),

                              // SMRITI AI Response Card
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(18),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(color: AppColors.blue.withOpacity(0.35), width: 1.5),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color.fromRGBO(26, 68, 141, 0.06),
                                      blurRadius: 12,
                                      offset: Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Text(
                                          'SMRITI:',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.blue,
                                            letterSpacing: 0.4,
                                          ),
                                        ),
                                        const Spacer(),
                                        if (_isSpeaking)
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFDCFCE7),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              l.voiceSpeakingGently,
                                              style: const TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w700,
                                                color: Color(0xFF15803D),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      '"${_voiceResponse!.responseText}"',
                                      style: const TextStyle(
                                        fontSize: 17,
                                        height: 1.5,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.ink,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Direct Action button if target tab is available
                              if (_voiceResponse!.targetTabIndex != null &&
                                  _voiceResponse!.actionLabel != null) ...[
                                SizedBox(
                                  width: double.infinity,
                                  child: FilledButton.icon(
                                    style: FilledButton.styleFrom(
                                      backgroundColor: AppColors.blue,
                                      minimumSize: const Size.fromHeight(50),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    onPressed: _onActionClick,
                                    icon: const Icon(Icons.arrow_forward_rounded),
                                    label: Text(
                                      _voiceResponse!.actionLabel!,
                                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                              ],

                              // Speak again button
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    minimumSize: const Size.fromHeight(46),
                                    side: const BorderSide(color: AppColors.blue),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: _startListeningFlow,
                                  icon: const Icon(Icons.mic_rounded, color: AppColors.blue),
                                  label: Text(
                                    l.voiceAskSomethingElse,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.blue,
                                    ),
                                  ),
                                ),
                              ),
                            ]
                            // 4. ERROR / FALLBACK STATE
                            else if (_state == VoiceModalState.error) ...[
                              const SizedBox(height: 10),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFEF3C7),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: const Color(0xFFFCD34D)),
                                ),
                                child: Column(
                                  children: [
                                    const Icon(Icons.mic_off_rounded, color: Color(0xFFB45309), size: 38),
                                    const SizedBox(height: 8),
                                    Text(
                                      l.voiceErrorTitle,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF92400E),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _errorMessage.isNotEmpty ? _errorMessage : l.voiceErrorSubtitle,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(fontSize: 13, color: Color(0xFF78350F)),
                                    ),
                                    const SizedBox(height: 12),
                                    FilledButton.icon(
                                      style: FilledButton.styleFrom(
                                        backgroundColor: const Color(0xFFD97706),
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      ),
                                      onPressed: _startListeningFlow,
                                      icon: const Icon(Icons.refresh_rounded, size: 18),
                                      label: Text(l.voiceTryAgainButton, style: const TextStyle(fontWeight: FontWeight.w700)),
                                    ),
                                  ],
                                ),
                              ),
                            ],

                            const SizedBox(height: 16),
                            const Divider(color: AppColors.line),
                            const SizedBox(height: 10),

                            // Interactive Fallback Text Input Field
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _textInputController,
                                    onSubmitted: (_) => _onSubmitTypedText(),
                                    decoration: InputDecoration(
                                      hintText: l.voiceTypeCommandPlaceholder,
                                      hintStyle: const TextStyle(fontSize: 13, color: AppColors.muted),
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      filled: true,
                                      fillColor: Colors.white,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(color: AppColors.line),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(color: AppColors.line),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(color: AppColors.blue, width: 1.5),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                FilledButton(
                                  style: FilledButton.styleFrom(
                                    backgroundColor: AppColors.blue,
                                    foregroundColor: Colors.white,
                                    minimumSize: const Size(60, 48),
                                    padding: const EdgeInsets.symmetric(horizontal: 14),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  onPressed: _onSubmitTypedText,
                                  child: const Icon(Icons.send_rounded, size: 18),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Common Questions Quick-Tap Chips
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                l.voiceCommonQuestionsHeader,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.muted,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),

                            ..._samplePrompts.map((cmd) => Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: SizedBox(
                                    width: double.infinity,
                                    child: OutlinedButton(
                                      style: OutlinedButton.styleFrom(
                                        alignment: Alignment.centerLeft,
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                        side: const BorderSide(color: AppColors.line),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        backgroundColor: Colors.white,
                                      ),
                                      onPressed: () => _handleCommand(cmd),
                                      child: Row(
                                        children: [
                                          const Text('💬', style: TextStyle(fontSize: 16)),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              '"$cmd"',
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.ink,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Try',
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.blue,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                )),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
