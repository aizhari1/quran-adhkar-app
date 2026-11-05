import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';

class MushafReaderScreen extends ConsumerWidget {
  const MushafReaderScreen({super.key, this.initialPage = 1});
  final int initialPage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.warmIvory,
      appBar: AppBar(
        title: Text('المصحف – صفحة $initialPage'),
        actions: [
          IconButton(icon: const Icon(Icons.bookmark_border), onPressed: () {}),
          IconButton(icon: const Icon(Icons.text_fields), onPressed: () {}),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'صفحة $initialPage',
              style: const TextStyle(
                fontFamily: 'ScheherazadeNew',
                fontSize: 28,
                color: AppColors.deepEmerald,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'سيتم استيراد نص عثماني موثق من Tanzil\nفي المرحلة التالية',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}
