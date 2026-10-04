import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/design_system/design_system.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/utils/validators.dart';
import '../../domain/entities/geo_point.dart';
import '../../domain/entities/visit.dart';
import '../../domain/usecases/create_visit.dart';
import '../../domain/usecases/get_current_position.dart';
import '../../domain/usecases/open_location_settings.dart';
import '../../domain/usecases/update_visit.dart';
import '../state/visit_form_controller.dart';
import '../widgets/coordinates_label.dart';

/// Crear o editar una ubicación (`visit` nulo = crear).
class LocationFormScreen extends StatelessWidget {
  const LocationFormScreen({super.key, this.visit});

  final Visit? visit;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => VisitFormController(
        createVisit: context.read<CreateVisit>(),
        updateVisit: context.read<UpdateVisit>(),
        getCurrentPosition: context.read<GetCurrentPosition>(),
        openSettings: context.read<OpenLocationSettings>(),
        editing: visit,
      ),
      child: _LocationFormView(visit: visit),
    );
  }
}

class _LocationFormView extends StatefulWidget {
  const _LocationFormView({required this.visit});

  final Visit? visit;

  @override
  State<_LocationFormView> createState() => _LocationFormViewState();
}

class _LocationFormViewState extends State<_LocationFormView> {
  static const _maxNameLength = 255;

  final _formKey = GlobalKey<FormState>();
  late final _nameController = TextEditingController(text: widget.visit?.name);

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickOnMap(VisitFormController controller) async {
    final point = await Navigator.of(context).pushNamed<GeoPoint>(
      AppRoutes.mapPicker,
      arguments: MapPickerArgs(initial: controller.point),
    );
    if (point != null) controller.setPoint(point);
  }

  Future<void> _submit(VisitFormController controller) async {
    final nameValid = _formKey.currentState?.validate() ?? false;
    final selectionValid = controller.validateSelection();
    FocusScope.of(context).unfocus();
    if (!nameValid || !selectionValid) return;

    final saved = await controller.submit(name: _nameController.text.trim());
    if (saved == null || !mounted) return;
    Navigator.of(context).pop(saved);
  }

  String? _validateName(String? value) {
    final requiredError = SkyValidators.required(value, field: 'El nombre');
    if (requiredError != null) return requiredError;
    if (value!.trim().length > _maxNameLength) {
      return 'El nombre no puede superar $_maxNameLength caracteres';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<VisitFormController>();
    final typography = context.skyTypography;
    final colors = context.skyColors;
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final selectedDate = controller.date;
    final firstDate = selectedDate != null && selectedDate.isBefore(todayDate)
        ? selectedDate
        : todayDate;

    return SkyScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: SkyIconButton(
          icon: SkyIconType.arrowLeft,
          tooltip: 'Volver',
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          controller.isEditing ? 'Editar ubicación' : 'Nueva ubicación',
          style: typography.headline,
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Form(
              key: _formKey,
              child: SkyShake(
                shakeKey: controller.shakeCount,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AnimatedSwitcher(
                      duration: SkyMotion.base,
                      child: controller.errorMessage == null
                          ? const SizedBox.shrink()
                          : Padding(
                              key: ValueKey(controller.errorMessage),
                              padding: const EdgeInsets.only(
                                bottom: SkySpacing.md,
                              ),
                              child: SkyInlineAlert(
                                message: controller.errorMessage!,
                              ),
                            ),
                    ),
                    SkyTextField(
                      controller: _nameController,
                      label: 'Nombre del lugar',
                      leadingIcon: SkyIconType.location,
                      textInputAction: TextInputAction.done,
                      validator: _validateName,
                    ),
                    const SizedBox(height: SkySpacing.lg),
                    Text('¿Dónde es?', style: typography.title),
                    const SizedBox(height: SkySpacing.xs),
                    _SourceCard(
                      icon: SkyIconType.crosshair,
                      title: 'Usar mi ubicación actual',
                      subtitle: 'Toma las coordenadas del GPS del teléfono',
                      loading: controller.gpsStatus == GpsStatus.loading,
                      onTap: controller.gpsStatus == GpsStatus.loading
                          ? null
                          : controller.useCurrentLocation,
                    ),
                    const SizedBox(height: SkySpacing.xs),
                    _SourceCard(
                      icon: SkyIconType.map,
                      title: 'Seleccionar en el mapa',
                      subtitle: 'Mueve el mapa y elige el punto exacto',
                      onTap: () => _pickOnMap(controller),
                    ),
                    _GpsAlert(controller: controller),
                    if (controller.point != null) ...[
                      const SizedBox(height: SkySpacing.sm),
                      Row(
                        children: [
                          SkyIcon(
                            SkyIconType.check,
                            size: 18,
                            color: colors.statusApt.background,
                          ),
                          const SizedBox(width: SkySpacing.xs),
                          Expanded(
                            child: Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Text(
                                  'Ubicación elegida: ',
                                  style: typography.caption,
                                ),
                                CoordinatesLabel(
                                  point: controller.point!,
                                  style: typography.bodyStrong,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (controller.pointError != null) ...[
                      const SizedBox(height: SkySpacing.xs),
                      Text(
                        controller.pointError!,
                        style: typography.caption.copyWith(
                          color: colors.primaryRed,
                        ),
                      ),
                    ],
                    const SizedBox(height: SkySpacing.lg),
                    SkyDateField(
                      value: controller.date,
                      onChanged: controller.setDate,
                      label: 'Fecha de la visita',
                      firstDate: firstDate,
                      lastDate: DateTime(
                        today.year + 2,
                        today.month,
                        today.day,
                      ),
                      errorText: controller.dateError,
                    ),
                    const SizedBox(height: SkySpacing.xl),
                    SkyButton(
                      label: 'Guardar ubicación',
                      expand: true,
                      loading: controller.isSubmitting,
                      onPressed: () => _submit(controller),
                    ),
                    const SizedBox(height: SkySpacing.md),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SourceCard extends StatelessWidget {
  const _SourceCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.loading = false,
  });

  final SkyIconType icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final colors = context.skyColors;
    final typography = context.skyTypography;

    return SkyCard(
      onTap: onTap,
      child: Row(
        children: [
          SizedBox(
            width: 28,
            height: 28,
            child: loading
                ? const Padding(
                    padding: EdgeInsets.all(4),
                    child: CircularProgressIndicator(strokeWidth: 2.4),
                  )
                : SkyIcon(icon, size: 28, color: colors.primaryBlue),
          ),
          const SizedBox(width: SkySpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: typography.bodyStrong),
                Text(
                  subtitle,
                  style: typography.caption.copyWith(color: colors.subtle),
                ),
              ],
            ),
          ),
          SkyIcon(SkyIconType.chevronRight, size: 20, color: colors.subtle),
        ],
      ),
    );
  }
}

class _GpsAlert extends StatelessWidget {
  const _GpsAlert({required this.controller});

  final VisitFormController controller;

  @override
  Widget build(BuildContext context) {
    final (String message, String action, VoidCallback onAction)?
    alert = switch (controller.gpsStatus) {
      GpsStatus.serviceDisabled => (
        'El GPS está desactivado. Actívalo o elige el punto en el mapa.',
        'Activar ubicación',
        controller.openSettingsForGps,
      ),
      GpsStatus.denied => (
        'Necesitamos permiso de ubicación. También puedes elegir el punto en el mapa.',
        'Reintentar',
        controller.useCurrentLocation,
      ),
      GpsStatus.deniedForever => (
        'Negaste el permiso de ubicación. Habilítalo en los ajustes o elige el punto en el mapa.',
        'Abrir ajustes',
        controller.openSettingsForGps,
      ),
      GpsStatus.failed => (
        'No pudimos obtener tu ubicación. Inténtalo de nuevo o elígela en el mapa.',
        'Reintentar',
        controller.useCurrentLocation,
      ),
      _ => null,
    };

    if (alert == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: SkySpacing.sm),
      child: SkyInlineAlert(
        message: alert.$1,
        tone: SkyInlineAlertTone.warning,
        actionLabel: alert.$2,
        onAction: alert.$3,
      ),
    );
  }
}
