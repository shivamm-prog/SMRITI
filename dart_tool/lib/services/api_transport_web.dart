import 'dart:async';
import 'dart:html' as html;
import 'api_transport_interface.dart';

ApiTransport createTransport() => ApiTransportWeb();

class ApiTransportWeb implements ApiTransport {
  @override
  Future<TransportResponse> sendRequest({
    required String method,
    required String url,
    Map<String, String>? headers,
    String? body,
    int timeoutSeconds = 5,
  }) async {
    try {
      final req = await html.HttpRequest.request(
        url,
        method: method,
        requestHeaders: headers,
        sendData: body,
      ).timeout(Duration(seconds: timeoutSeconds));

      return TransportResponse(
        statusCode: req.status ?? 200,
        body: req.responseText ?? '',
      );
    } on html.ProgressEvent catch (e) {
      final target = e.target;
      if (target is html.HttpRequest) {
        return TransportResponse(
          statusCode: target.status ?? 500,
          body: target.responseText ?? '',
        );
      }
      return const TransportResponse(
        statusCode: 0,
        body: 'Connection error',
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
