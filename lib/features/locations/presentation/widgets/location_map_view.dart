import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/design_system/design_system.dart';
import '../../domain/entities/geo_point.dart';

/// Permite mover la cámara del mapa desde fuera.
class LocationMapController {
  void Function(GeoPoint point)? _moveTo;

  void moveTo(GeoPoint point) => _moveTo?.call(point);
}

/// Único widget que conoce la librería de mapas (hoy `flutter_map` con
/// tiles de OpenStreetMap, sin API key). Para migrar a Google Maps basta
/// con reimplementar este archivo manteniendo su API pública.
class LocationMapView extends StatefulWidget {
  const LocationMapView({
    super.key,
    required this.initialCenter,
    required this.onCenterChanged,
    this.controller,
    this.initialZoom = 15,
  });

  final GeoPoint initialCenter;

  /// Se llama cada vez que el centro del mapa cambia (gesto o código).
  final ValueChanged<GeoPoint> onCenterChanged;
  final LocationMapController? controller;
  final double initialZoom;

  @override
  State<LocationMapView> createState() => _LocationMapViewState();
}

class _LocationMapViewState extends State<LocationMapView> {
  final _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _bind(widget.controller);
  }

  @override
  void didUpdateWidget(LocationMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?._moveTo = null;
      _bind(widget.controller);
    }
  }

  void _bind(LocationMapController? controller) {
    controller?._moveTo = (point) => _mapController.move(
      LatLng(point.latitude, point.longitude),
      _mapController.camera.zoom,
    );
  }

  @override
  void dispose() {
    widget.controller?._moveTo = null;
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final typography = context.skyTypography;
    final colors = context.skyColors;

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: LatLng(
          widget.initialCenter.latitude,
          widget.initialCenter.longitude,
        ),
        initialZoom: widget.initialZoom,
        minZoom: 3,
        maxZoom: 19,
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
        ),
        onPositionChanged: (camera, _) => widget.onCenterChanged(
          GeoPoint(
            latitude: camera.center.latitude,
            longitude: camera.center.longitude,
          ),
        ),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.skyplan.progra.movil.sky_plan',
        ),
        SimpleAttributionWidget(
          source: Text('© OpenStreetMap', style: typography.caption),
          backgroundColor: colors.surface,
        ),
      ],
    );
  }
}
