import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import 'api_envelope.dart';
import 'api_exception.dart';

/// Entrega el token de sesión vigente (o `null` si no hay sesión).
typedef TokenProvider = Future<String?> Function();

/// Cliente HTTP para la API de SkyPlan.
class ApiClient {
  ApiClient({http.Client? client, this.tokenProvider})
    : _client = client ?? http.Client();

  final http.Client _client;
  final TokenProvider? tokenProvider;
  final _unauthorized = StreamController<void>.broadcast();
  static const _timeout = Duration(seconds: 15);

  /// Emite cuando una petición autenticada recibe 401 (sesión inválida).
  Stream<void> get unauthorized => _unauthorized.stream;

  Future<ApiEnvelope> getJson(
    String path, {
    bool authenticated = true,
    String? token,
  }) => _send('GET', path, authenticated: authenticated, token: token);

  Future<ApiEnvelope> postJson(
    String path,
    Map<String, dynamic> body, {
    bool authenticated = true,
    String? token,
  }) => _send(
    'POST',
    path,
    body: body,
    authenticated: authenticated,
    token: token,
  );

  Future<ApiEnvelope> patchJson(
    String path,
    Map<String, dynamic> body, {
    bool authenticated = true,
  }) => _send('PATCH', path, body: body, authenticated: authenticated);

  Future<ApiEnvelope> deleteJson(String path, {bool authenticated = true}) =>
      _send('DELETE', path, authenticated: authenticated);

  Future<ApiEnvelope> _send(
    String method,
    String path, {
    Map<String, dynamic>? body,
    required bool authenticated,
    String? token,
  }) async {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}$path');
    final resolvedToken =
        token ?? (authenticated ? await tokenProvider?.call() : null);
    final headers = <String, String>{
      'Content-Type': 'application/json',
      if (resolvedToken != null) 'Authorization': 'Bearer $resolvedToken',
    };

    final request = http.Request(method, uri)..headers.addAll(headers);
    if (body != null) request.body = jsonEncode(body);

    http.Response response;
    try {
      final streamed = await _client.send(request).timeout(_timeout);
      response = await http.Response.fromStream(streamed).timeout(_timeout);
    } on TimeoutException {
      throw const NetworkException();
    } on SocketException {
      throw const NetworkException();
    } on http.ClientException {
      throw const NetworkException();
    }

    final Map<String, dynamic> json;
    try {
      json = response.body.isEmpty
          ? const {}
          : jsonDecode(response.body) as Map<String, dynamic>;
    } on FormatException {
      throw const NetworkException(
        'El servidor respondió de forma inesperada. Inténtalo de nuevo.',
      );
    }

    final envelope = ApiEnvelope.fromJson({
      'status': json['status'] ?? response.statusCode,
      'message': json['message'],
      'data': json['data'],
    });

    if (response.statusCode < 200 || response.statusCode >= 300) {
      if (response.statusCode == 401 && authenticated) {
        _unauthorized.add(null);
      }
      throw ApiException(
        status: envelope.status,
        message: envelope.message.isNotEmpty
            ? envelope.message
            : 'Ocurrió un error inesperado. Inténtalo de nuevo.',
        details: envelope.messages,
      );
    }

    return envelope;
  }

  void close() {
    _unauthorized.close();
    _client.close();
  }
}
