import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/design_system/design_system.dart';
import '../../../../core/navigation/app_drawer.dart';
import '../../../../core/routing/app_routes.dart';
import '../../domain/entities/visit.dart';
import '../../domain/usecases/cancel_visit.dart';
import '../../domain/usecases/complete_visit.dart';
import '../../domain/usecases/delete_visit.dart';
import '../../domain/usecases/get_visits.dart';
import '../state/visits_list_controller.dart';
import '../widgets/visit_card.dart';

/// Listado de ubicaciones registradas ("mi planificador").
class LocationsScreen extends StatelessWidget {
  const LocationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => VisitsListController(
        getVisits: context.read<GetVisits>(),
        completeVisit: context.read<CompleteVisit>(),
        cancelVisit: context.read<CancelVisit>(),
        deleteVisit: context.read<DeleteVisit>(),
      )..load(),
      child: const _LocationsView(),
    );
  }
}

class _LocationsView extends StatefulWidget {
  const _LocationsView();

  @override
  State<_LocationsView> createState() => _LocationsViewState();
}

class _LocationsViewState extends State<_LocationsView>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // El clima cambia solo en el backend: refrescar al volver a primer plano.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      context.read<VisitsListController>().load(silent: true);
    }
  }

  Future<void> _openForm({Visit? visit}) async {
    final saved = await Navigator.of(context).pushNamed<Visit>(
      AppRoutes.locationForm,
      arguments: LocationFormArgs(visit: visit),
    );
    if (saved == null || !mounted) return;

    await context.read<VisitsListController>().load(silent: true);
    if (!mounted) return;
    SkySnackbar.show(
      context,
      visit != null ? 'Ubicación actualizada' : 'Ubicación registrada',
      tone: SkySnackbarTone.success,
    );
  }

  Future<void> _handle(Visit visit, VisitAction action) async {
    final controller = context.read<VisitsListController>();

    switch (action) {
      case VisitAction.activities:
        await Navigator.of(context).pushNamed(
          AppRoutes.visitActivities,
          arguments: VisitActivitiesArgs(visit: visit),
        );
        return;
      case VisitAction.edit:
        await _openForm(visit: visit);
        return;
      case VisitAction.complete:
        final ok = await SkyDialog.confirm(
          context,
          title: '¿Marcar «${visit.name}» como finalizada?',
          message: 'Ya no podrás editarla ni cambiar su estado.',
          confirmLabel: 'Finalizar',
        );
        if (!ok || !mounted) return;
        _report(await controller.complete(visit), success: 'Visita finalizada');
      case VisitAction.cancel:
        final ok = await SkyDialog.confirm(
          context,
          title: '¿Cancelar la visita a «${visit.name}»?',
          message:
              'Seguirá visible en tu lista como cancelada, pero ya no podrás editarla.',
          confirmLabel: 'Cancelar visita',
          cancelLabel: 'Volver',
          destructive: true,
        );
        if (!ok || !mounted) return;
        _report(await controller.cancel(visit), success: 'Visita cancelada');
      case VisitAction.delete:
        final ok = await SkyDialog.confirm(
          context,
          title: '¿Eliminar «${visit.name}»?',
          message:
              'También se eliminarán todas las actividades registradas en esta ubicación. Esta acción no se puede deshacer.',
          confirmLabel: 'Eliminar',
          destructive: true,
        );
        if (!ok || !mounted) return;
        _report(await controller.delete(visit), success: 'Ubicación eliminada');
    }
  }

  void _report(String? error, {required String success}) {
    if (!mounted) return;
    SkySnackbar.show(
      context,
      error ?? success,
      tone: error == null ? SkySnackbarTone.success : SkySnackbarTone.error,
    );
  }

  static String _tabLabel(VisitStatus status) => switch (status) {
    VisitStatus.planned => 'Planeadas',
    VisitStatus.completed => 'Finalizadas',
    VisitStatus.cancelled => 'Canceladas',
  };

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<VisitsListController>();
    final typography = context.skyTypography;

    return SkyScaffold(
      drawer: const AppDrawer(currentRoute: AppRoutes.locations),
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
        title: Text('Mis ubicaciones', style: typography.headline),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SkySegmentedControl<VisitStatus>(
            value: controller.selectedTab,
            options: VisitStatus.values,
            optionLabel: _tabLabel,
            onChanged: controller.selectTab,
          ),
          const SizedBox(height: SkySpacing.md),
          Expanded(
            child: _Content(onAction: _handle, onCreate: _openForm),
          ),
          const SizedBox(height: SkySpacing.sm),
          SkyButton(
            label: 'Nueva ubicación',
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

  final Future<void> Function(Visit visit, VisitAction action) onAction;
  final Future<void> Function() onCreate;

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<VisitsListController>();

    if (controller.isLoading && !controller.hasLoaded) {
      return ListView(
        children: const [
          SkySkeleton(height: 170),
          SizedBox(height: SkySpacing.sm),
          SkySkeleton(height: 170),
          SizedBox(height: SkySpacing.sm),
          SkySkeleton(height: 170),
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

    final items = controller.visitsFor(controller.selectedTab);

    if (items.isEmpty) {
      final isPlanned = controller.selectedTab == VisitStatus.planned;
      return Center(
        child: SkyEmptyState(
          icon: SkyIconType.location,
          title: isPlanned
              ? 'Aún no tienes ubicaciones'
              : 'No hay ubicaciones en esta sección',
          message: isPlanned
              ? 'Registra un lugar para planear tus actividades.'
              : null,
          actionLabel: isPlanned ? 'Registrar ubicación' : null,
          onAction: isPlanned ? onCreate : null,
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => controller.load(silent: true),
      child: ListView.separated(
        padding: const EdgeInsets.only(bottom: SkySpacing.xs),
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(height: SkySpacing.sm),
        itemBuilder: (context, index) {
          final visit = items[index];
          return SkyFadeSlideIn(
            key: ValueKey(visit.id),
            delay: Duration(milliseconds: 40 * index.clamp(0, 6)),
            child: VisitCard(
              visit: visit,
              busy: controller.busyIds.contains(visit.id),
              onAction: (action) => onAction(visit, action),
            ),
          );
        },
      ),
    );
  }
}
