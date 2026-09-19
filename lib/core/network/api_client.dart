import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import 'api_envelope.dart';
import 'api_exception.dart';

/// Cliente HTTP para la API de SkyPlan.
class ApiClient {
  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  static const _timeout = Duration(seconds: 15);

  Future<ApiEnvelope> postJson(
    String path,
    Map<String, dynamic> body, {
    String? token,
  }) => _send('POST', path, body: body, token: token);

  Future<ApiEnvelope> _send(
    String method,
    String path, {
    Map<String, dynamic>? body,
    String? token,
  }) async {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}$path');
    final headers = <String, String>{
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    http.Response response;
    try {
      response = await _client
          .post(
            uri,
            headers: headers,
            body: body == null ? null : jsonEncode(body),
          )
          .timeout(_timeout);
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

  void close() => _client.close();
}
