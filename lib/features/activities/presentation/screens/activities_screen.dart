import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/design_system/design_system.dart';
import '../../../../core/navigation/app_drawer.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../locations/domain/entities/visit.dart';
import '../../../notifications/presentation/state/notifications_controller.dart';
import '../../../locations/presentation/widgets/date_format.dart';
import '../../../locations/presentation/widgets/visit_weather_panel.dart';
import '../../domain/entities/activity.dart';
import '../../domain/entities/visit_activities.dart';
import '../../domain/usecases/delete_activity.dart';
import '../../domain/usecases/get_activities_grouped_by_visit.dart';
import '../state/activities_overview_controller.dart';
import '../widgets/activity_card.dart';
import '../widgets/activity_delete_confirm.dart';
import '../widgets/activity_messages.dart';

/// Actividades agrupadas por ubicación.
class ActivitiesScreen extends StatelessWidget {
  const ActivitiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ActivitiesOverviewController(
        getGrouped: context.read<GetActivitiesGroupedByVisit>(),
        deleteActivity: context.read<DeleteActivity>(),
      )..load(),
      child: const _ActivitiesView(),
    );
  }
}

class _ActivitiesView extends StatefulWidget {
  const _ActivitiesView();

  @override
  State<_ActivitiesView> createState() => _ActivitiesViewState();
}

class _ActivitiesViewState extends State<_ActivitiesView>
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
    context.read<ActivitiesOverviewController>().load(silent: true);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _notifications.removeListener(_onNotification);
    super.dispose();
  }

  // La viabilidad cambia sola en el backend: refrescar al volver.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      context.read<ActivitiesOverviewController>().load(silent: true);
    }
  }

  Future<void> _openForm({Activity? activity, Visit? visit}) async {
    final saved = await Navigator.of(context).pushNamed<Activity>(
      AppRoutes.activityForm,
      arguments: ActivityFormArgs(activity: activity, visit: visit),
    );
    if (!mounted) return;
    final controller = context.read<ActivitiesOverviewController>();
    if (saved == null) {
      await controller.load(silent: true);
      return;
    }
    await controller.load(silent: true);
    if (!mounted) return;
    SkySnackbar.show(
      context,
      activitySavedMessage(saved, edited: activity != null),
      tone: SkySnackbarTone.success,
    );
  }

  Future<void> _handle(
    VisitActivities group,
    Activity activity,
    ActivityAction action,
  ) async {
    switch (action) {
      case ActivityAction.edit:
        await _openForm(activity: activity, visit: group.visit);
      case ActivityAction.delete:
        final controller = context.read<ActivitiesOverviewController>();
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
    final typography = context.skyTypography;

    return SkyScaffold(
      drawer: const AppDrawer(currentRoute: AppRoutes.activities),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Builder(
          builder: (context) => SkyIconButton(
            icon: SkyIconType.menu,
            tooltip: 'Menú',
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Text('Actividades', style: typography.headline),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _Content(onAction: _handle, onCreate: () => _openForm()),
          ),
          const SizedBox(height: SkySpacing.sm),
          SkyButton(
            label: 'Nueva actividad',
            leading: const SkyIcon(SkyIconType.plus, size: 20),
            expand: true,
            onPressed: () => _openForm(),
          ),
        ],
      ),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({required this.onAction, required this.onCreate});

  final Future<void> Function(VisitActivities, Activity, ActivityAction)
  onAction;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ActivitiesOverviewController>();

    if (controller.isLoading && !controller.hasLoaded) {
      return ListView(
        children: const [
          SkySkeleton(height: 60),
          SizedBox(height: SkySpacing.sm),
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

    if (controller.groups.isEmpty) {
      return const Center(
        child: SkyEmptyState(
          icon: SkyIconType.location,
          title: 'Aún no tienes ubicaciones',
          message: 'Registra un lugar para planear tus actividades.',
        ),
      );
    }

    if (controller.isEmpty) {
      return Center(
        child: SkyEmptyState(
          icon: SkyIconType.calendar,
          title: 'Aún no tienes actividades',
          message: 'Crea una actividad en alguna de tus ubicaciones.',
          actionLabel: 'Crear actividad',
          onAction: onCreate,
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => controller.load(silent: true),
      child: ListView(
        children: [
          for (final group in controller.groups)
            if (group.activities.isNotEmpty || group.visit.isEditable)
              _GroupSection(
                group: group,
                busyIds: controller.busyIds,
                onAction: (activity, action) =>
                    onAction(group, activity, action),
              ),
        ],
      ),
    );
  }
}

class _GroupSection extends StatelessWidget {
  const _GroupSection({
    required this.group,
    required this.busyIds,
    required this.onAction,
  });

  final VisitActivities group;
  final Set<int> busyIds;
  final void Function(Activity, ActivityAction) onAction;

  @override
  Widget build(BuildContext context) {
    final colors = context.skyColors;
    final typography = context.skyTypography;
    final visit = group.visit;
    final weather = visit.weather;

    return Padding(
      padding: const EdgeInsets.only(bottom: SkySpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => Navigator.of(context).pushNamed(
              AppRoutes.visitActivities,
              arguments: VisitActivitiesArgs(visit: visit),
            ),
            child: Row(
              children: [
                SkyIcon(SkyIconType.location, size: 20, color: colors.ink),
                const SizedBox(width: SkySpacing.xs),
                Expanded(child: Text(visit.name, style: typography.title)),
                SkyIcon(
                  SkyIconType.chevronRight,
                  size: 20,
                  color: colors.subtle,
                ),
              ],
            ),
          ),
          const SizedBox(height: SkySpacing.xxs),
          Wrap(
            spacing: SkySpacing.sm,
            runSpacing: SkySpacing.xs,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SkyIcon(SkyIconType.calendar, size: 16, color: colors.subtle),
                  const SizedBox(width: SkySpacing.xs),
                  Text(
                    formatDate(visit.date),
                    style: typography.caption.copyWith(color: colors.subtle),
                  ),
                ],
              ),
              VisitWeatherSummary(weather: weather),
            ],
          ),
          const SizedBox(height: SkySpacing.sm),
          if (group.activities.isEmpty)
            Text(
              'Sin actividades en esta ubicación.',
              style: typography.caption.copyWith(color: colors.subtle),
            )
          else
            for (final activity in group.activities) ...[
              SkyFadeSlideIn(
                key: ValueKey(activity.id),
                child: ActivityCard(
                  activity: activity,
                  busy: busyIds.contains(activity.id),
                  onAction: (action) => onAction(activity, action),
                ),
              ),
              const SizedBox(height: SkySpacing.sm),
            ],
        ],
      ),
    );
  }
}
