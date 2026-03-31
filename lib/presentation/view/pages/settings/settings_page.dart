import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:family_health/shared/extension/theme_data.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeOwn = Theme.of(context).own();
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.settings, size: 64, color: Colors.blue),
          const SizedBox(height: 16),
          Text(
            'bottom_nav.settings'.tr(),
            style: themeOwn.textTheme?.h2,
          ),
          const SizedBox(height: 8),
          const Text('Placeholder for Settings'),
        ],
      ),
    );
  }
}
