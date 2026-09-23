import 'api_transport_interface.dart';
import 'api_transport_stub.dart'
    if (dart.library.io) 'api_transport_io.dart'
    if (dart.library.html) 'api_transport_web.dart';

export 'api_transport_interface.dart';

final ApiTransport defaultTransport = createTransport();
