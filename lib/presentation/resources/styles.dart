import 'package:flutter/cupertino.dart';

import '../../gen/fonts.gen.dart';

/// Family Health — Typography Scale
///
/// Dựa trên font Inter (fallback GoogleSans).
/// Naming theo Material Design 3 convention.
abstract class AppStyles {
  static const _fontFamily = FontFamily.inter;

  // ─── Display ─────────────────────────────────────
  /// 32sp Bold — Splash title, Simplified alarm header
  static const displayLarge = TextStyle(
    fontWeight: FontWeight.w700,
    fontSize: 32,
    height: 1.2,
    fontFamily: _fontFamily,
  );

  // ─── Headline ────────────────────────────────────
  /// 28sp Bold — Simplified greeting
  static const headlineLarge = TextStyle(
    fontWeight: FontWeight.w700,
    fontSize: 28,
    height: 1.3,
    fontFamily: _fontFamily,
  );

  /// 24sp Bold — Screen titles, Welcome text
  static const headlineMedium = TextStyle(
    fontWeight: FontWeight.w700,
    fontSize: 24,
    height: 1.3,
    fontFamily: _fontFamily,
  );

  // ─── Title ───────────────────────────────────────
  /// 22sp Bold — Drug name in detail
  static const titleXLarge = TextStyle(
    fontWeight: FontWeight.w700,
    fontSize: 22,
    height: 1.3,
    fontFamily: _fontFamily,
  );

  /// 20sp SemiBold — AppBar titles, Card mode title
  static const titleLarge = TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 20,
    height: 1.4,
    fontFamily: _fontFamily,
  );

  /// 18sp SemiBold — Section headers, AI card title
  static const titleMedium = TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 18,
    height: 1.4,
    fontFamily: _fontFamily,
  );

  /// 16sp SemiBold — Card summary header, button text
  static const titleSmall = TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 16,
    height: 1.4,
    fontFamily: _fontFamily,
  );

  // ─── Body ────────────────────────────────────────
  /// 16sp Regular — Standard body text
  static const bodyLarge = TextStyle(
    fontWeight: FontWeight.w400,
    fontSize: 16,
    height: 1.5,
    fontFamily: _fontFamily,
  );

  /// 15sp Regular — Chat messages, info rows
  static const bodyMedium = TextStyle(
    fontWeight: FontWeight.w400,
    fontSize: 15,
    height: 1.5,
    fontFamily: _fontFamily,
  );

  /// 14sp Regular — Description, sub-info
  static const bodySmall = TextStyle(
    fontWeight: FontWeight.w400,
    fontSize: 14,
    height: 1.5,
    fontFamily: _fontFamily,
  );

  /// 13sp Regular — Event detail rows
  static const caption = TextStyle(
    fontWeight: FontWeight.w400,
    fontSize: 13,
    height: 1.5,
    fontFamily: _fontFamily,
  );

  // ─── Label ───────────────────────────────────────
  /// 16sp SemiBold — Primary button label
  static const labelLarge = TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 16,
    height: 1.25,
    fontFamily: _fontFamily,
  );

  /// 14sp SemiBold — Chip text, secondary button label
  static const labelMedium = TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 14,
    height: 1.25,
    fontFamily: _fontFamily,
  );

  /// 12sp Regular — Timestamp, disclaimer, nav label
  static const labelSmall = TextStyle(
    fontWeight: FontWeight.w400,
    fontSize: 12,
    height: 1.5,
    fontFamily: _fontFamily,
  );

  // ─── Simplified Mode ─────────────────────────────
  /// 22sp Regular — Body text cho người cao tuổi
  static const simplifiedBody = TextStyle(
    fontWeight: FontWeight.w400,
    fontSize: 22,
    height: 1.5,
    fontFamily: _fontFamily,
  );

  /// 24sp Bold — Drug name in Simplified card
  static const simplifiedTitle = TextStyle(
    fontWeight: FontWeight.w700,
    fontSize: 24,
    height: 1.3,
    fontFamily: _fontFamily,
  );

  /// 22sp Bold — Simplified button label
  static const simplifiedButton = TextStyle(
    fontWeight: FontWeight.w700,
    fontSize: 22,
    height: 1.25,
    fontFamily: _fontFamily,
  );

  /// 18sp SemiBold — Quick reply chip
  static const simplifiedChip = TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 18,
    height: 1.4,
    fontFamily: _fontFamily,
  );

  // ─── Bottom Navigation ───────────────────────────
  /// 12sp Medium — Bottom nav labels
  static const bottomNavigation = TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: 12,
    height: 1.3,
    fontFamily: _fontFamily,
  );

  // ─── Legacy (deprecated, giữ để không break code cũ) ──
  @Deprecated('Use headlineMedium instead')
  static const h1 = TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: 32,
    height: 32 / 32,
    fontFamily: _fontFamily,
  );
  @Deprecated('Use headlineMedium instead')
  static const h2 = TextStyle(
    fontWeight: FontWeight.w700,
    fontSize: 24,
    height: 32 / 24,
    fontFamily: _fontFamily,
  );
  @Deprecated('Use titleSmall instead')
  static const h3 = TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: 16,
    height: 18 / 16,
    fontFamily: _fontFamily,
  );
  @Deprecated('Use bodySmall instead')
  static const primary = TextStyle(
    fontWeight: FontWeight.w400,
    fontSize: 13,
    height: 18 / 13,
    fontFamily: _fontFamily,
  );
  @Deprecated('Use bodyLarge instead')
  static const medium = TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: 16,
    height: 24 / 16,
    fontFamily: _fontFamily,
  );
  @Deprecated('Use labelSmall instead')
  static const small = TextStyle(
    fontWeight: FontWeight.w400,
    fontSize: 12,
    height: 18 / 12,
    fontFamily: _fontFamily,
  );
  @Deprecated('Use labelMedium instead')
  static const highlightsMedium = TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: 13,
    height: 18 / 13,
    fontFamily: _fontFamily,
  );
  @Deprecated('Use labelMedium instead')
  static const highlightsBold = TextStyle(
    fontWeight: FontWeight.w700,
    fontSize: 14,
    height: 24 / 14,
    fontFamily: _fontFamily,
  );
  @Deprecated('Use labelLarge instead')
  static const button = TextStyle(
    fontWeight: FontWeight.w700,
    fontSize: 13,
    height: 18 / 13,
    fontFamily: _fontFamily,
  );
  @Deprecated('Use titleSmall instead')
  static const title = TextStyle(
    fontWeight: FontWeight.w700,
    fontSize: 16,
    height: 18 / 16,
    fontFamily: _fontFamily,
  );
  @Deprecated('Use titleMedium instead')
  static const header = TextStyle(
    fontWeight: FontWeight.w700,
    fontSize: 18,
    height: 28 / 18,
    fontFamily: _fontFamily,
  );
}