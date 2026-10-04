import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:sky_plan/core/network/api_client.dart';
import 'package:sky_plan/core/network/api_exception.dart';

http.Response _ok([Object? data]) => http.Response(
  jsonEncode({'status': 200, 'message': 'ok', 'data': data}),
  200,
);

void main() {
  test('authenticated requests carry the bearer token', () async {
    late http.BaseRequest seen;
    final client = ApiClient(
      client: MockClient((request) async {
        seen = request;
        return _ok([]);
      }),
      tokenProvider: () async => 'abc123',
    );

    await client.getJson('/visits');

    expect(seen.method, 'GET');
    expect(seen.headers['Authorization'], 'Bearer abc123');
  });

  test('authenticated: false sends no token', () async {
    late http.BaseRequest seen;
    final client = ApiClient(
      client: MockClient((request) async {
        seen = request;
        return _ok({});
      }),
      tokenProvider: () async => 'abc123',
    );

    await client.postJson('/auth/login', const {}, authenticated: false);

    expect(seen.headers.containsKey('Authorization'), isFalse);
  });

  test('uses the right method and body for PATCH and DELETE', () async {
    final seen = <http.Request>[];
    final client = ApiClient(
      client: MockClient((request) async {
        seen.add(request);
        return _ok({});
      }),
    );

    await client.patchJson('/visits/1', {'name': 'x'});
    await client.deleteJson('/visits/1');

    expect(seen[0].method, 'PATCH');
    expect(jsonDecode(seen[0].body), {'name': 'x'});
    expect(seen[1].method, 'DELETE');
    expect(seen[1].url.path, endsWith('/visits/1'));
  });

  test('a 401 on an authenticated request emits unauthorized', () async {
    final client = ApiClient(
      client: MockClient(
        (_) async => http.Response(
          jsonEncode({'status': 401, 'message': 'No autenticado'}),
          401,
        ),
      ),
    );

    final emitted = expectLater(client.unauthorized, emits(anything));
    await expectLater(
      client.getJson('/visits'),
      throwsA(isA<ApiException>().having((e) => e.status, 'status', 401)),
    );
    await emitted;
  });

  test('a 401 on a public request does not emit unauthorized', () async {
    final client = ApiClient(
      client: MockClient(
        (_) async => http.Response(
          jsonEncode({'status': 401, 'message': 'Credenciales inválidas'}),
          401,
        ),
      ),
    );
    var emissions = 0;
    client.unauthorized.listen((_) => emissions++);

    await expectLater(
      client.postJson('/auth/login', const {}, authenticated: false),
      throwsA(isA<ApiException>()),
    );
    await Future<void>.delayed(Duration.zero);

    expect(emissions, 0);
  });
}
