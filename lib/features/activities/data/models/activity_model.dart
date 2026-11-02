import '../../../locations/data/models/visit_model.dart';
import '../../domain/entities/activity.dart';
import '../../domain/entities/time_of_day_value.dart';

class ActivityModel extends Activity {
  const ActivityModel({
    required super.id,
    required super.visitId,
    required super.name,
    required super.description,
    required super.date,
    required super.startTime,
    required super.endTime,
    required super.type,
    required super.state,
    required super.conditions,
    super.isViable,
    super.probability,
    super.probabilityBand,
    super.cancelReason,
    super.cancelledAt,
    super.completedAt,
  });

  factory ActivityModel.fromJson(Map<String, dynamic> json) {
    final state = json['state'] as Map<String, dynamic>;
    return ActivityModel(
      id: json['id'] as int,
      visitId: json['visitId'] as int,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      date: VisitModel.parseApiDate(json['date'] as String),
      startTime: TimeOfDayValue.parse(json['startTime'] as String),
      endTime: TimeOfDayValue.parse(json['endTime'] as String),
      type: parseType(json['type'] as String),
      state: parseState(state['name'] as String),
      isViable: json['isViable'] as bool?,
      probability: (json['probability'] as num?)?.round(),
      probabilityBand: parseBand(json['probabilityBand'] as String?),
      cancelReason: json['cancelReason'] as String?,
      cancelledAt: _parseDateTime(json['cancelledAt']),
      completedAt: _parseDateTime(json['completedAt']),
      conditions: [
        for (final c in json['weatherConditions'] as List<dynamic>? ?? const [])
          ActivityCondition(
            id: (c as Map<String, dynamic>)['id'] as int,
            name: c['name'] as String,
          ),
      ],
    );
  }

  static ActivityType parseType(String value) =>
      value == 'INDOOR' ? ActivityType.indoor : ActivityType.outdoor;

  static String typeToApi(ActivityType type) =>
      type == ActivityType.indoor ? 'INDOOR' : 'OUTDOOR';

  static ProbabilityBand? parseBand(String? value) => switch (value) {
    'GREEN' => ProbabilityBand.green,
    'YELLOW' => ProbabilityBand.yellow,
    'RED' => ProbabilityBand.red,
    _ => null,
  };

  static DateTime? _parseDateTime(Object? value) =>
      value is String ? DateTime.tryParse(value) : null;

  static ActivityState parseState(String value) => switch (value) {
    'completed' => ActivityState.completed,
    'cancelled' => ActivityState.cancelled,
    'cancelled_by_system' => ActivityState.cancelledBySystem,
    _ => ActivityState.planned,
  };
}
