import 'voice_transport_interface.dart';

VoiceTransport createVoiceTransport() => VoiceTransportStub();

class VoiceTransportStub implements VoiceTransport {
  @override
  Future<bool> isRecognitionSupported() async => false;

  @override
  Future<bool> isSynthesisSupported() async => false;

  @override
  Future<String?> listenOnce({String lang = 'en-US', Duration timeout = const Duration(seconds: 8)}) async {
    return null;
  }

  @override
  Future<void> speak(String text, {String lang = 'en-US'}) async {}

  @override
  Future<void> stopSpeaking() async {}
}
