import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';

class KhatmaScreen extends ConsumerWidget {
  const KhatmaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.warmIvory,
      appBar: AppBar(title: const Text('الختمة')),
      body: const Center(
        child: Text('Khatma planner – coming next'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: AppColors.deepEmerald,
        foregroundColor: AppColors.warmIvory,
        icon: const Icon(Icons.add),
        label: const Text('New Khatma'),
      ),
    );
  }
}
