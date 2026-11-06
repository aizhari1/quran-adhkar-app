import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../data/adhkar_prefs.dart';

class AdhkarItem {
  final int id;
  final String textArabic;
  final int repetition;
  final String source;
  final String? translation;

  const AdhkarItem({
    required this.id,
    required this.textArabic,
    required this.repetition,
    required this.source,
    this.translation,
  });
}

const morningAdhkar = [
  AdhkarItem(
    id: 1,
    textArabic: 'أَصْبَحْنَا وَأَصْبَحَ الْمُلْكُ لِلَّهِ، وَالْحَمْدُ لِلَّهِ، لَا إِلَٰهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَىٰ كُلِّ شَيْءٍ قَدِيرٌ',
    repetition: 1,
    source: 'مسلم',
  ),
  AdhkarItem(
    id: 2,
    textArabic: 'اللَّهُمَّ بِكَ أَصْبَحْنَا، وَبِكَ أَمْسَيْنَا، وَبِكَ نَحْيَا، وَبِكَ نَمُوتُ، وَإِلَيْكَ النُّشُورُ',
    repetition: 1,
    source: 'الترمذي',
  ),
  AdhkarItem(
    id: 3,
    textArabic: 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ',
    repetition: 100,
    source: 'مسلم',
  ),
  AdhkarItem(
    id: 4,
    textArabic: 'لَا إِلَٰهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ، وَهُوَ عَلَىٰ كُلِّ شَيْءٍ قَدِيرٌ',
    repetition: 10,
    source: 'البخاري ومسلم',
  ),
  AdhkarItem(
    id: 5,
    textArabic: 'أَعُوذُ بِكَلِمَاتِ اللَّهِ التَّامَّاتِ مِنْ شَرِّ مَا خَلَقَ',
    repetition: 3,
    source: 'مسلم',
  ),
];

const eveningAdhkar = [
  AdhkarItem(
    id: 101,
    textArabic: 'أَمْسَيْنَا وَأَمْسَى الْمُلْكُ لِلَّهِ، وَالْحَمْدُ لِلَّهِ، لَا إِلَٰهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَىٰ كُلِّ شَيْءٍ قَدِيرٌ',
    repetition: 1,
    source: 'مسلم',
  ),
  AdhkarItem(
    id: 102,
    textArabic: 'اللَّهُمَّ بِكَ أَمْسَيْنَا، وَبِكَ أَصْبَحْنَا، وَبِكَ نَحْيَا، وَبِكَ نَمُوتُ، وَإِلَيْكَ الْمَصِيرُ',
    repetition: 1,
    source: 'الترمذي',
  ),
  AdhkarItem(
    id: 103,
    textArabic: 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ',
    repetition: 100,
    source: 'مسلم',
  ),
  AdhkarItem(
    id: 104,
    textArabic: 'أَعُوذُ بِكَلِمَاتِ اللَّهِ التَّامَّاتِ مِنْ شَرِّ مَا خَلَقَ',
    repetition: 3,
    source: 'مسلم',
  ),
];

class AdhkarProgressState {
  final Map<int, int> counts;
  final Set<int> completed;

  const AdhkarProgressState({
    this.counts = const {},
    this.completed = const {},
  });

  AdhkarProgressState copyWith({
    Map<int, int>? counts,
    Set<int>? completed,
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
    state = AdhkarProgressState(counts: counts, completed: completed);
  }

  Future<void> _persist() async {
    await _prefs.saveCounts(state.counts);
    await _prefs.saveCompleted(state.completed);
  }

  void increment(int itemId, int max) {
    HapticFeedback.lightImpact();
    final current = state.counts[itemId] ?? 0;
    if (current >= max) return;
    final next = current + 1;
    final newCounts = Map<int, int>.from(state.counts)..[itemId] = next;
    final newCompleted = Set<int>.from(state.completed);
    if (next >= max) newCompleted.add(itemId);
    state = state.copyWith(counts: newCounts, completed: newCompleted);
    _persist();
  }

  void resetCategory(List<AdhkarItem> items) {
    final newCounts = Map<int, int>.from(state.counts);
    final newCompleted = Set<int>.from(state.completed);
    for (final item in items) {
      newCounts.remove(item.id);
      newCompleted.remove(item.id);
    }
    state = state.copyWith(counts: newCounts, completed: newCompleted);
    _persist();
  }
}

final adhkarProvider =
    StateNotifierProvider<AdhkarNotifier, AdhkarProgressState>((ref) {
  return AdhkarNotifier(ref.watch(adhkarPrefsProvider));
});

class AdhkarScreen extends ConsumerStatefulWidget {
  const AdhkarScreen({super.key});

  @override
  ConsumerState<AdhkarScreen> createState() => _AdhkarScreenState();
}

class _AdhkarScreenState extends ConsumerState<AdhkarScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.warmIvory,
      appBar: AppBar(
        title: const Text('الأذكار'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.deepEmerald,
          unselectedLabelColor: AppColors.textMuted,
          indicatorColor: AppColors.mutedGold,
          tabs: const [
            Tab(text: 'الصباح'),
            Tab(text: 'المساء'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _AdhkarList(items: morningAdhkar, categoryLabel: 'Morning'),
          _AdhkarList(items: eveningAdhkar, categoryLabel: 'Evening'),
        ],
      ),
    );
  }
}

class _AdhkarList extends ConsumerWidget {
  const _AdhkarList({required this.items, required this.categoryLabel});
  final List<AdhkarItem> items;
  final String categoryLabel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(adhkarProvider);
    final notifier = ref.read(adhkarProvider.notifier);
    final completedCount =
        items.where((i) => progress.completed.contains(i.id)).length;

    return Column(
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
              Expanded(
                child: Text(
                  '$categoryLabel Adhkar',
                  style: const TextStyle(
                    color: AppColors.warmIvory,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
              Text(
                '$completedCount / ${items.length}',
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
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final current = progress.counts[item.id] ?? 0;
              final isDone = progress.completed.contains(item.id);
              return _AdhkarCard(
                item: item,
                current: current,
                isDone: isDone,
                onTap: () => notifier.increment(item.id, item.repetition),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: OutlinedButton(
            onPressed: () => notifier.resetCategory(items),
            child: const Text('إعادة تعيين'),
          ),
        ),
      ],
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
                item.textArabic,
                style: TextStyle(
                  fontFamily: 'ScheherazadeNew',
                  fontSize: 20,
                  height: 1.8,
                  color: isDone ? AppColors.textMuted : AppColors.textPrimary,
                ),
                textAlign: TextAlign.right,
                textDirection: TextDirection.rtl,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.mutedGold.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      item.source,
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
                  else
                    Text(
                      '$current / ${item.repetition}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.deepEmerald,
                      ),
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
