import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../quran/data/quran_repository.dart' show normalizeArabic, toArabicDigits;
import '../data/adhkar_prefs.dart';
import '../data/adhkar_repository.dart';

class AdhkarProgressState {
  /// Keys are "<categoryId>:<itemId>" (see [adhkarKey]).
  final Map<String, int> counts;
  final Set<String> completed;

  const AdhkarProgressState({
    this.counts = const {},
    this.completed = const {},
  });

  AdhkarProgressState copyWith({
    Map<String, int>? counts,
    Set<String>? completed,
  }) {
    return AdhkarProgressState(
      counts: counts ?? this.counts,
      completed: completed ?? this.completed,
    );
  }
}

class AdhkarNotifier extends StateNotifier<AdhkarProgressState> {
  AdhkarNotifier(this._prefs) : super(const AdhkarProgressState()) {
    _load();
  }

  final AdhkarPrefs _prefs;

  Future<void> _load() async {
    final counts = await _prefs.loadCounts();
    final completed = await _prefs.loadCompleted();
    if (mounted) {
      state = AdhkarProgressState(counts: counts, completed: completed);
    }
  }

  Future<void> _persist() async {
    await _prefs.saveCounts(state.counts);
    await _prefs.saveCompleted(state.completed);
  }

  void increment(String key, int max) {
    HapticFeedback.lightImpact();
    final current = state.counts[key] ?? 0;
    if (current >= max) return;
    final next = current + 1;
    final newCounts = Map<String, int>.from(state.counts)..[key] = next;
    final newCompleted = Set<String>.from(state.completed);
    if (next >= max) newCompleted.add(key);
    state = state.copyWith(counts: newCounts, completed: newCompleted);
    _persist();
  }

  void resetCategory(AdhkarCategory category) {
    final newCounts = Map<String, int>.from(state.counts);
    final newCompleted = Set<String>.from(state.completed);
    for (final item in category.items) {
      final key = category.keyFor(item);
      newCounts.remove(key);
      newCompleted.remove(key);
    }
    state = state.copyWith(counts: newCounts, completed: newCompleted);
    _persist();
  }
}

final adhkarProvider =
    StateNotifierProvider<AdhkarNotifier, AdhkarProgressState>((ref) {
  return AdhkarNotifier(ref.watch(adhkarPrefsProvider));
});

int completedIn(AdhkarCategory category, AdhkarProgressState progress) {
  return category.items
      .where((i) => progress.completed.contains(category.keyFor(i)))
      .length;
}

/// Index of all chapters of Hisn al-Muslim with search.
class AdhkarScreen extends ConsumerStatefulWidget {
  const AdhkarScreen({super.key});

  @override
  ConsumerState<AdhkarScreen> createState() => _AdhkarScreenState();
}

class _AdhkarScreenState extends ConsumerState<AdhkarScreen> {
  String _query = '';

  static const _featured = <(int, String, IconData)>[
    (kMorningEveningCategoryId, 'الصباح والمساء', Icons.wb_sunny_outlined),
    (kSleepCategoryId, 'النوم', Icons.bedtime_outlined),
    (kWakingCategoryId, 'الاستيقاظ', Icons.alarm),
    (kAfterPrayerCategoryId, 'بعد الصلاة', Icons.mosque_outlined),
  ];

  void _open(int id) => context.go('/adhkar/category/$id');

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(adhkarCategoriesProvider);
    final progress = ref.watch(adhkarProvider);

    return Scaffold(
      backgroundColor: AppColors.warmIvory,
      appBar: AppBar(title: const Text('الأذكار')),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('تعذر تحميل الأذكار'),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () => ref.invalidate(adhkarCategoriesProvider),
                  child: const Text('إعادة المحاولة'),
                ),
              ],
            ),
          ),
        ),
        data: (categories) {
          final nq = normalizeArabic(_query.trim());
          final filtered = nq.isEmpty
              ? categories
              : categories.where((c) {
                  if (normalizeArabic(c.title).contains(nq)) return true;
                  return c.items
                      .any((i) => normalizeArabic(i.text).contains(nq));
                }).toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: TextField(
                  textDirection: TextDirection.rtl,
                  decoration: InputDecoration(
                    hintText: 'ابحث في الأذكار والأدعية',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (v) => setState(() => _query = v),
                ),
              ),
              if (nq.isEmpty)
                SizedBox(
                  height: 84,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    children: [
                      for (final f in _featured)
                        _FeaturedTile(
                          label: f.$2,
                          icon: f.$3,
                          onTap: () => _open(f.$1),
                        ),
                    ],
                  ),
                ),
              Expanded(
                child: filtered.isEmpty
                    ? const Center(
                        child: Text('لا توجد نتائج',
                            style: TextStyle(color: AppColors.textMuted)),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(12, 4, 12, 16),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final c = filtered[index];
                          final done = completedIn(c, progress);
                          final all = done >= c.items.length;
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              onTap: () => _open(c.id),
                              leading: CircleAvatar(
                                backgroundColor:
                                    AppColors.deepEmerald.withOpacity(0.1),
                                child: Text(
                                  toArabicDigits(c.id),
                                  style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.deepEmerald),
                                ),
                              ),
                              title: Text(c.title,
                                  textDirection: TextDirection.rtl),
                              subtitle: Text(
                                '${toArabicDigits(c.items.length)} ${c.items.length == 1 ? 'ذكر' : 'أذكار'}',
                                textDirection: TextDirection.rtl,
                              ),
                              trailing: all
                                  ? const Icon(Icons.check_circle,
                                      color: AppColors.success)
                                  : (done > 0
                                      ? Text(
                                          '${toArabicDigits(done)}/${toArabicDigits(c.items.length)}',
                                          style: const TextStyle(
                                              color: AppColors.deepEmerald,
                                              fontWeight: FontWeight.w600),
                                        )
                                      : const Icon(Icons.chevron_left)),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _FeaturedTile extends StatelessWidget {
  const _FeaturedTile({
    required this.label,
    required this.icon,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      child: Material(
        color: AppColors.deepEmerald,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: SizedBox(
            width: 104,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: AppColors.mutedGold),
                const SizedBox(height: 6),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: AppColors.warmIvory,
                      fontSize: 13,
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// One chapter with tap-to-count cards.
class AdhkarCategoryScreen extends ConsumerWidget {
  const AdhkarCategoryScreen({super.key, required this.categoryId});
  final int categoryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(adhkarCategoriesProvider);
    final progress = ref.watch(adhkarProvider);
    final notifier = ref.read(adhkarProvider.notifier);

    return async.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: const Text('الأذكار')),
        body: const Center(child: Text('تعذر تحميل الأذكار')),
      ),
      data: (categories) {
        final matches = categories.where((c) => c.id == categoryId);
        if (matches.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: const Text('الأذكار')),
            body: const Center(child: Text('الباب غير موجود')),
          );
        }
        final category = matches.first;
        final done = completedIn(category, progress);

        return Scaffold(
          backgroundColor: AppColors.warmIvory,
          appBar: AppBar(
            title: Text(category.title, style: const TextStyle(fontSize: 18)),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: 'إعادة تعيين',
                onPressed: () => notifier.resetCategory(category),
              ),
            ],
          ),
          body: Column(
            children: [
              Container(
                width: double.infinity,
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.deepEmerald,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'المُنجَز اليوم',
                        style: TextStyle(
                          color: AppColors.warmIvory,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Text(
                      '${toArabicDigits(done)} / ${toArabicDigits(category.items.length)}',
                      style: const TextStyle(
                        color: AppColors.mutedGold,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  itemCount: category.items.length,
                  itemBuilder: (context, index) {
                    final item = category.items[index];
                    final key = category.keyFor(item);
                    return _AdhkarCard(
                      item: item,
                      current: progress.counts[key] ?? 0,
                      isDone: progress.completed.contains(key),
                      onTap: () => notifier.increment(key, item.count),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AdhkarCard extends StatelessWidget {
  const _AdhkarCard({
    required this.item,
    required this.current,
    required this.isDone,
    required this.onTap,
  });
  final AdhkarItem item;
  final int current;
  final bool isDone;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: isDone ? AppColors.deepEmerald.withOpacity(0.06) : Colors.white,
      child: InkWell(
        onTap: isDone ? null : onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                item.text,
                style: TextStyle(
                  fontFamily: 'ScheherazadeNew',
                  fontSize: 21,
                  height: 1.9,
                  color: isDone ? AppColors.textMuted : AppColors.textPrimary,
                ),
                textAlign: TextAlign.justify,
                textDirection: TextDirection.rtl,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  if (item.count > 1)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.mutedGold.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'التكرار: ${toArabicDigits(item.count)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.deepEmerald,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  const Spacer(),
                  if (isDone)
                    const Icon(Icons.check_circle,
                        color: AppColors.success, size: 28)
                  else if (item.count > 1)
                    Text(
                      '${toArabicDigits(current)} / ${toArabicDigits(item.count)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.deepEmerald,
                      ),
                    )
                  else
                    const Text(
                      'اضغط عند الانتهاء',
                      style: TextStyle(
                          fontSize: 13, color: AppColors.textMuted),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
