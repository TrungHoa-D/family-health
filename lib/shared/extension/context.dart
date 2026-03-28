import 'package:flutter/material.dart';
import 'package:family_health/shared/extension/theme_data.dart';

import '../../presentation/resources/theme_data.dart';

extension ContextExtension on BuildContext {
  ThemeData theme() {
    return Theme.of(this);
  }

  AppThemeData themeOwn() {
    return Theme.of(this).own();
  }

  AppTextTheme? styleOwn() {
    return Theme.of(this).own().textTheme;
  }

  AppColorSchema? colorOwn() {
    return Theme.of(this).own().colorSchema;
  }
}
