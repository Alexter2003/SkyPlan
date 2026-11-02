import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/design_system/design_system.dart';
import '../../domain/entities/activity.dart';
import '../../domain/entities/time_of_day_value.dart';
import '../../domain/usecases/reschedule_activity.dart';
import '../state/reschedule_controller.dart';

/// Reagendar: elige nueva fecha y horario (mismos selectores del formulario
/// de actividades) y deja que el backend revalide. Devuelve la actividad
/// reagendada, o `null` si el usuario cierra la hoja.
Future<Activity?> showRescheduleSheet(BuildContext context, Activity activity) {
  return SkyBottomSheet.show<Activity>(
    context,
    title: 'Reagendar «${activity.name}»',
    builder: (_) => ChangeNotifierProvider(
      create: (context) => RescheduleController(
        rescheduleActivity: context.read<RescheduleActivity>(),
        activity: activity,
      ),
      child: const _RescheduleForm(),
    ),
  );
}

TimeOfDay _toTimeOfDay(TimeOfDayValue v) =>
    TimeOfDay(hour: v.hour, minute: v.minute);

TimeOfDayValue _fromTimeOfDay(TimeOfDay t) => TimeOfDayValue(t.hour, t.minute);

class _RescheduleForm extends StatelessWidget {
  const _RescheduleForm();

  Future<void> _submit(BuildContext context) async {
    final controller = context.read<RescheduleController>();
    final navigator = Navigator.of(context);
    final saved = await controller.submit();
    if (saved != null) navigator.pop(saved);
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<RescheduleController>();
    final typography = context.skyTypography;
    final colors = context.skyColors;

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (controller.serverError != null) ...[
              SkyInlineAlert(message: controller.serverError!),
              const SizedBox(height: SkySpacing.sm),
            ],
            SkyDateField(
              value: controller.date,
              firstDate: controller.today,
              lastDate: DateTime(controller.today.year + 2),
              errorText: controller.dateError,
              onChanged: controller.setDate,
            ),
            const SizedBox(height: SkySpacing.sm),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: SkyTimeField(
                    label: 'Inicio',
                    value: _toTimeOfDay(controller.startTime),
                    onChanged: (t) => controller.setStart(_fromTimeOfDay(t)),
                  ),
                ),
                const SizedBox(width: SkySpacing.sm),
                Expanded(
                  child: SkyTimeField(
                    label: 'Fin',
                    value: _toTimeOfDay(controller.endTime),
                    onChanged: (t) => controller.setEnd(_fromTimeOfDay(t)),
                  ),
                ),
              ],
            ),
            if (controller.timeError != null) ...[
              const SizedBox(height: SkySpacing.xxs),
              Text(
                controller.timeError!,
                style: typography.caption.copyWith(color: colors.primaryRed),
              ),
            ],
            const SizedBox(height: SkySpacing.xs),
            Text(
              'El clima del nuevo día se valida con el pronóstico. Si estaba '
              'cancelada, volverá a estar pendiente.',
              style: typography.caption.copyWith(color: colors.subtle),
            ),
            const SizedBox(height: SkySpacing.md),
            SkyButton(
              label: 'Reagendar',
              expand: true,
              loading: controller.isSubmitting,
              onPressed: () => _submit(context),
            ),
          ],
        ),
      ),
    );
  }
}
