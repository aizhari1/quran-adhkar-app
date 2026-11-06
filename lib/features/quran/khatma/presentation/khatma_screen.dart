import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';

class KhatmaPlan {
  final String id;
  final String name;
  final int totalDays;
  final DateTime startDate;
  final int completedPages;
  final int totalPages;
  final bool isActive;

  const KhatmaPlan({
    required this.id,
    required this.name,
    required this.totalDays,
    required this.startDate,
    this.completedPages = 0,
    this.totalPages = 604,
    this.isActive = true,
  });

  int get remainingPages => (totalPages - completedPages).clamp(0, totalPages);
  double get progress => totalPages == 0 ? 0 : completedPages / totalPages;
  int get pagesPerDay => (totalPages / totalDays).ceil();
}

class KhatmaState {
  final List<KhatmaPlan> plans;
  const KhatmaState({this.plans = const []});
  KhatmaState copyWith({List<KhatmaPlan>? plans}) => KhatmaState(plans: plans ?? this.plans);
}

class KhatmaNotifier extends StateNotifier<KhatmaState> {
  KhatmaNotifier() : super(const KhatmaState());

  void addPlan({required String name, required int totalDays}) {
    final plan = KhatmaPlan(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      totalDays: totalDays,
      startDate: DateTime.now(),
    );
    state = state.copyWith(plans: [...state.plans, plan]);
  }

  void markPagesRead(String id, int pages) {
    state = state.copyWith(
      plans: state.plans.map((p) {
        if (p.id != id) return p;
        final newCompleted = (p.completedPages + pages).clamp(0, p.totalPages);
        return KhatmaPlan(
          id: p.id,
          name: p.name,
          totalDays: p.totalDays,
          startDate: p.startDate,
          completedPages: newCompleted,
          totalPages: p.totalPages,
          isActive: newCompleted < p.totalPages,
        );
      }).toList(),
    );
  }

  void deletePlan(String id) {
    state = state.copyWith(plans: state.plans.where((p) => p.id != id).toList());
  }
}

final khatmaProvider = StateNotifierProvider<KhatmaNotifier, KhatmaState>((ref) => KhatmaNotifier());

class KhatmaScreen extends ConsumerWidget {
  const KhatmaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(khatmaProvider);
    final notifier = ref.read(khatmaProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.warmIvory,
      appBar: AppBar(title: const Text('الختمة')),
      body: state.plans.isEmpty
          ? _EmptyState(onCreate: () => _showCreateDialog(context, notifier))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: state.plans.map((plan) => _KhatmaCard(
                plan: plan,
                onAddPages: (pages) => notifier.markPagesRead(plan.id, pages),
                onDelete: () => notifier.deletePlan(plan.id),
              )).toList(),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateDialog(context, notifier),
        backgroundColor: AppColors.deepEmerald,
        foregroundColor: AppColors.warmIvory,
        icon: const Icon(Icons.add),
        label: const Text('ختمة جديدة'),
      ),
    );
  }

  void _showCreateDialog(BuildContext context, KhatmaNotifier notifier) {
    final nameController = TextEditingController(text: 'ختمة جديدة');
    int selectedDays = 30;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(left: 24, right: 24, top: 24, bottom: MediaQuery.of(context).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('إنشاء ختمة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
              const SizedBox(height: 16),
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'الاسم', border: OutlineInputBorder())),
              const SizedBox(height: 16),
              const Text('المدة', style: TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [7, 15, 30, 60].map((d) => ChoiceChip(
                  label: Text('$d يوم'),
                  selected: selectedDays == d,
                  onSelected: (_) => setModalState(() => selectedDays = d),
                  selectedColor: AppColors.deepEmerald.withOpacity(0.15),
                )).toList(),
              ),
              const SizedBox(height: 8),
              Text('≈ ${(604 / selectedDays).ceil()} صفحة يومياً', style: const TextStyle(fontSize: 13, color: AppColors.textMuted)),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  notifier.addPlan(
                    name: nameController.text.trim().isEmpty ? 'ختمة' : nameController.text.trim(),
                    totalDays: selectedDays,
                  );
                  Navigator.pop(ctx);
                },
                child: const Text('إنشاء'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onCreate});
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.flag_outlined, size: 64, color: AppColors.mutedGold),
            const SizedBox(height: 16),
            const Text('لا توجد ختمة بعد', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            const Text('أنشئ خطة لقراءة القرآن في 7 أو 15 أو 30 أو 60 يوماً', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textMuted)),
            const SizedBox(height: 24),
            ElevatedButton.icon(onPressed: onCreate, icon: const Icon(Icons.add), label: const Text('ختمة جديدة')),
          ],
        ),
      ),
    );
  }
}

class _KhatmaCard extends StatelessWidget {
  const _KhatmaCard({required this.plan, required this.onAddPages, required this.onDelete});
  final KhatmaPlan plan;
  final void Function(int pages) onAddPages;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(child: Text(plan.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600))),
                IconButton(icon: const Icon(Icons.delete_outline, size: 20), onPressed: onDelete, color: AppColors.textMuted),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: plan.progress,
                minHeight: 8,
                backgroundColor: AppColors.borderLight,
                valueColor: const AlwaysStoppedAnimation(AppColors.mutedGold),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${plan.completedPages} / ${plan.totalPages} صفحة', style: const TextStyle(fontSize: 13, color: AppColors.textMuted)),
                Text('${(plan.progress * 100).toStringAsFixed(0)}%', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.deepEmerald)),
              ],
            ),
            const SizedBox(height: 4),
            Text('${plan.pagesPerDay} صفحة/يوم • ${plan.totalDays} يوم • متبقي ${plan.remainingPages}', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: OutlinedButton(onPressed: () => onAddPages(plan.pagesPerDay), child: Text('+ ${plan.pagesPerDay} صفحة'))),
                const SizedBox(width: 8),
                Expanded(child: ElevatedButton(onPressed: () => onAddPages(1), child: const Text('+1 صفحة'))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
