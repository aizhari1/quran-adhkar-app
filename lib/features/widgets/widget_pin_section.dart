import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'home_widget_sync.dart';

/// Buttons that add the home-screen widgets (آية اليوم، ذكر اليوم، مواقيت الصلاة).
class WidgetPinSection extends StatelessWidget {
  const WidgetPinSection({super.key});

  static const _items = <(String, String, IconData)>[
    ('verse', 'آية اليوم', Icons.menu_book_outlined),
    ('dhikr', 'ذكر اليوم', Icons.favorite_border),
    ('prayer', 'مواقيت الصلاة', Icons.access_time),
  ];

  Future<void> _pin(BuildContext context, String kind) async {
    final ok = await HomeWidgetSync.requestPin(kind);
    if (!context.mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('اختر مكان الويدجت ثم اضغط «إضافة» في نافذة النظام'),
        ),
      );
    } else {
      showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('إضافة الويدجت يدوياً'),
          content: const Text(
            'الشاشة الرئيسية لديك لا تدعم الإضافة من التطبيق.\n\n'
            '١. اضغط مطوّلاً على مكان فارغ في الشاشة الرئيسية\n'
            '٢. اختر «الويدجت»\n'
            '٣. ابحث عن «القرآن والأذكار» واسحب الويدجت المطلوبة',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('حسناً'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.widgets_outlined, color: AppColors.deepEmerald),
              const SizedBox(width: 10),
              Text(
                'ويدجت الشاشة الرئيسية',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'اعرض آية وذكر اليوم ومواقيت الصلاة على شاشة موبايلك',
            style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final item in _items)
                FilledButton.tonalIcon(
                  onPressed: () => _pin(context, item.$1),
                  icon: Icon(item.$3, size: 18),
                  label: Text(item.$2),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
