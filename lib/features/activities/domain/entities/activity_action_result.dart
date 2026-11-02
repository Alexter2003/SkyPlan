import '../../../locations/domain/entities/visit.dart';
import 'activity.dart';

/// Resultado de completar, desmarcar o cancelar: la actividad y el estado
/// en que quedó su visita (`null` si la API no lo informó).
class ActivityActionResult {
  const ActivityActionResult({required this.activity, this.visitStatus});

  final Activity activity;
  final VisitStatus? visitStatus;
}
