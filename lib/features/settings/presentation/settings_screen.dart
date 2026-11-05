import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.warmIvory,
      appBar: AppBar(title: const Text('الإعدادات')),
      body: ListView(
        children: const [
          ListTile(title: Text('Language / اللغة'), subtitle: Text('Arabic')),
          ListTile(title: Text('Theme'), subtitle: Text('System')),
          ListTile(title: Text('Quran Font Size'), subtitle: Text('24')),
          ListTile(title: Text('Calculation Method'), subtitle: Text('Egyptian')),
          ListTile(title: Text('Notifications'), trailing: Icon(Icons.toggle_on, color: AppColors.deepEmerald)),
          Divider(),
          ListTile(title: Text('Privacy Policy')),
          ListTile(title: Text('About')),
        ],
      ),
    );
  }
}
