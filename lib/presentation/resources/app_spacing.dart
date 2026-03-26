/// Family Health — Spacing Tokens
///
/// Hệ thống khoảng cách chuẩn cho toàn bộ ứng dụng.
/// Sử dụng các token thay vì giá trị magic number.
abstract class AppSpacing {
  /// 4dp — khoảng cách rất nhỏ (giữa text cùng nhóm)
  static const double xs = 4;

  /// 8dp — khoảng cách nhỏ (gap giữa items cùng danh sách)
  static const double sm = 8;

  /// 16dp — khoảng cách trung bình (padding lề, gap giữa các card)
  static const double md = 16;

  /// 24dp — khoảng cách lớn (padding khối, gap giữa các section)
  static const double lg = 24;

  /// 32dp — khoảng cách rất lớn
  static const double xl = 32;

  /// 48dp — khoảng cách cực lớn (margin top splash, FAB bottom offset)
  static const double xxl = 48;

  // ─── Border Radius ───────────────────────────────
  /// Input fields
  static const double radiusInput = 12;

  /// Cards
  static const double radiusCard = 16;

  /// Illustration
  static const double radiusIllustration = 32;

  /// Buttons (Capsule style)
  static const double radiusButton = 24;

  /// Chips
  static const double radiusChip = 20;

  // ─── Component Heights ───────────────────────────
  /// Standard button height
  static const double buttonHeight = 48;

  /// Simplified button height (người cao tuổi)
  static const double buttonHeightSimplified = 72;

  /// Input field height
  static const double inputHeight = 52;

  /// Bottom navigation bar height
  static const double bottomNavHeight = 56;

  /// Filter chip height
  static const double chipHeight = 36;

  /// AppBar height
  static const double appBarHeight = 56;

  // ─── Icon Sizes ──────────────────────────────────
  /// Standard icon
  static const double iconStandard = 24;

  /// Avatar small
  static const double avatarSmall = 24;

  /// Avatar medium
  static const double avatarMedium = 40;

  /// Avatar large
  static const double avatarLarge = 48;

  /// Avatar extra large
  static const double avatarXLarge = 64;

  /// Avatar xx large (Simplified Mode)
  static const double avatarXXLarge = 72;
}
