import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/design_system/design_system.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../locations/domain/entities/visit.dart';
import '../../../notifications/presentation/state/notifications_controller.dart';
import '../../../locations/presentation/widgets/date_format.dart';
import '../../domain/entities/activity.dart';
import '../../domain/usecases/delete_activity.dart';
import '../../domain/usecases/get_activities_by_visit.dart';
import '../state/visit_activities_controller.dart';
import '../widgets/activity_card.dart';
import '../widgets/activity_delete_confirm.dart';
import '../widgets/activity_messages.dart';

/// Actividades de una ubicación.
class VisitActivitiesScreen extends StatelessWidget {
  const VisitActivitiesScreen({super.key, required this.visit});

  final Visit visit;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => VisitActivitiesController(
        visitId: visit.id,
        getActivities: context.read<GetActivitiesByVisit>(),
        deleteActivity: context.read<DeleteActivity>(),
      )..load(),
      child: _VisitActivitiesView(visit: visit),
    );
  }
}

class _VisitActivitiesView extends StatefulWidget {
  const _VisitActivitiesView({required this.visit});

  final Visit visit;

  @override
  State<_VisitActivitiesView> createState() => _VisitActivitiesViewState();
}

class _VisitActivitiesViewState extends State<_VisitActivitiesView>
    with WidgetsBindingObserver {
  late final NotificationsController _notifications;
  int _revision = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _notifications = context.read<NotificationsController>();
    _revision = _notifications.revision;
    _notifications.addListener(_onNotification);
  }

  // Un aviso de viabilidad nuevo cambia el estado de alguna actividad.
  void _onNotification() {
    if (_notifications.revision == _revision) return;
    _revision = _notifications.revision;
    context.read<VisitActivitiesController>().load(silent: true);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _notifications.removeListener(_onNotification);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      context.read<VisitActivitiesController>().load(silent: true);
    }
  }

  Future<void> _openForm({Activity? activity}) async {
    final saved = await Navigator.of(context).pushNamed<Activity>(
      AppRoutes.activityForm,
      arguments: ActivityFormArgs(activity: activity, visit: widget.visit),
    );
    if (!mounted) return;
    await context.read<VisitActivitiesController>().load(silent: true);
    if (saved == null || !mounted) return;
    SkySnackbar.show(
      context,
      activitySavedMessage(saved, edited: activity != null),
      tone: SkySnackbarTone.success,
    );
  }

  Future<void> _handle(Activity activity, ActivityAction action) async {
    switch (action) {
      case ActivityAction.edit:
        await _openForm(activity: activity);
      case ActivityAction.delete:
        final controller = context.read<VisitActivitiesController>();
        final ok = await confirmDeleteActivity(context, activity);
        if (!ok || !mounted) return;
        final error = await controller.delete(activity);
        if (!mounted) return;
        SkySnackbar.show(
          context,
          error ?? 'Actividad eliminada',
          tone: error == null ? SkySnackbarTone.success : SkySnackbarTone.error,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<VisitActivitiesController>();
    final colors = context.skyColors;
    final typography = context.skyTypography;
    final visit = widget.visit;

    return SkyScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: SkyIconButton(
          icon: SkyIconType.arrowLeft,
          tooltip: 'Volver',
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(visit.name, style: typography.headline),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              SkyIcon(SkyIconType.calendar, size: 16, color: colors.subtle),
              const SizedBox(width: SkySpacing.xs),
              Text(
                formatDate(visit.date),
                style: typography.caption.copyWith(color: colors.subtle),
              ),
            ],
          ),
          const SizedBox(height: SkySpacing.md),
          Expanded(
            child: _Body(onAction: _handle, onCreate: _openForm),
          ),
          const SizedBox(height: SkySpacing.sm),
          SkyButton(
            label: 'Nueva actividad',
            leading: const SkyIcon(SkyIconType.plus, size: 20),
            expand: true,
            onPressed: visit.isEditable && !controller.isLoading
                ? () => _openForm()
                : null,
          ),
        ],
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.onAction, required this.onCreate});

  final Future<void> Function(Activity, ActivityAction) onAction;
  final Future<void> Function({Activity? activity}) onCreate;

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<VisitActivitiesController>();

    if (controller.isLoading && !controller.hasLoaded) {
      return ListView(
        children: const [
          SkySkeleton(height: 150),
          SizedBox(height: SkySpacing.sm),
          SkySkeleton(height: 150),
        ],
      );
    }

    if (controller.errorMessage != null && !controller.hasLoaded) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SkyInlineAlert(message: controller.errorMessage!),
          const SizedBox(height: SkySpacing.md),
          SkyButton(
            label: 'Reintentar',
            variant: SkyButtonVariant.secondary,
            expand: true,
            onPressed: controller.load,
          ),
        ],
      );
    }

    if (controller.activities.isEmpty) {
      return Center(
        child: SkyEmptyState(
          icon: SkyIconType.calendar,
          title: 'Sin actividades',
          message: 'Esta ubicación aún no tiene actividades.',
          actionLabel: 'Crear actividad',
          onAction: () => onCreate(),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => controller.load(silent: true),
      child: ListView.separated(
        itemCount: controller.activities.length,
        separatorBuilder: (_, _) => const SizedBox(height: SkySpacing.sm),
        itemBuilder: (context, index) {
          final activity = controller.activities[index];
          return SkyFadeSlideIn(
            key: ValueKey(activity.id),
            delay: Duration(milliseconds: 40 * index.clamp(0, 6)),
            child: ActivityCard(
              activity: activity,
              busy: controller.busyIds.contains(activity.id),
              onAction: (action) => onAction(activity, action),
            ),
          );
        },
      ),
    );
  }
}
