import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';

class RecitersScreen extends ConsumerWidget {
  const RecitersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.warmIvory,
      appBar: AppBar(title: const Text('القراء')),
      body: const Center(
        child: Text('مكتبة القرّاء قيد الإعداد، وسيُضاف الصوت من مصادر موثّقة فقط'),
      ),
    );
  }
}
