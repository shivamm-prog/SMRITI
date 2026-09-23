import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'api_transport_interface.dart';

ApiTransport createTransport() => ApiTransportIo();

class ApiTransportIo implements ApiTransport {
  final HttpClient _client = HttpClient()..connectionTimeout = const Duration(seconds: 5);

  @override
  Future<TransportResponse> sendRequest({
    required String method,
    required String url,
    Map<String, String>? headers,
    String? body,
    int timeoutSeconds = 5,
  }) async {
    try {
      final uri = Uri.parse(url);
      final request = await _client.openUrl(method, uri).timeout(Duration(seconds: timeoutSeconds));

      headers?.forEach((k, v) {
        request.headers.set(k, v);
      });

      if (body != null) {
        final bytes = utf8.encode(body);
        request.contentLength = bytes.length;
        request.add(bytes);
      }

      final response = await request.close().timeout(Duration(seconds: timeoutSeconds));
      final responseBody = await response.transform(utf8.decoder).join();

      return TransportResponse(
        statusCode: response.statusCode,
        body: responseBody,
      );
    } on SocketException catch (_) {
      return const TransportResponse(
        statusCode: 0,
        body: 'Server unreachable',
        isOffline: true,
      );
    } on TimeoutException catch (_) {
      return const TransportResponse(
        statusCode: 0,
        body: 'Timed out',
        isOffline: true,
      );
    } catch (e) {
      return TransportResponse(
        statusCode: 0,
        body: e.toString(),
        isOffline: true,
      );
    }
  }
}
