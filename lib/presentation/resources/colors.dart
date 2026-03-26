import 'package:flutter/material.dart';

/// Family Health — Color Tokens
///
/// Bảng màu chính thức theo Style Guide.
/// Sử dụng các token semantic thay vì tên màu trực tiếp.
abstract class AppColors {
  // ─── Primary ───────────────────────────────────────
  /// Royal Blue — CTA, links, active tabs, FAB
  static const primary = Color(0xFF0066FF);

  /// Nền nhẹ cho card được chọn, badge, highlight
  static const primaryLight = Color(0xFFE8F0FE);

  // ─── Secondary ─────────────────────────────────────
  /// Teal — accent, progress, viền avatar Simplified
  static const secondary = Color(0xFF00BFA5);

  // ─── Semantic ──────────────────────────────────────
  /// Trạng thái thành công (đã uống thuốc)
  static const success = Color(0xFF4CAF50);

  /// Cảnh báo (đang chờ, sắp trễ)
  static const warning = Color(0xFFFF9800);

  /// Lỗi, trễ hạn, nút xóa
  static const error = Color(0xFFF44336);

  // ─── Neutral ───────────────────────────────────────
  /// Nền chính (Standard Mode)
  static const background = Color(0xFFFFFFFF);

  /// Nền input, chip inactive, card loading
  static const surface = Color(0xFFF5F5F5);

  /// White
  static const white = Color(0xFFFFFFFF);

  /// Black
  static const black = Color(0xFF000000);

  // ─── Text ──────────────────────────────────────────
  /// Text chính — tiêu đề, nội dung quan trọng
  static const textPrimary = Color(0xFF1A1A1A);

  /// Text phụ — mô tả, placeholder, timestamp
  static const textSecondary = Color(0xFF666666);

  // ─── Border ────────────────────────────────────────
  /// Viền nhẹ, divider
  static const border = Color(0xFFE0E0E0);

  /// Google button border
  static const googleButtonBorder = Color(0xFFDADCE0);

  // ─── Simplified Mode ───────────────────────────────
  /// Nền tối cho Simplified Mode (người cao tuổi)
  static const simplifiedBg = Color(0xFF1A1A2E);

  /// Text trắng cho Simplified Mode
  static const simplifiedText = Color(0xFFFFFFFF);

  /// Card surface trong Simplified Mode
  static const simplifiedSurface = Color(0xFF2A2A40);

  // ─── Event type backgrounds ────────────────────────
  static const vaccineBackground = Color(0xFFE3F2FD);
  static const checkupBackground = Color(0xFFE8F5E9);
  static const dentalBackground = Color(0xFFFFF3E0);

  // ─── Alert ─────────────────────────────────────────
  /// Nền alert card (đỏ rất nhạt)
  static const alertBackground = Color(0xFFFFF3F0);

  /// Nền AI-filled input
  static const aiFilledBackground = Color(0xFFFFF8E1);

  // ─── Legacy (Login page) ───────────────────────────
  // Giữ lại cho Login page hiện tại
  static const loginEllipse1 = Color(0xFF94BCEB);
  static const loginEllipse2 = Color(0xFFA49EF4);
  static const loginGradient1 = Color(0xFF4983F6);
  static const loginGradient2 = Color(0xFFC175F5);
  static const loginGradient3 = Color(0xFFFBACB7);
  static const loginSubtitle = Color(0xFF6C7278);
  static const loginButtonBorder = Color(0xFFEFF0F6);
  static const loginCardText = Color(0xFF1A1C1E);
  static const loginInfoBlue = Color(0xFF4D81E7);
  static const loginPrimaryBlue = Color(0xFF1D61E7);

  // ─── Shadows ───────────────────────────────────────
  /// Card shadow color
  static final cardShadow = black.withValues(alpha: 0.06);

  /// Primary button shadow
  static final primaryShadow = primary.withValues(alpha: 0.2);

  /// FAB shadow
  static final fabShadow = primary.withValues(alpha: 0.3);
}
