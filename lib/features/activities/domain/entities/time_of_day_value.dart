/// Hora del día sin dependencia de Flutter (`HH:mm`, hora local de la ubicación).
class TimeOfDayValue implements Comparable<TimeOfDayValue> {
  const TimeOfDayValue(this.hour, this.minute);

  /// Interpreta `"HH:mm"`.
  factory TimeOfDayValue.parse(String value) {
    final parts = value.split(':');
    return TimeOfDayValue(int.parse(parts[0]), int.parse(parts[1]));
  }

  final int hour;
  final int minute;

  int get minutes => hour * 60 + minute;

  String format() =>
      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

  @override
  int compareTo(TimeOfDayValue other) => minutes.compareTo(other.minutes);

  bool isBefore(TimeOfDayValue other) => minutes < other.minutes;

  @override
  bool operator ==(Object other) =>
      other is TimeOfDayValue && other.minutes == minutes;

  @override
  int get hashCode => minutes.hashCode;

  @override
  String toString() => format();
}
