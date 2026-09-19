/// Sobre de respuesta de la API SkyPlan: `{ status, message, data }`.
class ApiEnvelope {
  const ApiEnvelope({
    required this.status,
    required this.message,
    required this.data,
    required this.messages,
  });

  factory ApiEnvelope.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final rawMessage = json['message'];

    // `data` puede ser un arreglo de strings (errores de validación).
    final messages = switch (data) {
      List<dynamic> list => list.map((e) => e.toString()).toList(),
      _ => rawMessage is String ? <String>[rawMessage] : const <String>[],
    };

    return ApiEnvelope(
      status: json['status'] as int,
      message: rawMessage is String ? rawMessage : '',
      data: data,
      messages: messages,
    );
  }

  final int status;
  final String message;
  final dynamic data;
  final List<String> messages;

  Map<String, dynamic> get dataObject =>
      data is Map<String, dynamic> ? data as Map<String, dynamic> : const {};
}
