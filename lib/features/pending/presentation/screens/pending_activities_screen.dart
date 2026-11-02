import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/design_system/design_system.dart';
import '../../../../core/navigation/app_drawer.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../activities/domain/services/activity_operations.dart';
import '../../../activities/domain/usecases/cancel_activity.dart';
import '../../../activities/domain/usecases/complete_activity.dart';
import '../../../activities/domain/usecases/reactivate_activity.dart';
import '../../../activities/domain/usecases/uncomplete_activity.dart';
import '../../../activities/presentation/widgets/activity_action_dialogs.dart';
import '../../../activities/presentation/widgets/reschedule_sheet.dart';
import '../../../locations/domain/entities/visit.dart';
import '../../../locations/domain/usecases/get_visits.dart';
import '../../../notifications/presentation/state/notifications_controller.dart';
import '../../domain/entities/upcoming_activity.dart';
import '../../domain/usecases/get_upcoming_activities.dart';
import '../state/pending_activities_controller.dart';
import '../widgets/pending_activity_card.dart';
import '../widgets/pending_filters_sheet.dart';

/// Actividades próximas: clima, probabilidad, filtros y acciones.
class PendingActivitiesScreen extends StatelessWidget {
  const PendingActivitiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => PendingActivitiesController(
        getUpcoming: context.read<GetUpcomingActivities>(),
        completeActivity: context.read<CompleteActivity>(),
        uncompleteActivity: context.read<UncompleteActivity>(),
        cancelActivity: context.read<CancelActivity>(),
        reactivateActivity: context.read<ReactivateActivity>(),
      )..load(),
      child: const _PendingView(),
    );
  }
}

class _PendingView extends StatefulWidget {
  const _PendingView();

  @override
  State<_PendingView> createState() => _PendingViewState();
}

class _PendingViewState extends State<_PendingView>
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

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _notifications.removeListener(_onNotification);
    super.dispose();
  }

  // Un aviso (incluida la cancelación automática) cambia el estado de alguna
  // actividad: se refresca sin esqueleto.
  void _onNotification() {
    if (_notifications.revision == _revision) return;
    _revision = _notifications.revision;
    context.read<PendingActivitiesController>().load(silent: true);
  }

  // El pronóstico cambia solo en el backend: refrescar al volver.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      context.read<PendingActivitiesController>().load(silent: true);
    }
  }

  void _toast(String message, {bool error = false}) {
    if (!mounted) return;
    SkySnackbar.show(
      context,
      message,
      tone: error ? SkySnackbarTone.error : SkySnackbarTone.success,
    );
  }

  Future<void> _toggle(UpcomingActivity item) async {
    final error = await context
        .read<PendingActivitiesController>()
        .toggleComplete(item);
    if (error != null) _toast(error.message, error: true);
  }

  Future<void> _operation(
    UpcomingActivity item,
    ActivityOperation operation,
  ) async {
    final controller = context.read<PendingActivitiesController>();
    switch (operation) {
      case ActivityOperation.cancel:
        final decision = await confirmCancelActivity(context, item.activity);
        if (decision == null || !mounted) return;
        final error = await controller.cancel(item, reason: decision.reason);
        error == null
            ? _toast('Actividad cancelada')
            : _toast(error.message, error: true);
      case ActivityOperation.reactivate:
        final ok = await confirmReactivate(context, item.activity);
        if (!ok || !mounted) return;
        final error = await controller.reactivate(item);
        if (error == null) {
          _toast('Actividad reactivada');
        } else if (error.offerReschedule) {
          await _offerReschedule(item, error.message);
        } else {
          _toast(error.message, error: true);
        }
      case ActivityOperation.reschedule:
        await _reschedule(item);
      case ActivityOperation.complete || ActivityOperation.uncomplete:
        await _toggle(item);
    }
  }

  Future<void> _offerReschedule(UpcomingActivity item, String message) async {
    final reschedule = await SkyDialog.confirm(
      context,
      title: 'No se pudo reactivar',
      message: message,
      confirmLabel: 'Reagendar',
    );
    if (reschedule && mounted) await _reschedule(item);
  }

  Future<void> _reschedule(UpcomingActivity item) async {
    final controller = context.read<PendingActivitiesController>();
    final saved = await showRescheduleSheet(context, item.activity);
    if (saved == null || !mounted) return;
    await controller.applyRescheduled(saved);
    _toast('Actividad reagendada');
  }

  Future<void> _openFilters() async {
    final controller = context.read<PendingActivitiesController>();
    var visits = const <Visit>[];
    try {
      visits = await context.read<GetVisits>()();
    } catch (_) {
      // Sin ubicaciones se omite ese filtro; el resto sigue disponible.
    }
    if (!mounted) return;
    final result = await showPendingFiltersSheet(
      context,
      current: controller.filters,
      visits: visits,
    );
    if (result != null) await controller.applyFilters(result);
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<PendingActivitiesController>();
    final typography = context.skyTypography;

    return SkyScaffold(
      drawer: const AppDrawer(currentRoute: AppRoutes.pending),
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
        title: Text('Pendientes', style: typography.headline),
        actions: [
          SkyIconButton(
            icon: SkyIconType.filter,
            tooltip: controller.hasFilters ? 'Filtros activos' : 'Filtros',
            onPressed: _openFilters,
          ),
        ],
      ),
      body: _Content(onToggle: _toggle, onOperation: _operation),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({required this.onToggle, required this.onOperation});

  final Future<void> Function(UpcomingActivity) onToggle;
  final Future<void> Function(UpcomingActivity, ActivityOperation) onOperation;

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<PendingActivitiesController>();
    final typography = context.skyTypography;
    final colors = context.skyColors;

    if (controller.isLoading && !controller.hasLoaded) {
      return ListView(
        children: const [
          SkySkeleton(height: 190),
          SizedBox(height: SkySpacing.sm),
          SkySkeleton(height: 190),
          SizedBox(height: SkySpacing.sm),
          SkySkeleton(height: 190),
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

    if (controller.items.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => controller.load(silent: true),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            const SizedBox(height: SkySpacing.xl),
            if (controller.hasFilters)
              SkyEmptyState(
                icon: SkyIconType.filter,
                title: 'Sin resultados',
                message: 'Ninguna actividad cumple los filtros elegidos.',
                actionLabel: 'Limpiar filtros',
                onAction: controller.clearFilters,
              )
            else
              const SkyEmptyState(
                icon: SkyIconType.calendar,
                title: 'No tienes actividades próximas',
                message:
                    'Crea actividades en tus ubicaciones para verlas aquí.',
              ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => controller.load(silent: true),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          if (controller.errorMessage != null) ...[
            SkyInlineAlert(message: controller.errorMessage!),
            const SizedBox(height: SkySpacing.sm),
          ],
          if (controller.hasFilters)
            Padding(
              padding: const EdgeInsets.only(bottom: SkySpacing.sm),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Filtros activos · ${controller.items.length} resultados',
                      key: const ValueKey('filters-summary'),
                      style: typography.caption.copyWith(color: colors.subtle),
                    ),
                  ),
                  SkyButton(
                    label: 'Limpiar',
                    variant: SkyButtonVariant.ghost,
                    onPressed: controller.clearFilters,
                  ),
                ],
              ),
            ),
          for (final item in controller.items) ...[
            SkyFadeSlideIn(
              key: ValueKey(item.id),
              child: PendingActivityCard(
                item: item,
                busy: controller.busyIds.contains(item.id),
                onToggleComplete: () => onToggle(item),
                onOperation: (op) => onOperation(item, op),
              ),
            ),
            const SizedBox(height: SkySpacing.sm),
          ],
          if (controller.hasMore)
            Padding(
              padding: const EdgeInsets.only(bottom: SkySpacing.md),
              child: Text(
                'Mostrando ${controller.items.length} de ${controller.total}. '
                'Usa los filtros para acotar.',
                style: typography.caption.copyWith(color: colors.subtle),
              ),
            ),
        ],
      ),
    );
  }
}
