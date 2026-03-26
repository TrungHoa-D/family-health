import 'package:family_health/gen/fonts.gen.dart';
import 'package:family_health/presentation/resources/app_spacing.dart';
import 'package:family_health/presentation/resources/styles.dart';
import 'package:family_health/shared/extension/theme_data.dart';
import 'package:flutter/material.dart';

import 'colors.dart';
import 'theme_data.dart';

const kDefaultPaddingLabelTabBar = 8.0;

abstract class AppTheme {
  // ─── Input border (no border by default) ─────────
  static final InputBorder _defaultInputBorder = OutlineInputBorder(
    borderSide: BorderSide.none,
    borderRadius: BorderRadius.circular(AppSpacing.radiusInput),
  );

  static final InputBorder _focusedInputBorder = OutlineInputBorder(
    borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
    borderRadius: BorderRadius.circular(AppSpacing.radiusInput),
  );

  static final InputBorder _errorInputBorder = OutlineInputBorder(
    borderSide: const BorderSide(color: AppColors.error, width: 1.5),
    borderRadius: BorderRadius.circular(AppSpacing.radiusInput),
  );

  static const _dividerTheme = DividerThemeData(
    space: 0,
    thickness: 1,
    color: AppColors.border,
  );

  static ThemeData get lightTheme {
    return ThemeData(
      fontFamily: FontFamily.inter,
      useMaterial3: true,
      appBarTheme: AppBarTheme(
        color: AppColors.background,
        titleTextStyle:
            AppStyles.titleLarge.copyWith(color: AppColors.textPrimary),
        shadowColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(
          color: AppColors.textPrimary,
          size: AppSpacing.iconStandard,
        ),
      ),
      scrollbarTheme: ScrollbarThemeData(
        thickness: WidgetStateProperty.all(6.0),
        radius: const Radius.circular(3),
        minThumbLength: 90,
        thumbColor: WidgetStateProperty.all(AppColors.border),
      ),
      colorScheme: const ColorScheme.light(
        surface: AppColors.background,
        primary: AppColors.primary,
        error: AppColors.error,
        onPrimary: AppColors.white,
        onSurface: AppColors.textPrimary,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: _defaultInputBorder,
        focusedErrorBorder: _errorInputBorder,
        errorBorder: _errorInputBorder,
        disabledBorder: _defaultInputBorder,
        enabledBorder: _defaultInputBorder,
        focusedBorder: _focusedInputBorder,
        hintStyle: AppStyles.bodyLarge.copyWith(color: AppColors.textSecondary),
        labelStyle:
            AppStyles.bodySmall.copyWith(color: AppColors.textSecondary),
        errorStyle: AppStyles.labelSmall.copyWith(color: AppColors.error),
        suffixStyle:
            AppStyles.bodySmall.copyWith(color: AppColors.textSecondary),
        iconColor: AppColors.textSecondary,
        suffixIconColor: AppColors.textSecondary,
        prefixIconColor: AppColors.textSecondary,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: 14,
        ),
        isDense: true,
        filled: true,
        fillColor: AppColors.surface,
      ),
      scaffoldBackgroundColor: AppColors.background,
      iconTheme: const IconThemeData(
        color: AppColors.textSecondary,
        size: AppSpacing.iconStandard,
      ),
      primaryIconTheme: const IconThemeData(
        color: AppColors.textSecondary,
        size: AppSpacing.iconStandard,
      ),
      dividerTheme: _dividerTheme,
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
      ),
      tabBarTheme: TabBarThemeData(
        labelStyle: AppStyles.labelMedium,
        unselectedLabelStyle: AppStyles.labelMedium.copyWith(
          fontWeight: FontWeight.normal,
        ),
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textSecondary,
        indicatorSize: TabBarIndicatorSize.tab,
        labelPadding: const EdgeInsets.symmetric(
          horizontal: kDefaultPaddingLabelTabBar,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surface,
        selectedColor: AppColors.primary,
        labelStyle: AppStyles.labelMedium,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusChip),
        ),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        selectedLabelStyle: AppStyles.bottomNavigation,
        unselectedLabelStyle: AppStyles.bottomNavigation,
        type: BottomNavigationBarType.fixed,
      ),
    )..addOwn(
        Brightness.light,
        AppThemeData(
          textTheme: AppTextTheme(
            h1: AppStyles.displayLarge,
            h2: AppStyles.headlineMedium,
            h3: AppStyles.titleSmall,
            primary: AppStyles.bodySmall,
            medium: AppStyles.bodyLarge,
            small: AppStyles.labelSmall,
            highlightsMedium: AppStyles.labelMedium,
            highlightsBold: AppStyles.labelMedium,
            button: AppStyles.labelLarge,
            title: AppStyles.titleSmall,
            header: AppStyles.titleMedium,
          ),
          colorSchema: AppColorSchema(
            primary: AppColors.primary,
            mainText: AppColors.textPrimary,
            subText: AppColors.textSecondary,
            whiteText: AppColors.white,
            disableText: AppColors.textSecondary,
            border: AppColors.border,
            background: AppColors.background,
            secondary1: AppColors.success,
            secondary2: AppColors.error,
            secondary3: AppColors.warning,
            secondary4: AppColors.secondary,
            barrierColor: AppColors.black.withValues(alpha: 0.5),
            badgeColor: AppColors.error,
            title2: AppColors.textSecondary,
          ),
        ),
      );
  }

  static ThemeData get darkTheme {
    return lightTheme.copyWith()..addOwn(Brightness.dark, lightTheme.own());
  }
}
