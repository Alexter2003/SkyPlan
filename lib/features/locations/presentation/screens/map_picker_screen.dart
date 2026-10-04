import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/design_system/design_system.dart';
import '../../domain/entities/geo_point.dart';
import '../../domain/usecases/get_current_position.dart';
import '../widgets/coordinates_label.dart';
import '../widgets/location_map_view.dart';

/// Selector de punto en el mapa: se mueve el mapa bajo un pin fijo y se
/// confirma. Devuelve el [GeoPoint] elegido al cerrar.
class MapPickerScreen extends StatefulWidget {
  const MapPickerScreen({super.key, this.initial});

  final GeoPoint? initial;

  /// Centro por defecto (Ciudad de Guatemala) si no hay punto ni GPS.
  static const fallbackCenter = GeoPoint(
    latitude: 14.6349,
    longitude: -90.5069,
  );

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  static const _pinSize = 44.0;

  final _mapController = LocationMapController();
  late GeoPoint _center = widget.initial ?? MapPickerScreen.fallbackCenter;
  bool _locating = false;

  @override
  void initState() {
    super.initState();
    if (widget.initial == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _goToDevice());
    }
  }

  Future<void> _goToDevice() async {
    final getCurrentPosition = context.read<GetCurrentPosition>();
    setState(() => _locating = true);
    try {
      final point = await getCurrentPosition();
      if (!mounted) return;
      _mapController.moveTo(point);
    } catch (_) {
      if (!mounted) return;
      SkySnackbar.show(
        context,
        'No pudimos obtener tu ubicación. Mueve el mapa para elegir el punto.',
      );
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.skyColors;
    final typography = context.skyTypography;

    return SkyScaffold(
      showGrid: false,
      padding: EdgeInsets.zero,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        leading: SkyIconButton(
          icon: SkyIconType.arrowLeft,
          tooltip: 'Volver',
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text('Elegir en el mapa', style: typography.headline),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: LocationMapView(
              initialCenter: _center,
              controller: _mapController,
              onCenterChanged: (point) => setState(() => _center = point),
            ),
          ),
          IgnorePointer(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: _pinSize),
                child: SkyIcon(
                  SkyIconType.pin,
                  size: _pinSize,
                  color: colors.primaryBlue,
                ),
              ),
            ),
          ),
          Positioned(
            top: SkySpacing.sm,
            right: SkySpacing.sm,
            child: _locating
                ? const SizedBox(
                    width: 44,
                    height: 44,
                    child: Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2.4),
                      ),
                    ),
                  )
                : SkyIconButton(
                    icon: SkyIconType.crosshair,
                    tooltip: 'Mi ubicación',
                    filled: true,
                    onPressed: _goToDevice,
                  ),
          ),
          Positioned(
            left: SkySpacing.md,
            right: SkySpacing.md,
            bottom: SkySpacing.md,
            child: SkyCard(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Ubicación seleccionada', style: typography.caption),
                  const SizedBox(height: SkySpacing.xxs),
                  CoordinatesLabel(
                    point: _center,
                    style: typography.bodyStrong,
                  ),
                  const SizedBox(height: SkySpacing.sm),
                  SkyButton(
                    label: 'Confirmar ubicación',
                    expand: true,
                    onPressed: () => Navigator.of(context).pop(_center),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
