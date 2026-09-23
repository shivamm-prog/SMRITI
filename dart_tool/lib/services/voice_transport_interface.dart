abstract interface class VoiceTransport {
  Future<bool> isRecognitionSupported();
  Future<bool> isSynthesisSupported();
  Future<String?> listenOnce({String lang = 'en-US', Duration timeout = const Duration(seconds: 8)});
  Future<void> speak(String text, {String lang = 'en-US'});
  Future<void> stopSpeaking();
}
