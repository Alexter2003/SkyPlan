import 'package:flutter/material.dart';

/// SkyPlan's type scale — geometric sans (Archivo), matched to the Bauhaus
/// direction approved in the design canvas.
///
/// The `Archivo` family isn't bundled as an asset yet: until
/// `assets/fonts/Archivo-*.ttf` is added and declared in `pubspec.yaml`,
/// these styles fall back to the platform default. Nothing else needs to
/// change when the font ships — just add the asset and this file keeps
/// working.
@immutable
class SkyTypography extends ThemeExtension<SkyTypography> {
  const SkyTypography({
    required this.display,
    required this.headline,
    required this.title,
    required this.body,
    required this.bodyStrong,
    required this.label,
    required this.caption,
  });

  /// Hero numbers/headers — 22sp/800.
  final TextStyle display;

  /// Screen titles — 19sp/800.
  final TextStyle headline;

  /// Card/section titles — 17sp/700.
  final TextStyle title;

  /// Default body copy — 14sp/500.
  final TextStyle body;

  /// Emphasized body copy — 14sp/700.
  final TextStyle bodyStrong;

  /// Uppercase field labels/eyebrows — 11sp/700, wide tracking.
  final TextStyle label;

  /// Fine print, timestamps — 11–12sp/500.
  final TextStyle caption;

  static const _fontFamily = 'Archivo';
  static const _fallback = <String>['Roboto', 'Helvetica Neue', 'sans-serif'];

  static const light = SkyTypography(
    display: TextStyle(
      fontFamily: _fontFamily,
      fontFamilyFallback: _fallback,
      fontSize: 22,
      fontWeight: FontWeight.w800,
      letterSpacing: -0.3,
      color: Color(0xFF132226),
    ),
    headline: TextStyle(
      fontFamily: _fontFamily,
      fontFamilyFallback: _fallback,
      fontSize: 19,
      fontWeight: FontWeight.w800,
      letterSpacing: -0.2,
      color: Color(0xFF132226),
    ),
    title: TextStyle(
      fontFamily: _fontFamily,
      fontFamilyFallback: _fallback,
      fontSize: 17,
      fontWeight: FontWeight.w700,
      color: Color(0xFF132226),
    ),
    body: TextStyle(
      fontFamily: _fontFamily,
      fontFamilyFallback: _fallback,
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: Color(0xFF132226),
    ),
    bodyStrong: TextStyle(
      fontFamily: _fontFamily,
      fontFamilyFallback: _fallback,
      fontSize: 14,
      fontWeight: FontWeight.w700,
      color: Color(0xFF132226),
    ),
    label: TextStyle(
      fontFamily: _fontFamily,
      fontFamilyFallback: _fallback,
      fontSize: 11,
      fontWeight: FontWeight.w700,
      letterSpacing: 1.1,
      color: Color(0xFF5C767C),
    ),
    caption: TextStyle(
      fontFamily: _fontFamily,
      fontFamilyFallback: _fallback,
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: Color(0xFF5C767C),
    ),
  );

  static final dark = light.copyWith(
    display: light.display.copyWith(color: const Color(0xFFE7F3F5)),
    headline: light.headline.copyWith(color: const Color(0xFFE7F3F5)),
    title: light.title.copyWith(color: const Color(0xFFE7F3F5)),
    body: light.body.copyWith(color: const Color(0xFFE7F3F5)),
    bodyStrong: light.bodyStrong.copyWith(color: const Color(0xFFE7F3F5)),
    label: light.label.copyWith(color: const Color(0xFF9CBAC0)),
    caption: light.caption.copyWith(color: const Color(0xFF9CBAC0)),
  );

  @override
  SkyTypography copyWith({
    TextStyle? display,
    TextStyle? headline,
    TextStyle? title,
    TextStyle? body,
    TextStyle? bodyStrong,
    TextStyle? label,
    TextStyle? caption,
  }) {
    return SkyTypography(
      display: display ?? this.display,
      headline: headline ?? this.headline,
      title: title ?? this.title,
      body: body ?? this.body,
      bodyStrong: bodyStrong ?? this.bodyStrong,
      label: label ?? this.label,
      caption: caption ?? this.caption,
    );
  }

  @override
  SkyTypography lerp(ThemeExtension<SkyTypography>? other, double t) {
    if (other is! SkyTypography) return this;
    return SkyTypography(
      display: TextStyle.lerp(display, other.display, t)!,
      headline: TextStyle.lerp(headline, other.headline, t)!,
      title: TextStyle.lerp(title, other.title, t)!,
      body: TextStyle.lerp(body, other.body, t)!,
      bodyStrong: TextStyle.lerp(bodyStrong, other.bodyStrong, t)!,
      label: TextStyle.lerp(label, other.label, t)!,
      caption: TextStyle.lerp(caption, other.caption, t)!,
    );
  }
}

extension SkyTypographyContext on BuildContext {
  SkyTypography get skyTypography => Theme.of(this).extension<SkyTypography>()!;
}
