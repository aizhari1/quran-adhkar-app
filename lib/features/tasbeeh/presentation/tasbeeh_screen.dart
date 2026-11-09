import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../data/tasbeeh_prefs.dart';

class TasbeehState {
  final String name;
  final String nameArabic;
  final int count;
  final int target;

  const TasbeehState({
    required this.name,
    required this.nameArabic,
    this.count = 0,
    this.target = 33,
  });

  TasbeehState copyWith({int? count, int? target}) {
    return TasbeehState(
      name: name,
      nameArabic: nameArabic,
      count: count ?? this.count,
      target: target ?? this.target,
    );
  }
}

final tasbeehProvider = StateNotifierProvider<TasbeehNotifier, TasbeehState>((ref) {
  return TasbeehNotifier(ref.watch(tasbeehPrefsProvider));
});

class TasbeehNotifier extends StateNotifier<TasbeehState> {
  TasbeehNotifier(this._prefs)
      : super(const TasbeehState(
          name: 'سبحان الله',
          nameArabic: 'سُبْحَانَ ٱللَّهِ',
        )) {
    _load();
  }

  final TasbeehPrefs _prefs;

  Future<void> _load() async {
    final s = await _prefs.load();
    if (s != null) {
      state = TasbeehState(
        name: s.name,
        nameArabic: s.nameArabic,
        count: s.count,
        target: s.target,
      );
    }
  }

  Future<void> _persist() async {
    await _prefs.save(TasbeehSnapshot(
      name: state.name,
      nameArabic: state.nameArabic,
      count: state.count,
      target: state.target,
    ));
  }

  void increment() {
    HapticFeedback.lightImpact();
    state = state.copyWith(count: state.count + 1);
    _persist();
  }

  void reset() {
    state = state.copyWith(count: 0);
    _persist();
  }

  void setDhikr(String name, String arabic, {int target = 33}) {
    state = TasbeehState(name: name, nameArabic: arabic, target: target);
    _persist();
  }
}

class TasbeehScreen extends ConsumerWidget {
  const TasbeehScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(tasbeehProvider);
    final notifier = ref.read(tasbeehProvider.notifier);
    final progress = state.target > 0 ? (state.count % state.target) / state.target : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('التسبيح'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('تصفير العدّاد؟'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('لا')),
                    TextButton(
                      onPressed: () {
                        notifier.reset();
                        Navigator.pop(ctx);
                      },
                      child: const Text('نعم'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 24),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _DhikrChip(
                    label: 'سبحان الله',
                    selected: state.nameArabic.contains('سُبْحَان'),
                    onTap: () => notifier.setDhikr('سبحان الله', 'سُبْحَانَ ٱللَّهِ'),
                  ),
                  _DhikrChip(
                    label: 'الحمد لله',
                    selected: state.nameArabic.contains('ٱلْحَمْد'),
                    onTap: () => notifier.setDhikr('الحمد لله', 'ٱلْحَمْدُ لِلَّهِ'),
                  ),
                  _DhikrChip(
                    label: 'الله أكبر',
                    selected: state.nameArabic.contains('أَكْبَر'),
                    onTap: () => notifier.setDhikr('الله أكبر', 'ٱللَّهُ أَكْبَرُ'),
                  ),
                  _DhikrChip(
                    label: 'أستغفر الله',
                    selected: state.nameArabic.contains('أَسْتَغْفِر'),
                    onTap: () => notifier.setDhikr('أستغفر الله', 'أَسْتَغْفِرُ ٱللَّهَ', target: 100),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Text(
              state.nameArabic,
              style: const TextStyle(
                fontFamily: 'ScheherazadeNew',
                fontSize: 32,
                color: AppColors.deepEmerald,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              RegExp(r'[A-Za-z]').hasMatch(state.name) ? '' : state.name,
              style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 40),
            GestureDetector(
              onTap: notifier.increment,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).colorScheme.surfaceContainerLowest,
                  border: Border.all(color: AppColors.mutedGold.withOpacity(0.5), width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.deepEmerald.withOpacity(0.12),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 200,
                      height: 200,
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 6,
                        backgroundColor: AppColors.borderLight,
                        valueColor: const AlwaysStoppedAnimation(AppColors.mutedGold),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${state.count}',
                          style: const TextStyle(
                            fontSize: 56,
                            fontWeight: FontWeight.w700,
                            color: AppColors.deepEmerald,
                          ),
                        ),
                        Text(
                          '/ ${state.target}',
                          style: const TextStyle(fontSize: 16, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'اضغط على الدائرة للعدّ',
              style: TextStyle(color: AppColors.textMuted.withOpacity(0.8), fontSize: 13),
            ),
            const Spacer(flex: 2),
          ],
        ),
      ),
    );
  }
}

class _DhikrChip extends StatelessWidget {
  const _DhikrChip({required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label, style: const TextStyle(fontFamily: 'NotoNaskhArabic', fontSize: 14)),
        selected: selected,
        onSelected: (_) => onTap(),
        selectedColor: AppColors.deepEmerald.withOpacity(0.15),
        checkmarkColor: AppColors.deepEmerald,
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
        side: BorderSide(
          color: selected ? AppColors.deepEmerald : AppColors.borderLight,
        ),
      ),
    );
  }
}
