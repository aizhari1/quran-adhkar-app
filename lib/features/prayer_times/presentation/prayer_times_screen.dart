import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:adhan/adhan.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';

/// Offline prayer times using the adhan package.
/// Default coordinates: Cairo (user can change later via settings/GPS).
class PrayerTimesState {
  final Coordinates coordinates;
  final CalculationMethod method;
  final Madhab madhab;
  final DateTime date;
  final PrayerTimes? times;
  final String cityName;

  const PrayerTimesState({
    this.coordinates = const Coordinates(30.0444, 31.2357), // Cairo
    this.method = CalculationMethod.egyptian,
    this.madhab = Madhab.shafi,
    required this.date,
    this.times,
    this.cityName = 'Cairo',
  });

  PrayerTimesState copyWith({
    Coordinates? coordinates,
    CalculationMethod? method,
    Madhab? madhab,
    DateTime? date,
    PrayerTimes? times,
    String? cityName,
  }) {
    return PrayerTimesState(
      coordinates: coordinates ?? this.coordinates,
      method: method ?? this.method,
      madhab: madhab ?? this.madhab,
      date: date ?? this.date,
      times: times ?? this.times,
      cityName: cityName ?? this.cityName,
    );
  }
}

class PrayerTimesNotifier extends StateNotifier<PrayerTimesState> {
  PrayerTimesNotifier() : super(PrayerTimesState(date: DateTime.now())) {
    _calculate();
  }

  void _calculate() {
    final params = state.method.getParameters();
    params.madhab = state.madhab;
    final times = PrayerTimes(
      state.coordinates,
      DateComponents.from(state.date),
      params,
    );
    state = state.copyWith(times: times);
  }

  void setDate(DateTime date) {
    state = state.copyWith(date: date);
    _calculate();
  }

  void setMethod(CalculationMethod method) {
    state = state.copyWith(method: method);
    _calculate();
  }

  void setMadhab(Madhab madhab) {
    state = state.copyWith(madhab: madhab);
    _calculate();
  }

  void setLocation(double lat, double lng, String city) {
    state = state.copyWith(
      coordinates: Coordinates(lat, lng),
      cityName: city,
    );
    _calculate();
  }
}

final prayerTimesProvider =
    StateNotifierProvider<PrayerTimesNotifier, PrayerTimesState>((ref) {
  return PrayerTimesNotifier();
});

class PrayerTimesScreen extends ConsumerWidget {
  const PrayerTimesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(prayerTimesProvider);
    final times = state.times;
    final now = DateTime.now();

    if (times == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final prayers = [
      _PrayerInfo('Fajr', 'الفجر', times.fajr),
      _PrayerInfo('Sunrise', 'الشروق', times.sunrise),
      _PrayerInfo('Dhuhr', 'الظهر', times.dhuhr),
      _PrayerInfo('Asr', 'العصر', times.asr),
      _PrayerInfo('Maghrib', 'المغرب', times.maghrib),
      _PrayerInfo('Isha', 'العشاء', times.isha),
    ];

    _PrayerInfo? nextPrayer;
    for (final p in prayers) {
      if (p.time.isAfter(now)) {
        nextPrayer = p;
        break;
      }
    }
    nextPrayer ??= prayers.first;

    final timeFormat = DateFormat.jm();

    return Scaffold(
      backgroundColor: AppColors.warmIvory,
      appBar: AppBar(
        title: const Text('مواقيت الصلاة'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today_outlined),
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: state.date,
                firstDate: DateTime(2020),
                lastDate: DateTime(2030),
              );
              if (picked != null) {
                ref.read(prayerTimesProvider.notifier).setDate(picked);
              }
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.deepEmerald,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.location_on, color: AppColors.mutedGold),
                    const SizedBox(width: 8),
                    Text(
                      state.cityName,
                      style: const TextStyle(
                        color: AppColors.warmIvory,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      DateFormat.yMMMd().format(state.date),
                      style: TextStyle(
                        color: AppColors.warmIvory.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (nextPrayer != null) ...[
                  Text(
                    'Next: ${nextPrayer.nameArabic}',
                    style: const TextStyle(
                      color: AppColors.mutedGold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    timeFormat.format(nextPrayer.time),
                    style: const TextStyle(
                      color: AppColors.warmIvory,
                      fontSize: 36,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          ...prayers.map((p) {
            final isNext = nextPrayer?.name == p.name;
            final isPassed = p.time.isBefore(now);
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: isNext
                    ? AppColors.mutedGold.withOpacity(0.12)
                    : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isNext
                      ? AppColors.mutedGold
                      : AppColors.borderLight,
                  width: isNext ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  if (isNext)
                    Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: const BoxDecoration(
                        color: AppColors.mutedGold,
                        shape: BoxShape.circle,
                      ),
                    )
                  else
                    const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          p.name,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            color: isPassed && !isNext
                                ? AppColors.textMuted
                                : AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          p.nameArabic,
                          style: TextStyle(
                            fontFamily: 'NotoNaskhArabic',
                            fontSize: 13,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    timeFormat.format(p.time),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: isNext
                          ? AppColors.deepEmerald
                          : (isPassed
                              ? AppColors.textMuted
                              : AppColors.textPrimary),
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 16),
          Text(
            'Method: ${state.method.name} • Madhab: ${state.madhab.name}',
            style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _PrayerInfo {
  final String name;
  final String nameArabic;
  final DateTime time;
  const _PrayerInfo(this.name, this.nameArabic, this.time);
}
