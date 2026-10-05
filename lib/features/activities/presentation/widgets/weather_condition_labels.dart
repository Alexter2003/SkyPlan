import '../../../../core/design_system/design_system.dart';
import '../../domain/entities/activity.dart';

/// Etiqueta en español de una condición (`name` es estable en la API).
String conditionLabel(String name) => switch (name) {
  'sunny' => 'Soleado',
  'clear' => 'Despejado',
  'partly_cloudy' => 'Parcialmente nublado',
  'cloudy' => 'Nublado',
  'drizzle' => 'Llovizna',
  'rainy' => 'Lluvia',
  'snowy' => 'Nieve',
  'windy' => 'Ventoso',
  _ => name,
};

/// Icono de la condición, si el set de iconos tiene uno apropiado.
SkyIconType? conditionIcon(String name) => switch (name) {
  'sunny' || 'clear' => SkyIconType.sun,
  'partly_cloudy' || 'cloudy' => SkyIconType.cloud,
  'drizzle' || 'rainy' => SkyIconType.rain,
  _ => null,
};

String typeLabel(ActivityType type) =>
    type == ActivityType.outdoor ? 'Al aire libre' : 'Interior';
