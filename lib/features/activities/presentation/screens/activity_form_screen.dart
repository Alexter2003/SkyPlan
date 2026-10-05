import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/design_system/design_system.dart';
import '../../../../core/utils/validators.dart';
import '../../../locations/domain/entities/visit.dart';
import '../../../locations/domain/usecases/get_visits.dart';
import '../../../locations/presentation/widgets/date_format.dart';
import '../../../locations/presentation/widgets/visit_weather_panel.dart';
import '../../domain/entities/activity.dart';
import '../../domain/entities/time_of_day_value.dart';
import '../../domain/usecases/create_activity.dart';
import '../../domain/usecases/get_activities_by_visit.dart';
import '../../domain/usecases/get_weather_conditions.dart';
import '../../domain/usecases/update_activity.dart';
import '../state/activity_form_controller.dart';
import '../widgets/weather_condition_labels.dart';
import '../widgets/weather_condition_selector.dart';

/// Crear o editar una actividad (`activity` nulo = crear). En creación,
/// [visit] preselecciona la ubicación.
class ActivityFormScreen extends StatelessWidget {
  const ActivityFormScreen({super.key, this.activity, this.visit});

  final Activity? activity;
  final Visit? visit;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ActivityFormController(
        createActivity: context.read<CreateActivity>(),
        updateActivity: context.read<UpdateActivity>(),
        getConditions: context.read<GetWeatherConditions>(),
        getActivities: context.read<GetActivitiesByVisit>(),
        getVisits: context.read<GetVisits>(),
        editing: activity,
        visit: visit,
      )..init(),
      child: _ActivityFormView(activity: activity),
    );
  }
}

class _ActivityFormView extends StatefulWidget {
  const _ActivityFormView({required this.activity});

  final Activity? activity;

  @override
  State<_ActivityFormView> createState() => _ActivityFormViewState();
}

class _ActivityFormViewState extends State<_ActivityFormView> {
  static const _maxLength = 255;

  final _formKey = GlobalKey<FormState>();
  late final _nameController = TextEditingController(
    text: widget.activity?.name,
  );
  late final _descriptionController = TextEditingController(
    text: widget.activity?.description,
  );

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit(ActivityFormController controller) async {
    final fieldsValid = _formKey.currentState?.validate() ?? false;
    final selectionValid = controller.validateSelection();
    FocusScope.of(context).unfocus();
    if (!fieldsValid || !selectionValid) return;

    final saved = await controller.submit(
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
    );
    if (!mounted) return;
    if (saved != null) {
      Navigator.of(context).pop(saved);
    } else if (controller.notFound) {
      Navigator.of(context).pop();
    }
  }

  String? _validateText(String? value, String field) {
    final requiredError = SkyValidators.required(value, field: field);
    if (requiredError != null) return requiredError;
    if (value!.trim().length > _maxLength) {
      return '$field no puede superar $_maxLength caracteres';
    }
    return null;
  }

  static TimeOfDay? _toTimeOfDay(TimeOfDayValue? v) =>
      v == null ? null : TimeOfDay(hour: v.hour, minute: v.minute);

  static TimeOfDayValue _fromTimeOfDay(TimeOfDay t) =>
      TimeOfDayValue(t.hour, t.minute);

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ActivityFormController>();
    final typography = context.skyTypography;
    final colors = context.skyColors;

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
          controller.isEditing ? 'Editar actividad' : 'Nueva actividad',
          style: typography.headline,
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: controller.isLoadingCatalog && controller.catalog.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : controller.catalogError != null && controller.catalog.isEmpty
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SkyInlineAlert(message: controller.catalogError!),
                    const SizedBox(height: SkySpacing.md),
                    SkyButton(
                      label: 'Reintentar',
                      variant: SkyButtonVariant.secondary,
                      expand: true,
                      onPressed: controller.init,
                    ),
                  ],
                )
              : SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  child: Form(
                    key: _formKey,
                    child: SkyShake(
                      shakeKey: controller.shakeCount,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (!controller.isEditing &&
                              controller.visit != null) ...[
                            _VisitWeatherHeader(visit: controller.visit!),
                            const SizedBox(height: SkySpacing.md),
                          ],
                          if (controller.errorMessage != null)
                            Padding(
                              padding: const EdgeInsets.only(
                                bottom: SkySpacing.md,
                              ),
                              child: SkyInlineAlert(
                                key: const ValueKey('form-error'),
                                message: controller.errorMessage!,
                              ),
                            ),
                          _VisitSection(controller: controller),
                          const SizedBox(height: SkySpacing.md),
                          SkyTextField(
                            controller: _nameController,
                            label: 'Nombre',
                            textInputAction: TextInputAction.next,
                            validator: (v) => _validateText(v, 'El nombre'),
                          ),
                          const SizedBox(height: SkySpacing.md),
                          SkyTextArea(
                            controller: _descriptionController,
                            label: 'Descripción',
                            minLines: 2,
                            validator: (v) =>
                                _validateText(v, 'La descripción'),
                          ),
                          const SizedBox(height: SkySpacing.md),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: SkyTimeField(
                                  label: 'Inicio',
                                  value: _toTimeOfDay(controller.startTime),
                                  onChanged: (t) =>
                                      controller.setStart(_fromTimeOfDay(t)),
                                ),
                              ),
                              const SizedBox(width: SkySpacing.sm),
                              Expanded(
                                child: SkyTimeField(
                                  label: 'Fin',
                                  value: _toTimeOfDay(controller.endTime),
                                  onChanged: (t) =>
                                      controller.setEnd(_fromTimeOfDay(t)),
                                ),
                              ),
                            ],
                          ),
                          if (controller.timeError != null) ...[
                            const SizedBox(height: SkySpacing.xs),
                            Text(
                              controller.timeError!,
                              key: const ValueKey('time-error'),
                              style: typography.caption.copyWith(
                                color: colors.primaryRed,
                              ),
                            ),
                          ],
                          const SizedBox(height: SkySpacing.lg),
                          Text('Tipo de actividad', style: typography.title),
                          const SizedBox(height: SkySpacing.xs),
                          SkySegmentedControl<ActivityType>(
                            value: controller.type,
                            options: ActivityType.values,
                            optionLabel: typeLabel,
                            onChanged: controller.setType,
                          ),
                          const SizedBox(height: SkySpacing.xs),
                          Text(
                            controller.type == ActivityType.outdoor
                                ? 'Se valida contra el pronóstico del clima.'
                                : 'No depende del clima.',
                            style: typography.caption.copyWith(
                              color: colors.subtle,
                            ),
                          ),
                          const SizedBox(height: SkySpacing.lg),
                          Text(
                            'Condiciones climáticas deseadas',
                            style: typography.title,
                          ),
                          const SizedBox(height: SkySpacing.xs),
                          WeatherConditionSelector(
                            catalog: controller.catalog,
                            selected: controller.selectedConditions,
                            onChanged: controller.setConditions,
                            errorText: controller.conditionsError,
                          ),
                          const SizedBox(height: SkySpacing.xl),
                          SkyButton(
                            label: 'Guardar actividad',
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

/// Encabezado con el clima de la ubicación elegida, para tenerlo presente
/// al planear la actividad.
class _VisitWeatherHeader extends StatelessWidget {
  const _VisitWeatherHeader({required this.visit});

  final Visit visit;

  @override
  Widget build(BuildContext context) {
    final colors = context.skyColors;
    final typography = context.skyTypography;

    return SkyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SkyIcon(SkyIconType.location, size: 18, color: colors.subtle),
              const SizedBox(width: SkySpacing.xs),
              Expanded(child: Text(visit.name, style: typography.title)),
              Text(
                formatDate(visit.date),
                style: typography.caption.copyWith(color: colors.subtle),
              ),
            ],
          ),
          const SizedBox(height: SkySpacing.xs),
          const SkyDivider(),
          const SizedBox(height: SkySpacing.xs),
          VisitWeatherPanel(weather: visit.weather),
        ],
      ),
    );
  }
}

/// Ubicación (editable solo al crear) y fecha heredada de la visita.
class _VisitSection extends StatelessWidget {
  const _VisitSection({required this.controller});

  final ActivityFormController controller;

  @override
  Widget build(BuildContext context) {
    final typography = context.skyTypography;
    final colors = context.skyColors;
    final visit = controller.visit;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (controller.isEditing)
          SkyCard(
            child: Row(
              children: [
                SkyIcon(SkyIconType.location, size: 20, color: colors.subtle),
                const SizedBox(width: SkySpacing.xs),
                Expanded(
                  child: Text(
                    visit?.name ?? 'Ubicación',
                    style: typography.bodyStrong,
                  ),
                ),
              ],
            ),
          )
        else
          SkyDropdown<Visit>(
            label: 'Ubicación',
            value: controller.visits
                .where((v) => v.id == visit?.id)
                .firstOrNull,
            items: controller.visits,
            itemLabel: (v) => '${v.name} · ${formatDate(v.date)}',
            onChanged: (v) {
              if (v != null) controller.selectVisit(v);
            },
            errorText: controller.visitError,
          ),
        if (visit != null) ...[
          const SizedBox(height: SkySpacing.xs),
          Row(
            children: [
              SkyIcon(SkyIconType.calendar, size: 18, color: colors.subtle),
              const SizedBox(width: SkySpacing.xs),
              Expanded(
                child: Text(
                  'Fecha: ${formatDate(visit.date)} (la define la ubicación)',
                  style: typography.caption.copyWith(color: colors.subtle),
                ),
              ),
            ],
          ),
        ],
        if (!controller.isEditing &&
            controller.visits.isEmpty &&
            !controller.isLoadingCatalog) ...[
          const SizedBox(height: SkySpacing.xs),
          Text(
            'Primero registra una ubicación planeada.',
            style: typography.caption.copyWith(color: colors.primaryRed),
          ),
        ],
      ],
    );
  }
}
