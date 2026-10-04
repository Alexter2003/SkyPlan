import 'package:flutter/material.dart';

import '../../domain/entities/geo_point.dart';

/// Coordenadas en texto (`14.63490, -90.50690`).
class CoordinatesLabel extends StatelessWidget {
  const CoordinatesLabel({super.key, required this.point, this.style});

  final GeoPoint point;
  final TextStyle? style;

  static String format(GeoPoint point) =>
      '${point.latitude.toStringAsFixed(5)}, '
      '${point.longitude.toStringAsFixed(5)}';

  @override
  Widget build(BuildContext context) => Text(format(point), style: style);
}
