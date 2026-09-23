class TransportResponse {
  const TransportResponse({
    required this.statusCode,
    required this.body,
    this.isOffline = false,
  });

  final int statusCode;
  final String body;
  final bool isOffline;
}

abstract class ApiTransport {
  Future<TransportResponse> sendRequest({
    required String method,
    required String url,
    Map<String, String>? headers,
    String? body,
    int timeoutSeconds = 5,
  });
}
