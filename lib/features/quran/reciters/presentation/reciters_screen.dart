import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../audio/audio_controller.dart';
import '../../../audio/audio_sources.dart';

class RecitersScreen extends ConsumerWidget {
  const RecitersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('القرّاء')),
      body: const ReciterList(),
    );
  }
}

/// Radio list of reciters. Used by the Reciters screen and the Mushaf sheet.
class ReciterList extends ConsumerWidget {
  const ReciterList({super.key, this.onSelected});
  final VoidCallback? onSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(audioControllerProvider).reciterId;
    return ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        for (final r in kReciters)
          RadioListTile<String>(
            value: r.id,
            groupValue: selected,
            title: Text(r.nameAr),
            onChanged: (v) {
              if (v == null) return;
              ref.read(audioControllerProvider.notifier).setReciter(v);
              onSelected?.call();
            },
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          child: Text(
            'التلاوة تحتاج اتصالاً بالإنترنت.\nالتلاوات عبر cdn.islamic.network (Al Quran Cloud).',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}
