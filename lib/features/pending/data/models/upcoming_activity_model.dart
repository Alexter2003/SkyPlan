import '../../../activities/data/models/activity_model.dart';
import '../../../locations/data/models/visit_model.dart';
import '../../domain/entities/forecast_hour.dart';
import '../../domain/entities/upcoming_activity.dart';
import '../../domain/entities/upcoming_page.dart';
import '../../domain/entities/upcoming_visit.dart';

/// Parseo de `GET /activities/upcoming`.
abstract final class UpcomingModels {
  static UpcomingPage page(Map<String, dynamic> json) {
    final items = json['items'] as List<dynamic>? ?? const [];
    return UpcomingPage(
      items: [for (final item in items) activity(item as Map<String, dynamic>)],
      page: json['page'] as int? ?? 1,
      limit: json['limit'] as int? ?? items.length,
      total: json['total'] as int? ?? items.length,
    );
  }

  static UpcomingActivity activity(Map<String, dynamic> json) {
    final forecast = json['forecast'];
    return UpcomingActivity(
      activity: ActivityModel.fromJson(json),
      visit: _visit(json['visit'] as Map<String, dynamic>),
      forecast: forecast is List
          ? [for (final hour in forecast) _hour(hour as Map<String, dynamic>)]
          : null,
    );
  }

  static UpcomingVisit _visit(Map<String, dynamic> json) => UpcomingVisit(
    id: json['id'] as int,
    name: json['name'] as String,
    latitude: (json['latitude'] as num).toDouble(),
    longitude: (json['longitude'] as num).toDouble(),
    date: VisitModel.parseApiDate(json['date'] as String),
    status: VisitModel.parseStatus(json['status'] as String),
  );

  static ForecastHour _hour(Map<String, dynamic> json) => ForecastHour(
    time: json['time'] as String,
    weatherCode: (json['weatherCode'] as num).toInt(),
    precipitation: (json['precipitation'] as num).toDouble(),
    cloudCover: (json['cloudCover'] as num).round(),
    windSpeed: (json['windSpeed'] as num).toDouble(),
    precipitationProbability: (json['precipitationProbability'] as num).round(),
  );
}
