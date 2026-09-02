import 'package:flutter/material.dart';

import '../design_system.dart';

/// Debug-only showcase of every component in the kit, with all its
/// variants/states, plus a light/dark toggle. Registered as `/kit` only
/// when `kDebugMode` is true — see `main.dart`.
class KitGalleryScreen extends StatefulWidget {
  const KitGalleryScreen({super.key});

  @override
  State<KitGalleryScreen> createState() => _KitGalleryScreenState();
}

class _KitGalleryScreenState extends State<KitGalleryScreen> {
  String _searchValue = '';
  bool _checkbox1 = true;
  bool _checkbox2 = false;
  String _radioValue = 'exterior';
  bool _toggleValue = true;
  SkySegment _segment = SkySegment.exterior;
  double _slider = 18;
  RangeValues _range = const RangeValues(15, 28);
  DateTime? _date;
  TimeOfDay? _time;
  String? _dropdownValue = 'Antigua Guatemala';
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final themeController = SkyThemeScope.of(context);

    return SkyScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const SkyLogo(showTagline: false, markSize: 28),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: SkySpacing.md),
            child: Row(
              children: [
                const Text('Oscuro'),
                const SizedBox(width: 8),
                SkyToggle(
                  value: themeController.isDark,
                  onChanged: (_) => themeController.toggle(),
                ),
              ],
            ),
          ),
        ],
      ),
      body: ListView(
        children: [
          _SectionTitle('Logotipo y color'),
          const SkyLogo(),
          const SizedBox(height: SkySpacing.lg),
          _ColorReference(),

          _SectionTitle('Explorador de color'),
          Text(
            'Los mismos componentes reales, recoloreados con cada candidato '
            '— para comparar antes de fijar qué color va en cada rol.',
            style: context.skyTypography.caption.copyWith(
              color: context.skyColors.subtle,
            ),
          ),
          const SizedBox(height: SkySpacing.sm),
          const _ColorExplorer(),

          _SectionTitle(
            'Tipografía',
            usage: 'ink (texto), subtle (label/caption)',
          ),
          Text('Display', style: context.skyTypography.display),
          Text('Headline', style: context.skyTypography.headline),
          Text('Title', style: context.skyTypography.title),
          Text('Body', style: context.skyTypography.body),
          Text('Body strong', style: context.skyTypography.bodyStrong),
          Text('LABEL', style: context.skyTypography.label),
          Text('Caption', style: context.skyTypography.caption),

          _SectionTitle(
            'Botones',
            usage:
                'primaryRed (primary), ink (secondary/ghost), statusPostpone (danger), onAccent (texto)',
          ),
          Wrap(
            spacing: SkySpacing.xs,
            runSpacing: SkySpacing.xs,
            children: [
              SkyButton(label: 'Primary', onPressed: () {}),
              SkyButton(
                label: 'Secondary',
                variant: SkyButtonVariant.secondary,
                onPressed: () {},
              ),
              SkyButton(
                label: 'Ghost',
                variant: SkyButtonVariant.ghost,
                onPressed: () {},
              ),
              SkyButton(
                label: 'Danger',
                variant: SkyButtonVariant.danger,
                onPressed: () {},
              ),
              SkyButton(label: 'Disabled', onPressed: null),
              SkyButton(
                label: 'Loading',
                loading: _loading,
                onPressed: () {
                  setState(() => _loading = true);
                  Future.delayed(const Duration(seconds: 2), () {
                    if (mounted) setState(() => _loading = false);
                  });
                },
              ),
              SkyIconButton(
                icon: SkyIconType.filter,
                filled: true,
                tooltip: 'Filtrar',
                onPressed: () {},
              ),
            ],
          ),

          _SectionTitle(
            'Inputs',
            usage:
                'surface (fondo), ink (borde/texto), primaryBlue (foco), statusPostpone (error)',
          ),
          const SkyEmailField(),
          const SizedBox(height: SkySpacing.sm),
          SkyPasswordField(label: 'Contraseña'),
          const SizedBox(height: SkySpacing.sm),
          SkySearchField(onChanged: (v) => setState(() => _searchValue = v)),
          if (_searchValue.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: SkySpacing.xxs),
              child: Text(
                'Buscando: $_searchValue',
                style: context.skyTypography.caption,
              ),
            ),
          const SizedBox(height: SkySpacing.sm),
          const SkyTextArea(label: 'Descripción', hint: 'Picnic al aire libre'),
          const SizedBox(height: SkySpacing.sm),
          SkyDateField(
            value: _date,
            onChanged: (d) => setState(() => _date = d),
          ),
          const SizedBox(height: SkySpacing.sm),
          SkyTimeField(
            value: _time,
            onChanged: (t) => setState(() => _time = t),
          ),
          const SizedBox(height: SkySpacing.sm),
          SkyDropdown<String>(
            label: 'Ubicación',
            value: _dropdownValue,
            items: const [
              'Antigua Guatemala',
              'Parque Central',
              'Lago de Atitlán',
            ],
            itemLabel: (v) => v,
            onChanged: (v) => setState(() => _dropdownValue = v),
          ),

          _SectionTitle(
            'Selección',
            usage: 'primaryBlue (seleccionado), ink (borde), surface (fondo)',
          ),
          Wrap(
            spacing: SkySpacing.xs,
            children: [
              SkyChip(label: 'Esta semana', selected: true, onSelected: (_) {}),
              SkyChip(label: 'Cerca de mí', onSelected: (_) {}),
              const SkyChip(label: 'Informativo'),
            ],
          ),
          const SizedBox(height: SkySpacing.sm),
          SkySegmentedControl<SkySegment>(
            value: _segment,
            options: SkySegment.values,
            optionLabel: (s) =>
                s == SkySegment.exterior ? 'Exterior' : 'Interior',
            onChanged: (s) => setState(() => _segment = s),
          ),
          const SizedBox(height: SkySpacing.sm),
          SkyCheckbox(
            value: _checkbox1,
            label: 'Preparar el mantel',
            strikeLabelWhenChecked: true,
            onChanged: (v) => setState(() => _checkbox1 = v),
          ),
          SkyCheckbox(
            value: _checkbox2,
            label: 'Comprar hielo',
            strikeLabelWhenChecked: true,
            onChanged: (v) => setState(() => _checkbox2 = v),
          ),
          const SizedBox(height: SkySpacing.xs),
          SkyRadio<String>(
            value: 'exterior',
            groupValue: _radioValue,
            label: 'Exterior',
            onChanged: (v) => setState(() => _radioValue = v),
          ),
          SkyRadio<String>(
            value: 'interior',
            groupValue: _radioValue,
            label: 'Interior',
            onChanged: (v) => setState(() => _radioValue = v),
          ),
          const SizedBox(height: SkySpacing.xs),
          Row(
            children: [
              const Text('Notificarme'),
              const SizedBox(width: 10),
              SkyToggle(
                value: _toggleValue,
                onChanged: (v) => setState(() => _toggleValue = v),
              ),
            ],
          ),

          _SectionTitle(
            'Rangos',
            usage: 'primaryBlue (track activo), ink (thumb)',
          ),
          SkySlider(
            label: 'Temperatura mínima',
            value: _slider,
            min: 0,
            max: 35,
            valueLabel: '${_slider.round()}°C',
            onChanged: (v) => setState(() => _slider = v),
          ),
          SkyRangeSlider(
            label: 'Rango aceptable',
            values: _range,
            min: 0,
            max: 35,
            valuesLabel: '${_range.start.round()}–${_range.end.round()}°C',
            onChanged: (v) => setState(() => _range = v),
          ),

          _SectionTitle(
            'Clima y estado',
            usage:
                'primaryBlue (clima), statusApt/Caution/Postpone (semáforo de actividad)',
          ),
          Wrap(
            spacing: SkySpacing.xs,
            runSpacing: SkySpacing.xs,
            children: const [
              SkyWeatherChip(
                temperatureCelsius: 24,
                condition: SkyWeatherCondition.sunny,
              ),
              SkyWeatherChip(
                temperatureCelsius: 19,
                condition: SkyWeatherCondition.cloudy,
              ),
              SkyWeatherChip(
                temperatureCelsius: 15,
                condition: SkyWeatherCondition.rainy,
              ),
              SkyStatusIndicator(status: SkyStatus.apt),
              SkyStatusIndicator(status: SkyStatus.caution),
              SkyStatusIndicator(status: SkyStatus.postpone),
            ],
          ),
          const SizedBox(height: SkySpacing.sm),
          const SkyProgressBar(value: 0.72),

          _SectionTitle(
            'Superficies',
            usage: 'surface (fondo), ink (borde grueso), border (divisor)',
          ),
          SkyCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Picnic en Parque Central',
                  style: context.skyTypography.title,
                ),
                const SizedBox(height: 4),
                Text(
                  '15:00 – 17:00 · Exterior',
                  style: context.skyTypography.caption,
                ),
              ],
            ),
          ),
          const SizedBox(height: SkySpacing.sm),
          const SkyDivider(thick: true),
          const SkySkeleton(height: 52),

          _SectionTitle(
            'Retroalimentación',
            usage:
                'ink/statusApt/statusPostpone (snackbar), surface (diálogo/sheet)',
          ),
          Wrap(
            spacing: SkySpacing.xs,
            children: [
              SkyButton(
                label: 'Mostrar snackbar',
                size: SkyButtonSize.sm,
                variant: SkyButtonVariant.secondary,
                onPressed: () => SkySnackbar.show(
                  context,
                  'Actividad reagendada',
                  tone: SkySnackbarTone.success,
                ),
              ),
              SkyButton(
                label: 'Mostrar diálogo',
                size: SkyButtonSize.sm,
                variant: SkyButtonVariant.secondary,
                onPressed: () => SkyDialog.confirm(
                  context,
                  title: 'Eliminar ubicación',
                  message: 'También se eliminarán sus actividades asociadas.',
                  confirmLabel: 'Eliminar',
                  destructive: true,
                ),
              ),
              SkyButton(
                label: 'Mostrar filtro',
                size: SkyButtonSize.sm,
                variant: SkyButtonVariant.secondary,
                onPressed: () => SkyBottomSheet.show<void>(
                  context,
                  title: 'Filtrar actividades',
                  builder: (_) => const SkyEmptyState(
                    icon: SkyIconType.filter,
                    title: 'Sin filtros activos',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: SkySpacing.xxxl),
        ],
      ),
    );
  }
}

enum SkySegment { exterior, interior }

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.label, {this.usage});

  final String label;

  /// Names which [SkyColors] tokens paint this section, so the color
  /// mapping stays visible next to the components that use it instead of
  /// only living in the palette reference above.
  final String? usage;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: SkySpacing.xl, bottom: SkySpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: context.skyTypography.label),
          if (usage != null) ...[
            const SizedBox(height: 2),
            Text(
              'Colores: $usage',
              style: context.skyTypography.caption.copyWith(fontSize: 11),
            ),
          ],
        ],
      ),
    );
  }
}

String _hex(Color color) {
  int channel(double v) => (v * 255).round().clamp(0, 255);
  final r = channel(color.r).toRadixString(16).padLeft(2, '0');
  final g = channel(color.g).toRadixString(16).padLeft(2, '0');
  final b = channel(color.b).toRadixString(16).padLeft(2, '0');
  return '#${(r + g + b).toUpperCase()}';
}

/// Full [SkyColors] reference: every token, its hex value in the current
/// theme, and where it's actually used across the kit — answers "how do
/// the colors look on the real components" in one scrollable list instead
/// of leaving the reader to hunt through each section.
class _ColorReference extends StatelessWidget {
  const _ColorReference();

  @override
  Widget build(BuildContext context) {
    final colors = context.skyColors;

    final entries = <(Color, String, String)>[
      (
        colors.background,
        'background',
        'Fondo de pantalla (SkyScaffold, SkyBackground + retícula)',
      ),
      (
        colors.surface,
        'surface',
        'Tarjetas, inputs, superficies (SkyCard, SkyTextField, diálogos)',
      ),
      (
        colors.ink,
        'ink',
        'Texto principal y bordes gruesos Bauhaus (SkyCard, SkyButton, iconos)',
      ),
      (colors.subtle, 'subtle', 'Texto secundario, labels, placeholders'),
      (colors.border, 'border', 'Divisores finos y la retícula de fondo'),
      (colors.primaryRed, 'primaryRed', 'Botón primary, estado "posponer"'),
      (
        colors.primaryBlue,
        'primaryBlue',
        'Chip de clima, foco de inputs, chip seleccionado',
      ),
      (colors.primaryYellow, 'primaryYellow', 'Acento del logotipo (sol)'),
      (
        colors.onAccent,
        'onAccent',
        'Texto/íconos sobre un fondo primaryRed/Blue/status',
      ),
      (
        colors.statusApt.background,
        'statusApt',
        'Indicador "Apto" (SkyStatusIndicator)',
      ),
      (
        colors.statusCaution.background,
        'statusCaution',
        'Indicador "Precaución"',
      ),
      (
        colors.statusPostpone.background,
        'statusPostpone',
        'Indicador "Posponer"',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final (color, name, usage) in entries)
          Padding(
            padding: const EdgeInsets.only(bottom: SkySpacing.xs),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: context.skyShapes.radiusXs,
                    border: Border.all(color: colors.ink, width: 1),
                  ),
                ),
                const SizedBox(width: SkySpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(name, style: context.skyTypography.bodyStrong),
                          const SizedBox(width: 8),
                          Text(
                            _hex(color),
                            style: context.skyTypography.caption,
                          ),
                        ],
                      ),
                      Text(
                        usage,
                        style: context.skyTypography.caption.copyWith(
                          color: colors.subtle,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// One color candidate to preview across components: the fill to try, and
/// the text/icon color that should sit on top of it.
class _ColorCandidate {
  const _ColorCandidate(this.label, this.accent, this.onAccent);

  final String label;
  final Color accent;
  final Color onAccent;
}

/// Builds a [ThemeData] identical to the ambient one except every token a
/// component would normally read as "the accent" (`primaryRed`,
/// `primaryBlue`, `onAccent`, plus the input focus border baked into
/// `InputDecorationTheme`) is swapped for [candidate] — so real kit
/// components dropped under this Theme render with that candidate's color
/// without the kit's actual tokens changing anywhere else.
ThemeData _recoloredTheme(BuildContext context, _ColorCandidate candidate) {
  final base = Theme.of(context);
  final colors = context.skyColors;
  final shapes = context.skyShapes;

  final recoloredColors = colors.copyWith(
    primaryRed: candidate.accent,
    primaryBlue: candidate.accent,
    onAccent: candidate.onAccent,
  );

  return base.copyWith(
    extensions: [recoloredColors, context.skyTypography, shapes],
    inputDecorationTheme: base.inputDecorationTheme.copyWith(
      focusedBorder: OutlineInputBorder(
        borderRadius: shapes.radiusMd,
        borderSide: BorderSide(
          color: candidate.accent,
          width: shapes.borderThick,
        ),
      ),
    ),
  );
}

/// Horizontally-scrolling row of [_ColorSwatchColumn]s — one real
/// SkyButton/SkyChip/SkyCheckbox/SkyToggle/SkyProgressBar stack per color
/// candidate (rojo, azul, amarillo, verde, blanco), so they can be compared
/// side by side before deciding which color plays which role.
class _ColorExplorer extends StatelessWidget {
  const _ColorExplorer();

  @override
  Widget build(BuildContext context) {
    final colors = context.skyColors;

    final candidates = [
      _ColorCandidate('Rojo', colors.primaryRed, colors.onAccent),
      _ColorCandidate('Azul', colors.primaryBlue, colors.onAccent),
      _ColorCandidate('Amarillo', colors.primaryYellow, colors.ink),
      _ColorCandidate(
        'Verde',
        colors.statusApt.background,
        colors.statusApt.foreground,
      ),
      _ColorCandidate('Blanco', colors.surface, colors.ink),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final candidate in candidates)
            Padding(
              padding: const EdgeInsets.only(right: SkySpacing.sm),
              child: _ColorSwatchColumn(candidate: candidate),
            ),
        ],
      ),
    );
  }
}

class _ColorSwatchColumn extends StatelessWidget {
  const _ColorSwatchColumn({required this.candidate});

  final _ColorCandidate candidate;

  @override
  Widget build(BuildContext context) {
    final colors = context.skyColors;
    final typography = context.skyTypography;
    final shapes = context.skyShapes;

    return Container(
      width: 168,
      padding: const EdgeInsets.all(SkySpacing.sm),
      decoration: BoxDecoration(
        // A neutral stage (not pure background/surface) so a light/white
        // candidate still reads clearly regardless of the active theme.
        color: Color.alphaBlend(
          colors.subtle.withValues(alpha: 0.12),
          colors.surface,
        ),
        borderRadius: shapes.radiusMd,
        border: Border.all(color: colors.border),
      ),
      child: Theme(
        data: _recoloredTheme(context, candidate),
        child: Builder(
          builder: (context) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(candidate.label, style: typography.bodyStrong),
                const SizedBox(height: SkySpacing.xs),
                SkyButton(
                  label: 'Botón',
                  size: SkyButtonSize.sm,
                  onPressed: () {},
                ),
                const SizedBox(height: SkySpacing.xs),
                SkyChip(label: 'Chip', selected: true, onSelected: (_) {}),
                const SizedBox(height: SkySpacing.xs),
                Row(
                  children: [
                    SkyCheckbox(value: true, onChanged: (_) {}),
                    const SizedBox(width: SkySpacing.sm),
                    SkyToggle(value: true, onChanged: (_) {}),
                  ],
                ),
                const SizedBox(height: SkySpacing.xs),
                SkyProgressBar(value: 0.62, color: candidate.accent),
              ],
            );
          },
        ),
      ),
    );
  }
}
