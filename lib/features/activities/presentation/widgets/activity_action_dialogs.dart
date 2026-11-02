import 'package:flutter/material.dart';

import '../../../../core/design_system/design_system.dart';
import '../../domain/entities/activity.dart';

/// Máximo de caracteres del motivo de cancelación (límite del backend).
const cancelReasonMaxLength = 500;

/// Resultado de confirmar la cancelación; [reason] nulo = sin motivo.
class CancelDecision {
  const CancelDecision(this.reason);
  final String? reason;
}

/// Pide confirmación y un motivo opcional antes de cancelar. Devuelve `null`
/// si el usuario se arrepiente.
Future<CancelDecision?> confirmCancelActivity(
  BuildContext context,
  Activity activity,
) {
  return SkyBottomSheet.show<CancelDecision>(
    context,
    title: '¿Cancelar «${activity.name}»?',
    builder: (_) => _CancelForm(activity: activity),
  );
}

class _CancelForm extends StatefulWidget {
  const _CancelForm({required this.activity});

  final Activity activity;

  @override
  State<_CancelForm> createState() => _CancelFormState();
}

class _CancelFormState extends State<_CancelForm> {
  final _formKey = GlobalKey<FormState>();
  final _reason = TextEditingController();

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final typography = context.skyTypography;
    final colors = context.skyColors;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Podrás reactivarla o reagendarla después.',
            style: typography.caption.copyWith(color: colors.subtle),
          ),
          const SizedBox(height: SkySpacing.sm),
          Form(
            key: _formKey,
            child: SkyTextArea(
              controller: _reason,
              label: 'Motivo (opcional)',
              minLines: 2,
              maxLines: 4,
              validator: (value) =>
                  (value ?? '').trim().length > cancelReasonMaxLength
                  ? 'El motivo no puede superar los $cancelReasonMaxLength '
                        'caracteres'
                  : null,
            ),
          ),
          const SizedBox(height: SkySpacing.md),
          SkyButton(
            label: 'Cancelar actividad',
            variant: SkyButtonVariant.danger,
            expand: true,
            onPressed: () {
              if (!(_formKey.currentState?.validate() ?? false)) return;
              final text = _reason.text.trim();
              Navigator.of(
                context,
              ).pop(CancelDecision(text.isEmpty ? null : text));
            },
          ),
          const SizedBox(height: SkySpacing.xs),
          SkyButton(
            label: 'Volver',
            variant: SkyButtonVariant.ghost,
            expand: true,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}

/// Reactivar: con semáforo rojo avisa que el clima sigue mal. Devuelve
/// `true` si se debe llamar al backend.
Future<bool> confirmReactivate(BuildContext context, Activity activity) async {
  if (activity.probabilityBand != ProbabilityBand.red) return true;
  return SkyDialog.confirm(
    context,
    title: 'El clima sigue mal',
    message:
        'La probabilidad de «${activity.name}» es baja. ¿Seguro que quieres '
        'reactivarla?',
    confirmLabel: 'Reactivar',
  );
}
