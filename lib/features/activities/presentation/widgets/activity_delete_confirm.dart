import 'package:flutter/material.dart';

import '../../../../core/design_system/design_system.dart';
import '../../domain/entities/activity.dart';

/// Confirmación de eliminación de una actividad.
Future<bool> confirmDeleteActivity(BuildContext context, Activity activity) {
  return SkyDialog.confirm(
    context,
    title: '¿Eliminar «${activity.name}»?',
    message: 'Esta acción no se puede deshacer.',
    confirmLabel: 'Eliminar',
    destructive: true,
  );
}
