import 'dart:async';
import 'dart:html' as html;
import 'voice_transport_interface.dart';

VoiceTransport createVoiceTransport() => VoiceTransportWeb();

class VoiceTransportWeb implements VoiceTransport {
  @override
  Future<bool> isRecognitionSupported() async {
    try {
      return html.SpeechRecognition.supported;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> isSynthesisSupported() async {
    try {
      return html.window.speechSynthesis != null;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<String?> listenOnce({
    String lang = 'en-US',
    Duration timeout = const Duration(seconds: 8),
  }) async {
    try {
      if (!html.SpeechRecognition.supported) return null;

      final recognition = html.SpeechRecognition();
      recognition.continuous = false;
      recognition.interimResults = false;
      recognition.lang = lang;

      final completer = Completer<String?>();
      StreamSubscription? resultSub;
      StreamSubscription? errorSub;
      StreamSubscription? endSub;

      void cleanup() {
        resultSub?.cancel();
        errorSub?.cancel();
        endSub?.cancel();
      }

      resultSub = recognition.onResult.listen((html.SpeechRecognitionEvent event) {
        try {
          final results = event.results;
          if (results != null && results.isNotEmpty) {
            final first = results[0];
            final item = first.item(0);
            final transcript = item.transcript?.trim();
            if (!completer.isCompleted) {
              completer.complete(transcript);
            }
          }
        } catch (_) {
          if (!completer.isCompleted) completer.complete(null);
        }
      });

      errorSub = recognition.onError.listen((_) {
        if (!completer.isCompleted) completer.complete(null);
      });

      endSub = recognition.onEnd.listen((_) {
        if (!completer.isCompleted) completer.complete(null);
      });

      recognition.start();

      return await completer.future.timeout(
        timeout,
        onTimeout: () {
          try {
            recognition.stop();
          } catch (_) {}
          return null;
        },
      ).whenComplete(cleanup);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> speak(String text, {String lang = 'en-US'}) async {
    try {
      final synth = html.window.speechSynthesis;
      if (synth == null) return;
      synth.cancel();
      final utterance = html.SpeechSynthesisUtterance(text);
      utterance.lang = lang;
      utterance.rate = 0.9; // gentle speaking rate for dementia care
      synth.speak(utterance);
    } catch (_) {}
  }

  @override
  Future<void> stopSpeaking() async {
    try {
      html.window.speechSynthesis?.cancel();
    } catch (_) {}
  }
}
