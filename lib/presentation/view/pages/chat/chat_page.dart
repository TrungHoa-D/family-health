import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:family_health/shared/extension/theme_data.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeOwn = Theme.of(context).own();
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.forum, size: 64, color: Colors.blue),
          const SizedBox(height: 16),
          Text(
            'bottom_nav.chat'.tr(),
            style: themeOwn.textTheme?.h2,
          ),
          const SizedBox(height: 8),
          const Text('Placeholder for Chat & Advice'),
        ],
      ),
    );
  }
}
