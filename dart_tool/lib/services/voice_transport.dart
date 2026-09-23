import 'voice_transport_interface.dart';
import 'voice_transport_stub.dart'
    if (dart.library.html) 'voice_transport_web.dart';

export 'voice_transport_interface.dart';

final VoiceTransport defaultVoiceTransport = createVoiceTransport();
