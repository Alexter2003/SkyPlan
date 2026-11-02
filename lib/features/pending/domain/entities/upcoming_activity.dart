import '../../../activities/domain/entities/activity.dart';
import '../../../locations/domain/entities/visit.dart';
import 'forecast_hour.dart';
import 'upcoming_visit.dart';

/// Actividad próxima con su ubicación y el clima de su franja.
class UpcomingActivity {
  const UpcomingActivity({
    required this.activity,
    required this.visit,
    this.forecast,
  });

  final Activity activity;
  final UpcomingVisit visit;

  /// `null` si todavía no hay pronóstico horario de su visita.
  final List<ForecastHour>? forecast;

  int get id => activity.id;

  /// Reemplaza la actividad (respuesta de una acción) conservando ubicación
  /// y pronóstico, que las acciones no devuelven.
  UpcomingActivity withActivity(Activity value, {VisitStatus? visitStatus}) {
    return UpcomingActivity(
      activity: value,
      visit: visitStatus == null ? visit : visit.withStatus(visitStatus),
      forecast: forecast,
    );
  }
}
