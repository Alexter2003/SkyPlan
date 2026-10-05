import '../../../../core/design_system/design_system.dart';

/// Textos en lenguaje cotidiano para los datos crudos del pronóstico.

String temperatureFeel(double celsius) {
  if (celsius < 10) return 'Frío';
  if (celsius < 18) return 'Fresco';
  if (celsius < 26) return 'Templado';
  if (celsius < 32) return 'Cálido';
  return 'Caluroso';
}

/// Qué tanta lluvia/nieve se espera, según los milímetros.
String precipitationText(double mm, Set<String> conditions) {
  if (conditions.contains('snowy')) return 'Nevará';
  if (conditions.contains('drizzle')) return 'Llovizna';
  if (mm <= 0) return 'Sin lluvia';
  if (mm < 2.5) return 'Lluvia ligera';
  if (mm < 7.6) return 'Lluvia moderada';
  return 'Lluvia fuerte';
}

String cloudText(double percent) {
  if (percent < 30) return 'Despejado';
  if (percent < 70) return 'Parcialmente nublado';
  return 'Nublado';
}

SkyIconType cloudIcon(double percent) {
  if (percent < 30) return SkyIconType.sun;
  if (percent < 70) return SkyIconType.partlyCloudy;
  return SkyIconType.cloud;
}

String windText(double kmh) {
  if (kmh < 12) return 'Viento suave';
  if (kmh < 30) return 'Viento moderado';
  return 'Viento fuerte';
}

/// Etiqueta visible de una condición del catálogo.
String weatherLabel(String condition) => switch (condition) {
  'snowy' => 'Nieve',
  'rainy' => 'Lluvia',
  'drizzle' => 'Llovizna',
  'cloudy' => 'Nublado',
  'partly_cloudy' => 'Parcialmente nublado',
  'sunny' || 'clear' => 'Soleado',
  'windy' => 'Ventoso',
  _ => condition,
};

SkyIconType weatherIcon(String condition) => switch (condition) {
  'snowy' => SkyIconType.snow,
  'rainy' || 'drizzle' => SkyIconType.rain,
  'cloudy' => SkyIconType.cloud,
  'partly_cloudy' => SkyIconType.partlyCloudy,
  'windy' => SkyIconType.wind,
  _ => SkyIconType.sun,
};

/// Condiciones a mostrar, en orden: precipitación, cielo y viento.
/// `sunny` y `clear` son sinónimos: se muestra solo "Soleado".
List<String> displayConditions(Set<String> conditions) {
  const order = [
    'snowy',
    'rainy',
    'drizzle',
    'cloudy',
    'partly_cloudy',
    'sunny',
    'windy',
  ];
  return [
    for (final c in order)
      if (conditions.contains(c)) c,
  ];
}

/// Condición principal para el icono: precipitación primero, luego cielo.
String? primaryCondition(Set<String> conditions) {
  final shown = displayConditions(conditions).where((c) => c != 'windy');
  return shown.isEmpty ? null : shown.first;
}
