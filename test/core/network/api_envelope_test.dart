import 'package:flutter_test/flutter_test.dart';
import 'package:sky_plan/core/network/api_envelope.dart';

void main() {
  group('ApiEnvelope.fromJson', () {
    test('parses a success response with an object data payload', () {
      final envelope = ApiEnvelope.fromJson({
        'status': 201,
        'message': 'Usuario registrado exitosamente',
        'data': {'id': 1, 'email': 'user@example.com'},
      });

      expect(envelope.status, 201);
      expect(envelope.message, 'Usuario registrado exitosamente');
      expect(envelope.dataObject, {'id': 1, 'email': 'user@example.com'});
      expect(envelope.messages, ['Usuario registrado exitosamente']);
    });

    test('parses an error response with data: null', () {
      final envelope = ApiEnvelope.fromJson({
        'status': 401,
        'message': 'Credenciales inválidas',
        'data': null,
      });

      expect(envelope.status, 401);
      expect(envelope.dataObject, isEmpty);
      expect(envelope.messages, ['Credenciales inválidas']);
    });

    test(
      'normalizes a class-validator array of strings in data into messages',
      () {
        final envelope = ApiEnvelope.fromJson({
          'status': 400,
          'message': null,
          'data': [
            'el password debe contener al menos una minúscula',
            'el email debe ser un correo válido',
          ],
        });

        expect(envelope.dataObject, isEmpty);
        expect(envelope.messages, [
          'el password debe contener al menos una minúscula',
          'el email debe ser un correo válido',
        ]);
      },
    );
  });
}
